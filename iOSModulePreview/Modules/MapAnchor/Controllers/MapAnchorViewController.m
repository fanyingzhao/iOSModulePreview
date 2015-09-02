//
//  MapAnchorViewController.m
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/1.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import "MapAnchorViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>
#import "AnnotationModel.h"
#import "CustomAnnotationView.h"

@interface MapAnchorViewController () <MAMapViewDelegate>

@property (nonatomic, strong)   MAMapView   *anchorMapView;

@end

@implementation MapAnchorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods
- (void)configureViews {
    [self.view addSubview:self.anchorMapView];
    [self setMapView];
    [self checkUserLocationAuthorization];
    
    // 生成随机坐标的大头针
    for (NSInteger i=0; i<10; i++) {
        
        CGFloat x=31.21323445;
        CGFloat y=121.43376265;
        
        CGFloat   stepX=(arc4random()%100)*0.0001;
        CGFloat   stepY=(arc4random()%100)*0.0001;
    
        PrintLog(@"stepX is %f stepY is %f",stepX,stepY);
        
        if (i%2==0) {
            x-=stepX;
            y+=stepY;
        } else {
            x+=stepX;
            y-=stepY;
        }
        
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(x, y);
        pointAnnotation.title = [NSString stringWithFormat:@"AnnotationView-%ld",i];
        pointAnnotation.subtitle = @"RandomAnnotationView";
        
        [self.anchorMapView addAnnotation:pointAnnotation];
    }
}

- (void)setMapView {
    self.anchorMapView.showsUserLocation=YES;
//    self.anchorMapView.showTraffic=YES;
    self.anchorMapView.userTrackingMode=MAUserTrackingModeFollow;
    self.anchorMapView.zoomLevel=13.0;
}

- (void)checkUserLocationAuthorization {
    if (![CLLocationManager locationServicesEnabled]) {
        PrintLog(@"定位服务未打开!");
        return;
    }
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined) {
        [[[CLLocationManager alloc] init] requestWhenInUseAuthorization];
    }
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation) {
        PrintLog(@"Current locations is %@",userLocation.location);
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString     *pointReuseIndentifier = @"pointReuseIndentifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= NO;       //设置气泡可以弹出，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MAAnnotationView *view = views[0];
    
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        pre.fillColor = [UIColor clearColor];
        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
        pre.image = [UIImage imageNamed:@"location.png"];
        pre.lineWidth = 1;
//        pre.lineDashPattern = @[@6, @3];
        
        [self.anchorMapView updateUserLocationRepresentation:pre];
        
        view.calloutOffset = CGPointMake(0, 0);
    } 
}

#pragma mark - Initializations
- (MAMapView *)anchorMapView {
    if (!_anchorMapView) {
        [MAMapServices sharedServices].apiKey=AMapApiKey;
        _anchorMapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _anchorMapView.mapType=MAMapTypeStandard;
        _anchorMapView.delegate=self;
    }
    return _anchorMapView;
}

@end
