//
//  AGLKVertexAttribArrayBuffer.h
//  OpenglTest
//
//  Created by luo luo on 19/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class AGLKElementIndexArrayBuffer;

@interface AGLKVertexAttribArrayBuffer : NSObject{
   
    GLsizeiptr stride;
    GLsizeiptr bufferSizeBytes;
    GLuint glName;
}
//顶点标识
@property(nonatomic, assign) GLuint glName;
//顶点buff大小
@property(nonatomic, readonly) GLsizeiptr bufferSizeBytes;
 //步幅
@property(nonatomic, readonly) GLsizeiptr stride;
//绑定顶点数据到缓存
-(id)initWithAttribStride:(GLsizeiptr)stride
         numberOfVertices:(GLsizei)count
                     data:(const GLvoid *)dataPtr
                    usage:(GLenum)usage;
/**
 *  配置顶点信息
 *
 *  @param index    缓存信息是什么标识 GLKVertexAttribPosition
 *  @param count    几维坐标
 *  @param offset 从什么位置开始访问缓存
 */
-(void)prepareToDrawWithAttrib:(GLuint)index
         numberOfCoordinates:(GLint)count
                attribOffset:(GLsizeiptr)offset
                shouldEnable:(BOOL)shouldEnable;


/**
 *  开始绘制顶点
 *
 *  @param model    绘制的是什么模型 如:GL_TRIANGLES(三角形)
 *  @param first 从第那个顶点开始
 *  @param count 顶点数
 */
-(void)drawArrayWithMode:(GLenum)model
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count;

//重新绑定顶点数据到缓存
- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;
@end
