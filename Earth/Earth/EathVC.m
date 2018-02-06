//
//  EathVC.m
//  Earth
//
//  Created by luo luo on 02/02/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "EathVC.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define AngleSpan 2 //每次递增10度
#define EathVertexNumber  (180/AngleSpan *(360/AngleSpan)*6*3)
#define EathTexCoordVertexNumber (180/AngleSpan *(360/AngleSpan)*6*2)
static float cylinder[EathVertexNumber] = {0};
static float eathTexVertex[EathTexCoordVertexNumber]={0};

@interface EathVC ()
@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexColorBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property(nonatomic, strong) GLKTextureInfo *secondTextureInfo;
@property(nonatomic, strong) GLKTextureInfo *thirdTextureInfo;

@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
@end

@implementation EathVC{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GLKView *view = (GLKView *)self.view;
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
//    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    //背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,//red
                                                              0.0f,//green
                                                              0.0f,//blue
                                                              1.0f);
    
   
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    //地球纹理 Earth512x256 banana
    CGImageRef earthImageRef =
    [[UIImage imageNamed:@"miandui.jpg"] CGImage];
    self.earthTextureInfo = [GLKTextureLoader
                             textureWithCGImage:earthImageRef
                             options:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES],
                                      GLKTextureLoaderOriginBottomLeft, nil]
                             error:NULL];
    
    CGImageRef secondImageRef =
    [[UIImage imageNamed:@"1111.jpg"] CGImage];
    self.secondTextureInfo = [GLKTextureLoader
                              textureWithCGImage:secondImageRef
                              options:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:YES],
                                       GLKTextureLoaderOriginBottomLeft, nil]
                              error:NULL];
    
    CGImageRef thirdImageRef =
    [[UIImage imageNamed:@"susu.jpg"] CGImage];
    self.thirdTextureInfo = [GLKTextureLoader
                              textureWithCGImage:thirdImageRef
                              options:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:YES],
                                       GLKTextureLoaderOriginBottomLeft, nil]
                              error:NULL];
    
    
   
    //视点位置
    [self setVisiblePort];
    //配置太阳光
//    [self configureLight];
    //缓存顶点初始化
    [self bufferData];
    
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    //设置当前片元的深度值最大深度值、并清理颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    //剔除背面不可见多边形
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);//反面消除
    
    //顶点缓存准备使用
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    
//    [self.vertexColorBuffer prepareToDrawWithAttrib:GLKVertexAttribColor
//                                numberOfCoordinates:3.0
//                                       attribOffset:0
//                                       shouldEnable:YES];


    [self.vertexTextureCoordBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:0
     shouldEnable:YES];
    
    [self drawBallOne];
//    [self drawBallSecond];
//    [self drawBallThird];
    
}

-(void)drawBallOne
{
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    
    static  GLfloat  eathRotationDegree = 20.0f;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    //Y轴旋转
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(eathRotationDegree),
                         0.0, 1.0, 0.0);
//    GLKMatrixStackRotate(
//                         self.modelviewMatrixStack,
//                         GLKMathDegreesToRadians(eathRotationDegree),
//                         0.0, 1.0, 0.0);
    
//    GLKMatrixStackScale(
//                        self.modelviewMatrixStack,
//                        0.5,
//                        0.5,
//                        0.5);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    //绘制顶点
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:EathVertexNumber/3];
    
    //取出原先第二个球的矩阵给第二个球使用
     GLKMatrixStackPop(self.modelviewMatrixStack);
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    eathRotationDegree = eathRotationDegree+1;
}


-(void)drawBallSecond
{
    self.baseEffect.texture2d0.name = self.secondTextureInfo.name;
    self.baseEffect.texture2d0.target = self.secondTextureInfo.target;
    
    static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.4;//放小倍数
    static GLfloat rotationDegree = 10;
    GLKMatrixStackPush(self.modelviewMatrixStack);
    //Y轴旋转
        GLKMatrixStackRotate(
                             self.modelviewMatrixStack,
                             GLKMathDegreesToRadians(rotationDegree),
                             0.0, 1.0, 0.0);
    //Y轴平移
    GLKMatrixStackTranslate(
                            self.modelviewMatrixStack,
                            0.0, -1.0, 0.0);
    //地球的1/4倍
    GLKMatrixStackScale(
                        self.modelviewMatrixStack,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:EathVertexNumber/3];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    rotationDegree += 1;
}
//绘制第三个球
-(void)drawBallThird
{
    self.baseEffect.texture2d0.name = self.thirdTextureInfo.name;
    self.baseEffect.texture2d0.target = self.thirdTextureInfo.target;
    static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.4;//放小倍数
    static GLfloat rotationDegree = 10;
    GLKMatrixStackPush(self.modelviewMatrixStack);
    //Y轴旋转
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(rotationDegree),
                         0.0, 1.0, 0.0);
    //Y轴平移--向上平移
    GLKMatrixStackTranslate(
                            self.modelviewMatrixStack,
                            0.0, 1.0, 0.0);
    //地球的1/4倍
    GLKMatrixStackScale(
                        self.modelviewMatrixStack,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:EathVertexNumber/3];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    rotationDegree += 1;
}

#pragma mark 其它
//设置实际比例和视点
-(void)setVisiblePort
{
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    //正交投影
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projecctionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0),//透视投影上下间的夹角(视角)夹角看到的越大物体越小
                                                                                                                 aspect, 0.1f, 10.0f);
    self.baseEffect.transform.projectionMatrix = projecctionMatrix;
    
    //眼睛的位置最好是xyz都大于物体对应的方向的的最高点
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0.0, 0.0,4.0,//眼睛的位置(z轴大于物体最高点以上)
                                                                     0.0, 0.0, 0.0,//看向的位置(锥体的正中心)
                                                                     0.0, 1.0, 0.0);//头朝向Y轴正方向(标配)
    
    //矩阵堆
    GLKMatrixStackLoadMatrix4(
                              self.modelviewMatrixStack,
                              self.baseEffect.transform.modelviewMatrix);

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

