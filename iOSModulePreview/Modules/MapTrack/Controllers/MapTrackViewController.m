//
//  MapTrackViewController.m
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/2.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import "MapTrackViewController.h"

@interface MapTrackViewController () <MAMapViewDelegate>

@property (nonatomic, strong)   MAMapView       *trackMapView;

@end

@implementation MapTrackViewController

#pragma mark - Life Cycle
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
    [self.view addSubview:self.trackMapView];
    [self setMapView];
    [self obtainPolylineArray];
}

- (void)setMapView {
    self.trackMapView.showsUserLocation=YES;
    self.trackMapView.userTrackingMode=MAUserTrackingModeFollow;
    self.trackMapView.zoomLevel=14.0;
}

- (void)obtainPolylineArray {
    CLLocationCoordinate2D commonPolylineCoords[100];
    CGFloat x=31.21323445;
    CGFloat y=121.43376265;
    for (NSInteger i=0; i<100; i++) {
        CGFloat   stepX=(arc4random()%100)*0.00001;
        CGFloat   stepY=(arc4random()%100)*0.00001;
        
        NSInteger step=arc4random()%100;
        if (step%2==0) {
            stepX=(-stepX);
        } else {

        }
        
        x+=stepX;
        y+=stepY;
        
        commonPolylineCoords[i].latitude=x;
        commonPolylineCoords[i].longitude=y;
    }
    MAPolyline *commonPolyline=[MAPolyline polylineWithCoordinates:commonPolylineCoords count:100];
    [self.trackMapView addOverlay:commonPolyline];
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation) {
        PrintLog(@"%@",userLocation.location);
    }
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 5.f;
        polylineView.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
        polylineView.lineJoin = kCGLineJoinRound;//连接类型
        polylineView.lineCap = kCGLineCapRound;
        
        return polylineView;
    }
    return nil;
}

#pragma mark - Initializations
- (MAMapView *)trackMapView {
    if (!_trackMapView) {
        [MAMapServices sharedServices].apiKey=AMapApiKey;
        _trackMapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _trackMapView.mapType=MAMapTypeStandard;
        _trackMapView.delegate=self;
    }
    return _trackMapView;
}

@end
