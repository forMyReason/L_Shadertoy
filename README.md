# L_Shadertoy
上班敲敲shadertoy，打发时间用...



## 0. 工具汇总
- https://www.desmos.com/calculator?lang=zh-CN
- https://www.desmos.com/matrix?lang=zh-CN
- https://www.wolframalpha.com/
- https://www.wolframalpha.com/input/?i=%5B%5Bcos%28t%29%2C-sin%28t%29%5D%2C%5Bsin%28t%29%2Ccos%28t%29%5D%5D+*%5Bx%2Cy%5D
- https://registry.khronos.org/OpenGL-Refpages/gl4/html/mix.xhtml
- https://zhuanlan.zhihu.com/p/52287086


## 使用SDF画一个圆
- 调整圆形比例，不随着窗口改变纵横比
- 使用iTime让圆随着时间改变颜色
- 让圆移动
- 空心圆【？】

## 画正方形
- 怎么让正方向不管怎么拖动，正方形都在所有屏幕中间？
- 让正方向旋转

## 多个2D形状的混合
- mix / lerp
- 2D SDF就是公式
- 两次mix混合多种形状
- 最好的sdf就是返回距离，每个draw不反悔vec3
- 新增渐变背景

## 2D SDF
- 常见的各种2D SDF公式
- 2D SDF 操作

## 6. RayMarching
- 坐标系
    - shadertoy采用右手坐标系。
    - x 轴沿画布的水平轴，y 轴沿画布的垂直轴，并假设摄像机朝向 -z
- 光线算法之间的区别
    - ray casting
    - ray marching
    - ray tracing
    - path tracing
- RayMarching原理
    - https://www.youtube.com/watch?v=nMAgogUyv3E
    - https://www.desmos.com/calculator/ragaytzefw


## 7.1 绘制多个3D对象
- 添加多个物体
    - 使用 min 对 sdSphere 返回的最近距离操作
- 添加地板