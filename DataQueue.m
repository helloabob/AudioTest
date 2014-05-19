//
//  DataQueue.m
//  AudioTest
//
//  Created by mac0001 on 5/19/14.
//  Copyright (c) 2014 Bob. All rights reserved.
//

#import "DataQueue.h"

@implementation DataQueue {
    dispatch_queue_t serial_queue;
    NSMutableArray *innerArray;
//    NSMutableArray *audioArray;
//    NSMutableArray *videoArray;
}

+ (instancetype)sharedInstance {
    static DataQueue *sharedNetUtilsInstance = nil;
    static dispatch_once_t predicate; dispatch_once(&predicate, ^{
        sharedNetUtilsInstance = [[self alloc] init];
        sharedNetUtilsInstance->serial_queue = dispatch_queue_create("com.bo.serial_dq", NULL);
        sharedNetUtilsInstance->innerArray = [[NSMutableArray alloc] init];
//        sharedNetUtilsInstance->videoArray = [[NSMutableArray alloc] init];
    });
    return sharedNetUtilsInstance;
}

- (void)pushData:(NSData *)data withType:(DataType)type {
    dispatch_async(serial_queue, ^(){
        if (type==DataTypeAudio) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:data forKey:@"1"];
            [innerArray addObject:dict];
        } else {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:data forKey:@"2"];
            [innerArray addObject:dict];
        }
    });
}

- (NSDictionary *)popData {
    __block NSDictionary *data=nil;
    dispatch_sync(serial_queue, ^(){
        if (innerArray.count>0) {
            data = [[innerArray objectAtIndex:0] retain];
            [innerArray removeObjectAtIndex:0];
        }
    });
    return [data autorelease];
}

@end
