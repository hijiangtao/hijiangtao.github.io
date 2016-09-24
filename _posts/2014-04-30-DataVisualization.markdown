---
date: 2014-04-30 21:00:00
layout: post
title: 大数据利器：浅谈数据可视化
thread: 116
categories: Documents
tags: [data, 数据可视化]
excerpt: 
---

**前言**: 什么是数据可视化？数据可视化主要旨在借助于图形化手段，清晰有效地传达与沟通信息。为了有效地传达思想概念，美学形式与功能需要齐头并进，通过直观地传达关键的方面与特征，从而实现对于相当稀疏而又复杂的数据集的深入洞察。

这意味面对一大堆杂乱的数据你无法嗅觉其中的关系，但通过可视化的数据呈现，你能很清晰的发觉其中价值。在经过一阶段的数据分析平台搭建工作后，结合比赛，我开始了对数据可视化的研究，结合几篇对可视化技术与工具的描述，以下整理出一些数据可视化的资料与知识，以供参考。

----

## 一、数据源类型

* One-dimensional data /  Points
* Two-dimensional data / Tables
* Multidimensional data / Relational Tables
* Text and hypertext
* Hierarchies and graphs / Telephone calls and Web documents
* Algorithms and software

----

## 二、可视化手段

* Standard 2D/3D displays

![](/assets/in-post/2014-04-30-DataVisualization-01.png)

* Geometrically transformed displays

![](/assets/in-post/2014-04-30-DataVisualization-02.png)

* Icon-based displays

![](/assets/in-post/2014-04-30-DataVisualization-03.png)

* Dense pixel displays
* Stacked displays

----

## 三、可视化工具汇总

### 3.1 简易图表

1.DataWrapper: 一个非常漂亮的在线服务，上传数据并快速生成图表后，就可以到处使用或将其嵌入在自己的站点中。这个服务最初定位于专栏记者，而实际上任何人都可以使用。 DataWrapper 在新版本浏览器中可以显示动态图表，而在旧版本浏览器中则显示静态图片。

Page: <http://datawrapper.de/>

![](/assets/in-post/2014-04-30-DataVisualization-04.png)

2.Flot: 一个基于jQuery 的绘图库，使用HTML 的canvas 元素，也支持旧版本浏览器（甚至IE6）。它支持有限的视觉形式（折线、散点、条形、面积），但使用很简单。

Page: <http://www.flotcharts.org/>

3.Google Chart Tools

4.gRaphaël: 与Flot 相比，它更灵活，而且还要更漂亮一些。

Page: <http://g.raphaeljs.com/>
 
![](/assets/in-post/2014-04-30-DataVisualization-05.png)

5.Highcharts JS: JavaScript 图表库，包含一些预定义的主题和图表。它在最新浏览器中使用SVG， 而在旧版本IE（包括IE6 及更新版本）中使用后备的VML。

Page: <http://www.highcharts.com/>
 
![](/assets/in-post/2014-04-30-DataVisualization-06.png)

6.JavaScript InfoVis Toolkit: 简称JIT，它提供了一些预设的样式可用于展示不同的数据，包括很多例子，而文档的技术味道太浓。

Page: <http://philogb.github.io/jit/index.html>

![](/assets/in-post/2014-04-30-DataVisualization-01.png)

7.jqPlot: jQuery 绘图插件，只支持一些简单的图表，适合不需要自定义样式的情况。

8.jQuery Sparklines: 可生成波形图的jQuery 插件，主要是那些可以嵌在字里行间的小条形图、折线图、面积图。支持大多数浏览器，包括IE6。

9.Peity: jQuery 插件，可生成非常小的条形图、折线图和饼图，只支持较新版本的浏览器。再强调一遍，它能生成非常小又非常精致的小型可视化图表。

Page: <http://benpickles.github.com/peity/>

![](/assets/in-post/2014-04-30-DataVisualization-07.png)
 
10.Timeline.js: 专门用于生成交互式时间线的一个库。不用编写代码，只用其代码生成器即可；只支持IE8及以后的版本。

### 3.2 图谱可视（具有网络结构的数据）

1.Arbor.js: 基于jQuery 的图谱可视化库，连它的文档都是用这个工具生成的（可见它有多纯粹、多meta）。这个库使用了HTML 的canvas 元素，因此只支持IE9 和其他较新的浏览器，当然也有一些针对旧版浏览器的后备措施。

Page: <http://arborjs.org/> 
 
![](/assets/in-post/2014-04-30-DataVisualization-08.png)

2.Sigma.js: 一个非常轻量级的图谱可视化库。无论如何，你得看看它的网站，在页面上方的大图上晃几下鼠标，然后再看看它的演示。Sigma.js 很漂亮，速度也快，同样使用canvas。

Page: <http://sigmajs.org/>
 
![](/assets/in-post/2014-04-30-DataVisualization-09.png)

### 3.3 地图映射（包括地理位置数据或地理数据）

1.Kartograph: Gregor Aisch 开发的一个基于JavaScript 和Python 的非常炫的、完全使用矢量的库，它的演示是必看的。最好现在就去看一看。保证你从来没见过这么漂亮的在线地图。Kartograph 支持IE7 及更新版本。

Page: <http://kartograph.org/>

![](/assets/in-post/2014-04-30-DataVisualization-10.png)

2.Leaflet: 贴片地图的库，可以在桌面和移动设备上流畅地交互。它支持在地图贴片上显示一些SVG 数据层（参见Mike 的演示"Using D3 with Leaflet"：<http://bost.ocks.org/mike/leaflet/> )。 Leaflet 支持IE6（勉强）或IE7（好得多），当然还有其他更新版本的浏览器。

Page: <http://leafletjs.com/> 

3.Modest Maps: 作为贴片地图库中的老爷爷，Modest Maps 已经被Polymaps 取代了，但很多人还是喜欢它，因为它体积小巧，又支持IE 和其他浏览器的老版本。Modest Maps 有很多版本， 包括ActionScript、Processing、Python、PHP、Cinder、openFrameworks…… 总之，它属于老当益壮那种。

Page: <http://modestmaps.com/>

4.Polymaps: 显示贴片地图的库，在贴片上可以叠加数据层。Polymaps 依赖于SVG，因此在较新的浏览器中表现很好。

Page: <http://polymaps.org/>

### 3.4 原始绘图（高级定制）

1.D3.js

![](/assets/in-post/2014-04-30-DataVisualization-11.png)

2.Processing.js
 
![](/assets/in-post/2014-04-30-DataVisualization-12.png)
 
![](/assets/in-post/2014-04-30-DataVisualization-13.png)

3.Paper.js: 在canavs 上渲染矢量图形的框架。同样，它的网站也堪称互联网上最漂亮的网站之一，它们的演示做得让人难以置信。

Page: <http://paperjs.org/>
 
![](/assets/in-post/2014-04-30-DataVisualization-14.png)

4.Raphaël: 一个绘制矢量图形的库。

Page: <http://raphaeljs.com/>
 
![](/assets/in-post/2014-04-30-DataVisualization-15.png)

### 3.5 三维图形

1.PhiloGL: 专注于3D 可视化的一个WebGL 框架。

Page: <http://www.senchalabs.org/philogl/>
 
![](/assets/in-post/2014-04-30-DataVisualization-16.png)

2.Three.js: 能帮你生成任何3D 场景的一个库，谷歌Data Arts 团队出品。

Page: <http://mrdoob.github.com/three.js/> 

![](/assets/in-post/2014-04-30-DataVisualization-17.png)

----

数据可视化之路，路漫漫其修远兮啊。