---
title: 从零开始学习时空数据可视化（序）
layout: post
thread: 214
date: 2019-02-24
author: Joe Jiang
categories: Document
tags: [2019, WebGL, 可视化, three.js, deck.gl, 教程]
excerpt: glmaps 是一个包含多个时空数据可视化示例代码集与学习教程的开源项目。该项目中的可视化效果基于可视化库 three.js 与 deck.gl 实现，非常容易上手，希望本项目对正在时空可视化学习之路上探寻的你有所帮助。

---

前言：没有什么特殊的原因、也不是要靠这个赚钱（毕竟是免费的），只是在以往的学习过程中非常感谢很多开发者的无私奉献，包括代码、问题解答以及文章，于是自己也萌生了类似的念头，希望在记录自己学习收获的同时，也能帮到一些朋友吧。

本文结构安排如下：

* 0 / 为什么会有这个系列
* 1 / 学习指北
* 2 / 效果演示
* 3 / 可视化示例
* 4 / 可视化教程
* 5 / 自问自答
* 6 / 几则故事

## 0 / 为什么会有这个系列

我经常被问到「我很喜欢数据可视化，我该如何入门呢？」，我曾在问题「[国内有哪些成熟的做前端数据可视化的团队，做工程的前端加入需要补充什么知识](https://www.zhihu.com/question/267808191/answer/329205003)」以及「[数据可视化工程师未来的路在何方](https://www.zhihu.com/question/279234059/answer/405490525)」说过我自己的一些小感受，但发现这些似乎不能解决所有疑惑。

你可能因为诸如「相机与可视区是什么，坐标世界如何转换」等问题而止步向前，即便 three.js 已经在 WebGL 上友好的封装了一层 API。事实如此，当你对图形学领域一些基本概念还没了解，你在入门时一定会遇到不少疑惑。究其原因，其实每个人精力有限。虽然基于 Web 的图形绘制接口依旧是 SVG 与 canvas，但其背后的标准仍在稳步向前。WebGL (OpenGL ES) 作为一个光栅化引擎，本质只包含两类着色器，但背后仍蕴藏如此多的内容。

如果你是一名数据可视化爱好者，但苦于没有相关基础，那么「从零开始学习时空数据可视化」这个系列便是完全为你准备的，让我们开始吧。

![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/glmaps.png )

## 1 / 学习指北

先说一句，这个系列是免费的。希望在帮助大家的同时，我们相互学习。

我为从零开始学习时空数据可视化系列创建了一个 GitHub 仓库，所有相关代码、文档以及教程都会放在一起，我给他取名叫 glmaps。如果你觉得值得关注可以点个 **watch** 接受邮件订阅提醒，如果从中有所收获也欢迎点个 **star** 鼓励一下。

![](/assets/in-post/2019-02-24-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-1.png )

- 项目地址 [GitHub](https://github.com/hijiangtao/glmaps)
- 中文说明 [README](https://github.com/hijiangtao/glmaps/blob/master/CN.md)

简单来说，`glmaps` 是一个包含多个时空数据可视化示例代码集与学习教程的开源项目。该项目中的可视化效果基于可视化库 `three.js` 与 `deck.gl` 实现，非常容易上手，希望本项目对正在时空可视化学习之路上探寻的你有所帮助。

希望通过 `glmaps` 的系列示例与教程，可以让你在使用 three.js 与 deck.gl 时能更加自信地创作出更好的可视化作品。

## 2 / 效果演示

废话不多说，我录制了一段短视频用于展现 `glmaps` 的可视化效果，你可以在 [YouTube](https://youtu.be/dddmamIAYj8) 或者[腾讯视频](https://v.qq.com/x/page/x0841840qwl.html)查看。

腾讯视频对画质压缩的非常严重，建议查看时打开超清模式，否则极有可能出现「两米开外，人畜不分」的马赛克效果。

## 3 / 可视化示例

`glmaps` 现包含有如下几种可视化形式，更多案例正在丰富中。其中 `2.5D` 意指在2D地图上绘制2D或者3D的物体，`3D` 意指完全在三维空间中实现时空数据的可视化效果。

|类型|描述|效果|支持动画|支持聚类|
|---|---|---|---|---|
|[3D / Curve](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js)|THREE.BufferGeometry()| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/Globe-Curve.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js) | Yes | No |
|[3D / Mover](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js)|THREE.SphereGeometry()| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/Globe-Point.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js) | Yes | No |
|[3D / Cube](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js)|THREE.BoxGeometry()| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/Globe-Cube.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js) | No | No |
|[2.5D / Icon](https://github.com/hijiangtao/glmaps/blob/master/src/layers/IconLayer/index.js)|No modification from deck| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/IconLayer.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/layers/IconLayer/index.js) | No | Yes |
|[2.5D / Brush](https://github.com/hijiangtao/glmaps/blob/master/src/layers/ArcLayer/animate.js)|Support OD Arc Animation| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/BrushArcLayer.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/layers/ArcLayer/animate.js) | Yes | No |
|[2.5D / Scatter](https://github.com/hijiangtao/glmaps/blob/master/src/layers/ScatterplotLayer/index.js)|Support Fade-out Animation| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/ScatterplotLayer.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/layers/ScatterplotLayer/index.js) | Yes | No |
|[2.5D / Hexagon](https://github.com/hijiangtao/glmaps/blob/master/src/layers/HexagonLayer/index.js)|Support Coverage Filter Conditions| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/HexagonLayer.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/layers/HexagonLayer/index.js) | Yes | Yes |
|[2.5D / Grid](https://github.com/hijiangtao/glmaps/blob/master/src/layers/ScreenGridLayer/index.js)|Support Coverage Filter Conditions| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/ScreenGridLayer.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/layers/ScreenGridLayer/index.js) | No | Yes |
|[2.5D / Trip](https://github.com/hijiangtao/glmaps/blob/master/src/layers/TripLayer/index.js)|No modification from deck| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/TripLayer.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/layers/TripLayer/index.js) | Yes | No |
|[Other / Segment](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js)|The same as curve animation| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/Globe-CurveSegment.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js) | Yes | No |
|[Other / Moon](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js)|Earth-Moon System| [![](https://github.com/hijiangtao/glmaps/raw/master/assets/screenshots/Globe-Moon.jpeg)](https://github.com/hijiangtao/glmaps/blob/master/src/globe/index.js) | Yes | No |

## 4 / 可视化教程

暂定八篇系列教程，如有需要可以提 [issue]((https://github.com/hijiangtao/glmaps/issues/new)) 讨论。

* 从零开始学习时空可视化（零） / three.js 入门笔记 - TBD
* 从零开始学习时空可视化（一） / deck.gl 入门笔记 - TBD
* 从零开始学习时空可视化（二） / 用 React 框架管理你的 three.js 项目 - TBD
* 从零开始学习时空可视化（三） / 用 three.js 画出你的第一个地球 - TBD
* 从零开始学习时空可视化（四） / 深入浅出 three.js 点、线、面、体的实现过程 - TBD
* 从零开始学习时空可视化（五） / 利用 props 与 transitions 让你的 deck.gl 图层动起来 - TBD
* 从零开始学习时空可视化（六） / 手写 shader 给你的 deck.gl 动画另辟蹊径 - TBD
* 从零开始学习时空可视化（七） / 使用 three.js 和 deck.gl 开发的踩坑记录 - TBD

在完成这些学习后，你将可以独立实现如上列出的几种可视化形式作品，而个人认为这些形式已经大致包含了基本的时空可视化类型。

## 5 / 自问自答

首先感谢你对 `glmaps` 项目的关注。在你进一步阅读本项目之前，想对你说的一些话。

**Q1: 除了列出的可视化框架，`glmaps` 项目还用到了哪些 Web 技术?**

从 16.8.0 开始，**Hooks** 便正式登陆 React，`glmaps` 在开发过程中也从中受益很多。如果你还不了解 React Hooks，建议先查看 [Introducing Hooks](https://reactjs.org/docs/hooks-intro.html) 了解大概，因为 `glmaps` 在多处使用到了各类 Hooks。另一方面，由于 deck.gl 利用了 **WebGL2** 特性进行可视化绘制，所以在查看 demo 前请确保你的浏览器支持这项技术。你可以通过 <http://get.webgl.org/> 或者 <https://get.webgl.org/webgl2/> 网站来查看你的浏览器对 WebGL(2) 的支持情况。  

![](/assets/in-post/2019-02-24-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-2.png )

除此外，由于 `glmaps` 未采用类似 create-react-app 这样成熟的脚手架进行搭建，而是我按需在构建流程上对 webpack 及 Babel 中的功能进行组合，因此在打包构建方面一定还存在诸多需要继续完善的地方。若你在本地运行 Demo 时遇到任何报错，我相信这都可能是 `glmaps` 本身的问题，而非你的问题，欢迎通过 [issues](https://github.com/hijiangtao/glmaps/issues/new) 和我交流讨论。

**Q2: 可视化初学者该如何利用这个项目学习？**

我比较建议你采用如下顺序配合 `glmaps` 进行学习：
  - 先学习如何在你的项目中引入 three.js 以及 deck.gl，了解基本的使用、项目创建，这部分内容直接在 three.js 与 deck.gl 官网便可找到。尝试根据教程，试试画出你的第一个图形；
  - 大概扫一下这两个框架的主 API 都有哪些，并试试下些官方 demo 在本地运行，感受下这些框架在实现可视化上的巨大能力；
  - 跟着「从零开始学习时空数据可视化系列」教程一步步把 glmaps 中涉及到的可视化案例都实现一遍；如果你对 three.js 与 deck.gl 有过一定的尝试，你也可以直接参考我在 `src` 文件夹中抽象出的代码；
  - （可选）尝试通过 `npm install glmaps --save` 在你的 demo 中引入 glmaps 进行展现；
  - 按照你的理解重写 `glmaps` 示例代码，并为他添加更多特性；
  - 恭喜你已经成功入门基本的时空数据可视化编程！你现在可以更加深入地了解 three.js 或者 deck.gl，并更加自信地创作出更好的可视化作品。

**Q3: 如何参与到 `glmaps` 项目中来？**

`glmaps` is still at the very beginning period of my thoughts, you are welcome to oepn ISSUE, PR or email me, if you have any ideas on how to make `glmaps` better for visualization beginners:
  - Participate in implementing tutorials together;
  - Contribute codes to `glmaps` with [PR](https://github.com/hijiangtao/glmaps/pulls) (such as imporve `mover` animation in `Globe`);
  - Speak out your doubts in learning data visualization with [issues](https://github.com/hijiangtao/glmaps/issues/new);
  - Tell me your advice on how to make `glmaps` better with [issues](https://github.com/hijiangtao/glmaps/issues/new);
  - Other aspects not included yet.

## 6 / 几则故事

**故事一**

前两天云舒在朋友圈的动态突然成了热点新闻，其中我非常赞同第一句的后半句「特地写出来大家看到，省得我改变心意」，`glmaps` 也是在这种环境下诞生的。

不要误解，我不离婚，我只是想说即便 `glmaps` 还处于初期阶段，我仍决定现在把它分享出来。起初，这个想法诞生于两个多月前，我曾在问题「[作为前端工程师的你在深入研究哪些领域？](https://www.zhihu.com/question/303354718/answer/558177026)」中说到新的一年要多搞搞数据可视化，但由于工作忙碌与天生懒惰，于是一直在给自己找往后拖延的借口。

现在把它分享出来，一方面是代码层面在基本功能上已完善，另一方面是想通过公开来鞭策自己按时完成剩余文章的编写，即「自我催更」。

**故事二**

由于平时还有工作要完成，所以如何分配时间呢？我觉得忙是件好事，一定程度上可以刺激你提高自我时间管理能力，所以我会利用好晚上及周末的时间来逐步完善这个项目，step by step。

另外，由于各种原因我也很久没尝试过 three.js 了，所以怎么说呢，还是那句话：希望在帮助大家的同时，我们相互学习。欢迎更有经验的同学多多指教！

更多本文未提到的内容欢迎移步 [GitHub](https://github.com/hijiangtao/glmaps) 啦！

![](/assets/in-post/2019-02-24-Learn-Spatio-Temporal-Data-Visualization-with-glmaps-from-Scratch-3.png )