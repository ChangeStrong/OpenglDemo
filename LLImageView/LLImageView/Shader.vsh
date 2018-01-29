
attribute vec4 position;
attribute vec2 texCoord0;
varying  vec2 texCoordVarying; //可变变量 在顶点着色器和片段着色器互通  此处用户将纹理坐标传给片段着色器使用
void main (){
    texCoordVarying = texCoord0;

    gl_Position = position;
    

    
}
