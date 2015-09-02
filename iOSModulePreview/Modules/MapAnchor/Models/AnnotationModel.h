//
//  AnnotationModel.h
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/2.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AnnotationModel : NSObject

@property (nonatomic, assign)   CLLocationCoordinate2D  *coordinate;
@property (nonatomic, copy)     NSString                *mainTitle;
@property (nonatomic, copy)     NSString                *detailTitile;

@end
