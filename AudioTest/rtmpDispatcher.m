//
//  rtmpDispatcher.m
//  AudioTest
//
//  Created by mac0001 on 5/20/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import "rtmpDispatcher.h"

#import <rtmp.h>
#import <x264.h>

#define RTMP_HEAD_SIZE (sizeof(RTMPPacket)+RTMP_MAX_HEADER_SIZE)


char *rtmp_url = "rtmp://192.168.0.124/live/stream_1";
//char *rtmp_url = "rtmp://131.252.90.53/live/stream_1";
//char *rtmp_url = "rtmp://131.252.90.95/live/stream_1";


@implementation rtmpDispatcher {
    RTMP *_rtmp;
    NSDate *start_time;
}

+ (instancetype)sharedInstance {
    static rtmpDispatcher *sharedNetUtilsInstance = nil;
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedNetUtilsInstance = [[self alloc] init];
        sharedNetUtilsInstance->start_time = [[NSDate date] retain];
//        sharedNetUtilsInstance->serial_queue = dispatch_queue_create("com.bo.serial_video", NULL);
//        sharedNetUtilsInstance->producerFps=15;
    });
    return sharedNetUtilsInstance;
}

- (int)startConnect {
    _rtmp = RTMP_Alloc();
    RTMP_Init(_rtmp);
    
    int err=RTMP_SetupURL(_rtmp, rtmp_url);
    if (err<0) {
        printf("error in setup");
        RTMP_Free(_rtmp);
        return 0;
    }
    RTMP_EnableWrite(_rtmp);
    err=RTMP_Connect(_rtmp, NULL);
    if (err<0) {
        printf("error in connect");
        RTMP_Free(_rtmp);
        return 0;
    }
    err=RTMP_ConnectStream(_rtmp, 0);
    if (err<0) {
        printf("error in connect_stream");
        RTMP_Close(_rtmp);
        RTMP_Free(_rtmp);
        return 0;
    }
    return 1;
}

- (void)stopConnect {
    RTMP_Close(_rtmp);
    RTMP_Free(_rtmp);
}

- (void)sendSPS:(NSData *)sps_data andPPS:(NSData *)pps_data {
//    NSLog(@"sps:%@\npps:%@", sps_data,pps_data);
    RTMPPacket * packet;
    unsigned char * body;
    int i;
    
    packet = (RTMPPacket *)malloc(RTMP_HEAD_SIZE+1024);
    memset(packet,0,RTMP_HEAD_SIZE);
    
    packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
    body = (unsigned char *)packet->m_body;
    
//    memcpy(winsys->pps,buf,len);
//    winsys->pps_len = len;
    
    uint8_t sps[sps_data.length];
    [sps_data getBytes:sps];
    int sps_len=sps_data.length;
    
    uint8_t pps[pps_data.length];
    [pps_data getBytes:pps];
    int pps_len=pps_data.length;
    
    i = 0;
    /*17:1-keyframe, 7-AVC*/
    body[i++] = 0x17;
    /*AVC sequence header  AVC packet type*/
    body[i++] = 0x00;
    
    /*fixed format  AVC时，全0，无意义*/
    body[i++] = 0x00;
    body[i++] = 0x00;
    body[i++] = 0x00;
    
    /*AVCDecoderConfigurationRecord  configurationVersion*/
    body[i++] = 0x01;
    /*0x42*/
    body[i++] = sps[1];
    /*0x00   now  0xc0*/
    body[i++] = sps[2];
    /*0x1e   now  0x15*/
    body[i++] = sps[3];
    body[i++] = 0xff;
    
    /*sps flag*/
    body[i++]   = 0xe1;
    /*sps length*/
    body[i++] = (sps_len >> 8) & 0xff;
    body[i++] = sps_len & 0xff;
    /*sps content*/
    memcpy(&body[i],sps,sps_len);
    i +=  sps_len;
    
    /*pps flag*/
    body[i++]   = 0x01;
    /*pps length*/
    body[i++] = (pps_len >> 8) & 0xff;
    body[i++] = (pps_len) & 0xff;
    /*pps content*/
    memcpy(&body[i],pps,pps_len);
    i +=  pps_len;
    
    packet->m_packetType = RTMP_PACKET_TYPE_VIDEO;
    packet->m_nBodySize = i;
    packet->m_nChannel = 0x04;
    packet->m_nTimeStamp = 0;
    packet->m_hasAbsTimestamp = 0;
    packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
    packet->m_nInfoField2 = _rtmp->m_stream_id;
    
    /*调用发送接口*/
    RTMP_SendPacket(_rtmp,packet,TRUE);
    free(packet);
}

