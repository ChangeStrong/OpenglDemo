//
//  AGLKView.h
//  OpenglTest
//
//  Created by luo luo on 19/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;
@protocol AGLKViewDelegate;

@interface AGLKView : UIView{
    EAGLContext *context;
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLint   drawableWidth;
    GLint drawableHeight;
}

@property (nonatomic, weak) id<AGLKViewDelegate> delegate;
@property(nonatomic, retain) EAGLContext *context;
//获取渲染buff的宽
@property(nonatomic, readonly) NSInteger drawableWidth;
//获取渲染buff的高
@property(nonatomic, readonly) NSInteger drawableHeight;
//设置view的上下文为当前上下文 让渲染填满整个帧缓存
-(void)display;

@end

@protocol AGLKViewDelegate <NSObject>

@required
-(void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;
@end
