//
//  LightViewController.m
//  Light
//
//  Created by luo luo on 29/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "LightViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "OpenGlCommenUtil.h"

@interface LightViewController (){
    SceneTriangle triangles[8];
}
//使用此对象后台会自动生成Shanding Language
@property(nonatomic, strong) GLKBaseEffect *baseeffect;
//用户控制法向量绘制时的颜色和旋转方向
@property(nonatomic, strong) GLKBaseEffect *extraffect;

@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
//用户需要显示法向量时缓存法向量坐标
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *extraBuffer;
//是否绘制法向量
@property(nonatomic) BOOL shouldDrawNormals;
///使用平面向量(被照亮的地方是白色未照亮的地方是黑色)
@property(nonatomic) BOOL shouldUseFaceNormals;
//设置锥体中间顶点的高
@property(nonatomic, assign) GLfloat centerVertexHeight;
@end

@implementation LightViewController

- (void)setShouldUseFaceNormals:(BOOL)aValue
{
    if(aValue != _shouldUseFaceNormals)
    {
        _shouldUseFaceNormals = aValue;
        
        [self updateNormals];
    }
}

-(void)setCenterVertexHeight:(GLfloat)centerVertexHeight
{
    _centerVertexHeight = centerVertexHeight;
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = _centerVertexHeight;
    //更新和中心顶点相关的三角形
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
     [self updateNormals];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    self.baseeffect.light0.enabled = GL_TRUE;
    //发射光的颜色
    self.baseeffect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    //光源位置
    self.baseeffect.light0.position = GLKVector4Make(1.0f, 1.0f, 0.5f
                                                     ,0.0f//表平行光
                                                     );
    
    self.extraffect = [[GLKBaseEffect alloc]init];
    self.extraffect.useConstantColor = GL_TRUE;
    //填充颜色
    self.extraffect.constantColor = GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);
    //旋转圆锥体
    //X轴逆时针旋转60度
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
    //z轴逆时针旋转30度
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.25f);
    //改变视点
    self.baseeffect.transform.modelviewMatrix = modelViewMatrix;
    self.extraffect.transform.modelviewMatrix = modelViewMatrix;
    
    //绘制底部8个三角形
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(triangles) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) data:triangles usage:GL_DYNAMIC_DRAW];
    //留在后面动态初始化
    self.extraBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 data:NULL usage:GL_DYNAMIC_DRAW];
    
    self.centerVertexHeight = 0.0f;
    self.shouldUseFaceNormals = YES;
    //不显示法向量
//    self.shouldDrawNormals = NO;
    
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseeffect prepareToDraw];
    //清理背景色
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    //顶点缓存准备使用
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    //法向量缓存准备使用
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, normal) shouldEnable:YES];
    //开始绘制多个三角形
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(SceneVertex)];
    
    if (self.shouldDrawNormals) {
        //显示法向量
        [self drawNormals];
    }
    
}

#pragma mark 其它
//绘制法向量
-(void)drawNormals
{
    //向量顶点缓存数组
    GLKVector3  normalLineVertices[NUM_LINE_VERTS];
    
    SceneTrianglesNormalLinesUpdate(triangles,
                                    GLKVector3MakeWithArray(self.baseeffect.light0.position.v),
                                    normalLineVertices);
    //重新生成顶点缓存
    [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3) numberOfVertices:NUM_LINE_VERTS bytes:normalLineVertices];
    
    [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                          numberOfCoordinates:3
                                 attribOffset:0
                                 shouldEnable:YES];
    
    
    self.extraffect.useConstantColor = GL_TRUE;
    self.extraffect.constantColor =
    GLKVector4Make(0.0, 1.0, 0.0, 1.0);//绿黄色
    
    [self.extraffect prepareToDraw];
    
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:0
                       numberOfVertices:NUM_NORMAL_LINE_VERTS];
    
    self.extraffect.constantColor =
    GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    
    [self.extraffect prepareToDraw];
    
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:NUM_NORMAL_LINE_VERTS
                       numberOfVertices:(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)];
    
}

-(void)updateNormals
{
    if (self.shouldUseFaceNormals) {
        //重新计算每个三角形的法向量并作为每个点的法向量 并更新
        SceneTrianglesUpdateFaceNormals(triangles);
    }else{
        //计算三角形的法向量使用平均值作为每个点的法向量 并更新
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    //重新绑定顶点数据到缓存
    [self.vertexBuffer
     reinitWithAttribStride:sizeof(SceneVertex)
     numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
     bytes:triangles];
}

#pragma mark 点击事件
//设置顶点的z坐标
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender {
    //改变三角锥顶点位置
    self.centerVertexHeight = sender.value;
    
 /*   //测试 改变视点
    static int i = 1;
    CGFloat angle ;
    angle = sender.value*360;
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(angle), 1.0f, 0.0f, 0.0f);
    //z轴逆时针旋转30度
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
//    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.25f);
    //改变视点
    self.baseeffect.transform.modelviewMatrix = modelViewMatrix;
  [self.baseEffect prepareToDraw];
    i++;
//    end*/
    
}

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

@end
