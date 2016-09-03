---
date: 2014-06-25 16:00:00
layout: post
title: D3笔记 - 处理数据
thread: 132
categories: Documents
tags: [D3, 数据可视化]
excerpt: 
---

上一周把《Getting Started with D3》看完了，书中内容比较浅显易懂于是没有记录太多笔记。这周开始看《Data Visualization with D3.js Cookbook》，边做边发现笔记真的很有用处，当有哪里不会的时候不可能再回去一页页的翻书，这时笔记就起到了关键性的作用。看完了第三章，整理一下有关处理数据方面的知识笔记。

----

## 定义数据——绑定数组

定义好一个数组后进行绑定是件比较简单的事情，也是最常见的D3中定义数据的方式。举个例子，我们看到多个数据存在一个数组里时，而此时你想用他们做可视化工作，并且在数组更新时希望可视化图像也随之更新。下面的内容就是介绍如何实现这一效果。

当然，我们需要首先定义一个数组元素：

```
var data = [10, 15, 30, 50, 80, 65, 55, 30, 20, 10, 8];
```

然后通过选择器将这些数据与html元素绑定，渲染函数中绑定部分如下：

```
d3.select("body").selectAll("div.h-bar") 
	.data(data) 
	.enter() 
		.append("div") 
			.attr("class", "h-bar")
		.append("span"); 

// Update
d3.select("body").selectAll("div.h-bar")
	.data(data) 
		.style("width", function (d) { 
			return (d * 3) + "px";
		})
		.select("span") 
			.text(function (d) {
				return d;
			});
		
// Exit
d3.select("body").selectAll("div.h-bar")
	.data(data)
	.exit() 
		.remove();        
```

函数中选中(selectAll)所有div.h-bar元素，并将其与需要绘制的数据绑定，每一个新增(append)的div元素都存放一个条形块，其宽度由数据本身决定。

二数据则可以通过随机数来产生，每隔1.5秒移除首行数据、新增一行随机产生的数据，这样使得图表具有实时更新的效果，移除通过**array.shift()**函数实现，而新增数据用**array.push()**加入现有数据中，而这些整体作为网页的呈现时，其刷新频率域函数的执行等细节可以使用**setInterval()**函数来实现。一个类似的案例代码如下所示：

```
setInterval(function () {
    data.shift();
    data.push(Math.round(Math.random() * 100));
    render(data);
}, 1500);
```

![](/assets/2014-06-25-DealingwithData-Note-1.png )

----

## 定义数据——对象文字（复杂数组）

要实现更加复杂的可视化操作，数据中的每个元素肯定都不会是单独的一个整数，可能都是一格格的JavaScript对象，而此时我们就要想想该如何用D3将这些数据可视化出来。

假设数据如下所示：

```
var data = [ // <- A
    {width: 10, color: 23},{width: 15, color: 33},
    {width: 30, color: 40},{width: 50, color: 60},
    {width: 80, color: 22},{width: 65, color: 10},
    {width: 55, color: 5},{width: 30, color: 30},
    {width: 20, color: 60},{width: 10, color: 90},
    {width: 8, color: 10}
];
```

那么我们想用width来定义长度，二color用来实现条形图的数据条颜色，该怎么做呢？因为数据绑定时绑定的成为了对象而不再是数组，所以我们可以通过d.x来访问对象中的x元素，比如：

```
d3.select("body").selectAll("div.h-bar")
    .data(data)
        .attr("class", "h-bar")
        .style("width", function (d) { 
            return (d.width * 5) + "px"; 
        })
        .style("background-color", function(d){
            return colorScale(d.color);
        })
    .select("span")
        .text(function (d) {
            return d.width;
        });
```

其中d.width和d.color均被使用到，而colorScale()函数由一个简单的线性变换函数转换而来：

```
var colorScale = d3.scale.linear()
    .domain([0, 100])
    .range(["#add8e6", "blue"]);
```

这样一来，不同的d.color就能呈现不同的颜色了，拒绝单调在可视化方面是个不错的设计。

![](/assets/2014-06-25-DealingwithData-Note-2.png )

----

## 定义数据——绑定函数

D3的一个好处就是他允许定义函数为数据，在一些特定场合下这个特色会给可视化工作带来强大的显示效果。

为了实现数据从函数生成，可以先定义一个空数组：

```
var data = [];
```

接下来写两个函数，分别实现函数长度的定义、数据增加的描述：

