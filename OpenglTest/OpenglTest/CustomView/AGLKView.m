//
//  AGLKView.m
//  OpenglTest
//
//  Created by luo luo on 19/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AGLKView

@synthesize delegate;
@synthesize context = context;

//告知程序此类使用的是opengl的layer而不是CAlayer
+(Class)layerClass
{
    //此类会与opengles共享帧缓存的像素颜色仓库
    return [CAEAGLLayer class];
}

-(void)setContext:(EAGLContext *)aContext
{
    if (context != aContext) {
        [EAGLContext setCurrentContext:context];
    }
    if (0 != defaultFrameBuffer) {
        //删除已有的这一帧缓存
        glDeleteFramebuffers(1, &defaultFrameBuffer);
        defaultFrameBuffer = 0;
    }
    if (0 != colorRenderBuffer ) {
        glDeleteRenderbuffers(1, &colorRenderBuffer);
        colorRenderBuffer = 0;
    }
    context = aContext;
    
    if (nil != context) {
        context = aContext;
        [EAGLContext setCurrentContext:context];
        //生成帧缓存
        glGenFramebuffers(1, &defaultFrameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
        //生成渲染缓存 后面的渲染操作就用此缓存 渲染缓存跟纹理类似 可以贴在帧缓存上
        glGenRenderbuffers(1, &colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
        //将渲染缓存绑定到帧缓存上
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
        
    }
}

-(EAGLContext *)context
{
    return context;
}

-(NSInteger)drawableWidth
{
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}
-(NSInteger)drawableHeight
{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

#pragma mark 初始化
//代码初始化进入
-(id)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext
{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        //不保留原先的任何内容重新绘制此层
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
        self.context = aContext;
    }
    return self;
}

//interface buind进入
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    }
    return self;
}

//设置view的上下文为当前上下文 让渲染填满整个帧缓存
-(void)display
{
    [EAGLContext setCurrentContext:self.context];
    //设置视口使用的大小(即当前view的可视大小) (控制渲染帧缓存的子集 此处为渲染整个帧缓存)
    glViewport(0, 0, (GLsizei)self.drawableWidth, (GLsizei)self.drawableHeight);
    [self drawRect:[self bounds]];
    //将buff渲染到layer上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.delegate) {
        [self.delegate glkView:self drawInRect:[self bounds]];
    }
}

-(void)layoutSubviews
{
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    //调整视图的缓存尺寸以适应新的缓存
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete frame buffer object %x",status);
    }
}



-(void)dealloc
{
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    context = nil;
}


@end
