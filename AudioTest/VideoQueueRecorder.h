//
//  VideoQueueRecorder.h
//  AudioTest
//
//  Created by wangbo on 5/18/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoQueueRecorder : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

+ (instancetype)sharedInstance;

- (void)startVideoCapture:(UIViewController *)vc;
- (void)stopVideoCapture:(id)arg;

@end
