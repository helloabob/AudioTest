//
//  x264Manager.m
//  AudioTest
//
//  Created by wangbo on 5/18/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import "x264Manager.h"
#import "DataQueue.h"
#import "rtmpDispatcher.h"


int sps_len;
int pps_len;
uint8_t sps[30];
uint8_t pps[10];


@implementation x264Manager

#pragma mark rtmp func



#pragma end



+ (instancetype)sharedInstance {
    static x264Manager *sharedNetUtilsInstance = nil;
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedNetUtilsInstance = [[self alloc] init];
        [sharedNetUtilsInstance initForX264];
        [sharedNetUtilsInstance initForFilePath];
//        sharedNetUtilsInstance->serial_queue = dispatch_queue_create("com.bo.serial_dj", NULL);
//        sharedNetUtilsInstance->producerFps=15;
    });
    return sharedNetUtilsInstance;
}

- (void)initForX264{
    
    
    p264Param = malloc(sizeof(x264_param_t));
    p264Pic  = malloc(sizeof(x264_picture_t));
    memset(p264Pic,0,sizeof(x264_picture_t));
    //x264_param_default(p264Param);  //set default param
    x264_param_default_preset(p264Param, "ultrafast", "zerolatency");
    p264Param->i_threads = 1;
    p264Param->i_width   = 192;  //set frame width
    p264Param->i_height  = 144;  //set frame height
    p264Param->b_cabac =0;
    p264Param->i_bframe =0;
    p264Param->b_interlaced=0;
    p264Param->rc.i_rc_method=X264_RC_ABR;//X264_RC_CQP
    p264Param->i_level_idc=21;
    p264Param->rc.i_bitrate=128;
    p264Param->b_intra_refresh = 1;
    p264Param->b_annexb = 1;
    p264Param->i_keyint_max=25;
    p264Param->i_fps_num=15;
    p264Param->i_fps_den=1;
    p264Param->b_annexb = 1;
    //    p264Param->i_csp = X264_CSP_I420;
    x264_param_apply_profile(p264Param, "baseline");
    if((p264Handle = x264_encoder_open(p264Param)) == NULL)
    {
        fprintf( stderr, "x264_encoder_open failed/n" );
        return ;
    }
    x264_picture_alloc(p264Pic, X264_CSP_YV12, p264Param->i_width, p264Param->i_height);
    p264Pic->i_type = X264_TYPE_AUTO;
    
    
}

- (void)initForFilePath{
    const char *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp/test.264"] cStringUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:path] error:nil];
//    char *path = [self GetFilePathByfileName:"IOSCamDemo.264"];
    NSLog(@"%s",path);
    fp = fopen(path,"wb");
}

- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer{
    
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t  *baseAddress0 = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    uint8_t  *baseAddress1 = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    unsigned int bufferSize = (uint32_t)CVPixelBufferGetDataSize(pixelBuffer);
    
    
    x264_picture_t pic_out;
    
//    NSLog(@"main_thread:%d", [NSThread isMainThread]);
    
    memcpy(p264Pic->img.plane[0], baseAddress0, 192*144);
    uint8_t * pDst1 = p264Pic->img.plane[1];
    uint8_t * pDst2 = p264Pic->img.plane[2];
    for( int i = 0; i < 192*144/4; i ++ )
    {
        *pDst1++ = *baseAddress1++;
        *pDst2++ = *baseAddress1++;
    }
    
    int nal_count;
    if(x264_encoder_encode(p264Handle, &nal_data, &nal_count, p264Pic ,&pic_out) < 0 )
    {
        fprintf( stderr, "x264_encoder_encode failed/n" );
    }
    if (nal_count > 0) {
//        int i_size;
//        char * data=(char *)szBodyBuffer+100;
        int i,last=0;
        NSLog(@"start................(%d)",nal_count);
        for (i=0; i<nal_count; i++) {
            if (p264Handle->nal_buffer_size<nal_data[i].i_payload*3/2+4) {
                p264Handle->nal_buffer_size=nal_data[i].i_payload*3/2+4;
                x264_free(p264Handle->nal_buffer);
                p264Handle->nal_buffer=x264_malloc(p264Handle->nal_buffer_size);
            }
            if (nal_data[i].i_type==NAL_SPS) {
                sps_len=nal_data[i].i_payload-4;
                NSLog(@"sps len:%d", sps_len);
                memcpy(sps, nal_data[i].p_payload+4, sps_len);
            }else if(nal_data[i].i_type==NAL_PPS){
                pps_len=nal_data[i].i_payload-4;
                memcpy(pps, nal_data[i].p_payload+4, pps_len);
                NSLog(@"pps len:%d", pps_len);
                [[rtmpDispatcher sharedInstance] sendSPS:[NSData dataWithBytes:sps length:sps_len] andPPS:[NSData dataWithBytes:pps length:pps_len]];
            }else{
                NSLog(@"normal len:%d", nal_data[i].i_payload);
                [[rtmpDispatcher sharedInstance] sendNormalVideo:[NSData dataWithBytes:nal_data[i].p_payload length:nal_data[i].i_payload]];
                break;
            }
            last+=nal_data[i].i_payload;
            
            
            
            
//            if (p264Handle->nal_buffer_size < p264Nal[i].i_payload*3/2+4) {
//                p264Handle->nal_buffer_size = p264Nal[i].i_payload*2+4;
//                x264_free( p264Handle->nal_buffer );
//                p264Handle->nal_buffer = x264_malloc( p264Handle->nal_buffer_size );
//            }
//            i_size = p264Nal[i].i_payload;
//            
//            memcpy(data, p264Nal[i].p_payload, p264Nal[i].i_payload);
////            fwrite(data, 1, i_size, fp);
//            
//            [[DataQueue sharedInstance] pushData:[NSData dataWithBytes:data length:i_size] withType:DataTypeVideo];
            
        }
        
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

@end
