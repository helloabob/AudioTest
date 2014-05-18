//
//  ViewController.h
//  AudioTest
//
//  Created by mac0001 on 4/21/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVCaptureAudioDataOutputSampleBufferDelegate,AVAudioRecorderDelegate>

@end
