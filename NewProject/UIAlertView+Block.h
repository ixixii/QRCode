//
//  UIAlertView+Block.h
//  NewProject
//
//  Created by xss on 15/6/4.
//  Copyright (c) 2015年 beyond.com All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^UIAlertViewBlock)(UIAlertView *alertView, NSInteger buttonIndex);
typedef void (^ConfirmBlock)(void);
@interface UIAlertView(Block) <UIAlertViewDelegate>
@property (nonatomic,copy)ConfirmBlock confirmBlock;
@property (nonatomic,copy)ConfirmBlock cancelBlock;

// 必须手动用运行时绑定方法
- (void)setConfirmBlock:(ConfirmBlock)confirmBlock;
- (void)setCancelBlock:(ConfirmBlock)cancelBlock;
- (ConfirmBlock)confirmBlock;
- (ConfirmBlock)cancelBlock;
@end
