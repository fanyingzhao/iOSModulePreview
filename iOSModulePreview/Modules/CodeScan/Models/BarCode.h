//
//  BarCode.h
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/2.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface BarCode : NSObject

@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
@property (nonatomic, strong) UIBezierPath *cornersPath;
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;

@end