```
var next = function (x) {
	return 15 + x * x;
};

var newData = function () {  
	data.push(next);
	return data;
};
```

在定义好这些之后，使用时只需要我们在选择好元素后在数据绑定的参数时，调用这些函数即可，具体见以下代码中的**.data(newData);**和 **.text(function(d, i){ return d(i);……**

```
function render(){
	var selection = d3.select("#container")
				.selectAll("div")
				.data(newData); 

	selection.enter().append("div").append("span");

	selection.exit().remove();

	selection.attr("class", "v-bar")
		.style("height", function (d, i) {
			return d(i) + "px"; 
		})
		.select("span")
			.text(function(d, i){ 
				return d(i); 
			}); 
}
```

![](/assets/2014-06-25-DealingwithData-Note-3.png)

----

## 数据处理——数组

大部分时候我们处理数据，都需要对数据进行大量地格式化与重构工作，而D3提供了一系列对数组的操作函数，这使得相关工作变得轻松了许多。

下面列出几个使用方法，作为常见的数据操纵方法（"#xxx"表示选中的元素是个id而非class）：

```
//返回最小值
d3.select("#min").text(d3.min(array));

//返回最大值
d3.select("#max").text(d3.max(array));

//同时返回最小值和最大值
d3.select("#extent").text(d3.extent(array));

//返回计算的所有元素和
d3.select("#sum").text(d3.sum(array));

//返回中位数
d3.select("#median").text(d3.median(array));

//返回元素的平均值
d3.select("#mean").text(d3.mean(array));

//具体的排序方法，返回排序结果。
//其中ascending为升序排序，descending为降序排序。
d3.select("#asc").text(array.sort(d3.ascending));
d3.select("#desc").text(array.sort(d3.descending));

//对已经排好序的数组特定位置（例如0.25处）的数值进行提取
//举个例子就是数据有十个，而我参数设置为0.25，则执行支该步骤后返回的是第4个元素的数值。
d3.select("#quantile").text(
	d3.quantile(array.sort(d3.ascending), 0.25)
);

//用于提供多重嵌套的显示结构
d3.nest()
```

----

## 数据处理——过滤数据

假设你将所有的数据都显现出来了，但为了便于分析你想将特定信息的数据与其他数据区分开，高亮出来，D3提供了一个过滤函数用于实现这方面的功能。

**d3.filter()**

当使用这个函数时需要注意几点，其包含的函数参数有三种：

1. d: 你绑定的数据集；
2. i: 从0开始计数的索引数列；
3. this: 隐藏的指向当前DOM元素的指针；

样例代码：

```
filter(function(d, i)) {
    return d.category == category;
}
```

此函数的返回值是布尔类型。当返回值为true时，则符合规则的数据会被加入新的选择器中，作为新选择地数据用于绘制。而filter对待布尔类型的区分时并非严格意义上的布尔类型，意思即为flase,null,0,"",undefined,NaN这些均可以被视为不二的false类型。

以下为一个例子，其特意描红了一组数据，以此与其它数据进行区分：

![](/assets/2014-06-25-DealingwithData-Note-4.png)

----

## 数据加载——与服务器通信

我们不可能一直使用本地数据进行数据可视化的工作，更多的时候我们需要动态的加载来自网上实时的数据进行可视化数据相关的绘制工作，同时我们也希望其效果可以不断的更新，那么接下来讲讲如何在数据可视化工作中实现动态加载数据。
以加载本地json文件为例，这个工作其实还算简单，简单到我们把之前定义的var data换成如下代码：

```
d3.json("data.json", function(error, json){
	data = data.concat(json);  
	render(data);
});
```

如上所示，假设我们在同目录下有一个数据文件叫data.json,此时我们将现有数据与其进行合并（合并时用的函数是data.concat()），然后对这个数据进行绘制（render(data)）。

除此之外，你还可以使D3用相同的方法加载csv,tsv,txt,html,xml等数据。

----

**总结：**最后介绍的数据加载这部分虽然有这么多方法，但仍然可以不局限于这些进行数据读取，除了D3之外，你还可以任意使用其他你喜欢的JS库进行数据读取操作，比如jQuery或者Zepto.js，用他们来调度Ajax请求。

**注：**本文已经成功投稿至36大数据网站，欢迎访问[数据可视化教程——如何用D3操纵数据](http://www.36dsj.com/archives/9379)。