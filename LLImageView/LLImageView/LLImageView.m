//
//  LLImageView.m
//  LLImageView
//
//  Created by luo luo on 26/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "LLImageView.h"
#import "LLShaderManager.h"

enum AttribType
{
    AttribTypeVertexPosition,
    AttribTypeVertexTextureCoord,
};

@interface LLImageView(){
    EAGLContext      *_glContext;
    GLuint          _framebuffer;
    GLuint          _renderbuffer;
    GLint           _backingWidth;//渲染buffer渲染的宽度 等于当前view的宽度
    GLint           _backingHeight;
    GLuint _textureAttribBufferAddress;
    GLuint _modelViewProjectAttriAddress;
    GLfloat         _vertices[8];
//    GLint           _uniformMatrix;
}
@property(nonatomic,strong)LLShaderManager *shaderManager;
@end

@implementation LLImageView
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void)dealloc
{
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    [self.shaderManager deleteProgram];
    
    if ([EAGLContext currentContext] == _glContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
}

#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        //没有初始化成功
        if (![self initFrameBufferAndShader]) {
            self = nil;
        }else{
            NSLog(@"Opengles: init shader successs.");
        }
    }
    
    return self;
}
//初始化帧buffer和着色器
-(BOOL)initFrameBufferAndShader
{
     CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    //设为不透明
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat,
                                    //[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                    nil];
     _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if(!_glContext || ![EAGLContext setCurrentContext:_glContext])
    {
        NSLog(@"Opengles:set context failture!!");
        return NO;
    }
    //生成帧缓存和渲染缓存 绑定渲染缓存到帧缓存
    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_renderbuffer);
    //绑定帧buff到渲染管线上
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    //将渲染buff放到渲染管线上
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    //将渲染buff的缓存设为layer的
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    //最后将所有buff都挂机到桢buff上
    //将渲染buff绑定在帧buff上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    
    //加载着色器到program
    self.shaderManager = [[LLShaderManager alloc]init];//创建program
    GLuint vertexShader,fragmentShader;
    NSURL *vertexShaderPath = [[NSBundle mainBundle]URLForResource:@"Shader" withExtension:@"vsh"];
    NSURL *fragmentShaderPath = [[NSBundle mainBundle]URLForResource:@"Shader" withExtension:@"fsh"];
    //编译着色器并吸附到program
    if (![self.shaderManager compileShader:&vertexShader type:GL_VERTEX_SHADER URL:vertexShaderPath]||![self.shaderManager compileShader:&fragmentShader type:GL_FRAGMENT_SHADER URL:fragmentShaderPath]){
        NSLog(@"Opengles:load vertex shader or load fragment shader failture.!!");
        return NO;
    }
    
    //设置着色器的普通属性
    //绑定顶点属性和纹理属性与着色器里面的一致 必须在连接程序之前
    [self.shaderManager bindAttribLocation:AttribTypeVertexPosition andAttribName:"position"]; //相当于GLKVertexAttribPosition
    [self.shaderManager bindAttribLocation:AttribTypeVertexTextureCoord andAttribName:"texCoord0"];//相当于GLKVertexAttribTexCoord0
   
    
    //链接program 产生可执行程序
    if(![self.shaderManager linkProgram]){
        //链接失败也删除
        [self.shaderManager deleteShader:&vertexShader];
        [self.shaderManager deleteShader:&fragmentShader];
    }else{
        NSLog(@"Opengles:link program success.!!");
    }
    
    //获取普通变量用来设置的地址 (必须在链接program之后)
    _textureAttribBufferAddress  = [self.shaderManager getUniformLocation:"sam2DR"];
    _modelViewProjectAttriAddress = [self.shaderManager getUniformLocation:"modelViewProjectionMatrix"];
    //设置统一变量的值
     glUniform1i(_textureAttribBufferAddress, 0); // 0 代表GL_TEXTURE0  为片段着色器里面的统一变量(sam2DR)初始化
    
    //删除着色器
    [self.shaderManager detachAndDeleteShader:&vertexShader];
    [self.shaderManager detachAndDeleteShader:&fragmentShader];
    [self.shaderManager useProgram];
    
    return YES;
}

