//
//  TriangeleVC2.m
//  OpenglTest
//
//  Created by luo luo on 15/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

#import "TriangeleVC2.h"

//定义顶点结构体 (也可以存入其它额外信息)
typedef struct {
    //内部再放一个顶点结构体
    GLKVector3 positioncoords;
}SceneVertex;

@interface TriangeleVC2 ()
//渲染后期相关装饰 颜色等控制
@property(nonatomic, strong) GLKBaseEffect *baseeffect;
@end

static const SceneVertex vertices[] = {
    {{-0.5,-0.5,0.0}},
    {{0.5f,-0.5f,0.0}},
    {{-0.5f,0.5f,0.0}},
};
@implementation TriangeleVC2{
    GLuint vertexBufferId;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //将当前vc的的view的上下文配置好 -- 运行时会拿出来按它自己的上下文来渲染
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //当前的渲染使用view的上下文
    [EAGLContext setCurrentContext:view.context];
    self.baseeffect = [[GLKBaseEffect alloc]init];
    self.baseeffect.useConstantColor = GL_TRUE;
    //使用白色渲染整体三角形
    self.baseeffect.constantColor = GLKVector4Make(1.0f,//red
                                                   1.0f,//green
                                                   1.0f,//blue
                                                   1.0f);
    //设置用来清除的颜色
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    //将顶点缓存起来 缓存在gpu
    glGenBuffers(1, &vertexBufferId);//生成缓存标识
    glBindBuffer(GL_ARRAY_BUFFER,//缓存的东西是顶点
                 vertexBufferId);//接下来的运算 使用被标记的缓存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices,
                 GL_STATIC_DRAW //缓存内的数据会频繁发生变化
                 );
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   // [super glkView:view drawInRect:rect];
    [self.baseeffect prepareToDraw];
    
    //清楚缓存内的附加缓存 用原来上下文中设置的颜色来清除
    glClear(GL_COLOR_BUFFER_BIT);
    //是view的上下文中缓存的顶点生效
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //告知顶点数据位置 已经是用SceneVertex存储的
    glVertexAttribPointer(GLKVertexAttribPosition,//缓存信息包含顶点位置信息
                          3,//每个位置有3部分x,y,z
                          GL_FLOAT,
                          GL_FALSE,//小数点固定数据是否可以被改变 否
                          sizeof(SceneVertex),//每个顶点占的步幅
                          NULL //从当前缓存的开始位置访问顶点
                          );
    //绘制数组内的顶点
    glDrawArrays(GL_TRIANGLES,
                 0, //第一个顶点位置
                 3 //顶点数量
                 );
    
    
}

//-(void)viewDidUnload
//{
//    [super viewDidUnload];
//    GLKView *view = (GLKView *)self.view;
//    [EAGLContext setCurrentContext:view.context];
//    //清楚缓存的顶点
//    if (0!= vertexBufferId) {
//        glDeleteBuffers(1, &vertexBufferId);
//        vertexBufferId = 0;
//    }
//
//    ((GLKView *)self.view).context = nil;
//    [EAGLContext setCurrentContext:nil];
//}


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
