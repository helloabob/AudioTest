//
//  ChinaPay_iPhone_ViewController.h
//  ChinaPay_iPhone
//
//  Created by zhu xiaomeng on 13-7-30.
//  Copyright (c) 2013年 zhu xiaomeng. All rights reserved.
//

#import "ChinaPay_iPhone_MyNavigationViewController.h"

@protocol ChinaPayIPhoneDelegate<NSObject>
@required
- (void)viewClose:(NSData *)myData;

@end

@interface ChinaPay_iPhone_ViewController : ChinaPay_iPhone_MyNavigationViewController<UIAlertViewDelegate>
{
    id<ChinaPayIPhoneDelegate> delegate;
}

@property (nonatomic,assign) id<ChinaPayIPhoneDelegate> delegate;

- (void)setXmlData:(NSData *)data;
- (NSData *)getReturnXml;
- (void)closeView:(NSData*)data;


@end
