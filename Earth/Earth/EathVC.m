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

#define AngleSpan 10 //每次递增10度
#define EathVertexNumber  (180/AngleSpan *(360/AngleSpan)*6*3) // (180/10 *37*6*3)    3 * ((100*2+2) * (100))
#define EathTexCoordVertexNumber (180/AngleSpan *(360/AngleSpan)*6*2)  //2 * ((100*2+2) * (100))
#define sPerVertex  360
static float cylinder[EathVertexNumber] = {0};
static float eathTexVertex[EathTexCoordVertexNumber]={0};

static float cylinder_texcoord[sPerVertex * sPerVertex*2*6] = {0};

@interface EathVC ()
@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexColorBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@property (nonatomic) GLKMatrixStackRef modelviewMatrixStack;
//@property (nonatomic) GLfloat earthRotationAngleDegrees;
@end

@implementation EathVC{
//    GLfloat *_vertexArray;
//    GLfloat *_vertexTexcoordArray;
    
    GLint  m_Stacks, m_Slices;
    GLfloat  m_Scale;
    GLfloat m_Squash;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
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
//    [self configureLight];
    //缓存顶点初始化
    [self bufferData];
    
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT];
    //设置当前片元的深度值最大深度值、并清理颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    self.earthRotationAngleDegrees += 360.0f / 60.0f;
//    //开启深度测试
    glEnable(GL_DEPTH_TEST);
//    glDepthFunc(GL_LESS);
    //剔除背面不可见多边形
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
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
    
    //绘制顶点
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:EathVertexNumber/3];//EathVertexNumber sPerVertex * sPerVertex*6*3
    
    
}

#pragma mark 其它
//设置实际比例和视点
-(void)setVisiblePort
{
    //正交投影
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projecctionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0),//透视投影上下间的夹角(视角)夹角看到的越大物体越小
                                                                                                                 aspect, 0.1f, 10.0f);
    self.baseEffect.transform.projectionMatrix = projecctionMatrix;
    
    //眼睛的位置最好是xyz都大于物体对应的方向的的最高点
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0, 0,-5.0,//眼睛的位置(z轴大于物体最高点以上)
                                                                     0.0, 0.0, 0.0,//看向的位置(锥体的正中心)
                                                                     0.0, 1.0, 0.0);//头朝向Y轴正方向(标配)

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
//    [self getTexVertex];
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
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0.0+angle*6, angle*6, 5.8,//眼睛的位置(z轴大于物体最高点以上)
                                                                     0.0, 0.0, 0.0,//看向的位置(锥体的正中心)
                                                                     0.0, 1.0, 0.0);//头朝向Y轴正方向(标配);
    [self.baseEffect prepareToDraw];

    //    end
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

//生成球体模型坐标
//- (void)genData {
//    int index = 0;
//    double perRadius = 2 * M_PI / (float)sPerVertex;// glmPi
//    float R = 1.0f;
//    //
//    for (int a = 0; a < sPerVertex; a++) {
//        //
//        for (int b = 0; b < sPerVertex; b++) {
//            //此角度下的一点
//            float x1 = R*(float)(sin(a * perRadius / 2) * cos(b* perRadius));
//            float z1 = R*(float)(sin(a * perRadius / 2) * sin(b* perRadius));
//            float y1 = R*(float) cos(a * perRadius / 2);
//            //x1这个点向右加一度
//            float x2 = R*(float)(sin((a + 1) * perRadius / 2) * cos(b * perRadius));
//            float z2 = R*(float)(sin((a + 1) * perRadius / 2) * sin(b * perRadius));
//            float y2 = R*(float)cos((a + 1) * perRadius / 2);
//            //x2这个点向上加一度
//            float x3 = R*(float)(sin((a + 1) * perRadius / 2) * cos((b + 1) * perRadius));
//            float z3 = R*(float)(sin((a + 1) * perRadius / 2) * sin((b + 1) * perRadius));
//            float y3 = R*(float)cos((a + 1) * perRadius / 2);
//            //x1这个点向上加一度
//            float x4 = R*(float)(sin(a * perRadius / 2) * cos((b + 1) * perRadius));
//            float z4 = R*(float)(sin(a * perRadius / 2) * sin((b + 1) * perRadius));
//            float y4 = R*(float)cos(a * perRadius / 2);
//
//            cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
//            cylinder[index++] = x2; cylinder[index++] = y2; cylinder[index++] = z2;
//            cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
//
//            cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
//            cylinder[index++] = x4; cylinder[index++] = y4; cylinder[index++] = z4;
//            cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
//
//        }
//    }
//}
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
            float z0 = (float)(r*sin(DEGREES_TO_RADIANS(vAngle)) * cos(DEGREES_TO_RADIANS(hAngle)));

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
            
            
            eathTexVertex[texIndex++] = hAngle/360.0; eathTexVertex[texIndex++] = (1 - (90-vAngle)/180.0);
            eathTexVertex[texIndex++] = (hAngle+angleSpan)/360.0;eathTexVertex[texIndex++] = (1 - (90-vAngle)/180.0);
            eathTexVertex[texIndex++] = hAngle/360.0; eathTexVertex[texIndex++] = (1 - (90-(vAngle+angleSpan))/180.0);
            
            
             eathTexVertex[texIndex++] = (hAngle+angleSpan)/360.0;eathTexVertex[texIndex++] = (1 - (90-vAngle)/180.0);
             eathTexVertex[texIndex++] = (hAngle+angleSpan)/360.0;eathTexVertex[texIndex++] = (1 - (90-(vAngle+angleSpan))/180.0);
             eathTexVertex[texIndex++] = hAngle/360.0; eathTexVertex[texIndex++] = (1 - (90-(vAngle+angleSpan))/180.0);
            
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

