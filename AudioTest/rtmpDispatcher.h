//
//  rtmpDispatcher.h
//  AudioTest
//
//  Created by mac0001 on 5/20/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rtmpDispatcher : NSObject
+ (instancetype)sharedInstance;
- (int)startConnect;
- (void)stopConnect;

- (void)sendSPS:(NSData *)sps_data andPPS:(NSData *)pps_data;
- (void)sendNormalVideo:(NSData *)data;

- (void)sendAACSpec:(NSData *)data;
- (void)sendNormalAudio:(NSData *)data;
@end
