//
//  AGLKVertexAttribArrayBuffer.m
//  OpenglTest
//
//  Created by luo luo on 19/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer()

@property(nonatomic, assign) GLsizeiptr bufferSizeBytes;
@property(nonatomic, assign) GLsizeiptr stride;

@end

@implementation AGLKVertexAttribArrayBuffer

@synthesize glName = glName;
@synthesize stride = stride;
@synthesize bufferSizeBytes = bufferSizeBytes;

-(id)initWithAttribStride:(GLsizeiptr)astride
         numberOfVertices:(GLsizei)count
                     data:(const GLvoid *)dataPtr
                    usage:(GLenum)usage
{
    NSParameterAssert(0 < astride);
    NSAssert((0 < count && NULL != dataPtr) ||
             (0 == count && NULL == dataPtr),
             @"data must not be NULL or count > 0");
//    NSParameterAssert(NULL != dataPtr);
    
    if (nil != (self = [super init])) {
        stride = astride;
        bufferSizeBytes = stride *count;
        glGenBuffers(1, &glName);
        glBindBuffer(GL_ARRAY_BUFFER, self.glName);//GL_ARRAY_BUFFER(顶点数组) GL_ELEMENT_ARRAY_BUFFER(表示顶点索引数组)
        glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, dataPtr, usage);
        NSAssert(0 != glName, @"Failed to generate glName");
    }
    return self;
    
}
//配置顶点索引
-(void)configerVerticIndexsBufferSize:(GLsizeiptr)size
                                bytes:(const GLvoid *)dataPtr
{
    NSParameterAssert(0 < size);
    glGenBuffers(1, &_indexName);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexName);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, dataPtr, GL_STATIC_DRAW);
    NSAssert(0 != _indexName, @"Failed to generate _indexName");
}


- (void)reinitWithAttribStride:(GLsizeiptr)aStride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;
{
    NSParameterAssert(0 < aStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    NSAssert(0 != glName, @"Invalid name");
    
    self.stride = aStride;
    self.bufferSizeBytes = aStride * count;
    
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 self.glName);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 bufferSizeBytes,  // Number of bytes to copy
                 dataPtr,          // Address of bytes to copy
                 GL_DYNAMIC_DRAW);
}

//配置顶点索引

//准备绘制缓存的数据 index表示绘制的是顶点还是纹理等
-(void)prepareToDrawWithAttrib:(GLuint)index
         numberOfCoordinates:(GLint)count
                attribOffset:(GLsizeiptr)offset
                shouldEnable:(BOOL)shouldEnable
{
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(0 < self.stride);
    NSAssert(0 != glName, @"Invalid glName");
    //注意此步骤不能少
    glBindBuffer(GL_ARRAY_BUFFER,     // STEP 2
                 self.glName);
    if (shouldEnable) {
        //准备绘制index类型的顶点
        glEnableVertexAttribArray(index);
    }
    //设置绘制的类型、几坐标顶点、步幅、什么位置开始绘制
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, (GLsizei)self.stride, NULL + offset);
#ifdef DEBUG
    {  // Report any errors
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
}

-(void)drawArrayWithMode:(GLenum)model
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes >= ((first + count)*self.stride), @"Attempt to draw more vertex data than available.");
    //设置图元类型、第几个点绘制、顶点数
    glDrawArrays(model, first, count);
}

/////////////////////////////////////////////////////////////////
// Submits the drawing command identified by mode and instructs
// OpenGL ES to use count vertices from previously prepared
// buffers starting from the vertex at index first in the
// prepared buffers
+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;
{
    glDrawArrays(mode, first, count); // Step 6
}
-(void)dealloc
{
    if (0 != glName) {
        glDeleteBuffers(1, &glName);
        glName = 0;
    }
}
@end
