//
//  AGLKContext.m
//  OpenglTest
//
//  Created by luo luo on 19/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext
@synthesize clearColor = clearColor;

-(void)setClearColor:(GLKVector4)clearColorRGBA
{
    clearColor = clearColorRGBA;
    NSAssert([[self class] currentContext] == self, @"Receiving context required to be current context");
    //设置当前上下文背景色
    glClearColor(clearColorRGBA.r, clearColorRGBA.g, clearColorRGBA.b, clearColorRGBA.a);
}

-(GLKVector4)clearColor
{
    return clearColor;
}

-(void)clear:(GLbitfield)mask
{
    //不是当前上下文崩溃
     NSAssert([[self class] currentContext] == self, @"Receiving context required to be current context");
    glClear(mask);
}

@end
