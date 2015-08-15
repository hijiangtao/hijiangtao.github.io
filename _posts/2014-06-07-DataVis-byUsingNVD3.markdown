---
date: 2014-06-07 13:20:00
layout: post
title: 浅谈用NVD3实现轻量级数据可视化
thread: 128
categories: Documents
tags: [data, 数据可视化]
excerpt: 
---

最近花了些时间在了解与实践上，用JS库实现了一些数据的可视化效果，包括散点图、条形图、折线图之类的，对于轻量级的数据可视化呈现这简直赞呐。

最基础的当然是D3，Data-Driven Documents创建之初就是为了让数据来驱动可视化的呈现，最近尝试的也是将数据库中的数据表或者现有的csv/tsv/json等各种数据格式的文件导入前端进行可视化效果呈现。

自己写一些简单的测试数据用D3来做也不错，官方给的一些例子源码也都已经给出，但为了简短时间，我还是使用了另一个库——NVD3。其实也不算是另一个新事物，他基于D3做了代码的另一次封装，使得用数据进行可视化效果变得更加容易与简便，官方是这样介绍的：

>This project is an attempt to build re-usable charts and chart components for d3.js without taking away the power that d3.js gives you. This is a very young collection of components, with the goal of keeping these components very customizeable, staying away from your standard cookie cutter solutions.

那就以一个折线图为例，通过NVD3官方的一个例子来进行说明。这是一个正余弦的曲线图，最终呈现效果如下：

![](/assets/2014-06-07-DataVis-byUsingNVD3-1.png )

----

NVD3给他封装的功能特点包括：

* Ability to combine as many line series’ as you want.
* Tooltip which shows all visible series data.
* Line transitions that happen when turning on/off series, and when resizing chart.
* Can specify whether a series should be an area chart.

我简单粗暴的翻译一下就是：

1. 能够结合多条曲线绘制，即在一个折线图里实现多条信息线的呈现。
2. 把鼠标放在相应的轴上，该轴上的所有点信息均会在一个div块中呈现出来。
3. 多条曲线可以进行选择性呈现，并且在曲线条数更新时，曲线图的坐标轴范围也会随时更新，以适应最佳呈现效果。
4. 可以指定特定曲线是否设置为面积图。

----

以下来讲解一下这段效果的实现。其实，更确切的说应该是NVD3的用法，虽然说NVD3相当年轻，以至于主体部分可以认为还没开发完，但他强大的优点已经开始展现出来，感谢NVD3优秀的设计者们。

首先，我们当然需要一个html文件作为呈现页面，如果不嫌弃可以像我一样新建一个index.html，然后设置成如下这样：

```html
<!DOCTYPE html>
<meta charset="utf-8">
<head>
	<title>Data.Blog</title>
	<script src="./js/d3.js" charset="utf-8"></script>
	<script src="./js/nv.d3.js" charset="utf-8"></script>
	<link rel="stylesheet" type="text/css" href="./js/nv.d3.css" />
	<script src="./js/basic-chart.js" charset="utf-8"></script>
	<style>
	#chart svg {
	  height: 400px;
	  width: 600px;
	  float: none;
	}
	</style>						
</head>
<body>
    <div id="chart">
    	  <svg></svg>
    </div>
</body>
```

其中，d3.js、nv.d3.js、nv.d3.css三个文件需要你先下载在本地并放在新建的js文件夹中（当然，路径可以随便改，我这只是习惯），下载地址如下：

