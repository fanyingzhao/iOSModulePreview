//
//  PreviewView.m
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/2.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import "PreviewView.h"

@implementation PreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=RGBACOLOR(40, 40, 40, 0.7);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // 中间清空的矩形框
    CGRect clearDrawRect = self.clearScanRect;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    // 画出透明区域
    CGContextClearRect(ctx, rect);
}


@end
