//
//  ViewController.m
//  NewProject
//
//  Created by xss on 15/5/12.
//  Copyright (c) 2015年 beyond.com All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZBarReaderDelegate>
{
    // 扫描线条的y坐标
    int lineYPos;
    BOOL isGoUp;
    NSTimer * timer;
    
}
// 来回扫描的绿色线
@property (nonatomic, strong) UIImageView * lineImgView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIButton * scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [scanButton setTitle:@"点我扫描" forState:UIControlStateNormal];
    scanButton.frame = CGRectMake(100, 100, 120, 40);
    [scanButton addTarget:self action:@selector(jumpToCameraVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];

}
-(void)jumpToCameraVC
{          
    if(IOS7){
        // 如果iOS7以上，则使用系统的API
        Class c = NSClassFromString(@"AVCaptureCtrl");
        [self presentViewController:[[c alloc]init] animated:YES completion:^{
        }];
    }else{
        // 如果iOS7以下，则使用ZBar
        [self jumpToZBarCtrl];
    }
}
-(void)jumpToZBarCtrl
{
    lineYPos = 0;
    isGoUp = NO;
    // 初始话ZBarReader控制器
    ZBarReaderViewController * ZBarReaderCtrl = [ZBarReaderViewController new];
    // 设置ZBarReader控制器的代理
    ZBarReaderCtrl.readerDelegate = self;
    // 支持界面旋转
    ZBarReaderCtrl.supportedOrientationsMask = ZBarOrientationMaskAll;
    ZBarReaderCtrl.showsHelpOnFail = NO;
    // 重要！扫描的感应框
    ZBarReaderCtrl.scanCrop = CGRectMake(0.1, 0.2, 0.8, 0.8);
    // 设置ZBarImageScanner扫描器的扫描目标类型
    [ZBarReaderCtrl.scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
    view.backgroundColor = [UIColor clearColor];
    ZBarReaderCtrl.cameraOverlayView = view;
    
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    label.text = @"请将扫描的二维码至于下面的框内\n谢谢！";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.lineBreakMode = 0;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    UIImageView * bigBgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
    bigBgImgView.frame = CGRectMake(20, 80, 280, 280);
    [view addSubview:bigBgImgView];
    
    
    _lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    _lineImgView.image = [UIImage imageNamed:@"line.png"];
    [bigBgImgView addSubview:_lineImgView];
    //定时器，设定时间过1.5秒，
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
    [self presentViewController:ZBarReaderCtrl animated:YES completion:^{
    }];
}
// 绿线上下扫描动画
-(void)lineAnimation
{
    if(isGoUp){
        // 代表 向 上 走
        lineYPos --;
        _lineImgView.frame = CGRectMake(30, 10+2*lineYPos, 220, 2);
        if (lineYPos == 0) {
            // 已经走到图片顶部了，不能再往上走了，应该往下走了
            isGoUp = NO;
        }
    }
    
    if (!isGoUp) {
        // 代表 向 下 走
        lineYPos ++;
        _lineImgView.frame = CGRectMake(30, 10+2*lineYPos, 220, 2);
        if (2*lineYPos == 260) {
            // 已经走到图片底部了，应该往上走了
            isGoUp = YES;
        }
    }
    
    
    
}
#pragma mark - 图片选择代理方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [timer invalidate];
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [timer invalidate];
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
        // 取出原图
        UIImage * originalImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        // 初始化 ZBarReaderController控制器
        ZBarReaderController *read = [ZBarReaderController new];
        // 设置ZBarReaderController控制器代理
        read.readerDelegate = self;
        CGImageRef cgImageRef = originalImg.CGImage;
        ZBarSymbol * symbol = nil;
        id <NSFastEnumeration> ZBarSymbolArr = [read scanImage:cgImageRef];
        for (symbol in ZBarSymbolArr)
        {
            break;
        }
        NSString *result;
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding]){
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }else{
            result = symbol.data;
        }
        NSLog(@"%@",result);
    }];
}
@end
