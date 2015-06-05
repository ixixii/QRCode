//
//  UIAlertView+Block.h
//  NewProject
//
//  Created by xss on 15/6/4.
//  Copyright (c) 2015年 beyond.com All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^UIAlertViewBlock)(UIAlertView *alertView, NSInteger buttonIndex);
typedef void (^DoneBlock)(void);
@interface UIAlertView(Block) <UIAlertViewDelegate>
@property (nonatomic,copy)DoneBlock confirmBlock;
@property (nonatomic,copy)DoneBlock cancelBlock;

// 必须手动用运行时绑定方法
- (void)setConfirmBlock:(DoneBlock)confirmBlock;
- (void)setCancelBlock:(DoneBlock)cancelBlock;
- (DoneBlock)confirmBlock;
- (DoneBlock)cancelBlock;
@end
