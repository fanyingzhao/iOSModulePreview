//
//  CodeScanViewController.m
//  iOSModulePreview
//
//  Created by silent.shi on 15/9/2.
//  Copyright (c) 2015年 Gao Friend Information and Technology Inc. All rights reserved.
//

#import "CodeScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BarCode.h"
#import "PreviewView.h"

@interface CodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

// AVFoundation中的核心类，用于通过硬件获取、处理和输出视频。一个Capture Session由多个输入和多个输出组成，并控制输出帧的格式和分辨率
@property   (nonatomic, retain) AVCaptureSession            *captureSession;
// 封装设备上的物理摄像头。对iPhone而言有前后两个摄像头
@property   (nonatomic, retain) AVCaptureDevice             *captureDevice;
// 要添加一个AVCaptureDevice到session中，需要用AVCaptureDeviceInput来包裹一下
@property   (nonatomic, retain) AVCaptureDeviceInput        *captureDeviceInput;
// 用于显示摄像头捕捉到得视频到UI
@property   (nonatomic, retain) AVCaptureVideoPreviewLayer  *capturePrieviewLayer;
// 当从视频帧中检测到元数据时，AVCaptureMetadataOutput会调用应用程序的回调函数。AV Foundation支持两种类型的元数据：机器可读的编码和人脸识别
@property   (nonatomic, retain) AVCaptureMetadataOutput     *metadataOutput;
// 语音合成器
@property   (nonatomic, retain) AVSpeechSynthesizer         *speechSynthesizer;
// 用于存放session的状态，标明session在运行还是处于停止状态
@property   (nonatomic, assign) BOOL                        isRunning;
// 缩放摄像头
@property   (nonatomic, assign) CGFloat                     initialPinchZoom;

@property   (nonatomic, strong) UIView                      *scanRectView;
@property   (nonatomic, strong) UIImageView                 *scanRectBackground;
@property   (nonatomic, strong) UIImageView                 *scanLine;
@property   (nonatomic, assign) CGRect                      scanRect;

@property   (nonatomic, copy)   NSMutableDictionary         *barCodes;

@property   (nonatomic, copy)   CAShapeLayer                *cornersPathLayer;
@property   (nonatomic, strong) UIView                      *previewView;
@property   (nonatomic, strong) PreviewView                 *previewCover;


@end

@implementation CodeScanViewController
#pragma mark - Life Cycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupCaptureSession];
    
    _barCodes=[NSMutableDictionary dictionary];
    
    [self.previewView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)]];
    
    [self setUpScanRectAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

#pragma mark - Private methods
- (void)setUpScanRectAnimation {
    self.scanRectBackground=[[UIImageView alloc] initWithFrame:self.scanRectView.bounds];
    self.scanRectBackground.image=[UIImage imageNamed:@"scan_bg"];
    [self.scanRectView addSubview:self.scanRectBackground];
    
    self.scanLine=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scanRectView.bounds.size.width, 2)];
    self.scanLine.image=[UIImage imageNamed:@"line"];
    [self.scanRectView addSubview:self.scanLine];
}

- (void)scanAnimation {

    CAKeyframeAnimation     *positionAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    NSValue  *position_1=[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.scanRectView.bounds),0)];
    NSValue  *position_2=[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.scanRectView.bounds), self.scanRectView.bounds.size.height)];
    NSValue  *position_3=[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.scanRectView.bounds), 0)];
    NSArray  *positions=@[position_1,position_2,position_3];
    positionAnimation.values=positions;
    positionAnimation.removedOnCompletion=NO;
    positionAnimation.repeatCount=MAXFLOAT;
    positionAnimation.duration=2.0;
    
    [self.scanLine.layer addAnimation:positionAnimation forKey:@"scanAnimation"];

}

