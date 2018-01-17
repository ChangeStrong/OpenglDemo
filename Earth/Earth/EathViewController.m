//
//  EathViewController.m
//  Earth
//
//  Created by luo luo on 03/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "EathViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "banana.h"
//#import "sphere.h"

@interface EathViewController ()
@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@property (nonatomic) GLfloat earthRotationAngleDegrees;

@end

@implementation EathViewController{
    GLKMatrix4 _lastModelViewMatrix;
}

static const GLfloat  SceneEarthAxialTiltDeg = 23.5f;
//static const GLfloat  SceneDaysPerMoonOrbit = 28.0f;
- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    //背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,//red
                                                              0.0f,//green
                                                              0.0f,//blue
                                                              1.0f);
    
    glEnable(GL_DEPTH_TEST);
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    //地球纹理 Earth512x256 banana
    CGImageRef earthImageRef =
    [[UIImage imageNamed:@"banana.jpg"] CGImage];
    self.earthTextureInfo = [GLKTextureLoader
                             textureWithCGImage:earthImageRef
                             options:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES],
                                      GLKTextureLoaderOriginBottomLeft, nil]
                             error:NULL];
    
    
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    //视点位置
    [self setVisiblePort];
    //配置太阳光
    [self configureLight];
    //缓存顶点初始化
    [self bufferData];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    //设置当前片元的深度值最大深度值、并清理颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    self.earthRotationAngleDegrees += 360.0f / 60.0f;

    //顶点缓存准备使用
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    //绘制顶点
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:sizeof(bananaVerts) / (3 * sizeof(GLfloat))];
    
    
}

- (void)bufferData {
    
//    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    //顶点数据缓存
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                 initWithAttribStride:(3 * sizeof(GLfloat))
                                 numberOfVertices:sizeof(bananaVerts) / (3 * sizeof(GLfloat))
                                 data:bananaVerts
                                 usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                               initWithAttribStride:(3 * sizeof(GLfloat))
                               numberOfVertices:sizeof(bananaNormals) / (3 * sizeof(GLfloat))
                               data:bananaNormals
                               usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                     initWithAttribStride:(2 * sizeof(GLfloat))
                                     numberOfVertices:sizeof(bananaTexCoords) / (2 * sizeof(GLfloat))
                                     data:bananaTexCoords
                                     usage:GL_STATIC_DRAW];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//x轴旋转
- (IBAction)sliderAction:(UISlider *)sender {
    
       //测试 改变视点
     static int i = 1;
     CGFloat angle ;
     angle = sender.value*360;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,GLKMathDegreesToRadians(angle), 1.0f, 0.0f, 0.0f);
     self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.baseEffect prepareToDraw];
     i++;
     // end
}

//y轴旋转
- (IBAction)ySliderAction:(UISlider *)sender {
    static int i = 1;
    CGFloat angle ;
    angle = sender.value*360;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Rotate(self.baseEffect.transform.modelviewMatrix,GLKMathDegreesToRadians(angle), 0.0f, 1.0f, 0.0f);
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
    [self.baseEffect prepareToDraw];
    i++;
}

#pragma mark 其它
//设置实际比例和视点
-(void)setVisiblePort
{
    GLfloat   aspectRatio =
    (self.view.bounds.size.width) /
    (self.view.bounds.size.height);
    //正交投影
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakeOrtho(
                        -1.0 * aspectRatio,
                        1.0 * aspectRatio,
                        -1.0,
                        1.0,
                        1.0,
                        120.0);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0);
}

//看见物体的亮度由---漫反射光+环境光
- (void)configureLight
{
    self.baseEffect.light0.enabled = GL_TRUE;
    //漫反射光(由太阳决定)
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    //太阳照射的位置
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     0.0f,
                                                     0.8f,
                                                     0.0f);
    //环境光
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         0.5f, // Blue
                                                         1.0f);// Alpha
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation !=
//            UIInterfaceOrientationPortraitUpsideDown &&
//            interfaceOrientation !=
//            UIInterfaceOrientationPortrait);
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//*****************使用代码编写球体顶点坐标
//生成球体模型坐标

#define sPerVertex  360
float cylinder[sPerVertex * sPerVertex] = {0};
- (void)genData {
    int index = 0;
    
    double perRadius = 2 * M_PI / (float)sPerVertex;// glmPi
    float R = 1.0f;
    for (int a = 0; a < sPerVertex; a++) {
        for (int b = 0; b < sPerVertex; b++) {
            float x1 = R*(float)(sin(a * perRadius / 2) * cos(b* perRadius));
            float z1 = R*(float)(sin(a * perRadius / 2) * sin(b* perRadius));
            float y1 = R*(float) cos(a * perRadius / 2);
            
            float x2 = R*(float)(sin((a + 1) * perRadius / 2) * cos(b * perRadius));
            float z2 = R*(float)(sin((a + 1) * perRadius / 2) * sin(b * perRadius));
            float y2 = R*(float)cos((a + 1) * perRadius / 2);
            
            float x3 = R*(float)(sin((a + 1) * perRadius / 2) * cos((b + 1) * perRadius));
            float z3 = R*(float)(sin((a + 1) * perRadius / 2) * sin((b + 1) * perRadius));
            float y3 = R*(float)cos((a + 1) * perRadius / 2);
            
            float x4 = R*(float)(sin(a * perRadius / 2) * cos((b + 1) * perRadius));
            float z4 = R*(float)(sin(a * perRadius / 2) * sin((b + 1) * perRadius));
            float y4 = R*(float)cos(a * perRadius / 2);
            
            cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
            cylinder[index++] = x2; cylinder[index++] = y2; cylinder[index++] = z2;
            cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
            
            cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
            cylinder[index++] = x4; cylinder[index++] = y4; cylinder[index++] = z4;
            cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
            
        }
    }
}

//计算对应的纹理坐标
float cylinder_texcoord[sPerVertex * sPerVertex] = {0};
-(void)getTexVertex
{
    //计算模型坐标的同时计算纹理坐标：
    int index_texcoord = 0;
    double perW = 1 / (float) sPerVertex;
    double perH = 1 / (float) (sPerVertex);
    for (int a = 0; a < sPerVertex; a++) {//H
        for (int b = 0; b < sPerVertex; b++) {//W
            float w1 = (float) (a * perH);
            float h1 = (float) (b * perW);
            float w2 = (float) ((a + 1) * perH);
            float h2 = (float) (b * perW);
            float w3 = (float) ((a + 1) * perH);
            float h3 = (float) ((b + 1) * perW);
            float w4 = (float) (a * perH);
            float h4 = (float) ((b + 1) * perW);
            cylinder_texcoord[index_texcoord++] = h1;
            cylinder_texcoord[index_texcoord++] = w1;
            cylinder_texcoord[index_texcoord++] = h2;
            cylinder_texcoord[index_texcoord++] = w2;
            cylinder_texcoord[index_texcoord++] = h3;
            cylinder_texcoord[index_texcoord++] = w3;
            cylinder_texcoord[index_texcoord++] = h3;
            cylinder_texcoord[index_texcoord++] = w3;
            cylinder_texcoord[index_texcoord++] = h4;
            cylinder_texcoord[index_texcoord++] = w4;
            cylinder_texcoord[index_texcoord++] = h1;
            cylinder_texcoord[index_texcoord++] = w1;
        }
    }
    
}



@end
