---
date: 2014-04-07 11:00:00
layout: post
title: D3.js学习笔记：画圆实例
thread: 108
categories: Tutorial
tags: [D3, 数据可视化]
excerpt: Tutorials of Learning D3.
---

昨天莫名其妙的生病了，再加上D3还处于初级学习阶段，于是被各种效果显示不出来折腾疯了，想想还是自己太弱的缘故。网上的教程总是不太全（这里指的是中文教程），而英文原版书籍又太厚不知道从何看起，摸索中完成了下面这个小例子，实现的效果是根据绑定的数据来设定参数，然后画圆，并在圆中显示所画圆的编号。

对了，有关圆的绘制以下例子中没有体现圆的消除，所以还是记一下这个方法：`circle.exit().remove();`

```
	<!DOCTYPE html>
	<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<title>Test of D3.js</title>
		<meta charset="utf-8">
		<script src="js/d3.js" charset="utf-8"></script>
		<style type="text/css"></style>
	</head>
	<body>
		<script>

		var body = d3.select("body");
		body.style("color", "white");
		body.style("background-color", "black");
		
		var circledata = [32, 57, 112, 253];
		
		//创建一个SVG容器
		var svg = d3.select("body").append("svg");
		
		//g为类似于html中的一个div容器元素，在其中添加圆信息和文字信息
		var g = svg.selectAll("g")
			.data(circledata)
			.enter().append("g")
			.attr("transform", function(d) { return "translate(" + d*4 + "," + d*2 + ")";});
		
		//创建圆，圆心位置为g
		g.append("circle")
		.style("fill", "rgba(255, 24, 0, 1)")
		
		.attr("r", 30);
		
		//文字部分，返回值为d时则显示数据，返回值为i时则是序号
		//dy为行间距设置，fill为颜色设置
		g.append("text")
			.style("fill", "white")
			.attr("dy", ".35em")
			.attr("text-anchor", "middle")
			.text(function(d,i) { return i; });

		</script>
	</body>
	</html>
```

效果图如下所示：

![](/assets/2014-04-07-D3CircleExample.png "效果图")

最后如果想在圆上加入动画收缩效果可以选用如下代码：

```
circle.exit().transition()
    .attr("r", 0)
    .remove();
```

----

参考：[Circle绘制说明文档](http://mbostock.github.io/d3/tutorial/circle.html)