
//
//  AVCaptureCtrl.m
//  NewProject
//
//  Created by xss on 15/5/12.
//  Copyright (c) 2015年 beyond.com All rights reserved.
//

#import "AVCaptureCtrl.h"
#import <AVFoundation/AVFoundation.h>
#import "UIAlertView+Block.h"
#import "NSTimer+Pause.h"
@interface AVCaptureCtrl ()<AVCaptureMetadataOutputObjectsDelegate>
{
    // 扫描线条的y坐标
    int lineYPos;
    BOOL isGoUp;
    NSTimer * timer;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
// 来回扫描的绿色线
@property (nonatomic, strong) UIImageView * lineImgView;
@end

@implementation AVCaptureCtrl
#pragma mark - 生命周期
-(void)viewWillAppear:(BOOL)animated
{
    [self coreConfig];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    // 返回按钮
	UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(100, 420, 120, 40);
    [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    
    // 顶部的提示语句
    UILabel * hintLabel= [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 290, 50)];
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.numberOfLines=2;
    hintLabel.tag = 5267;
    hintLabel.textColor=[UIColor whiteColor];
    hintLabel.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [self.view addSubview:hintLabel];
    
    
    // 300*300的选景框
    UIImageView * bigBgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 300, 300)];
    bigBgImgView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:bigBgImgView];
    
    // 绿色扫描线：初始位置和动画方向
    isGoUp = NO;
    lineYPos =0;
    _lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, 220, 2)];
    _lineImgView.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_lineImgView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeScan) name:@"notice_reStartScan" object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark 扫描动画效果
-(void)lineAnimation
{
    if (isGoUp == NO) {
        lineYPos ++;
        _lineImgView.frame = CGRectMake(50, 110+2*lineYPos, 220, 2);
        if (2*lineYPos == 280) {
            isGoUp = YES;
        }
    }
    else {
        lineYPos --;
        _lineImgView.frame = CGRectMake(50, 110+2*lineYPos, 220, 2);
        if (lineYPos == 0) {
            isGoUp = NO;
        }
    }

}
#pragma mark 返回按钮点击事件
-(void)backBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
    }];
}

#pragma mark - 核心配置代码
- (void)coreConfig
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    // AVCaptureSession 可以设置 sessionPreset 属性，这个决定了视频输入每一帧图像质量的大小。
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]){
        // 为会话设置input
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]){
        // 为会放设置output
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    // metadataObjectTypes属性非常重要，因为它的值会被用来判定整个应用程序对哪类元数据感兴趣。在这里我们将它指定为AVMetadataObjectTypeQRCode。
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview，最后，通过会话 创建 AVCaptureVideoPreviewLayer，并添加到self.view 展示
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(20,110,280,280);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    // Start
    [_session startRunning];
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
// 核心方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    /**
     (lldb) po metadataObjects
     <__NSArrayM 0x14db69a0>(
     <AVMetadataMachineReadableCodeObject: 0x14db2500> type "org.iso.QRCode", bounds { 0.4,0.2 0.3x0.6 }, corners { 0.4,0.9 0.8,0.9 0.8,0.3 0.4,0.2 }, time 322767896792333, stringValue "adsfa爱迪生发"
     )
     */
   
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        // 重要！释放会话
        [_session stopRunning];
        [timer pause];
        timer.state = @"pause";
        
        
        UILabel *hintLabel = (UILabel *)[self.view viewWithTag:5267];
        hintLabel.text = stringValue;
        // 是否打开：
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"风险提示" message:@"您确定要打开该网页吗？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.confirmBlock = ^(){
            // 调用父类的返回
            [self openUrl:stringValue];
        };
        alertView.cancelBlock = ^(){
            [self resumeScan];
        };

        [alertView show];
    }

    return;

   [self dismissViewControllerAnimated:YES completion:^
    {
        NSLog(@"%@",stringValue);
    }];
}


- (void)resumeScan
{
    
    if ([timer.state isEqualToString:@"pause"]) {
        // 重要！释放会话
        [_session startRunning];
        [timer resume];
    }
}
- (void)openUrl:(NSString *)url
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

// 仅适合于打电话，打开应用等
- (void)openUrl2:(NSString *)url
{   UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:webView];
    webView.userInteractionEnabled = true;
    [webView loadRequest:[ [ NSURLRequest alloc] initWithURL:[ [ NSURL alloc] initWithString:url] ] ];
}

@end
