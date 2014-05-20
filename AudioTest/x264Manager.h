//
//  x264Manager.h
//  AudioTest
//
//  Created by wangbo on 5/18/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <x264.h>
#import <common/common.h>
#import <AVFoundation/AVFoundation.h>

@interface x264Manager : NSObject {
    x264_param_t * p264Param;
    x264_picture_t * p264Pic;
    x264_t *p264Handle;
    x264_nal_t  *nal_data;
    int previous_nal_size;
    unsigned  char * pNal;
    FILE *fp;
    unsigned char szBodyBuffer[1024*32];
}

+ (instancetype)sharedInstance;

- (void)initForX264;
//初始化x264

- (void)initForFilePath;
//初始化编码后文件的保存路径

- (void)encoderToH264:(CMSampleBufferRef )pixelBuffer;
//将CMSampleBufferRef格式的数据编码成h264并写入文件

@end
