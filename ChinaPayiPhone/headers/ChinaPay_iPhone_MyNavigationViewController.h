//
//  ChinaPay_iPhone_MyNavigationViewController.h
//  ChinaPay_iPhone
//
//  Created by zhu xiaomeng on 13-7-30.
//  Copyright (c) 2013年 zhu xiaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChinaPay_iPhone_KaTool;
@interface ChinaPay_iPhone_MyNavigationViewController : UINavigationController
{
    ChinaPay_iPhone_KaTool *tool;
    UIImageView *imageLogo;
}
- (void)setButtons:(NSArray*)buttonArray;
- (void)setTool:(ChinaPay_iPhone_KaTool *)tool;
- (void)hideLogo:(BOOL)b;
- (void)setLogoFrame:(CGRect)frame;

@end
