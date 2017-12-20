//
//  AGLKContext.h
//  OpenglTest
//
//  Created by luo luo on 19/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

//#import <OpenGLES/OpenGLES.h>
#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext{
    GLKVector4 clearColor;
    
}
//清除颜色时使用的背景色
@property(nonatomic, assign) GLKVector4 clearColor;

//开始清除缓存内的附加缓存 在drawrect方法内调用此方法
-(void)clear:(GLbitfield)mask;

@end
