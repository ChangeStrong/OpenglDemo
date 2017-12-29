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
        glBindBuffer(GL_ARRAY_BUFFER, self.glName);
        glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, dataPtr, usage);
        NSAssert(0 != glName, @"Failed to generate glName");
    }
    return self;
    
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

-(void)prepareToDrawWithAttrib:(GLuint)index
         numberOfCoordinates:(GLint)count
                attribOffset:(GLsizeiptr)offset
                shouldEnable:(BOOL)shouldEnable
{
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(0 < self.stride);
    NSAssert(0 != glName, @"Invalid glName");
    
    if (shouldEnable) {
        //使缓存的顶点生效
        glEnableVertexAttribArray(index);
    }
    
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, (GLsizei)self.stride, NULL + offset);
    
}

-(void)drawArrayWithMode:(GLenum)model
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes >= ((first + count)*self.stride), @"Attempt to draw more vertex data than available.");
    glDrawArrays(model, first, count);
}

-(void)dealloc
{
    if (0 != glName) {
        glDeleteBuffers(1, &glName);
        glName = 0;
    }
}
@end
