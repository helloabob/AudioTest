//
//  AudioQueueRecorder.m
//  AudioTest
//
//  Created by mac0001 on 5/15/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import "AudioQueueRecorder.h"
#import <faac.h>
#import "DataQueue.h"

faacEncHandle hEncoder;
unsigned long inputSamples;
unsigned long maxOutputBytes;
unsigned char *outputBuffer;
NSString *fileName;

@implementation AudioQueueRecorder {
    
    dispatch_queue_t serial_queue;

}

+ (instancetype)sharedInstance {
    static AudioQueueRecorder *sharedNetUtilsInstance = nil;
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedNetUtilsInstance = [[self alloc] init];
        sharedNetUtilsInstance->serial_queue = dispatch_queue_create("com.bo.serial_audio", NULL);
    });
    return sharedNetUtilsInstance;
}

static void HandleInputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,
							   UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    
    RecordState *pAqData = (RecordState *) aqData;
    if (pAqData->recording==NO) {
        return;
    }
//    static int count=0;
//    count++;
//    if (count%10==0) {
//        NSLog(@"send_audio_data");
//        count=0;
//    }
    
//    NSData *audioData = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
//    NSLog(@"old_data_count:%d", audioData.length);
    
//    unsigned char outputBuffer[maxOutputBytes];
    
    
//    static int cc=0;
//    cc+=nRet;
    
//    NSLog(@"ret:%d", nRet);
    
    
    
        
        
//        NSData *tmp = [NSData dataWithBytes:inBuffer->mAudioData length:nRet];
//    __block int32_t tmp[inBuffer->mAudioDataByteSize];
    NSData *tmp = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
    dispatch_async([AudioQueueRecorder sharedInstance]->serial_queue, ^(){
        unsigned int bufferSize=0;
        int nRet=faacEncEncode(hEncoder, (int32_t *)tmp.bytes, inputSamples, outputBuffer, bufferSize);
        
        if (nRet>0) {
            NSData *data = [NSData dataWithBytes:outputBuffer length:nRet];
            [[DataQueue sharedInstance] pushData:data withType:DataTypeAudio];
//            NSMutableData *dt = [NSMutableData dataWithContentsOfFile:fileName];
//            if (dt==nil) {
//                dt = [NSMutableData data];
//            }
//            [dt appendBytes:outputBuffer length:nRet];
//            [dt writeToFile:fileName atomically:YES];
        }
    });
    
    
//        NSData *dd = [NSData dataWithBytes:outputBuffer length:nRet];
//        dd writeToFile:<#(NSString *)#> options:<#(NSDataWritingOptions)#> error:<#(NSError **)#>
    
    
//    NSLog(@"count:%d",cc);
    
//    NSLog(@"new_data_count:%d nRet:%d", bufferSize,nRet);

    
//    audioData=[NSData dataWithBytes:outputBuffer length:bufferSize];
    
//    NSLog(@"encodedData:%@", audioData);
    
//    dispatch_async(sharedNetUtilsInstance->serial_send_audio, ^(){
//        [[NetUtils sharedInstance] startSendData:audioData withType:CommandTypeAudio];
//    });
    AudioQueueEnqueueBuffer(pAqData->queue, inBuffer, 0, NULL);
}

- (void)cl {
    
}

- (BOOL)startRecord {
    
    
//    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(endRecord) userInfo:nil repeats:NO];
    
    fileName = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp/test.aac"] retain];
    
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    
    hEncoder=faacEncOpen(8000, 1, &inputSamples, &maxOutputBytes);
    faacEncConfigurationPtr ptr=faacEncGetCurrentConfiguration(hEncoder);
    ptr->inputFormat=FAAC_INPUT_16BIT;
    printf("outputFormat:%u\n",ptr->outputFormat);
    faacEncSetConfiguration(hEncoder, ptr);
    
    outputBuffer=malloc(maxOutputBytes);
    
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    [audioSession setActive:YES error: nil];
    AudioStreamBasicDescription *format = &recordState.dataFormat;
    format->mSampleRate = 8000.0;
    format->mFormatID = kAudioFormatLinearPCM;
//    format->mFormatFlags = kLinearPCMFormatFlagIsNonInterleaved|kLinearPCMFormatFlagIsNonMixable;
    format->mFormatFlags = kAudioFormatFlagIsSignedInteger;
    format->mChannelsPerFrame = 1;
    format->mBitsPerChannel = 16;
    format->mFramesPerPacket = 1;
    format->mBytesPerPacket = 2;
    format->mBytesPerFrame = 2;
    format->mReserved = 0;
    //    CFURLRef fileURL =  CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *) [filePath UTF8String], [filePath length], NO);
    // recordState.currentPacket = 0;
    
	// new input queue
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat, HandleInputBuffer, &recordState, CFRunLoopGetCurrent(),kCFRunLoopCommonModes, 0, &recordState.queue);
    if (status) {NSLog(@"Could not establish new queue");return NO;}
    //    if (status) {CFRelease(fileURL); printf("Could not establish new queue\n"); return NO;}
	// create new audio file
    //    status = AudioFileCreateWithURL(fileURL, kAudioFileAIFFType, &recordState.dataFormat, kAudioFileFlags_EraseFile, &recordState.audioFile);
    //	CFRelease(fileURL); // thanks august joki
    //    if (status) {printf("Could not create file to record audio\n"); return NO;}
    
	// figure out the buffer size
    //    DeriveBufferSize(recordState.queue, recordState.dataFormat, 0.5, &recordState.bufferByteSize);
	
//    recordState.bufferByteSize=8000;
    recordState.bufferByteSize=inputSamples*2;
    
	// allocate those buffers and enqueue them
    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        status = AudioQueueAllocateBuffer(recordState.queue, recordState.bufferByteSize, &recordState.buffers[i]);
        if (status) {printf("Error allocating buffer %d\n", i); return NO;}
        
        status = AudioQueueEnqueueBuffer(recordState.queue, recordState.buffers[i], 0, NULL);
        if (status) {printf("Error enqueuing buffer %d\n", i); return NO;}
    }
	
	// enable metering
    UInt32 enableMetering = YES;
    status = AudioQueueSetProperty(recordState.queue, kAudioQueueProperty_EnableLevelMetering, &enableMetering,sizeof(enableMetering));
    if (status) {printf("Could not enable metering\n"); return NO;}
    
	// start recording
    status = AudioQueueStart(recordState.queue, NULL);
    if (status) {printf("Could not start Audio Queue\n"); return NO;}
    recordState.currentPacket = 0;
    recordState.recording = YES;
    return YES;
}

- (void)endRecord {
//    faacEncClose(hEncoder);
    recordState.recording=NO;
    AudioQueueStop(recordState.queue,YES);
    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
    }
    AudioQueueDispose(recordState.queue, YES);
    
    [self performSelector:@selector(endfaac) withObject:nil afterDelay:1.0f];
}

- (void)endfaac {
    faacEncClose(hEncoder);
    NSLog(@"end");
}

@end