//计算对应的纹理坐标

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

//-(void)genData
//{
//    static int big = 1;
//    static float scale = 0;
//    if (big){
//        scale += 0.01;
//    }else{
//        scale -= 0.01;
//    }
//
//
//    if (scale >= 0.5){
//        big = 0;
//    }
//    if (scale <= 0){
//        big = 1;
//    }
//    m_Scale = 0.5 + scale;
//    m_Slices = 100;
//    m_Squash = 1;
//    m_Stacks = 100;
//
//    //vertices
//    GLfloat *vPtr =  _vertexArray =
//    (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));    //3
//
//    GLfloat *texCoorderPtr = _vertexTexcoordArray = (GLfloat*)malloc(sizeof(GLfloat) * 2 * ((m_Slices*2+2) * (m_Stacks)));    //2维坐标
//
//
//    unsigned int    phiIdx, thetaIdx;
//
//    //latitude
//    for(phiIdx=0; phiIdx < m_Stacks; phiIdx++)        //5
//    {
//
//        float phi0 = M_PI * ((float)(phiIdx+0) * (1.0f/(float)( m_Stacks)) - 0.5f);//从-90到90度
//        float phi1 = M_PI * ((float)(phiIdx+1) * (1.0f/(float)( m_Stacks)) - 0.5f);//向纬度递增方向加一度
//        float cosPhi0 = cos(phi0);            //8
//        float sinPhi0 = sin(phi0);
//        float cosPhi1 = cos(phi1);
//        float sinPhi1 = sin(phi1);
//        float cosTheta, sinTheta;
//        for(thetaIdx=0; thetaIdx < m_Slices; thetaIdx++)
//        {
//
//
//            float theta = 2.0f*M_PI * ((float)thetaIdx) * (1.0f/(float)( m_Slices -1));//360度
//            cosTheta = cos(theta);
//            sinTheta = sin(theta);
//            //本层上某点
//            vPtr [0] = m_Scale*cosPhi0 * cosTheta;//z
//            vPtr [1] = m_Scale*sinPhi0*m_Squash;//y
//            vPtr [2] = m_Scale*cosPhi0 * sinTheta;//x
//
//            //维度递增方向上层圆上一点
//            vPtr [3] = m_Scale*cosPhi1 * cosTheta;
//            vPtr [4] = m_Scale*sinPhi1*m_Squash;
//            vPtr [5] = m_Scale* cosPhi1 * sinTheta;
//            NSLog(@"x=%f y=%f z=%f",vPtr[2],vPtr[1],vPtr[0]);
//            NSLog(@"xx=%f yy=%f zz=%f",vPtr[5],vPtr[4],vPtr[3]);
//            vPtr += 2*3;
//
//            texCoorderPtr[0] = (1.0/(float)m_Slices)*thetaIdx;
//            texCoorderPtr[1] = (1.0/(float)m_Stacks)*phiIdx;
//
//            texCoorderPtr[0] = (1.0/(float)m_Slices)*thetaIdx;
//            texCoorderPtr[1] = (1.0/(float)m_Stacks)*(phiIdx+1);
//
//            texCoorderPtr += 2*2;
//
//
//        }
//    }
//    /***
//        1      3
//       | |   |  |
//      |   | |    |
//     0     2      4
//     **/
//}




@end
