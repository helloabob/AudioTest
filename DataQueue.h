//
//  DataQueue.h
//  AudioTest
//
//  Created by mac0001 on 5/19/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DataTypeVideo,
    DataTypeAudio,
}DataType;

@interface DataQueue : NSObject
+ (instancetype)sharedInstance;
- (void)pushData:(NSData *)data withType:(DataType)type;
- (NSDictionary *)popData;
@end