[D3.js下载地址](https://github.com/mbostock/d3/releases/download/v3.4.8/d3.zip)

[NVD3下载地址](https://codeload.github.com/novus/nvd3/legacy.zip/master)

下载完之后，新建一个basic-chart.js文件，然后开始编写我们的绘制函数与数据处理函数。

nvd3用addGraph()封装了绘图的入口，首先我们需要定义一个变量，让它接受我们的绘图信息，由于我们画的是折线图，所以使用models里的linechart()来定义：

```javascript
var chart = nv.models.lineChart();
```

为了使图表美观一些，我们增加margin值，并且开启鼠标操作信息提示以及坐标轴与坐标信息的呈现，这一段代码完整如下：

```javascript
var chart = nv.models.lineChart()
            .margin({left: 100})  //Adjust chart margins to give the x-axis some breathing room.
            .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
            .transitionDuration(350)  //how fast do you want the lines to transition?
            .showLegend(true)       //Show the legend, allowing users to turn on/off line series.
            .showYAxis(true)        //Show the y-axis
            .showXAxis(true)        //Show the x-axis
;
```

坐标的格式设定：axisLabel()用来显示相应坐标轴信息标签，tickFormat()则来处理坐标轴数据的格式，相关各种格式的说明在d3的github官方文档里已经有相对详细的说明，这里就不再详说。x轴与y轴的设定类似，这一段代码完整定义如下：

```javascript
chart.xAxis     //Chart x-axis settings
  .axisLabel('Time (ms)')
  .tickFormat(d3.format(',r'));

chart.yAxis     //Chart y-axis settings
  .axisLabel('Voltage (v)')
  .tickFormat(d3.format('.02f'));
```

然后定义数据来源与sinAndCos()函数：

```javascript
var myData = sinAndCos();
```

那么，现在开始我们最重要的一个环节，选择svg元素并将data载入进行绘制，这是很简单的一步，也是应该NVD3帮我们做了很多简化D3的事情，select用来选择元素，datum用来选择数据，call用来调用绘制函数（我暂时是这么理解的，不知道这一块是否有说错的地方），代码如下：

```javascript
d3.select('#chart svg')    //Select the <svg> element you want to render the chart in.   
  .datum(myData)         //Populate the <svg> element with chart data...
  .call(chart);          //Finally, render the chart!
```

对于窗口改变时，我们的图表也应该进行相应的更新，所以我们增加如下代码：

```javascript
nv.utils.windowResize(function() { chart.update() });
  return chart;
```

以下则为正弦余弦数据生成器，当我们需要使用json或者数据库数据时，只需要在数据选择时将我们的信息替换掉这个函数，然后稍作修改即可。考虑到我们做数据可视化注重的是自然数据，而非人工生成的数据，这里的sinAndCos函数也是为了方便才定义的，所以直接贴上NVD3这段代码，不再详述。

```javascript
function sinAndCos() {
  var sin = [],sin2 = [],
      cos = [];

  //Data is represented as an array of {x,y} pairs.
  for (var i = 0; i < 100; i++) {
    sin.push({x: i, y: Math.sin(i/10)});
    sin2.push({x: i, y: Math.sin(i/10) *0.25 + 0.5});
    cos.push({x: i, y: .5 * Math.cos(i/10)});
  }

  //Line chart data should be sent as an array of series objects.
  return [
    {
      values: sin,      //values - represents the array of {x,y} data points
      key: 'Sine Wave', //key  - the name of the series.
      color: '#ff7f0e'  //color - optional: choose your own line color.
    },
    {
      values: cos,
      key: 'Cosine Wave',
      color: '#2ca02c'
    },
    {
      values: sin2,
      key: 'Another sine wave',
      color: '#7777ff',
      area: true      //area - set to true if you want this line to turn into a filled area chart.
    }
  ];
}
```

----

到这里，所有的工作就完成了，刷新一下浏览器里的index.html效果应该就出来了。如果我们取消一个黄色曲线的呈现，效果就变成如下这样了：

![](/assets/2014-06-07-DataVis-byUsingNVD3-2.png )

----

**总结**：写在最后，总是有那么几句概括性的话想说说。使用过D3的人再来看这篇文章大都会觉得不可思议吧，NVD3使用起来实在是太简便了，不是吗？但是不可否认的一点：NVD3实在是太年轻了。虽然使用方便布局精美，但是现有函数与样式还是有限，并且我在尝试让更多数据格式进行可视化时也遇到了一些难以解决的问题，比如NVD3对json格式的要求在nvd3定义里就有一个length的设计缺陷。我暂且这么叫吧，可能是我没太理解透彻，也可能是开发者还没开发完善好这一部分。所以，我的建议是可以用NVD3多多尝试，但要放到现实来看，作为数据可视化的学习者，主要工作应该还是学习D3。当然，如果感兴趣，可以和开发者们一起开发NVD3。

**最后，感谢无数默默无私奉献的开源爱好者。**