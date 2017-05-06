---
title: Three.js 入门与扫盲-基础结构,坐标系与几何类型介绍
layout: post
thread: 172
date: 2017-05-03
author: Joe Jiang
categories: documents
tags: [Visualization, JavaScript, threejs]
excerpt: WebGL 是基于 OpenGL ES 2.0 的 Web 标准，可以通过 HTML5 Canvas 元素作为 DOM 接口访问。Three.js 封装了底层的的图形操作接口,使用户可以便捷的操作构建空间物体与场景,实现 3D 可视化. 一个完整的 Three.js 必定包含一些必要的结构,例如场景,相机等等,而在深入了解 Three.js 及相关操作之前,有几个概念有必要完整的学习一遍. 本文基于此目的, 详细的描述了一个完整的 Three.js 程序的基本结构, 空间坐标系以及汇总了常用的 Three.js 中的几何类型.
---

WebGL 是基于 OpenGL ES 2.0 的 Web 标准，可以通过 HTML5 Canvas 元素作为 DOM 接口访问。Three.js 封装了底层的的图形操作接口,使用户可以便捷的操作构建空间物体与场景,实现 3D 可视化. 一个完整的 Three.js 必定包含一些必要的结构,例如场景,相机等等,而在深入了解 Three.js 及相关操作之前,有几个概念有必要完整的学习一遍. 本文基于此目的, 详细的描述了一个完整的 Three.js 程序的基本结构, 空间坐标系以及汇总了常用的 Three.js 中的几何类型.

 
*注: 本笔记记载内容基于 Three.js r85 实现.*

## Three.js 基础结构与分析

一个典型的 Three.js 程序至少包括 渲染器、场景、照相机、以及场景中创建的物体。

* three.js 支持多种渲染器, 其中主要的为 CanvasRenderer 和 WebGLRenderer; 设置渲染器的代码一般包括: 用 `new Renderer()` 来新建一个WebGL渲染器, `renderer.setSize(width,height)` 来设置渲染器的宽高(或者给 canvas 元素设定宽高, 注意 CSS 指定是无效的且 canvas 元素有默认宽高值), 用 `renderer.setClearColor(clearColor,clearAlpha)` 设置 canvas 背景色与透明度, 用 `renderer.render()` 操作渲染绘制过程;
* 我们需要渲染的物体在初始化之后需要添加到场景(Scene)中, 场景提供了添加/删除物体的方法, 同时也涵盖添加雾效果以及材质覆盖等方法; 在场景和相机都设置好的情况下, 只要将 scene 和 camera 交给 Three.js 的 Renderer ，渲染操作就开始了;
* 照相机分为两种, 使用**透视投影照相机**获得的结果是类似人眼在真实世界中看到的有“近大远小”的效果（如下图左图）；而使用**正交投影照相机**获得的结果就像我们在数学几何学课上老师教我们画的效果，对于在三维空间内平行的线，投影到二维空间中也一定是平行的（如下图中右图）

![](/assets/in-post/2017-05-03-Three-js-Introduction-Study-Note-1.png )

```
@PerspectiveCamera https://threejs.org/docs/index.html#api/cameras/PerspectiveCamera
@OrthographicCamera https://threejs.org/docs/index.html#api/cameras/OrthographicCamera
THREE.OrthographicCamera(left, right, top, bottom, near, far)
THREE.PerspectiveCamera(fov, aspect, near, far)
```

* 在创建物体时，需要传入两个参数，一个是几何形状（Geometry），另一个是材质（Material）。

## 坐标系

Three.js 采用右手坐标系, 如下图所示:

![](/assets/in-post/2017-05-03-Three-js-Introduction-Study-Note-4.jpg )

## 矩阵变换

在三维图形学中,几何变换大致分为三种,平移变换(Translation),缩放变换(Scaling),旋转变换(Rotation).

