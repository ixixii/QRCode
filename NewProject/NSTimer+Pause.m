//
//  NSTimer+Pause.m
//  NewProject
//
//  Created by xss on 15/6/4.
//  Copyright (c) 2015年 Steven. All rights reserved.
//

#import "NSTimer+Pause.h"
#import <objc/runtime.h>
static void *state = (void *)@"state";
@implementation NSTimer (Pause)
-(void)pause
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate distantFuture]]; //如果给我一个期限，我希望是4001-01-01 00:00:00 +0000
}
-(void)resume
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate date]];
}
- (NSString *)state
{
    return objc_getAssociatedObject(self, state);
}
- (void)setState:(NSString *)s
{
    objc_setAssociatedObject(self, state, s, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
