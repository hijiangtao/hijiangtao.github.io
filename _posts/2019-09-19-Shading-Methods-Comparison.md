---
title: Flat、Gouraud、Phong Shading 着色方法对比
layout: post
thread: 231
date: 2019-09-19
author: Joe Jiang
categories: Document
tags: [2019, 可视化, WebGL, Shading, 着色方法]
excerpt: 当前，常见的三类多边形着色方法分别是 Flat Shading、Gouraud Shading 和 Phong Shading，一起来看看它们之间都有哪些区别。
---

当前，常见的三类多边形着色方法分别是 Flat Shading、Gouraud Shading 和 Phong Shading。其实从效果图就能看出它们之间大致的区别，以下为三类着色的效果图：

![](/assets/in-post/2019-09-19-Shading-Methods-Comparison.png )

## Shading: Phong vs Gouraud vs Flat

Flat shading 是最简单的着色模型，每个多边形只会呈现一个颜色，这个颜色由面法向量和光照计算得来。在该模型中，每个多边形中只有多边形的面存在法向量，而其各个顶点没有。

Phong shading 是三者之中最复杂的着色方法。它的特点是结合了多边形物体表面反射光的亮度，并以特定位置的表面法线作为像素参考值，以插值方式来估计其他位置像素的色值。在这种情况下，多边形中每个顶点都有一个法向量，通过这些法向量与光照计算，来得到每个点的颜色。在使用有限数量的多边形时，对定点法向量进行插值可以给出近似平滑的曲面效果，但是这样一来的计算量肯定是非常大的。

Gouraud shading 是三者中比较折衷的方法。类似 Phong shading，其多边形的每个顶点都有一个法向量，但它在着色时不是对向量进行插值。实际使用时，通常先计算多边形每个顶点的光照，再通过双线性插值计算三角形区域中其它像素的颜色。

第一种着色模型比较直观非常好理解，相比之下，后两个方法就显得有些难理解。虽然两个方法都需要应用多边形的法向量计算出其公共顶点的法向量，也都需要计算各顶点处的光强，但在逐像素计算上还是有所区别。

Phong shading 逐像素计算的思路可以理解为从顶点着色器传递过来的法向量，只是这一个顶点的法线方向，而到了片段着色器处理的阶段，每个像素所对应的向量由其周围几个顶点进行插值后得到，之后我们再用该像素点对应的法向量与光照进行计算，得到其着色，即上述所述，我们的插值是对法向量进行插值。而 Gouraud shading 的计算逻辑，我们则可以简单的理解成是对多边形的每个顶点计算好着色，然后再使用双线性插值方法对面上的像素进行计算。

## 参考与标注

* 双线性插值，又称为双线性内插。在数学上，双线性插值是对线性插值在二维直角网格上的扩展，用于对双变量函数进行插值。其核心思想是在两个方向分别进行一次线性插值。
* 由于片段着色器等 WebGL 概念，在本文中，多边形的概念等同于三角形。
* Phong shading <https://en.wikipedia.org/wiki/Phong_shading>
* Gouraud Shading <https://en.wikipedia.org/wiki/Gouraud_shading>
* Shading: Phong vs Gouraud vs Flat <https://computergraphics.stackexchange.com/questions/377/shading-phong-vs-gouraud-vs-flat>