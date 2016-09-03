---
date: 2014-04-05 19:00:00
layout: post
title: D3.js学习笔记：简单条形图制作
thread: 103
categories: Tutorial
tags: [D3, 数据可视化]
excerpt: Tutorials of Learning D3.
---

**D3简介**：D3.js is a JavaScript library for manipulating documents based on data. D3 helps you bring data to life using HTML, SVG and CSS. D3’s emphasis on web standards gives you the full capabilities of modern browsers without tying yourself to a proprietary framework, combining powerful visualization components and a data-driven approach to DOM manipulation.

----

## 一、元素选择

平常的程序如下所示：

```html
var div = document.createElement("div");
div.innerHTML = "Hello, world!";
document.body.appendChild(div);
```

通过使用D3.js的selector程序如下所示（网页全代码）：

```html
<!DOCTYPE html>
<meta charset="utf-8">
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<body>
<script>

var body = d3.select("body");
var div = body.append("div");
div.html("Hello, world!");

</script>
</body>
```

其中，d3.select的元素body可以替换成其他很多元素。

----

## 二、变换方法

selection.attr返回当前的选择内容，selection.append返回一个新内容。以下为一些示例：

* 改变body样式

```javascript
var body = d3.select("body");
body.style("color", "black");
body.style("background-color", "white");
```

* 添加一个新div（section需在样式表中提前定义）

```javascript
d3.selectAll("section")
	.attr("class", "special")
  .append("div")
	.html("Hello, world!");
```

----

## 三、手动码表

```html
<!DOCTYPE html>
<style>

.chart div {
  font: 10px sans-serif;
  background-color: steelblue;
  text-align: right;
  padding: 3px;
  margin: 1px;
  color: white;
}

</style>
<div class="chart">
  <div style="width: 40px;">4</div>
  <div style="width: 80px;">8</div>
  <div style="width: 150px;">15</div>
  <div style="width: 160px;">16</div>
  <div style="width: 230px;">23</div>
  <div style="width: 420px;">42</div>
</div>
```

----

## 四、自动码表

假设我们已经定义了chart的样式，则代码如下：

```javascript
d3.select(".chart")
  .selectAll("div")
	.data(data)
  .enter().append("div")
	.style("width", function(d) { return d * 10 + "px"; })
	.text(function(d) { return d; });
```

select是选中chart块，而selectAll是选中chart中的已有和之后可能有的div块，data是用于数据绑定，enter().append()是为现在不存在的元素增加div块，style是设置显示长度，text是设置显示文字内容。

为了让条形图的长度适合，我们可以定下一个范围，让数据根据自身大小自行处理。x轴的长度设置如下所示：

```javascript
var x = d3.scale.linear()
	.domain([0, d3.max(data)])
	.range([0, 420]);
```

自动填补长度的代码如下：

```javascript
d3.select(".chart")
  .selectAll("div")
	.data(data)
  .enter().append("div")
	.style("width", function(d) { return x(d) + "px"; })
	.text(function(d) { return d; });
```

总代码如下：

```html
<!DOCTYPE html>
<meta charset="utf-8">
<style>

.chart div {
  font: 10px sans-serif;
  background-color: steelblue;
  text-align: right;
  padding: 3px;
  margin: 1px;
  color: white;
}

</style>
<div class="chart"></div>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script>

var data = [4, 8, 15, 16, 23, 42];

var x = d3.scale.linear()
	.domain([0, d3.max(data)])
	.range([0, 420]);

d3.select(".chart")
  .selectAll("div")
	.data(data)
  .enter().append("div")
	.style("width", function(d) { return x(d) + "px"; })
	.text(function(d) { return d; });

</script>
```