- (void)setupCaptureSession {
    // 如果Session已经存在,则直接返回
    if (_captureSession) {
        return;
    }
    // 初始化VideoDevice,如果没有可用的设备,则直接返回
    _captureDevice=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_captureDevice) {
        return;
    }
    // 初始化captureSession
    _captureSession=[[AVCaptureSession alloc] init];
    // 使用Device创建Input
    _captureDeviceInput=[[AVCaptureDeviceInput alloc] initWithDevice:_captureDevice error:nil];
    // 查询Session是否接收Input,如果接收,则添加它
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    
    // 创建预览层并制定要预览的Session
    _capturePrieviewLayer=[[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _capturePrieviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    _capturePrieviewLayer.frame=self.previewView.layer.bounds;
    [self.previewView.layer addSublayer:_capturePrieviewLayer];
    
    
    
    [self.previewView addSubview:self.scanRectView];
    [self.previewView addSubview:self.previewCover];
    [self.view addSubview:self.previewView];
    [self.previewView bringSubviewToFront:self.scanRectView];
    
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    CGSize size=self.previewView.bounds.size;
    [_metadataOutput setRectOfInterest : CGRectMake(self.scanRectView.frame.origin.y/size.height, self.scanRectView.frame.origin.x/size.width, self.scanRectView.bounds.size.height/size.height, self.scanRectView.bounds.size.width/size.width)];
    
    dispatch_queue_t metadataQueue = dispatch_queue_create("com.GaoFriend.ColloQR.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    
    if([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
    
    _metadataOutput.metadataObjectTypes=@[AVMetadataObjectTypeUPCECode,
                                          AVMetadataObjectTypeCode39Code,
                                          AVMetadataObjectTypeCode39Mod43Code,
                                          AVMetadataObjectTypeEAN13Code,
                                          AVMetadataObjectTypeEAN8Code,
                                          AVMetadataObjectTypeCode93Code,
                                          AVMetadataObjectTypeCode128Code,
                                          AVMetadataObjectTypePDF417Code,
                                          AVMetadataObjectTypeQRCode,
                                          AVMetadataObjectTypeAztecCode,
                                          AVMetadataObjectTypeInterleaved2of5Code,
                                          AVMetadataObjectTypeITF14Code,
                                          AVMetadataObjectTypeDataMatrixCode];
    
    //    _speechSynthesizer=[[AVSpeechSynthesizer alloc] init];
}

- (void)startRunning {
    if (_isRunning) {
        return;
    }
    [self scanAnimation];
    [_captureSession startRunning];
    _isRunning=YES;
    // 设置要检测的元数据类型为所有类型
    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
}

- (void)stopRunning {
    if (!_isRunning) {
        return;
    }
    [_captureSession stopRunning];
    _isRunning=NO;
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    [self startRunning];
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    [self stopRunning];
}

- (BarCode *)processMetadataObject:(AVMetadataMachineReadableCodeObject *)code {
    // 查询baoCodes字典,检查是否有相同的BarCode存在
    BarCode *barcode = _barCodes[code.stringValue];
    
    // 如果没有则创建一个BarCode对象放入到字典中
    if (!barcode) {
        barcode = [BarCode new];
        _barCodes[code.stringValue] = barcode;
    }
    
    // 存储二维码的元数据到barCode对象中
    barcode.metadataObject = code;
    
    // 创建用于储存二维码四个角路径的path
    CGMutablePathRef cornersPath = CGPathCreateMutable();
    
    // 使用CoreGraphics将第一个角转换为CGpoint实例
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[0], &point);
    
    // 从point开始绘制路径
    CGPathMoveToPoint(cornersPath, nil, point.x, point.y);
    for (int i = 1; i < code.corners.count; i++) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[i], &point);
        CGPathAddLineToPoint(cornersPath, nil, point.x, point.y);
    }
    
    // 绘制完成后关闭路径
    CGPathCloseSubpath(cornersPath);
    
    // 使用cornersPath创建UIBezierPath对象并存储到barcode对象中
    barcode.cornersPath =[UIBezierPath bezierPathWithCGPath:cornersPath];
    CGPathRelease(cornersPath);
    
    // 通过bezierPathWithRect:方法创建边框块
    barcode.boundingBoxPath = [UIBezierPath bezierPathWithRect:code.bounds];
    
    return barcode;
}

- (void)pinchDetected:(UIPinchGestureRecognizer*)recogniser {
    if (!_captureDevice) {
        return;
    }
    if (recogniser.state == UIGestureRecognizerStateBegan) {
        _initialPinchZoom = _captureDevice.videoZoomFactor;
    }
    NSError *error = nil;
    [_captureDevice lockForConfiguration:&error];
    
    if (!error) {
        CGFloat zoomFactor;
        CGFloat scale = recogniser.scale;
        if (scale < 1.0f) {
            zoomFactor = _initialPinchZoom - pow(_captureDevice.activeFormat.videoMaxZoomFactor, 1.0f - recogniser.scale);
        } else {
            zoomFactor = _initialPinchZoom + pow(_captureDevice.activeFormat.videoMaxZoomFactor, (recogniser.scale - 1.0f) / 2.0f);
        }
        zoomFactor = MIN(10.0f, zoomFactor);
        zoomFactor = MAX(1.0f, zoomFactor);
        _captureDevice.videoZoomFactor = zoomFactor;
        [_captureDevice unlockForConfiguration];
    }
}

#pragma mark - MetadataOutputDelegate
// 每当AVCaptureMetadataOutput类检测到新的元数据时，调用captureOutput方法，在captureOutput方法中，我们打印所有检测到的元数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 目的是在处理一个新的frame前，将所有检测到的二维码存储起来。用于比较已经缓存的二维码和新检测到的二维码是否相同
    NSSet *originalBarcodes = [NSSet setWithArray:_barCodes.allValues];
    // 创建用于遍历检测到的二维码的NSMutableSet
    NSMutableSet    *foundBarcodes=[NSMutableSet new];
    // 处理类型为AVMetadataMachineReadableCodeObject的对象
    [metadataObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"Metadata is %@",obj);
        if ([obj  isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            // 转换图像的bounds和corner坐标为容器preview的坐标
            AVMetadataMachineReadableCodeObject *code=(AVMetadataMachineReadableCodeObject*)[_capturePrieviewLayer transformedMetadataObjectForMetadataObject:obj];
            // 处理二维码数据并加入到字典中
            BarCode *barcode=[self processMetadataObject:code];
            [foundBarcodes addObject:barcode];
        }
    }];
    // 去除已经缓存了的二维码，只保留新扫描到的二维码
    NSMutableSet *newBarcodes = [foundBarcodes mutableCopy];
    [newBarcodes minusSet:originalBarcodes];
    
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        // 移除预览view中的所有子图层
        //        NSArray *allSublayers = [_previewView.layer.sublayers copy];
        //        [allSublayers enumerateObjectsUsingBlock: ^(CALayer *layer, NSUInteger idx, BOOL *stop) { if (layer != _capturePrieviewLayer) {
        //            [layer removeFromSuperlayer];
        //        }
        //
        //        }];
        // 遍历所有检测到的二维码，为它们添加边界路径和角路径。这些layer有着不同的颜色，alpha值也被设置为0.5，这样我们可以透过叠加层看到原始二维码图片
        [foundBarcodes enumerateObjectsUsingBlock: ^(BarCode *barcode, BOOL *stop) {
            // bounds定义了包含二维图像的矩形
            //            CAShapeLayer *boundingBoxLayer = [CAShapeLayer new];
            //            boundingBoxLayer.path = barcode.boundingBoxPath.CGPath;
            //            boundingBoxLayer.lineWidth = 2.0f;
            //            boundingBoxLayer.strokeColor = [UIColor greenColor].CGColor; boundingBoxLayer.fillColor =
            //            [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.5f].CGColor;
            //            [_previewView.layer addSublayer:boundingBoxLayer];
            //
            // corners定义了二维码图像的实际坐标
            _cornersPathLayer = [CAShapeLayer new];
            _cornersPathLayer.path = barcode.cornersPath.CGPath;
            _cornersPathLayer.lineWidth = 2.0f;
            _cornersPathLayer.strokeColor =[UIColor blueColor].CGColor;
            _cornersPathLayer.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f].CGColor;
            [self.previewView.layer addSublayer:_cornersPathLayer];
        }];
        
        // 利用集合操作移除已经不在屏幕范围内的二维码，并更新_barcode字典
        NSMutableSet *goneBarcodes = [originalBarcodes mutableCopy];
        [goneBarcodes minusSet:foundBarcodes];
        [goneBarcodes enumerateObjectsUsingBlock: ^(BarCode *barcode, BOOL *stop) {
            [_barCodes removeObjectForKey:barcode.metadataObject.stringValue];
        }];
        
        [_barCodes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[BarCode class]]) {
                [self stopRunning];
                BarCode     *barcode=(BarCode*)obj;
                NSString    *codeString=barcode.metadataObject.stringValue;
                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"图像内容" message:codeString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
        
    });
    NSLog(@"Current barcode is %@",_barCodes);
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        [self startRunning];
        [_cornersPathLayer removeFromSuperlayer];
    }
}

#pragma mark - Initialization
- (UIView *)previewView {
    if (!_previewView) {
        _previewView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    }
    return _previewView;
}

- (UIView *)scanRectView {
    if (_scanRectView==nil) {
        _scanRectView=[[UIView alloc] init];
        _scanRectView.frame=CGRectMake (CGRectGetMidX(self.previewView.layer.bounds)-110,CGRectGetMidY(self.previewView.layer.bounds) -110, 220, 220);
        _scanRectView.backgroundColor=[UIColor clearColor];
        _scanRectView.alpha=1;
        _scanRectView.layer.borderColor=[UIColor whiteColor].CGColor;
        _scanRectView.layer.borderWidth=2.0f;
    }
    return _scanRectView;
}

- (PreviewView *)previewCover {
    if (!_previewCover) {
        _previewCover=[[PreviewView alloc] initWithFrame:self.previewView.bounds];
        _previewCover.clearScanRect=self.scanRectView.frame;
    }
    return _previewCover;
}


@end
