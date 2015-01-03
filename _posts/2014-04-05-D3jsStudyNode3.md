---
date: 2014-04-05 21:10:00
layout: post
title: D3.js学习笔记：条形图绘制方向转换与优化
thread: 105
categories: Tutorial
tags: [D3, 数据可视化]
excerpt: Tutorials of Learning D3.
---

##一、行列转换

代码：

```
	<!DOCTYPE html>
	<meta charset="utf-8">
	<style>

	.chart rect {
	  fill: steelblue;
	}

	.chart text {
	  fill: white;
	  font: 10px sans-serif;
	  text-anchor: middle;
	}

	</style>
	<svg class="chart"></svg>
	<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
	<script>

	var width = 960,
		height = 500;

	var y = d3.scale.linear()
		.range([height, 0]);
		/*范围不再采用0-width，而是height-0*/

	var chart = d3.select(".chart")
		.attr("width", width)
		.attr("height", height);

	d3.tsv("data.tsv", type, function(error, data) {
	  y.domain([0, d3.max(data, function(d) { return d.value; })]);

	  var barWidth = width / data.length;

	  var bar = chart.selectAll("g")
		  .data(data)
		.enter().append("g")
		  .attr("transform", function(d, i) { return "translate(" + i * barWidth + ",0)"; });/*条形线绘画位置*/

	  bar.append("rect")/*条形线高度与宽度*/
		  .attr("y", function(d) { return y(d.value); })
		  .attr("height", function(d) { return height - y(d.value); })
		  .attr("width", barWidth - 1);

	  bar.append("text")/*文字添加*/
		  .attr("x", barWidth / 2)
		  .attr("y", function(d) { return y(d.value) + 3; })
		  .attr("dy", ".75em")
		  .text(function(d) { return d.value; });
	});

	function type(d) {
	  d.value = +d.value; // coerce to number
	  return d;
	}

	</script>
```

采用如下代码可以实现X坐标的排序：

```
	var x = d3.scale.ordinal()
		.domain(["A", "B", "C", "D", "E", "F"])
		.rangeRoundBands([0, width], .1);
```

但对于第三个参数.1的使用不是很理解，是实现坐标单位表示的位置右移么？原作者的解释是：

>If width is 960, x("A") is now 0 and x("B") is 160, and so on. These positions serve as the left edge of each bar, while x.rangeBand() returns the width of each bar. But rangeBands can also add padding between bars with an optional third argument, and the rangeRoundBands variant will compute positions that snap to exact pixel boundaries for crisp edges.

以下是采用[array.map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map) 和 [array.sort](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort)的代码：

```
	<!DOCTYPE html>
	<meta charset="utf-8">
	<style>

	.chart rect {
	  fill: steelblue;
	}

	.chart text {
	  fill: white;
	  font: 10px sans-serif;
	  text-anchor: middle;
	}

	</style>
	<svg class="chart"></svg>
	<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
	<script>

	var width = 960,
		height = 500;

	var x = d3.scale.ordinal()
		.rangeRoundBands([0, width], .1);

	var y = d3.scale.linear()
		.range([height, 0]);

	var chart = d3.select(".chart")
		.attr("width", width)
		.attr("height", height);

	d3.tsv("data.tsv", type, function(error, data) {
	  x.domain(data.map(function(d) { return d.name; }));
	  y.domain([0, d3.max(data, function(d) { return d.value; })]);

	  var bar = chart.selectAll("g")
		  .data(data)
		.enter().append("g")
		  .attr("transform", function(d) { return "translate(" + x(d.name) + ",0)"; });

	  bar.append("rect")
		  .attr("y", function(d) { return y(d.value); })
		  .attr("height", function(d) { return height - y(d.value); })
		  .attr("width", x.rangeBand());

	  bar.append("text")
		  .attr("x", x.rangeBand() / 2)
		  .attr("y", function(d) { return y(d.value) + 3; })
		  .attr("dy", ".75em")
		  .text(function(d) { return d.value; });
	});

	function type(d) {
	  d.value = +d.value; // coerce to number
	  return d;
	}

	</script>
```

----

##二、边距设定

对于一个960*500的图标框，边界设定可以如下所示：

```
	var margin = {top: 20, right: 30, bottom: 30, left: 40},
		width = 960 - margin.left - margin.right,
		height = 500 - margin.top - margin.bottom;
```

SVG容器的设定则为：

```
	var chart = d3.select(".chart")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
	  .append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
```

----

##三、添加坐标轴

在图表底部定义坐标轴：

```
	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom");

	chart.append("g")
		.attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")")
		.call(xAxis);
```

