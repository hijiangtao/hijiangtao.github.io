---
title: WebGL 基础概念摘要（上）
layout: post
thread: 213
date: 2019-02-01
author: Joe Jiang
categories: Document
tags: [2019, WebGL, GLSL, 可视化]
excerpt: 翻阅 WebGL Fundamentals 时碎碎记录下 WebGL 基础概念一些细节。

---

## 一、概念基础

WebGL 实质上是一个光栅化引擎，根据你的代码绘制出点，线和三角形。

* 成对方法：在 GPU 上运行的 WebGL 代码需要是成对的方法，每对方法中一个叫顶点着色器， 另一个叫片断着色器，用 GLSL 编码。每一对组合起来称作一个 program（着色程序）。
* 属性（Attributes）和缓冲：缓冲是发送到 GPU 的一些二进制数据序列，通常情况下缓冲数据包括位置，法向量，纹理坐标，顶点颜色值等。属性用来指明怎么从缓冲中获取所需数据并将它提供给顶点着色器。
* 全局变量（Uniforms）：在着色程序运行前赋值，在运行过程中全局有效。
* 纹理（Textures）：纹理是一个数据序列，可以在着色程序运行中随意读取其中的数据。
* 可变量（Varyings）：是一种顶点着色器给片断着色器传值的方式。

WebGL 每次绘制需要两个着色器， 一个顶点着色器和一个片断着色器，每一个着色器都是一个方法。 一个顶点着色器和一个片断着色器链接在一起放入一个着色程序中（或者只叫程序）。一个典型的 WebGL 应用会有多个着色程序。

* 顶点着色器需要的数据，获取方式分三种：
  - Attributes 属性 (从缓冲中获取的数据)
  - Uniforms 全局变量 (在一次绘制中对所有顶点保持一致值)
  - Textures 纹理 (从像素或纹理元素中获取的数据)
* 片段着色器所需的数据，获取方式分三种：
  - Uniforms 全局变量 (values that stay the same for every pixel of a single draw call)
  - Textures 纹理 (data from pixels/texels)
  - Varyings 可变量 (data passed from the vertex shader and interpolated)
* GLSL 是门强类型语言，以下是一些用法枚举：

```glsl
// vec2, vec3和 vec4分别代表两个值，三个值和四个值
vec4 a = vec4(1, 2, 3, 4);
vec4 b = a * 2.0;
// b 现在是 vec4(2, 4, 6, 8);

// mat2, mat3 和 mat4 分别代表 2x2, 3x3 和 4x4 矩阵
mat4 a = ???
mat4 b = ???
mat4 c = a * b;

vec4 v;
// v.x 和 v.s 以及 v.r ， v[0] 表达的是同一个分量。
// v.y 和 v.t 以及 v.g ， v[1] 表达的是同一个分量。
// v.z 和 v.p 以及 v.b ， v[2] 表达的是同一个分量。
// v.w 和 v.q 以及 v.a ， v[3] 表达的是同一个分量。

v.yyyy // === vec4(v.y, v.y, v.y, v.y)
v.bgra // === vec4(v.b, v.g, v.r, v.a)
vec4(1) // === vec4(1, 1, 1, 1)
// 支持矢量调制

// 如果 v1 和 v2 都是 vec4, f 是浮点型，以下两个变量等价
vec4 m = mix(v1, v2, f);

vec4 m = vec4(
  mix(v1.x, v2.x, f),
  mix(v1.y, v2.y, f),
  mix(v1.z, v2.z, f),
  mix(v1.w, v2.w, f));
```

## 二、二维变换

对于二维变换使用 3x3 矩阵，可以快速的实现平移，旋转，缩放，单位化效果。

```javascript
var m3 = {
  translation: function(tx, ty) {
    return [
      1, 0, 0,
      0, 1, 0,
      tx, ty, 1,
    ];
  },
 
  rotation: function(angleInRadians) {
    var c = Math.cos(angleInRadians);
    var s = Math.sin(angleInRadians);
    return [
      c,-s, 0,
      s, c, 0,
      0, 0, 1,
    ];
  },
 
  scaling: function(sx, sy) {
    return [
      sx, 0, 0,
      0, sy, 0,
      0, 0, 1,
    ];
  },
  identity: function() {
    return [
      1, 0, 0,
      0, 1, 0,
      0, 0, 1,
    ];
  },
};
```

关于如下一个矩阵计算，有两种解释方式：

```javascript
projectionMat * translationMat * rotationMat * scaleMat * position
```

从右向左解释：首先将位置乘以缩放矩阵获得缩放后的位置，然后将缩放后的位置和旋转矩阵相乘得到缩放旋转位置，然后将缩放旋转位置和平移矩阵相乘得到缩放旋转平移位置，最后和投影矩阵相乘得到裁剪空间中的坐标。

从左往右解释：每一个矩阵改变的都是画布的坐标空间， 画布的起始空间是裁剪空间的范围(-1 到 +1)，矩阵从左到右改变着画布所在的空间。

## 三、三维变换

* WebGL 中的三角形有正反面概念，通过下面代码可以开启不绘制背面三角形（顺时针方向）的特性。

```
gl.enable(gl.CULL_FACE);
```

* 深度缓冲（DEPTH BUFFER）：WebGL 绘制一个着色像素之前会检查对应的深度像素， 如果对应的深度像素中的深度值小于当前像素的深度值，WebGL 就不会绘制新的颜色。 反之它会绘制片断着色器提供的新颜色并更新深度像素中的深度值。如下命令可以开启这个特性：

```
gl.enable(gl.DEPTH_TEST);
```

* 三维矩阵相比二维多一行一列，(x,y,z,w) 中 w 可以用于透视投影（近大远小）处理。
* 日常观察的物体都应是透视投影，而非正射投影。

## 四、动画与纹理

实现动画与 WebGL 并不直接相关，需要利用 JavaScript 随着时间改变一些值然后绘制。在此处请使用 requestAnimationFrame API.

* GPU 在绘制时使用的是一个纹理贴图，它是一个逐渐缩小的图像集合， 每一个是前一个的四分之一大小（方法：双线性插值）。`gl.generateMipmap` 做的事情就是根据原始图像创建所有的缩小级别。使用 `generateMipmap` 时需注意纹理的维度必须是2的整数次幂。

由于纹理需要异步加载资源，所以在物体渲染上存在两种处理方式。

* 纹理图集：将多个图像通过一个纹理提供的方法，即将图像放在一个纹理中，然后利用纹理坐标映射不同的图像到每个面。

## 五、组织结构

一个 WebGL 应用推荐遵循的结构

* 初始化阶段
  * 创建所有着色器和程序并寻找参数位置
  * 创建缓冲并上传顶点数据
  * 创建纹理并上传纹理数据
* 渲染阶段
  * 清空并设置视图和其他全局状态（开启深度检测，剔除等等）
  * 对于想要绘制的每个物体（此处可抽象复用）
    * 调用 `gl.useProgram` 使用需要的程序
    * 设置物体的属性变量
      * 为每个属性调用 `gl.bindBuffer`, `gl.vertexAttribPointer`, `gl.enableVertexAttribArray`
    * 设置物体的全局变量
      * 为每个全局变量调用 `gl.uniformXXX`
      * 调用 `gl.activeTexture` 和 `gl.bindTexture` 设置纹理到纹理单元
      * 调用 `gl.drawArrays` 或 `gl.drawElements`
