//
//  CubeVC.m
//  OpenglTest
//
//  Created by luo luo on 18/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "CubeVC.h"
#import "CubeUtil.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"


@interface CubeVC (){
    //四边形顶点对象
    SceneQuadrilateral quadrilaterals[6];
//    SceneTriangle triangeles[12];
    GLKTextureInfo *_textureInfo;
     GLKTextureInfo *_textureInfo2;
}

//使用此对象后台会自动生成Shanding Language
@property(nonatomic, strong) GLKBaseEffect *baseeffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

@implementation CubeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //上面
    SceneTriangle triangelOne = {vertexA,vertexB,vertexC};
    SceneTriangle triangelTwo = {vertexA,vertexC,vertexD};
    
    //下面
    SceneTriangle triangelThree = {vertexE,vertexG,vertexF};
    SceneTriangle triangelFour = {vertexE,vertexH,vertexG};
    //左
    SceneTriangle triangelFive = {vertexE,vertexD,vertexH};
    SceneTriangle triangelSix = {vertexE,vertexA,vertexD};
    //右
    SceneTriangle triangelSeven = {vertexF,vertexG,vertexC};
    SceneTriangle triangelEight = {vertexF,vertexC,vertexB};
    //前
    SceneTriangle triangelNine = {vertexE,vertexF,vertexB};
    SceneTriangle triangelTen = {vertexE,vertexB,vertexA};
    //后
    SceneTriangle triangelEleven = {vertexH,vertexC,vertexG};
    SceneTriangle triangelTwelve = {vertexH,vertexD,vertexC};
    
    
//    triangeles[0] =triangelOne;
//    triangeles[1] =triangelTwo;
//    triangeles[2] =triangelThree;
//    triangeles[3] =triangelFour;
//    triangeles[4] =triangelFive;
//    triangeles[5] =triangelSix;
//    triangeles[6] =triangelSeven;
//    triangeles[7] =triangelEight;
//    triangeles[8] =triangelNine;
//    triangeles[9] =triangelTen;
//    triangeles[10] =triangelEleven;
//    triangeles[11] =triangelTwelve;
    
    
    //下
    quadrilaterals[0] = SceneQuadrilaterMake(triangelThree, triangelFour);
    //左
    quadrilaterals[1] = SceneQuadrilaterMake(triangelFive, triangelSix);
    //后
    quadrilaterals[2] = SceneQuadrilaterMake(triangelEleven, triangelTwelve);
    //右
    quadrilaterals[3] = SceneQuadrilaterMake(triangelSeven, triangelEight);
    //前
    quadrilaterals[4] = SceneQuadrilaterMake(triangelNine, triangelTen);
    //上
    quadrilaterals[5] = SceneQuadrilaterMake(triangelOne, triangelTwo);
   
    
   
    
    
    
    GLKView *view = (GLKView *)self.view;
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    //背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,//red
                                                              0.0f,//green
                                                              0.0f,//blue
                                                              1.0f);
    //设置灯光颜色和发射位置
    self.baseeffect = [[GLKBaseEffect alloc]init];
    self.baseeffect.useConstantColor = GL_TRUE;
    self.baseeffect.constantColor = GLKVector4Make(1.0, 1.0f, 1.0f, 1.0f);
    //视域比例按手机比例
     float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
//    GLKMatrix4 projecctionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(240.0),//透视投影上下间的夹角(视角)夹角看到的越大物体越小
//                                                             aspect, 0.1f, 100.0f);
//    self.baseeffect.transform.projectionMatrix = projecctionMatrix;
    //X轴逆时针旋转60度
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-0.0f), 1.0f, 0.0f, 0.0f);
      //Y轴旋转
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(30.0f), 0.0f, 1.0f, 0.0f);
    self.baseeffect.transform.modelviewMatrix = modelViewMatrix;
    //眼睛的位置最好大于物体的最高点
//    self.baseeffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0.5, -0.5, 0.2,//眼睛的位置(右边偏上)
//                                                                         0.0, 0.0, 0.0,//看向的位置(锥体的正中心)
//                                                                         0.0, 1.0, 0.0);//头朝向Y轴正方向(标配)
    NSLog(@"%lu",sizeof(cubeVertices)/sizeof(SceneVertex));
    
     self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(cubeVertices)/sizeof(SceneVertex) data:cubeVertices usage:GL_STATIC_DRAW];
    
    CGImageRef imageRef = [UIImage imageNamed:@"test.png"].CGImage;
   _textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    CGImageRef imageRef2 = [UIImage imageNamed:@"timg.gif"].CGImage;
    _textureInfo2 = [GLKTextureLoader textureWithCGImage:imageRef2 options:nil error:NULL];
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    //剔除背面不可见多边形
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseeffect prepareToDraw];
    //清理背景色
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    NSLog(@"offset:%lu",offsetof(SceneVertex, positioncoords));
    //顶点缓存准备使用
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positioncoords) shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribColor numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, colorcoords) shouldEnable:YES];
    
    //配置纹理和使纹理生效
//    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
//
//
//    self.baseeffect.texture2d0.name = _textureInfo.name;
//    self.baseeffect.texture2d0.target = _textureInfo.target;
//    [self.baseeffect prepareToDraw];
//
//    //开始绘制多个三角形
//    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:4];
//    self.baseeffect.texture2d0.name = _textureInfo2.name;
//    self.baseeffect.texture2d0.target = _textureInfo2.target;
//    [self.baseeffect prepareToDraw];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(cubeVertices)/sizeof(SceneVertex)];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sliderAction:(UISlider *)sender {
       //测试 改变视点
     static int i = 1;
     CGFloat angle ;
     angle = sender.value*360;
     GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(angle), 1.0f, 0.0f, 0.0f);
     //z轴逆时针旋转30度
         modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
         modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.25f);
     //改变视点
     self.baseeffect.transform.modelviewMatrix = modelViewMatrix;
    [self.baseeffect prepareToDraw];
     i++;
     //    end
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
