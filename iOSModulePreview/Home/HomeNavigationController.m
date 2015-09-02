//
//  HomeNavigationController.m
//  iOSModulePreview
//
//  Created by silent.shi on 15/8/29.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import "HomeNavigationController.h"

@interface HomeNavigationController ()

@end

@implementation HomeNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
}

#pragma mark - PrivateMethods
- (void)configureViews {
    [self.navigationBar setBarTintColor:RGBACOLOR(100, 0, 90, 0.9)];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
