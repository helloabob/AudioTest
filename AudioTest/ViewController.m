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

@interface ViewController ()

@property(nonatomic,retain) AVAudioRecorder * recorder;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    AudioQueueRecorder *recorder = [[AudioQueueRecorder alloc] init];
    
//    [recorder startRecord];
    [[AudioQueueRecorder sharedInstance] startRecord];
    
    [[VideoQueueRecorder sharedInstance] startVideoCapture:self];
    
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
    
    
    
    
    NSError *error = nil;
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    [captureSession beginConfiguration];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    [captureSession addInput:audioInput];
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0)];
    [captureSession addOutput:audioOutput];
    [audioOutput connectionWithMediaType:AVMediaTypeAudio];
    [captureSession commitConfiguration];
    [captureSession startRunning];
    
    UIButton *bb = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 50)];
    [self.view addSubview:bb];
    [bb setTitle:@"aaa" forState:UIControlStateNormal];
    [bb addTarget:self action:@selector(bb) forControlEvents:UIControlEventTouchUpInside];
    [bb setBackgroundColor:[UIColor brownColor]];
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

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"aa:%@", sampleBuffer);
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 44100.00;
    AudioStreamBasicDescription outputFormat;
    outputFormat.mSampleRate = 8000.0;
    
    AudioConverterRef acr;
    
    AudioConverterNew(&audioFormat, &outputFormat, &acr);
    
    
    AudioBufferList audioBufferList;
    NSMutableData *data = [NSMutableData data];
    CMBlockBufferRef blockBuffer;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
    for( int y=0; y< audioBufferList.mNumberBuffers; y++ ){
        
        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
//        Float32 *frame = (Float32*)audioBuffer.mData;
        
        UInt32 outputSize;
        void *outputData;
//        OSStatus status = AudioConverterConvertBuffer(acr, audioBuffer.mDataByteSize, audioBuffer.mData, &outputSize, outputData);
        
//        OSStatus status = AudioConverterFillComplexBuffer(acr, <#AudioConverterComplexInputDataProc inInputDataProc#>, <#void *inInputDataProcUserData#>, <#UInt32 *ioOutputDataPacketSize#>, <#AudioBufferList *outOutputData#>, <#AudioStreamPacketDescription *outPacketDescription#>)
        
//        Float32 *frame = (Float32*)outputData;
        
//        [data appendBytes:frame length:audioBuffer.mDataByteSize];
        
//        NSLog(@"status:%d old_size:%d new_size:%d", status, audioBuffer.mDataByteSize, outputSize);
        
//        [data appendBytes:frame length:outputSize];
        
    }
    
    CFRelease(blockBuffer);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