* [矩阵](http://www.opengl-tutorial.org/cn/beginners-tutorials/tutorial-3-matrices/) - opengl-tutorial
* [Matrix4](https://threejs.org/docs/#api/math/Matrix4) - three.js
* 三维顶点为三元组(x,y,z),引入一个新的分量w，得到向量(x,y,z,w): 若w=1，则向量(x, y, z, 1)为空间中的点;若w=0，则向量(x, y, z, 0)为方向;
* 三维图形学中我们只用到4x4矩阵，它能对顶点(x,y,z,w)作变换。这一变换是用矩阵左乘顶点来实现的：矩阵\*顶点= 变换后的顶点;
* 将三维空间中的一个点 `[x, y, z, 1]` 移动到另外一个点 `[x', y', z', 1]` ，三个坐标轴的移动分量分别为 `dx=Tx, dy=Ty, dz=Tz`;
* 平移变换矩阵的逆矩阵与原来的平移量相同但是方向相反;
* 旋转变换矩阵的逆矩阵与原来的旋转轴相同但是角度相反;
* 缩放变换的逆矩阵正好和原来的效果相反，如果原来是放大，则逆矩阵是缩小，如果原来是缩小，则逆矩阵是放大;
* 累积变换的顺序: 先缩放,接着旋转,最后平移;

```
TransformedVector = TranslationMatrix * RotationMatrix * ScaleMatrix * OriginalVector;
```

## Geometry 几何形状类型汇总

[Geometry#Three.js](https://threejs.org/docs/index.html#api/core/Geometry) 是所有几何形状的基类, 用户也可以操作继承该类用于自定义形状的定义和绘制, 常见的 Three.js 中几何形状包括立方体,柱体,球体等等.

* **BoxGeometry** 是四边形几何类, 它通常用给定的长宽高参数构造立方体或不规则四边形(CubeGeometry 也可以实现相同效果,但在 Three.js 中该函数已被删除);

```
THREE.BoxGeometry(width, height, depth, widthSegments, heightSegments, depthSegments)
```

* **PlaneGeometry** 是平面类, 其实是一个长方形，而不是数学意义上无限大小的平面;

```
THREE.PlaneGeometry(width, height, widthSegments, heightSegments)
```

* **SphereGeometry** 是球体类, 构造函数如下所示 ( `radius` 是半径； `segmentsWidth` 表示经度上的切片数； `segmentsHeight` 表示纬度上的切片数； `phiStart` 表示经度开始的弧度； `phiLength` 表示经度跨过的弧度； `thetaStart` 表示纬度开始的弧度； `thetaLength` 表示纬度跨过的弧度), 其中需要注意的是在使用时可以根据经纬度切片数来定制球形外形, 可以通过经纬度弧度来定制球形起始形状;

```
THREE.SphereGeometry(radius, segmentsWidth, segmentsHeight, phiStart, phiLength, thetaStart, thetaLength)
```

* **CircleGeometry** 几何类可以创建圆形或者扇形;

```
THREE.CircleGeometry(radius, segments, thetaStart, thetaLength)
```

![](/assets/in-post/2017-05-03-Three-js-Introduction-Study-Note-2.png )

* **CylinderGeometry** 表示柱体类, 构造函数如下所示( `radiusTop` 与 `radiusBottom` 分别是顶面和底面的半径，由此可知，当这两个参数设置为不同的值时，实际上创建的是一个圆台； `height` 是圆柱体的高度； `radiusSegments` 与 `heightSegments` 可类比球体中的分段； `openEnded` 是一个布尔值，表示是否没有顶面和底面，缺省值为false，表示有顶面和底面);

```
THREE.CylinderGeometry(radiusTop, radiusBottom, height, radiusSegments, heightSegments, openEnded)
```

* **TetrahedronGeometry** / 正四面体、**OctahedronGeometry** / 正八面体、**IcosahedronGeometry** / 正二十面体的构造函数分别如下所示;

```
THREE.TetrahedronGeometry(radius, detail)
THREE.OctahedronGeometry(radius, detail)
THREE.IcosahedronGeometry(radius, detail)
```

* **TorusGeometry** 即圆环面, 也为甜甜圈的形状;

```
THREE.TorusGeometry(radius, tube, radialSegments, tubularSegments, arc)
```

* **TorusKnotGeometry** / 圆环结, 形如打了结的甜甜圈;

```
THREE.TorusKnotGeometry(radius, tube, radialSegments, tubularSegments, p, q, heightScale)
```

![](/assets/in-post/2017-05-03-Three-js-Introduction-Study-Note-3.png )

* **ExtrudeGeometry** 几何类, 用于从一条路径中抽取出特征用于构建几何形状;

```
THREE.ExtrudeGeometry(shapes, options)
```

* **ConeGeometry** 锥形几何类;

```
THREE.ConeGeometry(radius, height, radialSegments, heightSegments, openEnded, thetaStart, thetaLength)
```

* Three.js 还提供了很多其他几何类, 详情可以在 Three.js 文档搜索框中输入 `Geometry` 关键字, 查看 Geometries 下栏目.

## 其他: 光与影

* three.js 中常用的四种光源模型为环境光、平行光、点光源、聚光灯;
* 在Three.js中，能形成阴影的光源只有THREE.DirectionalLight与THREE.SpotLight；而相对地，能表现阴影效果的材质只有THREE.LambertMaterial与THREE.PhongMaterial。因而在设置光源和材质的时候，一定要注意这一点;

## 参考

* [three.js / docs](https://threejs.org/docs/index.html#manual/introduction/Creating-a-scene)
* [Three.js 入门指南](http://www.ituring.com.cn/article/47975)
* [three.js右手坐标系， 显示和线条](http://www.cnblogs.com/Yimi/p/6007811.html)
* [Intro to WebGL with Three.js](http://davidscottlyons.com/threejs/presentations/frontporch14/)