设置好需要在样式表里添加：

```
	.axis text {
	  font: 10px sans-serif;
	}

	.axis path,
	.axis line {
	  fill: none;
	  stroke: #000;
	  shape-rendering: crispEdges;
	}
```

完整代码：

```
	<!DOCTYPE html>
	<meta charset="utf-8">
	<style>

	.bar {
	  fill: steelblue;
	}

	.axis text {
	  font: 10px sans-serif;
	}

	.axis path,
	.axis line {
	  fill: none;
	  stroke: #000;
	  shape-rendering: crispEdges;
	}

	.x.axis path {
	  display: none;
	}

	</style>
	<svg class="chart"></svg>
	<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
	<script>

	var margin = {top: 20, right: 30, bottom: 30, left: 40},
		width = 960 - margin.left - margin.right,
		height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
		.rangeRoundBands([0, width], .1);

	var y = d3.scale.linear()
		.range([height, 0]);

	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom");

	var yAxis = d3.svg.axis()
		.scale(y)
		.orient("left");

	var chart = d3.select(".chart")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
	  .append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	d3.tsv("data.tsv", type, function(error, data) {
	  x.domain(data.map(function(d) { return d.name; }));
	  y.domain([0, d3.max(data, function(d) { return d.value; })]);

	  chart.append("g")
		  .attr("class", "x axis")
		  .attr("transform", "translate(0," + height + ")")
		  .call(xAxis);

	  chart.append("g")
		  .attr("class", "y axis")
		  .call(yAxis);

	  chart.selectAll(".bar")
		  .data(data)
		.enter().append("rect")
		  .attr("class", "bar")
		  .attr("x", function(d) { return x(d.name); })
		  .attr("y", function(d) { return y(d.value); })
		  .attr("height", function(d) { return height - y(d.value); })
		  .attr("width", x.rangeBand());
	});

	function type(d) {
	  d.value = +d.value; // coerce to number
	  return d;
	}

	</script>
```

----

##四、互动呈现

```
	<!DOCTYPE html>
	<meta charset="utf-8">
	<style>

	.bar {
	  fill: steelblue;
	}

	.bar:hover {
	  fill: brown;
	}

	.axis {
	  font: 10px sans-serif;
	}

	.axis path,
	.axis line {
	  fill: none;
	  stroke: #000;
	  shape-rendering: crispEdges;
	}

	.x.axis path {
	  display: none;
	}

	</style>
	<body>
	<script src="http://d3js.org/d3.v3.min.js"></script>
	<script>

	var margin = {top: 20, right: 20, bottom: 30, left: 40},
		width = 960 - margin.left - margin.right,
		height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
		.rangeRoundBands([0, width], .1);

	var y = d3.scale.linear()
		.range([height, 0]);

	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom");

	var yAxis = d3.svg.axis()
		.scale(y)
		.orient("left")
		.ticks(10, "%");

	var svg = d3.select("body").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
	  .append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	d3.tsv("data.tsv", type, function(error, data) {
	  x.domain(data.map(function(d) { return d.letter; }));
	  y.domain([0, d3.max(data, function(d) { return d.frequency; })]);

	  svg.append("g")
		  .attr("class", "x axis")
		  .attr("transform", "translate(0," + height + ")")
		  .call(xAxis);

	  svg.append("g")
		  .attr("class", "y axis")
		  .call(yAxis)
		.append("text")
		  .attr("transform", "rotate(-90)")
		  .attr("y", 6)
		  .attr("dy", ".71em")
		  .style("text-anchor", "end")
		  .text("Frequency");

	  svg.selectAll(".bar")
		  .data(data)
		.enter().append("rect")
		  .attr("class", "bar")
		  .attr("x", function(d) { return x(d.letter); })
		  .attr("width", x.rangeBand())
		  .attr("y", function(d) { return y(d.frequency); })
		  .attr("height", function(d) { return height - y(d.frequency); });

	});

	function type(d) {
	  d.frequency = +d.frequency;
	  return d;
	}

	</script>
```

data.tsv可以采用如下数据也可以自行编写：

>letter	frequency

>A	.08167

>B	.01492

>C	.02782

>D	.04253

>E	.12702

>F	.02288

>G	.02015

>H	.06094

>I	.06966

>J	.00153

>K	.00772

>L	.04025

>M	.02406

>N	.06749

>O	.07507

>P	.01929

>Q	.00095

>R	.05987

>S	.06327

>T	.09056

>U	.02758

>V	.00978

>W	.02360

>X	.00150

>Y	.01974

>Z	.00074