- (void)bufferData {
    
    
    [self genData];
    //顶点数据缓存
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:(3 * sizeof(GLfloat))
                         numberOfVertices:EathVertexNumber/3.0
                         data:cylinder
                         usage:GL_STATIC_DRAW];
    
//    self.vertexColorBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:(3*sizeof(GLfloat)) numberOfVertices:sizeof(cylinder)/ (3 * sizeof(GLfloat)) data:cylinder usage:GL_STATIC_DRAW];

    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                     initWithAttribStride:(2 * sizeof(GLfloat))
                                     numberOfVertices:EathTexCoordVertexNumber/2.0//EathTexCoordVertexNumber sizeof(cylinder_texcoord) / (2 * sizeof(GLfloat))
                                     data:eathTexVertex
                                     usage:GL_STATIC_DRAW];
    
    
    
    
}

- (IBAction)sliderAction:(UISlider *)sender {
    //测试 改变视点
  CGFloat  angle = sender.value;
    //改变视点
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(angle*12-6, angle*12-6, 3.8,//眼睛的位置(z轴大于物体最高点以上)
                                                                     0.0, 0.0, 0.0,//看向的位置(锥体的正中心)
                                                                     0.0, 1.0, 0.0);//头朝向Y轴正方向(标配);
    [self.baseEffect prepareToDraw];
    //    end
}


//594 666 *6*3
-(void)genData
{
    int index = 0;
    int texIndex = 0;
    int angleSpan = AngleSpan;//单位切割的角度 步幅为10度
    float r = 1.0;
    // 垂直方向angleSpan度一份
    for (int vAngle = -90;vAngle < 90; vAngle = vAngle+angleSpan) {
        //// 水平方向angleSpan度一份
        for (int hAngle = 0; hAngle <360; hAngle = hAngle+angleSpan) {
            // 纵向横向各到一个角度后计算对应的此点在球面上的坐标
            float x0 = (float)(r*cos(DEGREES_TO_RADIANS(vAngle)) * sin(DEGREES_TO_RADIANS(hAngle)));
            float y0 = (float)(r*sin(DEGREES_TO_RADIANS(vAngle)));
            float z0 = (float)(r*cos(DEGREES_TO_RADIANS(vAngle)) * cos(DEGREES_TO_RADIANS(hAngle)));

            float x1 = (float) (r * cos(DEGREES_TO_RADIANS(vAngle)) * sin(DEGREES_TO_RADIANS(hAngle + angleSpan)));
            float y1 = (float) (r  * sin(DEGREES_TO_RADIANS(vAngle)));
            float z1 = (float) (r * cos(DEGREES_TO_RADIANS(vAngle)) * cos(DEGREES_TO_RADIANS(hAngle + angleSpan)));

            float x2 = (float) (r * cos(DEGREES_TO_RADIANS(vAngle + angleSpan)) * sin(DEGREES_TO_RADIANS(hAngle + angleSpan)));
            float y2 = (float) (r  * sin(DEGREES_TO_RADIANS(vAngle + angleSpan)));
            float z2 = (float) (r * cos(DEGREES_TO_RADIANS(vAngle + angleSpan)) * cos(DEGREES_TO_RADIANS(hAngle + angleSpan)));

            float x3 = (float) (r * cos(DEGREES_TO_RADIANS(vAngle + angleSpan)) * sin(DEGREES_TO_RADIANS(hAngle)));
            float y3 = (float) (r *sin(DEGREES_TO_RADIANS(vAngle + angleSpan)));
            float z3 = (float) (r * cos(DEGREES_TO_RADIANS(vAngle + angleSpan)) * cos(DEGREES_TO_RADIANS(hAngle)));
            
            //四边形
            cylinder[index++] = x0; cylinder[index++] = y0; cylinder[index++] = z0;
            cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
            cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
            
            cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
            cylinder[index++] = x2; cylinder[index++] = y2; cylinder[index++] = z2;
            cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
            
            //纹理坐标
            eathTexVertex[texIndex++] = hAngle/360.0; eathTexVertex[texIndex++] = (1 - (90-vAngle)/180.0);//0
            eathTexVertex[texIndex++] = (hAngle+angleSpan)/360.0;eathTexVertex[texIndex++] = (1 - (90-vAngle)/180.0);//1
            eathTexVertex[texIndex++] = hAngle/360.0; eathTexVertex[texIndex++] = (1 - (90-(vAngle+angleSpan))/180.0);//3
            
             eathTexVertex[texIndex++] = (hAngle+angleSpan)/360.0;eathTexVertex[texIndex++] = (1 - (90-vAngle)/180.0);//1
             eathTexVertex[texIndex++] = (hAngle+angleSpan)/360.0;eathTexVertex[texIndex++] = (1 - (90-(vAngle+angleSpan))/180.0);//2
             eathTexVertex[texIndex++] = hAngle/360.0; eathTexVertex[texIndex++] = (1 - (90-(vAngle+angleSpan))/180.0);//3
            
            NSLog(@"index:0-%d",index-1);//共11988个坐标

        }
    }

}



/*
 绘制顺序和顶点制作的四边形对应
 3--------2
 |        |
 |        |
 0--------1
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

/*矩阵栈:
 把矩阵MatrixA放入栈中缓存，然后对矩阵进行操作，得到新的矩阵MatrixB；
 最后把矩阵出栈，可以得到原始矩阵MatrixA。*/


@end
