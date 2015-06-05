//
//  UIAlertView+Block.m
//  NewProject
//
//  Created by xss on 15/6/4.
//  Copyright (c) 2015年 beyond.com All rights reserved.
//

#import "UIAlertView+Block.h"
#import <objc/runtime.h>
@implementation UIAlertView(Block)
- (void)setCancelBlock:(DoneBlock)cancelBlock
{
    objc_setAssociatedObject(self, @selector(cancelBlock), cancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (cancelBlock == NULL) {
        self.delegate = nil;
    }
    else {
        self.delegate = self;
    }
}
- (void)setConfirmBlock:(DoneBlock)confirmBlock
{
    objc_setAssociatedObject(self, @selector(confirmBlock), confirmBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (confirmBlock == NULL) {
        self.delegate = nil;
    }
    else {
        self.delegate = self;
    }
}

- (DoneBlock)confirmBlock
{
    return objc_getAssociatedObject(self, @selector(confirmBlock));
}
- (DoneBlock)cancelBlock
{
    return objc_getAssociatedObject(self, @selector(cancelBlock));
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // 确定
        if (self.confirmBlock) {
            self.confirmBlock();
        }
    } else if (buttonIndex == 0) {
        // 取消
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }
}
@end
