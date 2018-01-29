//
//  TriangleVC.m
//  OpenglTest
//
//  Created by luo luo on 29/11/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "TriangleVC.h"
@interface TriangleVC()
@property(nonatomic, strong) EAGLContext *eagcontext;
@end

@implementation TriangleVC{
    GLuint _program;
    int _vertexcolor;
    GLuint _vertexBuffer;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    //创建一个EAGContext 用来跟踪OpenGL 的状态和管理数据和命令
    [self createEagContext];
    //设置glview的格式
    [self configure];
    //初始化编译顶点着色器和片段着色器
    [self initVerticalAndsegment];
    
}



// MARK: - 创建一个EAGContext 用来跟踪OpenGL 的状态和管理数据和命令
-(void)createEagContext{
    self.eagcontext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.eagcontext];
}

// MARK: - 配置GLKView 控制器的view的类型就是GLKView类型
-(void)configure{
    GLKView *view = (GLKView*)self.view;
    view.context = self.eagcontext;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

-(BOOL)initVerticalAndsegment
{
    // 1.创建标示
    GLuint vertShader, fragShader;
    // 2.获取文件路径
    NSString *vertShaderPathname, *fragShaderPathname;
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    // 3.编译
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"编译失败 vertex shader");
        return NO;
    }
    
    // 创建 编译 片断着色器
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    //创建着一个空的色器程序，把刚才编译好的两个着色器目标代码，连接到这个空的程序中去
    _program = glCreateProgram();
    // 第九步 将顶点着色器加到程序中
    glAttachShader(_program, vertShader);
    
    // 将片断着色器加到程序中
    glAttachShader(_program, fragShader);
    
    // 绑定着色器的属性 - 将着色器程序的属性绑定到OpenGL 中
    glBindAttribLocation(_program, 0, "position");  // 0代表枚举位置 既顶点位置标识保持 和glEnableVertexAttribArray填入的标识一致
    //链接着色器程序
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    //获取着色器中输入变量的索引值
    _vertexcolor = glGetUniformLocation(_program, "color");
    return  YES;
}

//将顶点数据加载到GPU 中去
// 三角形顶点数据
static GLfloat vertex[6] = {
    -1,-1,// 左下
    -1,1, // 左上
    1,1  // 右上
};

-(void)loadVertex{
    glGenBuffers(1, &_vertexBuffer); // 申请内存标识
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);// 绑定
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);// 申请内存空间
    glEnableVertexAttribArray(GLKVertexAttribPosition);// 开启顶点数据
    // 设置指针
    glVertexAttribPointer(GLKVertexAttribPosition,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          8,
                          0);
}

//绘制数据
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    static NSInteger count = 0;
    // 清除颜色缓冲区
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    count ++;
    if (count > 50 ) {
        count = 0;
        // 根据颜色索引值,设置颜色数据，就是刚才我们从着色器程序中获取的颜色索引值
        glUniform4f(_vertexcolor,   arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, 1);
    }
    // 使用着色器程序
    glUseProgram(_program);
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
}




#pragma mark 其它
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    
    //1  获取文件的内容 并进行NSUTF8StringEncoding 编码
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    //2 根据类型创建着色器
    *shader = glCreateShader(type);
    //3. 获取着色器的数据源
    glShaderSource(*shader, 1, &source, NULL);
    //4. 开始编译
    glCompileShader(*shader);
    // 方便调试，可以不用
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    //5. 查看是否编译成功
    GLint status;
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

//链接着色器程序
- (BOOL)linkProgram:(GLuint)prog
{
    // 1链接程序
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    // 2 检查链接结果
    GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
    
}
@end
