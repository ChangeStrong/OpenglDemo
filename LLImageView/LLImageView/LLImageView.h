//
//  LLImageView.h
//  LLImageView
//
//  Created by luo luo on 26/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>

@interface LLImageView : UIView{
    @public
    GLubyte *_imageData;
}


@property(nonatomic, assign) GLsizei imageWidth;
@property(nonatomic, assign) GLsizei imageHeight;

@end
