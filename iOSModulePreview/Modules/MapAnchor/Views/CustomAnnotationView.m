//
//  CustomAnnotationView.m
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/1.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import "CustomAnnotationView.h"

@interface CustomAnnotationView ()

@property (nonatomic, strong, readwrite) CallOutView *calloutView;

@end

@implementation CustomAnnotationView

- (instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self=[super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureCustomAnnotationView];
    }
    return self;
}

- (void)configureCustomAnnotationView {
    self.canShowCallout=YES;
    self.image=[UIImage imageNamed:@"LocationIcon"];
}

#define kCalloutWidth       220.0
#define kCalloutHeight      70.0

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (self.calloutView == nil) {
            self.calloutView = [[CallOutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        
        self.calloutView.portraitView.image = [UIImage imageNamed:@"Logo"];
        self.calloutView.titleLabel.text = self.annotation.title;
        self.calloutView.subtitleLabel.text = self.annotation.subtitle;
        
        [self addSubview:self.calloutView];
    } else {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

@end
