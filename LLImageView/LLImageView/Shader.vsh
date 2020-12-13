
attribute vec4 position;//存位置顶点数组
attribute vec2 texCoord0;//存纹理顶点数组
varying  vec2 texCoordVarying; //可变变量 在顶点着色器和片段着色器互通  此处用户将纹理坐标传给片段着色器使用
uniform mat4 modelViewProjectionMatrix;//统一变量 链接program之前获取地址然后初始化
void main (){
    texCoordVarying = texCoord0;

    gl_Position = modelViewProjectionMatrix * position;
    

    
}

/*
 attribute 可以理解为目前只用于顶点
 varying 顶点着色器里面的数据传到片段着色器
 uniform 外部传进来的变量
 */
