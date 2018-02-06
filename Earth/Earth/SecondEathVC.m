//
//  SecondEathVC.m
//  Earth
//
//  Created by luo luo on 06/02/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "SecondEathVC.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface SecondEathVC ()
@property(nonatomic, strong) GLKBaseEffect *baseEffect;
@property(nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexColorBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (strong, nonatomic) GLKTextureInfo *earthTextureInfo;
@end

@implementation SecondEathVC{
    GLfloat *_vertexArray;
    GLfloat *_vertexTexcoordArray;
    
    GLint  m_Stacks, m_Slices;
    GLfloat  m_Scale;
    GLfloat m_Squash;
    
    GLint _eathVertexNumber;
    
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
    //缓存顶点初始化
    [self bufferData];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    //    glDepthFunc(GL_LESS);
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
    
        [self.vertexTextureCoordBuffer
         prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
         numberOfCoordinates:2
         attribOffset:0
         shouldEnable:YES];
    
    //绘制顶点
    [self.baseEffect prepareToDraw];
    
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLE_STRIP
     startVertexIndex:0
     numberOfVertices:_eathVertexNumber];
    
    /* GL_TRIANGLE_STRIP 如果当前顶点是奇数：
     组成三角形的顶点排列顺序：T = [n-1 n-2 n].
     如果当前顶点是偶数：
     组成三角形的顶点排列顺序：T = [n-2 n-21 n]. 总共绘制N-2个三角形*/
    
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
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(0, 0,2.0,//眼睛的位置(z轴大于物体最高点以上)
                                                                     0.0, 0.0, 0.0,//看向的位置(锥体的正中心)
                                                                     0.0, 1.0, 0.0);//头朝向Y轴正方向(标配)
    
}

- (void)bufferData {
    [self createEathVertexs];
    //顶点数据缓存
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:(3 * sizeof(GLfloat))
                         numberOfVertices:_eathVertexNumber
                         data:_vertexArray
                         usage:GL_STATIC_DRAW];
    
    
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                     initWithAttribStride:(2 * sizeof(GLfloat))
                                     numberOfVertices:_eathVertexNumber
                                     data:_vertexTexcoordArray
                                     usage:GL_STATIC_DRAW];
    
}



-(void)createEathVertexs
{
    static int big = 1;
    static float scale = 0;
    if (big){
        scale += 0.01;
    }else{
        scale -= 0.01;
    }


    if (scale >= 0.5){
        big = 0;
    }
    if (scale <= 0){
        big = 1;
    }
    m_Scale = 0.5 + scale;
    m_Slices = 100;
    m_Squash = 1;
    m_Stacks = 100;

    _eathVertexNumber = ((m_Slices*2+2) * (m_Stacks));
    //vertices
    GLfloat *vPtr =  _vertexArray =
    (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));    //3

    GLfloat *texCoorderPtr = _vertexTexcoordArray = (GLfloat*)malloc(sizeof(GLfloat) * 2 * ((m_Slices*2+2) * (m_Stacks)));    //2维坐标

    unsigned int    phiIdx, thetaIdx;

    for(phiIdx=0; phiIdx < m_Stacks; phiIdx++)        //5
    {
        float phi0 = M_PI * ((float)(phiIdx+0) * (1.0f/(float)( m_Stacks)) - 0.5f);//从-90到90度
        float phi1 = M_PI * ((float)(phiIdx+1) * (1.0f/(float)( m_Stacks)) - 0.5f);//向纬度递增方向加一度
        float cosPhi0 = cos(phi0);            //8
        float sinPhi0 = sin(phi0);
        float cosPhi1 = cos(phi1);
        float sinPhi1 = sin(phi1);
        float cosTheta, sinTheta;
        
        for(thetaIdx=0; thetaIdx < m_Slices; thetaIdx++)
        {
            float theta = 2.0f*M_PI * ((float)thetaIdx) * (1.0f/(float)( m_Slices -1));//360度
            cosTheta = cos(theta);
            sinTheta = sin(theta);
            //本层上某点
            vPtr [0] = m_Scale*cosPhi0 * cosTheta;//z
            vPtr [1] = m_Scale*sinPhi0*m_Squash;//y
            vPtr [2] = m_Scale*cosPhi0 * sinTheta;//x

            //维度递增方向上层圆上一点
            vPtr [3] = m_Scale*cosPhi1 * cosTheta;
            vPtr [4] = m_Scale*sinPhi1*m_Squash;
            vPtr [5] = m_Scale* cosPhi1 * sinTheta;
            NSLog(@"x=%f y=%f z=%f",vPtr[2],vPtr[1],vPtr[0]);
            NSLog(@"xx=%f yy=%f zz=%f",vPtr[5],vPtr[4],vPtr[3]);
            vPtr += 2*3;

            texCoorderPtr[0] = (1.0/(float)m_Slices)*thetaIdx;
            texCoorderPtr[1] = (1.0/(float)m_Stacks)*phiIdx;

            texCoorderPtr[0] = (1.0/(float)m_Slices)*thetaIdx;
            texCoorderPtr[1] = (1.0/(float)m_Stacks)*(phiIdx+1);

            texCoorderPtr += 2*2;


        }
    }
    /***
        1      3
       | |   |  |
      |   | |    |
     0     2      4
     **/
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
