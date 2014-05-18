//
//  AudioQueueRecorder.h
//  AudioTest
//
//  Created by mac0001 on 5/15/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AudioToolbox/AudioQueue.h>
//#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define NUM_BUFFERS 30


typedef struct
{
    AudioFileID                 audioFile;
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         buffers[NUM_BUFFERS];
    UInt32                      bufferByteSize;
    SInt64                      currentPacket;
    BOOL                        recording;
} RecordState;

@interface AudioQueueRecorder : NSObject {
    RecordState recordState;
}

+ (instancetype)sharedInstance;


- (BOOL)startRecord;
- (void)endRecord;

@end
