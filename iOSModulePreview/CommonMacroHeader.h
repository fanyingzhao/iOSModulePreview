//
//  CommonMacroHeader.h
//  iOSModulePreview
//
//  Created by silent.shi on 15/8/29.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#ifndef iOSModulePreview_CommonMacroHeader_h
#define iOSModulePreview_CommonMacroHeader_h

#define AMapApiKey          @"84f0d863817e09a5d012d969dade5a8e"

#define PrintLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#define RGBCOLOR(r,g,b)             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define ScreenWidth                 [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                [[UIScreen mainScreen] bounds].size.height


#endif
