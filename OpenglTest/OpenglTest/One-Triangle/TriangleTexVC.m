//
//  TriangleTexVC.m
//  OpenglTest
//
//  Created by luo luo on 19/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "TriangleTexVC.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

//定义顶点结构体 (也可以存入其它额外信息)
typedef struct {
    //内部再放一个顶点结构体
    GLKVector3 positioncoords;
    GLKVector2 textureCoords;
}SceneVertex;
//uiimage得到的图片属于uikit坐标与coregraph以及quartz以及opengl是相反的 造成上下颠倒 左上是原点(0,0)
static const SceneVertex vertices[] = {
    //下三角
    {{-0.5,-0.5,0.0},{0.0f,1.0f}},//A
    {{0.5f,-0.5f,0.0},{1.0f,1.0f}},//B
    {{-0.5f,0.5f,0.0},{0.0f,0.0f}},//C
    
    //正方形则添加上面的三角形
      {{0.5f,0.5f,0.0},{1.0f,0.0f}},//D
    {{0.5f,-0.5f,0.0},{1.0f,1.0f}},//B
    {{-0.5f,0.5f,0.0},{0.0f,0.0f}},//C
  
    
};

@interface TriangleTexVC ()
//渲染后期相关装饰 颜色等控制
@property(nonatomic, strong) GLKBaseEffect *baseeffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@end

@implementation TriangleTexVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"VC's view is not glview");
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [AGLKContext setCurrentContext:view.context];
    
    self.baseeffect = [[GLKBaseEffect alloc]init];
    self.baseeffect.useConstantColor = GL_TRUE;
    //使用白色渲染填充整体三角形
    self.baseeffect.constantColor = GLKVector4Make(1.0f,//red
                                                   1.0f,//green
                                                   1.0f,//blue
                                                   1.0f);
    //背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f,//red
                                                              0.0f,//green
                                                              0.0f,//blue
                                                              1.0f);
    
    
    NSLog(@"vertes=%lu",sizeof(vertices)/sizeof(SceneVertex));
    //生成顶点缓存
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices)/sizeof(SceneVertex) data:vertices usage:GL_STATIC_DRAW];
    
    //设置纹理
    CGImageRef imageRef = [UIImage imageNamed:@"test.png"].CGImage;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.baseeffect.texture2d0.name = textureInfo.name;
    self.baseeffect.texture2d0.target = textureInfo.target;
    
//    self.baseeffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0f), 0.0, 0.0, 1.0);
    
    //右侧看
//    self.baseeffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0.2, -0.2, 0.2,//眼睛的位置(右边偏上)
//                                                                     0.0, 0.0, 0.0,//看向的位置(锥体的正中心)
//                                                                     0.0, 1.0, 0.0);//头朝向Y轴正方向(标配)
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseeffect prepareToDraw];
    //清理背景色
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positioncoords) shouldEnable:YES];
    //配置纹理和使纹理生效
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(vertices)/sizeof(SceneVertex)];
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
