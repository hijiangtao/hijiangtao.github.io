---
date: 2014-04-05 20:50:00
layout: post
title: D3.js学习笔记：SVG制图与简单TSV数据呈现
thread: 104
categories: Tutorial
tags: [D3, 数据可视化]
excerpt: Tutorials of Learning D3.
---

##一、手动码表

在SVG上静态生成条形图：

```html
<!DOCTYPE html>
<style>

.chart rect {
  fill: steelblue;
}

.chart text {
  fill: white;
  font: 10px sans-serif;
  text-anchor: end;
}

</style>
<svg class="chart" width="420" height="120">
  <g transform="translate(0,0)">
	<rect width="40" height="19"></rect>
	<text x="37" y="9.5" dy=".35em">4</text>
  </g>
  <g transform="translate(0,20)">
	<rect width="80" height="19"></rect>
	<text x="77" y="9.5" dy=".35em">8</text>
  </g>
  <g transform="translate(0,40)">
	<rect width="150" height="19"></rect>
	<text x="147" y="9.5" dy=".35em">15</text>
  </g>
  <g transform="translate(0,60)">
	<rect width="160" height="19"></rect>
	<text x="157" y="9.5" dy=".35em">16</text>
  </g>
  <g transform="translate(0,80)">
	<rect width="230" height="19"></rect>
	<text x="227" y="9.5" dy=".35em">23</text>
  </g>
  <g transform="translate(0,100)">
	<rect width="420" height="19"></rect>
	<text x="417" y="9.5" dy=".35em">42</text>
  </g>
</svg>
```

----

##二、自动码表

```html
<!DOCTYPE html>
<meta charset="utf-8">
<style>

.chart rect {
  fill: steelblue;
}

.chart text {
  fill: white;
  font: 10px sans-serif;
  text-anchor: end;
}

</style>
<svg class="chart"></svg>
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script>

var data = [4, 8, 15, 16, 23, 42];

var width = 420,
	barHeight = 20;

var x = d3.scale.linear()
	.domain([0, d3.max(data)])
	.range([0, width]);

var chart = d3.select(".chart")
	.attr("width", width)
	.attr("height", barHeight * data.length);

var bar = chart.selectAll("g")
	.data(data)
  .enter().append("g")
	.attr("transform", function(d, i) { return "translate(0," + i * barHeight + ")"; });

bar.append("rect")
	.attr("width", x)
	.attr("height", barHeight - 1);

bar.append("text")
	.attr("x", function(d) { return x(d) - 3; })
	.attr("y", barHeight / 2)
	.attr("dy", ".35em")
	.text(function(d) { return d; });

</script>
```

注意样式表中定义的.chart样式，以及transform的使用，rect的增加是绘制图形，text是添加文字。

----

##三、批量数据处理

将以下信息存在tsv文件中（带空格分隔符的txt文件也可以），这样我们就可以批量从文件中读取数据并绘制可视化图表了。

>name	value
>Locke	4
>Reyes	8
>Ford	15
>Jarrah	16
>Shephard	23
>Kwon	42

有关TSV/CSV的信息可以查阅[D3.TSV](https://github.com/mbostock/d3/wiki/CSV)，以下为处理代码：

```html
<!DOCTYPE html>
<meta charset="utf-8">
<style>

.chart rect {
  fill: steelblue;
}

.chart text {
  fill: white;
  font: 10px sans-serif;
  text-anchor: end;
}

</style>
<svg class="chart"></svg>
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script>

var width = 420,
	barHeight = 20;

var x = d3.scale.linear()
	.range([0, width]);

var chart = d3.select(".chart")
	.attr("width", width);

d3.tsv("data.tsv", type, function(error, data) {
  x.domain([0, d3.max(data, function(d) { return d.value; })]);

  chart.attr("height", barHeight * data.length);

  var bar = chart.selectAll("g")
	  .data(data)
	.enter().append("g")
	  .attr("transform", function(d, i) { return "translate(0," + i * barHeight + ")"; });

  bar.append("rect")
	  .attr("width", function(d) { return x(d.value); })
	  .attr("height", barHeight - 1);

  bar.append("text")
	  .attr("x", function(d) { return x(d.value) - 3; })
	  .attr("y", barHeight / 2)
	  .attr("dy", ".35em")
	  .text(function(d) { return d.value; });
});

function type(d) {
  d.value = +d.value; // coerce to number
  return d;
}

</script>
```

以上读入了一个名为“data.tsv”的文件，其在脚本中处理后的结构呈现如下所示：

>var data = [
>  {name: "Locke",    value:  4},
>  {name: "Reyes",    value:  8},
>  {name: "Ford",     value: 15},
>  {name: "Jarrah",   value: 16},
>  {name: "Shephard", value: 23},
>  {name: "Kwon",     value: 42}
>];

同样需要注意的函数还有：`function(d) { return x(d.value); `，他会返回一个数值，具体由x()函数确定；最后一个函数type(d)用于类型转换。