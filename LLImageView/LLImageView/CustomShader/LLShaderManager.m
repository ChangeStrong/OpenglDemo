//
//  LLShaderManager.m
//  LLImageView
//
//  Created by luo luo on 26/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "LLShaderManager.h"

@implementation LLShaderManager
//(一)
-(instancetype)init{
    if (self = [super init]){
        // 创建一个显卡程序
        self.program = glCreateProgram();
    }
    return self;
}
//(二)
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL
{
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
    if (sourceString == nil) {
        NSLog(@"Failed to load vertex shader: %@", [error localizedDescription]);
        return NO;
    }
    
    GLint status;
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    
    *shader = glCreateShader(type);//1-创建着色器
    glShaderSource(*shader, 1, &source, NULL);//2-提供着色器的文本(路径)
    glCompileShader(*shader);//3-编译着色器
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        //获取着色器的日志属性值
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    //4- 编译成功后，吸附到程序中去
    glAttachShader(self.program, *shader);
    
    return YES;
}
//（五-1）
- (BOOL)linkProgram
{
    GLint status;
    glLinkProgram(_program);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}
//（五-2）
- (BOOL)validateProgram
{
    GLint logLength, status;
    
    glValidateProgram(_program);
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);//获取用来装载打印信息的size
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    //获取目前program的状态
    glGetProgramiv(_program, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}
//（三） 绑定程序顶点属性位置到与glEnableVertexAttribArray()和glVertexAttribPointer()联合使用的标识上
- (void)bindAttribLocation:(GLuint)index andAttribName:(GLchar*)name{
    glBindAttribLocation(self.program, index, name);
    
}

- (void)deleteShader:(GLuint*)shader{
    if (*shader){
        glDeleteShader(*shader);
        *shader = 0;
    }
}
//（四） 获取每个程序的统一变量的存储位置
- (GLint)getUniformLocation:(const GLchar*) name{
    return  glGetUniformLocation(self.program, name);
}

-(void)detachAndDeleteShader:(GLuint *)shader{
    if (*shader){
        glDetachShader(self.program, *shader);
        glDeleteShader(*shader);
        *shader = 0;
    }
    
}

-(void)deleteProgram{
    if (self.program){
        glDeleteProgram(self.program);
        self.program = 0;
    }
    
}

-(void)useProgram{
    glUseProgram(self.program);
    
}
@end
