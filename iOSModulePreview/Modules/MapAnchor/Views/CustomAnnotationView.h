//
//  CustomAnnotationView.h
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/1.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CallOutView.h"

@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic, readonly) CallOutView *calloutView;

@end
