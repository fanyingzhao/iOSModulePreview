//
//  CallOutView.h
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/2.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPortraitMargin     5
#define kPortraitWidth      50
#define kPortraitHeight     50

#define kTitleWidth         150
#define kTitleHeight        20

@interface CallOutView : UIView

@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end