- (void)sendNormalVideo:(NSData *)data {
//    NSLog(@"nor:%@", data);
    int type;
    long timeoffset;
    RTMPPacket * packet;
    unsigned char * body;
    
    unsigned char *buf=(unsigned char *)data.bytes;
    int len=data.length;
    
    
    timeoffset=[[NSDate date] timeIntervalSinceDate:start_time]*1000.0;
//    timeoffset = GetTickCount() - start_time;  /*start_time为开始直播时的时间戳*/

//    timeoffset = GetTickCount() - start_time;  /*start_time为开始直播时的时间戳*/
    
    /*去掉帧界定符*/
    if (buf[2] == 0x00) { /*00 00 00 01*/
        buf += 4;
        len -= 4;
    } else if (buf[2] == 0x01){ /*00 00 01*/
        buf += 3;
        len -= 3;
    }
    type = buf[0]&0x1f;
    
//    packet = (RTMPPacket *)base_malloc(RTMP_HEAD_SIZE+len+9);
    packet = (RTMPPacket *)malloc(RTMP_HEAD_SIZE+len+9);

    memset(packet,0,RTMP_HEAD_SIZE);
    
    packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
    packet->m_nBodySize = len + 9;
    
    /*send video packet*/
    body = (unsigned char *)packet->m_body;
    memset(body,0,len+9);
    
    /*key frame*/
    body[0] = 0x27;
    if (type == NAL_SLICE_IDR) {
        body[0] = 0x17;
    }
    
    /*AVC NALU*/
    body[1] = 0x01;   /*nal unit*/
    /*composition time*/
    body[2] = 0x00;
    body[3] = 0x00;
    body[4] = 0x00;
    
    /*NALU length*/
    body[5] = (len >> 24) & 0xff;
    body[6] = (len >> 16) & 0xff;
    body[7] = (len >>  8) & 0xff;
    body[8] = (len ) & 0xff;
    
    /*copy data*/
    memcpy(&body[9],buf,len);
    
    static unsigned long ts2 = 0;
    ts2+=67;
    
    packet->m_hasAbsTimestamp = 0;
    packet->m_packetType = RTMP_PACKET_TYPE_VIDEO;
//    packet->m_nInfoField2 = winsys->rtmp->m_stream_id;
    packet->m_nInfoField2=_rtmp->m_stream_id;
    packet->m_nChannel = 0x04;
    packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    packet->m_nTimeStamp = timeoffset;
    
    /*调用发送接口*/
    RTMP_SendPacket(_rtmp,packet,TRUE);
    free(packet);
}

- (void)sendAACSpec:(NSData *)data {
    unsigned char *spec_buf=(unsigned char *)data.bytes;
    int spec_len=data.length;
    RTMPPacket * packet;
    unsigned char * body;
    int len;
    
    len = spec_len;  /*spec data长度,一般是2*/
    
//    packet = (RTMPPacket *)base_malloc(RTMP_HEAD_SIZE+len+2);
    packet = (RTMPPacket *)malloc(RTMP_HEAD_SIZE+len+2);

    memset(packet,0,RTMP_HEAD_SIZE);
    
    packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
    body = (unsigned char *)packet->m_body;
    
    /*AF 00 + AAC RAW data*/
    body[0] = 0xAF;
    body[1] = 0x00;
    memcpy(&body[2],spec_buf,len); /*spec_buf是AAC sequence header数据*/
    
    packet->m_packetType = RTMP_PACKET_TYPE_AUDIO;
    packet->m_nBodySize = len+2;
    packet->m_nChannel = 0x04;
    packet->m_nTimeStamp = 0;
    packet->m_hasAbsTimestamp = 0;
    packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
    packet->m_nInfoField2 = _rtmp->m_stream_id;
    
    /*调用发送接口*/
    RTMP_SendPacket(_rtmp,packet,TRUE);
    free(packet);
}

- (void)sendNormalAudio:(NSData *)data {
    
    unsigned char *buf=(unsigned char *)data.bytes;
    int len=data.length;
    
    long timeoffset;
//    timeoffset = GetTickCount() - start_time;

    timeoffset=[[NSDate date] timeIntervalSinceDate:start_time]*1000.0;

    
    buf += 7;
    len -= 7;
    
    if (len > 0) {
        RTMPPacket * packet;
        unsigned char * body;
        
        packet = (RTMPPacket *)malloc(RTMP_HEAD_SIZE+len+2);
        memset(packet,0,RTMP_HEAD_SIZE);
        
        packet->m_body = (char *)packet + RTMP_HEAD_SIZE;
        body = (unsigned char *)packet->m_body;
        
        /*AF 01 + AAC RAW data*/
        body[0] = 0xAF;
        body[1] = 0x01;
        memcpy(&body[2],buf,len);
        
        static unsigned long ts2 = 0;
        ts2+=125;
        
        packet->m_packetType = RTMP_PACKET_TYPE_AUDIO;
        packet->m_nBodySize = len+2;
        packet->m_nChannel = 0x04;
        packet->m_nTimeStamp = ts2;
        packet->m_hasAbsTimestamp = 0;
        packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
        packet->m_nInfoField2 = _rtmp->m_stream_id;
        
        /*调用发送接口*/
        RTMP_SendPacket(_rtmp,packet,TRUE);
        free(packet);
    }
}

@end
