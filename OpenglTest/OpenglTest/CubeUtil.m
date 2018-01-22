//
//  CubeUtil.m
//  OpenglTest
//
//  Created by luo luo on 18/01/2018.
//  Copyright © 2018 ChangeStrong. All rights reserved.
//

#import "CubeUtil.h"
//设置一个三角形顶点数组
SceneTriangle SceneTriangleMake(SceneVertex vertexA,SceneVertex vertexB,SceneVertex vertexC)
{
    SceneTriangle triangle = {vertexA,vertexB,vertexC};
    return triangle;
}

SceneQuadrilateral SceneQuadrilaterMake(SceneTriangle one,SceneTriangle two)
{
    SceneQuadrilateral quadrilateral = {one,two};
    return quadrilateral;
}
@implementation CubeUtil

@end
