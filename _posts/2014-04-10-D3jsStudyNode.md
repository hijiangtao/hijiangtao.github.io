---
date: 2014-04-10 23:00:00
layout: post
title: D3.js学习笔记：模式更新实例
thread: 111
categories: Tutorial
tags: [D3, 数据可视化]
---

利用一个例子在代码中添加了很多中文注释，实现D3下的基本模式更新，用以解释他的原理。

**exit()用法**：

>Returns the exiting selection: existing DOM elements in the current selection for which no new data element was found. This method is only defined on a selection returned by the data operator. The exiting selection defines all the normal operators, though typically the main one you'll want to use is remove; the other operators exist primarily so you can define an exiting transition as desired. Note that the exit operator merely returns a reference to the exiting selection, and it is up to you to remove the new nodes.

**enter()用法**：

>Returns the entering selection: placeholder nodes for each data element for which no corresponding existing DOM element was found in the current selection. This method is only defined on a selection returned by the data operator. In addition, the entering selection only defines append, insert, select and call operators; you must use these operators to instantiate the entering nodes before modifying any content. (Enter selections also support empty to check if they are empty.) Note that the enter operator merely returns a reference to the entering selection, and it is up to you to add the new nodes.

----

测试代码：

{% highlight javascript %}
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<title>Test of D3.js</title>
	<meta charset="utf-8">
	<!-- 调用d3.js库 -->
	<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
	<style type="text/css">

	text {
	  font: bold 48px monospace;
	  align: center;
	}

	.enter {
	  fill: green;
	  align: center;
	}

	.update {
	  fill: #333;
	  align: center;
	}

	</style>
</head>
<body>
	<script>

	//创建字符串并将一个字符串分割成字符串数组
	var alphabet = "abcdefghijklmnopqrstuvwxyz".split("");

	//定义宽度和高度
	var width = 960,
		height = 500;

	//基于svg画布新建元素g
	var svg = d3.select("body").append("svg")
		.attr("width", width)
		.attr("height", height)
	  .append("g")
		.attr("transform", "translate(32," + (height / 2) + ")");

	function update(data) {

	  // DATA JOIN
	  // 数据绑定
	  var text = svg.selectAll("text")
		  .data(data);

	  // UPDATE
	  text.attr("class", "update");

	  // ENTER
	  // 对新文字进行元素生成
	  // 注意enter()与exit()两个函数的使用方法
	  text.enter().append("text")
		  .attr("class", "enter")
		  .attr("x", function(d, i) { return i * 32; })//文字位置,从添加填补的位置开始
		  .attr("dy", ".35em");

	  // ENTER + UPDATE
	  text.text(function(d) { return d; });

	  // EXIT
	  // 删除旧的未使用到的元素
	  text.exit().remove();
	}

	// 初始化显示模块.
	update(alphabet);

	// 以字典序显示一段随机分隔的文字块.
	// setInterval() 方法可按照指定的周期（以毫秒计）来调用函数或计算表达式。它会不停地调用函数，直到 clearInterval() 被调用或窗口被关闭。由 setInterval() 返回的 ID 值可用作 clearInterval() 方法的参数。
	// slice() 方法可提取字符串的某个部分，并以新的字符串返回被提取的部分。
	// Math.random() -- 返回0和1之间的伪随机数
	setInterval(function() {
	  update(shuffle(alphabet)
		  .slice(0, Math.floor(Math.random() * 26))
		  .sort());
	}, 1500);

	// 对存在数组进行洗牌
	function shuffle(array) {
	  var m = array.length, t, i;
	  while (m) {
		i = Math.floor(Math.random() * m--);
		t = array[m], array[m] = array[i], array[i] = t;
	  }
	  return array;
	}

	</script>
</body>
</html>
{% endhighlight %}