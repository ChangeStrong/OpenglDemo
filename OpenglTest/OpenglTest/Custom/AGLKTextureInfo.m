//
//  AGLKTextureInfo.m
//  OpenglTest
//
//  Created by luo luo on 20/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "AGLKTextureInfo.h"
@implementation AGLKTextureInfo

@end

typedef enum
{
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}AGLKTPowerOf2;

static AGLKTPowerOf2 AGLKCalculatePowerOfForDimension(GLuint dimension);
static NSData * AGLKDataWithResizedCGImageBytes(CGImageRef cgImage, size_t * width , size_t * heightPtr);
@implementation AGLKTextureLoader



+(AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
                               options:(NSDictionary *)options
                                 error:(NSError **)outError
{
    size_t width;
    size_t height;
    NSData *imageData = AGLKDataWithResizedCGImageBytes(cgImage, &width, &height);
    
    GLuint textureBufferID;
    glGenTextures(1, &textureBufferID);
    glBindBuffer(GL_TEXTURE_2D, textureBufferID);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [imageData bytes]);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
//    AGLKTextureInfo *result = [AGLKTextureInfo alloc]initwith
    
    return nil;
}
@end

static NSData * AGLKDataWithResizedCGImageBytes(CGImageRef cgImage,size_t *widthPtr,size_t *heightPtr){
    
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);
    size_t originalWidth = CGImageGetWidth(cgImage);
    size_t originalHeight = CGImageGetHeight(cgImage);
    NSCAssert(0 < originalWidth, @"Ivalid image width");
    NSCAssert(0 < originalHeight, @"Ivalid image height");
    
    size_t width = (size_t)AGLKCalculatePowerOfForDimension((GLuint)originalWidth);
    size_t height = (size_t)AGLKCalculatePowerOfForDimension((GLuint)originalHeight);
    
    NSMutableData *imageData = [NSMutableData dataWithLength:height*width*4];
    NSCAssert(nil != imageData, @"Uable to allcoate Image storage");
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgcontext = CGBitmapContextCreate([imageData mutableBytes], width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(cgcontext, 0, height);
    CGContextScaleCTM(cgcontext, 1.0, -1.0);
    
    CGContextDrawImage(cgcontext, CGRectMake(0, 0, width, height), cgImage);
    
    CGContextRelease(cgcontext);
    
    *widthPtr = width;
    *heightPtr = height;
    
    return imageData;
}

static AGLKTPowerOf2 AGLKCalculatePowerOfForDimension(GLuint dimension)
{
    AGLKTPowerOf2 result = AGLK1;
    if (dimension > (GLuint)AGLK512)
    {
        result  = AGLK1024;
    }
    else if(dimension > (GLuint)AGLK256)
    {
        result = AGLK512;
    }
    else if(dimension > (GLuint)AGLK128)
    {
        result = AGLK256;
    }
    else if(dimension > (GLuint)AGLK64)
    {
        result = AGLK128;
    }
    else if(dimension > (GLuint)AGLK32)
    {
        result = AGLK64;
    }
    else if(dimension > (GLuint)AGLK16)
    {
        result = AGLK32;
    }
    else if(dimension > (GLuint)AGLK8)
    {
        result = AGLK16;
    }
    else if(dimension > (GLuint)AGLK4)
    {
        result = AGLK8;
    }
    else if(dimension > (GLuint)AGLK2)
    {
        result = AGLK4;
    }
    else if(dimension > (GLuint)AGLK1)
    {
        result = AGLK2;
    }
    
    return result;
}


