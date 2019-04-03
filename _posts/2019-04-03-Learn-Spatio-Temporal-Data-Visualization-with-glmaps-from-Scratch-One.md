---
title: 从零开始学习时空数据可视化（一）
layout: post
thread: 216
date: 2019-04-03
author: Joe Jiang
categories: Document
tags: [2019, WebGL, 可视化, three.js, deck.gl, 教程]
excerpt: glmaps 是一个包含多个时空数据可视化示例代码集与学习教程的开源项目。该项目中的可视化效果基于可视化库 three.js 与 deck.gl 实现，非常容易上手，希望本项目对正在时空可视化学习之路上探寻的你有所帮助。
header:
  image: ../assets/in-post/2019-04-03-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-One-Teaser.png
  caption: "@hijiangtao"
---

前言：本教程为「从零开始学习时空数据可视化」系列第一篇教程——three.js 简介与示例教学，主要通过一个简单示例教学让读者轻松上手 three.js 的一些基本 API。关于这个系列以及代码等细节可见：

* 项目 [GitHub](https://github.com/hijiangtao/glmaps) 地址，欢迎 watch 关注与 star 鼓励
* [从零开始学习时空数据可视化（序）](./2019/02/24/Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch/)
* [Zero to One: How I mastered Data Visualization and how you can too](https://medium.com/@hijiangtao/data-visualization-examples-and-tutorials-from-scratch-with-glmaps-2b93f478607f)

众所周知，得益于浏览器在 canvas 上实现了 WebGL 接口，开发者可以按照规范在 canvas 画布上建立场景、几何体与动画。WebGL 是基于 OpenGL ES 2.0 的 Web 标准，可以通过 HTML5 Canvas 元素作为 DOM 接口访问。但由于 WebGL (OpenGL ES) 的特殊性，基于 canvas 3D 上下文的开发相距常规的前端开发还是有不少差距，面对大量的 API 时，刚入门的同学大概率会被绕的头晕目眩。

本文将以一个实际的几何体动画 Demo 为例，来阐明两件事：

1. 初步了解 WebGL 的一些基本概念与 three.js 的基本内容；
2. 实战编写一个简单的几何体动画来熟悉 three.js 中的一些基本 API；

在描述过程中我会将涉及到的 API 全部标注出来，如果需要进一步了解可以复制到 MDN 或者 threejs.org 查看 API 文档。

## 一、WebGL 碎碎念

首先在正式使用一个 Web API 之前，你可以通过 <https://caniuse.com/> 这个网站查看当下浏览器对其的支持程度，比如 WebGL 的支持程度便如下图所示：

![](/assets/in-post/2019-04-03-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-One-1.png )

鉴于 WebGL 已经得到了各大浏览器的广泛支持，我们直接进入正题。你可以访问 <http://get.webgl.org/> 或者 <https://get.webgl.org/webgl2/> 网站来查看你的浏览器对 WebGL(2) 的支持情况。我简单写了一个函数，如果需要添加检测用户环境是否支持 WebGL 的逻辑，你可以在应用中调用如下函数：

```javascript
const detectWebGLContext = () => {
  let canvas = document.createElement("canvas");
  let gl = canvas.getContext("webgl")
    || canvas.getContext("experimental-webgl");

  let msgTxt = "无法检测到 WebGL 上下文，你的浏览器不支持 WebGL。";
  if (gl && gl instanceof WebGLRenderingContext) {
    msgTxt = "恭喜，你的浏览器支持 WebGL！";
  }
  
  alert(msgTxt);
}
```

还有一个有用的 API 组合方法，想想你在 canvas 上绘制完图像后，如何清除画布以便重新绘制其他图像呢？你可以试试如下函数，它的作用是通过一个单色清除整个区域内容：

```javascript
const clearWithColor = (gl) => {
  gl.viewport(
    0, 
    0,
    gl.drawingBufferWidth, 
    gl.drawingBufferHeight
  );

  gl.clearColor(0.0, 0.5, 0.0, 1.0);

  gl.clear(gl.COLOR_BUFFER_BIT);
}
```

简单介绍一下，代码第一行通过 `WebGLRenderingContext.viewport()` 方法设置了视口的范围，然后通过 `clearColor()` 设置清除色为绿色（只改变 WebGL 内部的一个状态，但并不会绘制任何东西），最后使用 `clear()` 方法实际绘制。

WebGL 暂时就说这么多，这些大致够我们继续往后看关于 three.js 的内容了。

## 二、初识 three.js

three.js 是一个轻量的 3D 可视化库，它通过抽象隐藏了 WebGL 的很多复杂性，使得在 Web 上构建 3D 场景变得非常简单。

![](/assets/in-post/2019-04-03-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-One-3.png )

说到 3D 场景，我们有一些概念需要提前了解：

1. 场景：是物体、光源等元素的容器；
2. 相机：场景中的相机，代替人眼去观察，场景中只能添加一个，决定哪些东西将在屏幕上渲染；
3. 物体对象：包括二维物体（点、线、面）、三维物体，模型等等，他们是在相机透视图里主要的渲染对象；
4. 光源：场景中的光照，如果不添加光照场景将会是一片漆黑，包括全局光、平行光、点光源等；
5. 渲染器：场景的渲染方式，如 WebGL/canvas2D/CSS3D；
6. 控制器：可通过键盘、鼠标控制相机的移动，用于交互；

关于 three.js 的一些详细介绍，可以参阅如下资源：

* three.js 官网 <https://threejs.org/>
* GitHub 地址 <https://github.com/mrdoob/three.js>
* Stack Overflow <https://stackoverflow.com/questions/tagged/three.js>
* Intro to WebGL with Three.js <http://davidscottlyons.com/threejs-intro/>
* three.js 在线编辑器<https://threejs.org/editor/>

## 三、上手简单动画示例

* 在线预览地址 [Online Demo](https://hijiangtao.github.io/glmaps/tutorials/example_three_geometry_hierarchy.html)
* 本文示例完整代码见 [GitHub](https://github.com/hijiangtao/glmaps/blob/master/tutorials/example_three_geometry_hierarchy.html)
* 项目地址 [glmaps](https://github.com/hijiangtao/glmaps)

开始敲代码之前，请准备好这几样东西：

1. 一个支持 WebGL 的浏览器（推荐 Chrome）
2. JavaScript 基础知识
3. 充满一颗好奇心

简单起见，我们的代码将全部放在一个 html 文件中，并且我们使用 CDN 地址引入 three.js 框架（本文引用 three.js v103），以下为我们初始化的 `index.html` 文件。

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <title>从零开始学习时空数据可视化示例 - glmaps</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
  <style>
    body {
      background: #fff;
      padding: 0;
      margin: 0;
      overflow: hidden;
    }
  </style>
</head>
<body>
  <div id="glmapsTitle" >
      从零开始学习时空数据可视化示例 <a href="https://github.com/hijiangtao/glmaps">GitHub 代码地址</a>
  </div>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/103/three.min.js"
    integrity="sha256-T4lfPbatZLyNhpEgCvtmXmlhOUq0HZHkDX4cMlQWExA=" crossorigin="anonymous"></script>

</body>

</html>
```

让我们先仔细看看，把一个随时间变化的几何体动画拆解一下，看看具体有哪些工作要做：

1. 场景、相机及需要绘制的几何体
2. 事件响应函数
3. three.js 渲染器与挂载元素
4. 渲染函数

我们一个个来看。three.js 提供有多种相机，本例中我们创建一个透视相机（API `THREE.PerspectiveCamera`），该相机投影类似人眼成像的模式，也是3D场景中最普通的投影模式。

```javascript
camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 1, 10000);
camera.position.z = 500;
```

接着是我们需要绘制的物体了。在本例中，我们准备绘制1000个立方体，它们大小相同、位置随机分布。我们可以直接绘制1000个几何体然后把他们依次加入场景，但为了更好的管理，我们用组（API `THREE.Group`）来作为这些立方体的容器，组在功能上和 `Object3D` 几乎是相同的，其目的是使得组中对象在语法上的结构更加清晰。

而每个立方体我们用网格（API `THREE.Mesh`）来构建，网格被用来表示基于以三角形为 polygon mesh（多边形网格）的物体的类。而传入的 Mesh 构造器的两个参数，一个是几何体（API `THREE.BoxBufferGeometry`），你可以简单把它想像成用于描述几何体的一个有效表述集合，比如顶点位置，面片索引、法相量、颜色值等等；另一个是材质（API `THREE.MeshNormalMaterial`），材质被用来描述几何体的外观呈现。

除此外，我们给 Mesh 添加一个x, y, z都分布在-1000到1000之间的随机位置，并加上一个随机旋转量。

```javascript
let geometry = new THREE.BoxBufferGeometry(100, 100, 100);
let material = new THREE.MeshNormalMaterial();
group = new THREE.Group();

for (let i = 0; i < 1000; i++) {
  let mesh = new THREE.Mesh(geometry, material);
  mesh.position.x = Math.random() * 2000 - 1000;
  mesh.position.y = Math.random() * 2000 - 1000;
  mesh.position.z = Math.random() * 2000 - 1000;
  mesh.rotation.x = Math.random() * 2 * Math.PI;
  mesh.rotation.y = Math.random() * 2 * Math.PI;
  mesh.matrixAutoUpdate = false;
  mesh.updateMatrix();
  group.add(mesh);
}
```

接着我们创建一个场景（API `THREE.Scene`），并把刚刚建立的对象组加入场景：

```javascript
const scene = new THREE.Scene();
scene.background = new THREE.Color(0xffffff);
scene.fog = new THREE.Fog(0xffffff, 1, 10000);

// 将对象组添加到场景中
scene.add(group);
```

到现在为止，我们都没有对 DOM 进行操作，接下来我们构建渲染器（API `THREE.WebGLRenderer`），并将通过 `.domElement` 属性得到的 canvas 元素添加到 DOM 中。

```javascript
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setPixelRatio(window.devicePixelRatio);
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);
```

我们可以通过 JavaScript 或者 CSS 改变 canvas 的尺寸，但这样一来原有的 canvas 内容可能就会模糊，由于前面的代码中我们用窗口尺寸来描述渲染器，当窗口尺寸变化时，我们需要重新设置渲染器的尺寸等属性：

```javascript
function onWindowResize() {
  windowHalfX = window.innerWidth / 2;
  windowHalfY = window.innerHeight / 2;
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

window.addEventListener('resize', onWindowResize, false);
```

至此，一个基本的 three.js 程序就写完了。但我们好像还差了些什么。是的，我们需要为这个场景添加动画，让它动起来。这个动画包含两个部分，一方面我们需要不断的更改物体的旋转位置，另一方面我们也准备不断变化相机的位置。canvas 的动画实现很简单，利用 `requestAnimationFrame` API 不断的绘制新的场景。在每次调用的渲染函数中，我们在每次更新时先算出相机偏移以及物体位置，然后更新它们的位置并重新调用渲染器渲染场景与相机。

```javascript
function render() {
  // 根据当前时间创建正弦偏移量
  let time = Date.now() * 0.001;
  let rx = Math.sin(time * 0.7) * 0.5,
    ry = Math.sin(time * 0.3) * 0.5,
    rz = Math.sin(time * 0.2) * 0.5;

  // 更新相机的坐标，并让相机面朝场景对准
  camera.position.x += (mouseX - camera.position.x) * 0.05;
  camera.position.y += (- mouseY - camera.position.y) * 0.05;
  camera.lookAt(scene.position);
  
  // 更新对象组的旋转坐标
  group.rotation.x = rx;
  group.rotation.y = ry;
  group.rotation.z = rz;
  
  // 
  renderer.render(scene, camera);
} 
```

记得调用相机的方法 `camera.lookAt(scene.position)` 让相机始终对着几何体。

效果图如下：

![](/assets/in-post/2019-04-03-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-One-2.png )

## 总结

总结一下，我们简单聊了下 WebGL，并对 three.js 的一些基本情况作了介绍。之后通过一个示例，我们接触到了场景、相机、渲染器、几何体、材质、对象组等概念，requestAnimationFrame API 以及更新几何体位置等属性的方法。

以上大致涵盖了一个 three.js 程序所会用到的大部分特性，但这些特性都有很多「变种」，比如几何体除了本文列出的 BoxBufferGeometry 外，还有 CircleBufferGeometry、ConeBufferGeometry、CylinderBufferGeometry、DodecahedronBufferGeometry、EdgesGeometry、ExtrudeBufferGeometry 等等。

但不要怕，想必通过本文你已经大致了解了如何编写一个 three.js 程序，万变不离其宗，你已经成功迈出了第一步。

在下一篇教程中，我们将会更进一步、详细探讨如何实现 [glmaps](https://github.com/hijiangtao/glmaps) 中截图的示例——星空地球。

![](/assets/in-post/2019-02-24-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-3.png )