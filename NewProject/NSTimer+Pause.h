//
//  NSTimer+Pause.h
//  NewProject
//
//  Created by xss on 15/6/4.
//  Copyright (c) 2015年 Steven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Pause)
@property (nonatomic, strong, readwrite) NSString *state;
-(void)pause;
-(void)resume;
@end