#pragma mark 加载帧缓存和渲染缓存
//父类回调方法
-(void)layoutSubviews
{
    //设置此次呈现那个渲染buffer
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    //设置呈现渲染buffer在自己的layer上
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        
        NSLog(@"Opengles:failed to make complete framebuffer object %x", status);
        
    } else {
        
        NSLog(@"Opengles:framebuffer width=%d height=%d", _backingWidth, _backingHeight);
    }
    
    //开始渲染并呈现
    [self updateVertices];
    [self render];
}

//更新顶点的值
- (void)updateVertices
{
    
    const BOOL fit      =  YES;//(self.contentMode == UIViewContentModeScaleAspectFit);
    const float width   = _imageWidth;
    const float height  = _imageHeight;
    const float dH      = (float)_backingHeight / height;
    const float dW      = (float)_backingWidth      / width;
    const float dd      = fit ? MIN(dH, dW) : MAX(dH, dW);//最大的边占满 
    const float h       = (height * dd / (float)_backingHeight);
    const float w       = (width  * dd / (float)_backingWidth );
    NSLog(@"w=%f h=%f",w,h);
    _vertices[0] = - w;
    _vertices[1] = - h;
    _vertices[2] =   w;
    _vertices[3] = - h;
    _vertices[4] = - w;
    _vertices[5] =   h;
    _vertices[6] =   w;
    _vertices[7] =   h;
}

- (void)render
{
    //此处将纹理坐标颠倒了  所以从uikit中拿到的图片不用颠倒了
    static const GLfloat texCoords[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    [EAGLContext setCurrentContext:_glContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    glClearColor(1.0f, 0.5f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.shaderManager useProgram];
    
    //加载纹理数据到缓存中
    //   glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glUniform1f(_textureAttribBufferAddress, 0);//GL_TEXTURE0
    GLuint tex1;
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &tex1);//生成一个纹理缓存  也可以直接传入3 三个容量的标识数组
    glBindTexture(GL_TEXTURE_2D,  tex1);//绑定后表示接下来放入的纹理是输入tex1的
    
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA , self.imageWidth, self.imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, _imageData);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //设置标识
    
    
    GLfloat modelviewProj[16];
    mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);
    //设置投影矩阵 将上下颠倒的画面纠正
    glUniformMatrix4fv(_modelViewProjectAttriAddress, 1, GL_FALSE, modelviewProj);
    //将我们的vertices数组的地址赋值给vertex shader中的position属性.
    glVertexAttribPointer(AttribTypeVertexPosition, 2, GL_FLOAT, 0, 0, _vertices);
    //根据变量的位置AttribTypeVertexPosition启动a_Position这个变量
    glEnableVertexAttribArray(AttribTypeVertexPosition);
    
    glVertexAttribPointer(AttribTypeVertexTextureCoord, 2, GL_FLOAT, 0, 0, texCoords);
    glEnableVertexAttribArray(AttribTypeVertexTextureCoord);
    
#if 0
    if (![self.shaderManager validateProgram])
    {
        NSLog(0, @"Failed to validate program");
        return;
    }
#endif
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}


#pragma mark 其它
static void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout)
{
    float r_l = right - left;
    float t_b = top - bottom;
    float f_n = far - near;
    float tx = - (right + left) / (right - left);
    float ty = - (top + bottom) / (top - bottom);
    float tz = - (far + near) / (far - near);
    
    mout[0] = 2.0f / r_l;
    mout[1] = 0.0f;
    mout[2] = 0.0f;
    mout[3] = 0.0f;
    
    mout[4] = 0.0f;
    mout[5] = 2.0f / t_b;
    mout[6] = 0.0f;
    mout[7] = 0.0f;
    
    mout[8] = 0.0f;
    mout[9] = 0.0f;
    mout[10] = -2.0f / f_n;
    mout[11] = 0.0f;
    
    mout[12] = tx;
    mout[13] = ty;
    mout[14] = tz;
    mout[15] = 1.0f;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [EAGLContext setCurrentContext:_glContext];
     glClearColor(1.0f, 0.5f, 1.0f, 1.0f);
     glClear(GL_COLOR_BUFFER_BIT);
     [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}

//Program渲染的目标是帧缓存


@end
