//
//  QYCustomCameraVC.m
//  QYCustomCamera
//
//  Created by Zhang jiyong on 2018/6/13.
//  Copyright © 2018年 PasserbyQ. All rights reserved.
//

#import "QYCustomCameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>



#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface QYCustomCameraVC ()

//捕获设备，通常是前置摄像头，后置摄像头
@property (nonatomic, strong) AVCaptureDevice *device;
//由他把输入输出结合在一起，并开始启动捕获设备
@property (nonatomic, strong) AVCaptureSession* session;
//输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
//照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
//图像预览层，实时显示捕获的图像
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

// ------------- 界面 --------------
//拍照按钮
@property (nonatomic, strong) UIButton *photoButton;
//闪光灯按钮
@property (nonatomic, strong) UIButton *torchButotn;
//返回按钮
@property (nonatomic, strong) UIButton *backButotn;
//聚焦
@property (nonatomic, strong) UIView *focusView;
//是否开启闪光灯
@property (nonatomic, assign) BOOL isflashOn;
//输出照片
@property (nonatomic, strong) UIImage *photopImage;
//底部操作视图
@property (nonatomic, strong) UIView *downView;

@end

@implementation QYCustomCameraVC


- (void)viewDidLoad {
    [super viewDidLoad];
    _isflashOn = NO;
    [self createCustomCapture];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = YES;
    
    if (self.session) {
        
        [self.session startRunning];
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    if (self.session) {
        
        [self.session stopRunning];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)turnOnFocus {
    if ([self.device hasTorch]) {
        [_torchButotn setBackgroundImage:[UIImage imageNamed:@"camera_flash_off"] forState:UIControlStateNormal];
        [self.device lockForConfiguration:nil];
        [self.device setFlashMode:AVCaptureFlashModeOn];
        [self.device unlockForConfiguration];
    }
}
-(void)turnOffFocus {
    if ([self.device hasTorch]) {
        [_torchButotn setBackgroundImage:[UIImage imageNamed:@"camera_flash_on"] forState:UIControlStateNormal];
        [self.device lockForConfiguration:nil];
        //        [device setTorchMode: AVCaptureTorchModeOff];
        [self.device setFlashMode:AVCaptureFlashModeOff];
        
        [self.device unlockForConfiguration];
    }
}

-(void)changeFocusing:(UIButton *)btn
{
    if (_isflashOn)
    {
        [self turnOffFocus];
    } else
    {
        [self turnOnFocus];
    }
    _isflashOn = !_isflashOn;
    
}

#pragma mark - 构造自定义相机
-(void)createCustomCapture
{
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [self.device lockForConfiguration:nil];
    [self.device setFlashMode:AVCaptureFlashModeOff];
    [self.device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    self.previewLayer.frame = CGRectMake(0,0,self.view.frame.size.width ,self.view.frame.size.height);
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    //    [self.previewLayer setBounds:self.view.bounds];
    self.previewLayer.contentsScale = [UIScreen mainScreen].scale;
    self.previewLayer.backgroundColor = [[UIColor blackColor]CGColor];
    self.view.layer.masksToBounds = YES;
    
    [self.view.layer addSublayer:self.previewLayer];
    //创建相机下面自定义视图
    [self createCustomView];
}

-(void)createCustomView
{
    CGFloat viewH = 140;
    _downView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-viewH, SCREEN_WIDTH, viewH)];
    _downView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_downView];
    
    _backButotn = [[UIButton alloc] initWithFrame:CGRectMake(30, 50, 10, 18)];
//    [_backButotn setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    [_backButotn setBackgroundImage:[UIImage imageNamed:@"icon_top_backs"] forState:UIControlStateNormal];
    [_backButotn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_backButotn];
    
    _photoButton = [[UIButton alloc] init];
    [_photoButton setBackgroundImage:[UIImage imageNamed:@"xiangji"] forState:UIControlStateNormal];
    [_photoButton addTarget:self action:@selector(savePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_photoButton];
    _photoButton.frame = CGRectMake((SCREEN_WIDTH-40)/2, 40, 45, 35);
    
    _torchButotn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 50, 19, 19)];
//    [_torchButotn setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
    [_torchButotn setBackgroundImage:[UIImage imageNamed:@"camera_flash_on"] forState:UIControlStateNormal];
    [_torchButotn addTarget:self action:@selector(changeFocusing:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_torchButotn];
    
    //取景框
//    UIImage *image = [UIImage imageNamed:@"cameraLocation"];
//    CGFloat height = SCREEN_HEIGHT-viewH-40;
//    _layerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height*image.size.width/image.size.height, height)];
//    _layerImageView.image = image;
//    _layerImageView.center = CGPointMake(self.view.center.x, (SCREEN_HEIGHT-viewH)*0.5);
//    [self.view addSubview:_layerImageView];
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    // 获得点击的坐标，然后用坐标对屏幕的尺寸进行数据处理，应为focusPointOfInterest是从左上到右下(0~1,0~1)范围内
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1 - point.x/size.width );
    
    if ([self.device lockForConfiguration:nil]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            //曝光量调节
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                weakSelf.focusView.hidden = YES;
            }];
        }];
    }
    
}

-(void)savePhoto:(UIButton *)button
{
    //进行拍照保存图片
    AVCaptureConnection *conntion = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        NSLog(@"拍照失败，请重新拍照");
        return;
    }
    __weak typeof(self) weakSelf = self;

    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        weakSelf.photopImage = [UIImage imageWithData:imageData];
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.finishBlock) {
                weakSelf.finishBlock(weakSelf.photopImage);
            }
        }];
    }];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
