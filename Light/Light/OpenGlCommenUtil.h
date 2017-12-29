//
//  OpenGlCommenUtil.h
//  Light
//
//  Created by luo luo on 29/12/2017.
//  Copyright © 2017 ChangeStrong. All rights reserved.
//

//#ifndef OpenGlCommenUtil_h
//#define OpenGlCommenUtil_h
#import <GLKit/GLKit.h>

typedef struct {
    //内部再放一个顶点结构体
    GLKVector3 position;
    //法向量坐标
    GLKVector3 normal;
}SceneVertex;

//三角形顶点结构体
typedef struct {
    SceneVertex vertices[3];
}SceneTriangle;

//设置一个三角形
SceneTriangle SceneTriangleMake(SceneVertex vertexA,SceneVertex vertexB,SceneVertex vertexC);
//锥体的所有顶点
static const SceneVertex vertexA = {{-0.5,0.5,-0.5},{0.0,0.0,1.0}};//左中下
static const SceneVertex vertexB = {{-0.5,0.0,-0.5},{0.0,0.0,1.0}};//左下
static const SceneVertex vertexC = {{-0.5,-0.5,-0.5},{0.0,0.0,1.0}};//左下下
static const SceneVertex vertexD = {{0.0,0.5,-0.5},{0.0,0.0,1.0}};
static const SceneVertex vertexE = {{0.0,0.0,0.0},{0.0,0.0,1.0}};
static const SceneVertex vertexF = {{0.0,-0.5,-0.5},{0.0,0.0,1.0}};
static const SceneVertex vertexG = {{0.5,0.5,-0.5},{0.0,0.0,1.0}};
static const SceneVertex vertexH = {{0.5,0.0,-0.5},{0.0,0.0,1.0}};
static const SceneVertex vertexI = {{0.5,-0.5,-0.5},{0.0,0.0,1.0}};

//八个面
#define NUM_FACES (8)

//8个面，每个面3个点，每个点有顶点坐标和顶点法线
//48个顶点，用于绘制8个面
#define NUM_NORMAL_LINE_VERTS (48)

//8个面，24个点，每个点需要2个顶点来画法向量，最后2个顶点是光照向量
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS + 2)
//以点0为出发点，通过叉积计算平面法向量
GLKVector3 SceneTriangleFaceNormal(
                                   const SceneTriangle triangle);
//计算三角形平面法向量，更新每个点的平面法向量
void SceneTrianglesUpdateFaceNormals(
                                     SceneTriangle someTriangles[NUM_FACES]);
//计算各三角形的法向量，通过平均值求出每个点的法向量
void SceneTrianglesUpdateVertexNormals(
                                       SceneTriangle someTriangles[NUM_FACES]);
//以每个顶点的坐标为起点，顶点坐标加上法向量的偏移值作为终点，更新法线显示数组
void SceneTrianglesNormalLinesUpdate(
                                     const SceneTriangle someTriangles[NUM_FACES],
                                     GLKVector3 lightPosition,
                                     GLKVector3 someNormalLineVertices[NUM_LINE_VERTS]);

//通过向量A和向量B的叉积求出平面法向量
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB);

//#endif /* OpenGlCommenUtil_h */

