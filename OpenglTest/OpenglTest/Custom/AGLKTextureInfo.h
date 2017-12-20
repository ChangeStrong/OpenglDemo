//
//  AGLKTextureInfo.h
//  OpenglTest
//
//  Created by luo luo on 20/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface AGLKTextureInfo : NSObject
{
    @private
    GLuint name;
    GLenum target;
    GLuint width;
    GLuint height;
}
@property(readonly) GLuint name;
@property(readonly) GLenum target;
@property(readonly) GLuint width;
@property(readonly) GLuint height;
@end

@interface AGLKTextureLoader : NSObject
//生成纹理缓存
+(AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage
                               options:(NSDictionary *)options
                                 error:(NSError **)outError;
@end
