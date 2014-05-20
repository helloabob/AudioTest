//
//  ViewController.m
//  AudioTest
//
//  Created by mac0001 on 4/21/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "AudioQueueRecorder.h"

#import "VideoQueueRecorder.h"
#import "x264Manager.h"
#import "DataQueue.h"

#import "rtmpDispatcher.h"



static BOOL canGo=YES;

@interface ViewController ()

@property(nonatomic,retain) AVAudioRecorder * recorder;

@end

@implementation ViewController {
    dispatch_queue_t serial_queue;
}



//- (void)publishVideo {
//    
//    double ts=[[NSDate date] timeIntervalSinceReferenceDate];
//    
//    while (canGo) {
//        NSDictionary *dict = [[DataQueue sharedInstance] popData];
//        NSData *data = nil;
//        DataType dt = DataTypeAudio;
//        if ([dict objectForKey:@"1"]) {
//            dt = DataTypeAudio;
//            data = [dict objectForKey:@"1"];
//        } else {
//            dt = DataTypeVideo;
//            data = [dict objectForKey:@"2"];
//        }
//        if (data!=nil) {
//            RTMPPacket rtmp_packet;
//            RTMPPacket_Reset(&rtmp_packet);
//            RTMPPacket_Alloc(&rtmp_packet, data.length);
//            double dt=[[NSDate date] timeIntervalSinceReferenceDate];
//            unsigned int ts2 = (dt-ts)*1000.0;
//            NSLog(@"ts2:%u", ts2);
//            rtmp_packet.m_packetType=dt==DataTypeAudio?RTMP_PACKET_TYPE_AUDIO:RTMP_PACKET_TYPE_VIDEO;
//            rtmp_packet.m_nBodySize=data.length;
//            rtmp_packet.m_nTimeStamp=ts2;
//            rtmp_packet.m_hasAbsTimestamp=NO;
//            rtmp_packet.m_nChannel=0x04;
//            rtmp_packet.m_headerType=RTMP_PACKET_SIZE_LARGE;
//            rtmp_packet.m_nInfoField2=_rtmp->m_stream_id;
//            memcpy(rtmp_packet.m_body, data.bytes, data.length);
//            if (RTMP_IsConnected(_rtmp)) {
//                int nRet=RTMP_SendPacket(_rtmp, &rtmp_packet, 0);
//                NSLog(@"ret:%d", nRet);
//            }
//            
//            RTMPPacket_Free(&rtmp_packet);
//        }
//        usleep(10000);
//    }
//    
//    RTMP_Close(_rtmp);
//    RTMP_Free(_rtmp);
//    
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    AudioQueueRecorder *recorder = [[AudioQueueRecorder alloc] init];
    
//    [recorder startRecord];
    
    [[rtmpDispatcher sharedInstance] startConnect];
    [[AudioQueueRecorder sharedInstance] startRecord];
    
    
    
//    [[VideoQueueRecorder sharedInstance] startVideoCapture:self];
    
//    [self publish];
//    [self performSelectorInBackground:@selector(publishVideo) withObject:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    
//    NSError * err = nil;
//    
//	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
//    
//	if(err){
//        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
//        return;
//	}
//    
//	[audioSession setActive:YES error:&err];
//    
//	err = nil;
//	if(err){
//        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
//        return;
//	}
//	
//	NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
//	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//	[recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
//	[recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
//    [recordSetting setValue:[NSNumber numberWithInt:16] forKeyPath:AVLinearPCMBitDepthKey];
//    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
//	
//    /*
//     [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//     [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//     [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
//     */
//    
//	NSURL * url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()]];
//	
//	err = nil;
//	
//	NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
//    
//	if(audioData)
//	{
//		NSFileManager *fm = [NSFileManager defaultManager];
//		[fm removeItemAtPath:[url path] error:&err];
//	}
//	
//	err = nil;
//    
//    if(self.recorder){[self.recorder stop];self.recorder = nil;}
//    
//	self.recorder = [[[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err] autorelease];
//    
//	if(!_recorder){
//        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
//        UIAlertView *alert =
//        [[UIAlertView alloc] initWithTitle: @"Warning"
//								   message: [err localizedDescription]
//								  delegate: nil
//						 cancelButtonTitle:@"OK"
//						 otherButtonTitles:nil];
//        [alert show];
//        return;
//	}
//	
//	[_recorder setDelegate:self];
//	[_recorder prepareToRecord];
//	_recorder.meteringEnabled = YES;
//	
//	BOOL audioHWAvailable = audioSession.inputIsAvailable;
//	if (! audioHWAvailable) {
//        UIAlertView *cantRecordAlert =
//        [[UIAlertView alloc] initWithTitle: @"Warning"
//								   message: @"Audio input hardware not available"
//								  delegate: nil
//						 cancelButtonTitle:@"OK"
//						 otherButtonTitles:nil];
//        [cantRecordAlert show];
//        return;
//	}
//	
//	[_recorder recordForDuration:(NSTimeInterval) 60];
    
    
    
    
//    NSError *error = nil;
//    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
//    [captureSession beginConfiguration];
//    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
//    [captureSession addInput:audioInput];
//    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
//    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0)];
//    [captureSession addOutput:audioOutput];
//    [audioOutput connectionWithMediaType:AVMediaTypeAudio];
//    [captureSession commitConfiguration];
//    [captureSession startRunning];
//    
//    UIButton *bb = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 50)];
//    [self.view addSubview:bb];
//    [bb setTitle:@"aaa" forState:UIControlStateNormal];
//    [bb addTarget:self action:@selector(bb) forControlEvents:UIControlEventTouchUpInside];
//    [bb setBackgroundColor:[UIColor brownColor]];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"recorder");
}

- (void)bb {
    NSLog(@"tapped");
}

- (void)recei:(NSNotification *)notif {
    NSLog(@"%@", notif);
}

//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
////    NSLog(@"aa:%@", sampleBuffer);
//    AudioStreamBasicDescription audioFormat;
//    audioFormat.mSampleRate = 44100.00;
//    AudioStreamBasicDescription outputFormat;
//    outputFormat.mSampleRate = 8000.0;
//    
//    AudioConverterRef acr;
//    
//    AudioConverterNew(&audioFormat, &outputFormat, &acr);
//    
//    
//    AudioBufferList audioBufferList;
//    NSMutableData *data = [NSMutableData data];
//    CMBlockBufferRef blockBuffer;
//    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
//    for( int y=0; y< audioBufferList.mNumberBuffers; y++ ){
//        
//        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
////        Float32 *frame = (Float32*)audioBuffer.mData;
//        
//        UInt32 outputSize;
//        void *outputData;
////        OSStatus status = AudioConverterConvertBuffer(acr, audioBuffer.mDataByteSize, audioBuffer.mData, &outputSize, outputData);
//        
//        
////        Float32 *frame = (Float32*)outputData;
//        
////        [data appendBytes:frame length:audioBuffer.mDataByteSize];
//        
////        NSLog(@"status:%d old_size:%d new_size:%d", status, audioBuffer.mDataByteSize, outputSize);
//        
////        [data appendBytes:frame length:outputSize];
//        
//    }
//    
//    CFRelease(blockBuffer);
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
