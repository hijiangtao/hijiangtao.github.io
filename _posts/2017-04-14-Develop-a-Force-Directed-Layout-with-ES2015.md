---
title: 用 ES2015 实现一个简单的力导向可视化图库
layout: post
thread: 171
date: 2017-04-14
author: Joe Jiang
categories: documents
tags: [Visualization, JavaScript, ForceLayout]
excerpt: 正好熟练一下 ES2015 的新特性, 用它开发一个简单的力导向图库怎么样?
---

最近正好在忙面试, 面试官给了一个代码开发的任务: 用 JavaScript 实现一个力导向布局的视图, 要求考虑到巨量数据绘制的性能以及布局收敛平衡的条件.

于是就开始干呗, 先把任务分解: 确定可视化索要使用的数据格式, 确定系统受力与计算逻辑, 确定布局的更新与收敛过程, 测试. 大致就这些, 想想 ES2015 融入了很多便捷开发的新特性, 那么就用该版本的 ECMAScript 语法来开发呗, 还可以在实际操作中熟悉熟悉. 先附上实现效果图:

![](/assets/in-post/2017-04-14-Develop-a-Force-Directed-Layout-with-ES2015.png "Demo Picture")

## 介绍

* Github 地址: [Force-Directed-Layout](https://github.com/hijiangtao/Force-Directed-Layout)
* [README](https://github.com/hijiangtao/Force-Directed-Layout/blob/master/README.md)
* 中文版 [README](https://github.com/hijiangtao/Force-Directed-Layout/blob/master/README_zh.md)
* [在线演示地址](https://hijiangtao.github.io/Force-Directed-Layout/)
* 主要代码文件 [forceLayout.js](https://github.com/hijiangtao/Force-Directed-Layout/blob/master/src/forceLayout.js)

## 参考与前期准备

之前已经有很多力导向布局的可视化库了, 比如 [d3-force](https://github.com/d3/d3-force), [springy](https://github.com/dhotson/springy) 等等; 查看了 Mike Bostock 用 D3 V4 实现的 [Force-Directed Graph](https://bl.ocks.org/mbostock/4062045), 动画过程大致可以分解为初始化中心点簇, 在受力情况下更新位置和受力平衡系统停止三个部分.

在开始正式开发之前可以准备好的内容包括使用到的测试数据, 测试指标等等. 为了简化开发流程, 直接使用由[Donald Knuth](http://www-cs-faculty.stanford.edu/~uno/sgb.html) 制作的基于维克多雨果编著的悲惨世界一书中的人物相关关系数据, 做了少许修改, 数据见 [data.js](https://github.com/hijiangtao/Force-Directed-Layout/blob/master/src/data.js). 为了测试项目运行的性能效果, 可以开放如下参数供运行时监控: 绘制方式, 绘制耗时, 系统迭代次数, 当前系统能量, 当前系统点/边数量, 页面堆内存消耗, 系统占用 DOM 个数等等, 大部分数据我们在更新系统时都会计算, 页面内存消耗使用的是 `wwindow.performance.memory.usedJSHeapSize`. 该部分代码布置在函数 `updateDetails` 中, 每帧更新时会调用一次:

``` js
/**
 * update details in page (container: table)
 * @param  {[type]} energy [description]
 * @return {[type]}        [description]
 */
updateDetails(energy) {
	let ths = document.getElementById('detailTable').getElementsByTagName('td');
	if (this.iterations === 1) {
		/**
		 * Update Items in first time
		 *
		 * {Drawing Approach} [1]
		 * {Node Number} [9]
		 * {Edge Number} [11]
		 * {DOM ChildNodes} [15]
		 */
		ths[1].innerHTML = this.props.approach;
		ths[9].innerHTML = this.nodes.length;
		ths[11].innerHTML = this.edges.length;
		ths[15].innerHTML = this.props.approach === 'canvas' ? 1 : this.nodes.length + this.edges.length;
	}

	/**
	 * Regular update items
	 * 
	 * {Render time} [3]
	 * {Iterations} [5]
	 * {Current Energy} [7]
	 * {Used JS Heap Size} [13]
	 */
	ths[3].innerHTML = `${this.renderTime}ms`;
	ths[5].innerHTML = this.iterations;
	ths[7].innerHTML = energy.toFixed(2);
	ths[13].innerHTML = `${window.performance.memory.usedJSHeapSize}`;
}
```

## 数据结构

对于一个力导向图来说, 其中涉及到的数据包括点数据, 边数据以及各自在计算力和状态时所要使用到的二维平面坐标系. 考虑到这些, 我们使用以下几个类组织这些数据.

* Vector 向量类: 存储二维空间中的一个向量, 并包含其中的加减乘除等向量操作基本函数

``` js
class Vector {
	constructor(x, y) {
		this.x = x; // x position
		this.y = y; // y position
	}

	getvec() {
		return this;
	}

	add(v2) {
		return new Vector(this.x + v2.x, this.y + v2.y);
	}

	subtract(v2) {
		return new Vector(this.x - v2.x, this.y - v2.y);
	}

	magnitude() {
		return Math.sqrt(this.x * this.x + this.y * this.y);
	}

	normalise() {
		return this.divide(this.magnitude());
	}

	divide(n) {
		return new Vector((this.x / n) || 0, (this.y / n) || 0);
	}

	multiply(n) {
		return new Vector(this.x * n, this.y * n);
	}
}
```

* Point 质点类: 存储质点及其属性

``` js
let Point = function(position, id = -1, group = -1, mass = 1.0) {
	this.p = position; // 质点位置
	this.m = mass; // 质点质量
	this.v = new Vector(0, 0); // 质点速度
	this.a = new Vector(0, 0); // 质点加速度
	this.id = id; // 质点 id
	this.group = group; // 质点所属组别编号

	let self = this;
	this.updateAcc = function(force) { // 更新质点加速度
		self.a = self.a.add(force.divide(self.m));
	}
}
```

* Spring 弹簧类: 存储弹簧长度及相邻两个质点信息

``` js
class Spring {
	constructor(source, target, length) {
		this.source = source;
		this.target = target;
		this.length = length;
	}
}
```

## 系统受力分析与状态更新

系统中的原始数据, 其基本单位由质点和弹簧两部分组成. 任意两个质点存在于空间中彼此间存在库仑力, 存在弹簧相连的两个质点间存在弹力. 库仑力的产生见 [Coulomb's law](https://en.wikipedia.org/wiki/Coulomb%27s_law), 弹力产生见 [Hooke's law](https://en.wikipedia.org/wiki/Hooke%27s_law). 结合以上的分析, 所以我们要解决以下几个问题: 初始化点簇系统, 排斥力(模拟库仑力)和弹力(模拟弹簧力)的计算, 质点加速度与位置随时刻的更新, 系统收敛与停止的判断, 我们一个个来解决.

### 1. 初始化点簇系统

初始化点簇可以通过简单的随机函数实现, 假设我们初始化的实例中已经存有点边(this.nodes, this.edges)数据, 那么通过以下逻辑可以初始化由中心向周围一定距离随机分布的点簇系统. 这里考虑到点边的唯一性, 我们使用 [Set](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/Set) 数据结构实现对点边数据的组织.

``` js
let self = this,
	nlen = this.nodes.length,
	elen = this.edges.length;

let startX = this.props.width * 0.5, //this.props 表示初始化屏幕规格参数
	startY = this.props.height * 0.5,
	initSize = 20; // 初始化随机位移最大值

for (let i = 0; i < nlen; i++) {
	// initial the point position
	let node = this.nodes[i],
		x = startX + initSize * (Math.random() - .5),
		y = startY + initSize * (Math.random() - .5),
		vec = new Vector(x, y);
	this.nodePoints.set(node.id, new Point(vec, node.id, node.data.group));
}

for (let i = 0; i < elen; i++) {
	let edge = this.edges[i],
		source = this.nodePoints.get(edge.source.id),
		target = this.nodePoints.get(edge.target.id),
		length = this.props.defSpringLen * Number.parseInt(edge.data);

	this.edgeSprings.set(edge.id, new Spring(source, target, length));
}
```

### 2. 系统主要受力分析

参考以上所说的库仑定律和胡克定律, 我们需要确定该两种力的计算公式; 除此外, 考虑到系统实际呈现基于屏幕画布进行展现, 应该添加一个额外的向心力以保证整个系统不会偏离屏幕中心太多.

* 本实现中使用的排斥力来自公式 `F=Repusion*Mass_1*Mass_2/Math.pow(Dis*coulombDisScale, 2)`, 其中 **Repusion** 表示库伦常量, **Mass**表示质量, **Dis** 表示两个质点间的距离, 考虑到实际距离以屏幕像素点为单位, 故增加 **coulombDisScale** 表示距离标度系数, 由于实现过程中所有质点质量均看成1.0, 故上式在实现中 **Mass** 不额外计算;
* 本实现中使用的吸引力来自公式 `F=Stiffness*Displacement`, 其中 **Stiffness** 表示弹簧的劲度系数, **Displacement** 表示弹簧相比原始长度的位移, 负数表示拉伸, 正数表示压缩;
* 在屏幕正中心添加一个对所有点的向心吸引力, 公式为 `F=Repulsion/100` (未证明), 其中 **Repusion** 表示库伦常量, 除数 100 根据效果设定, 未经过严格证明;

以上所说的三个力我们分别用三个函数单独实现 (注意: 其中`normalise`属性为标准化函数, `subtract`属性为向量减法函数, `updateAcc`属性为加速度更新函数, `divide`属性为除法函数, `multiply`属性为乘法函数, 详细向量操作类实现见[Vector.js](https://github.com/hijiangtao/Force-Directed-Layout/blob/master/src/Vector.js)):

``` js
/**
 * Update repulsion forces between nodes
 * @return {[type]} [description]
 */
updateCoulombsLaw() {
	let len = this.nodes.length;

	for (let i = 0; i < len; i++) {
		for (let j = i + 1; j < len; j++) {
			if (i === j) continue;

			let iNode = this.nodes[i],
				jNode = this.nodes[j],
				v = this.nodePoints.get(iNode.id).p.subtract(this.nodePoints.get(jNode.id).p),
				dis = (v.magnitude() + 0.1) * this.props.coulombDisScale,
				direction = v.normalise();

			this.nodePoints.get(iNode.id).updateAcc(direction.multiply(this.props.repulsion).divide(Math.pow(dis, 2)));
			this.nodePoints.get(jNode.id).updateAcc(direction.multiply(this.props.repulsion).divide(-Math.pow(dis, 2)));
		}
	}
}

/**
 * update attraction forces between nodes in each edge
 * @return {[type]} [description]
 */
updateHookesLaw() {
	let len = this.edges.length;

	for (let i = 0; i < len; i++) {
		let spring = this.edgeSprings.get(this.edges[i].id),
			v = spring.target.p.subtract(spring.source.p),
			displacement = spring.length - v.magnitude(),
			direction = v.normalise();

		spring.source.updateAcc(direction.multiply(-this.props.stiffness * displacement));
		spring.target.updateAcc(direction.multiply(this.props.stiffness * displacement));
	}
}

/**
 * Attract to center with little repulsion acceleration
 *
 * the divisor is set to 100.0 by experience, but lack of provements
 * @return {[type]} [description]
 */
attractToCentre() {
	let len = this.nodes.length;

	for (let i = 0; i < len; i++) {
		let point = this.nodePoints.get(this.nodes[i].id),
			direction = point.p.subtract(this.center);

		point.updateAcc(direction.multiply(-this.props.repulsion / 100.0));
	}
}
```

### 3. 质点加速度与位置随时刻的更新

加速度可以通过简单受力除以质点质量得出, 但是在进一步计算质量的位移更新之前我们需要为系统加上一个阻尼力, 使质量在正常受力的情况下有一个Suunto衰减的过程, 以不至于系统永远处于不收敛状态. 我们将阻尼系数存在 `this.props.damping` 中, 于是得到速度和位移的更新函数可以如下表示:

``` js
attractToCentre() {
	let len = this.nodes.length;

	for (let i = 0; i < len; i++) {
		let point = this.nodePoints.get(this.nodes[i].id),
			direction = point.p.subtract(this.center);

		point.updateAcc(direction.multiply(-this.props.repulsion / 100.0));
	}
}

updateVelocity(interval) {
	let len = this.nodes.length;

	for (let i = 0; i < len; i++) {
		let point = this.nodePoints.get(this.nodes[i].id);
		point.v = point.v.add(point.a.multiply(interval)).multiply(this.props.damping);

		if (point.v.magnitude() > this.props.maxSpeed) {
			point.v = point.v.normalise().multiply(this.props.maxSpeed);
		}
		point.a = new Vector(0, 0);
	}
}
```

### 4. 系统收敛与停止的判断

对于系统收敛, 正常的判断应当是根据系统当前状态拥有的总能量进行评定, 提前设置一个阈值, 如果系统总能量一旦小于该值我们立即停止整个系统的更新, 以防止不必要的微小位移使得系统受力变化, 而长久处于扰动状态; 另一方面, 我们也可以根据受力更新总迭代次数来判断当前系统是否有必要停止更新.

在这个项目中, 我们将系统能量阈值设置为 0.1, 最大迭代次数设置为 1000000. 我们将该部分判断逻辑加入系统逐帧更新 (利用 `window.requestAnimationFrame` 实现) 的逻辑部分:

``` js
window.requestAnimationFrame(function step() {
	self.tick(self.props.tickInterval); // 每次受力与质点系统位置的更新
	self.render(); // 页面绘制的更新
	self.iterations++; // 迭代次数增加
	let energy = self.calTotalEnergy(); // 计算当前系统总能量

	if (self.props.detail) { // 默认更新页面中的系统监控信息详情
		self.updateDetails(energy);
	}
    
    // 系统停止判断条件
	if (energy < self.props.minEnergyThreshold || self.iterations === 1000000) {
		window.cancelAnimationFrame(step);
		clearInterval(timer);
	} else {
		window.requestAnimationFrame(step);
	}
});
```

## 前端绘制策略

项目在开发初期默认采用的是 SVG 绘制策略, 如同 Mike Bostock 用 D3 开发的[版本](https://bl.ocks.org/mbostock/4062045)一样, 用 `path` 和 `circle` 作为主要的绘制元素去承载点边的绘制. 但是, 考虑到系统要兼容不同规模的数据量, 当点边数量原来越大时, 基于 DOM 的 SVG 势必会拖慢整个页面的运行性能, 考虑到此, Canvas 绘制方法的实现便被提了出来.

因为 Canvas 绘制是基于像素的, 所以每次更新受力系统之后我们都需要重新绘制整个 Canvas 画布, 基于此我们将 Canvas 的实现过程分为:

* 获取画布并重置 (假设我们已经在之前生成过 Canvas 画布)

``` js
if (this.props.approach === 'canvas') {
	this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
}
```

* 遍历系统中存在的边用 `ctx.beginPath` 方法进行绘制 (source, target 分别为源节点与目标节点)

``` js
if (self.props.approach === 'canvas') {
	self.ctx.strokeStyle = strokeStyle;
	self.ctx.lineWidth = strokeWidth;
	self.ctx.beginPath();
	self.ctx.moveTo(source.p.x, source.p.y);
	self.ctx.lineTo(target.p.x, target.p.y);
	self.ctx.stroke();

	return;
}
```

* 遍历系统中存在的节点用 `ctx.arc` 方法进行绘制 (val为绘制的节点数据结构)

``` js
if (self.props.approach === 'canvas') {
	self.ctx.strokeStyle = strokeStyle;
	self.ctx.fillStyle = fillStyle;
	self.ctx.lineWidth = lineWidth;
	self.ctx.beginPath();
	self.ctx.arc(val.p.x, val.p.y, r, 0, 2 * Math.PI);
	self.ctx.stroke();
	self.ctx.fill();

	return;
}
```

## 封装

针对以上设计的不同模块, 我们在实现了之后将其简单封装在一个命名空间中, 比如 `forceLayout`, 那么之后再开发中我们就可以直接使用以下语句引入该模块进行图形绘制或者二次开发了:

``` js
import forceLayout from 'forceLayout'
``` 

为以上测试数据制作一个简单的页面 [index.html](https://github.com/hijiangtao/Force-Directed-Layout/blob/master/index.html), 再加上一些简单的样式 [default.css](https://github.com/hijiangtao/Force-Directed-Layout/blob/master/default.css) 改善界面呈现效果, 最后通过 webpack 等工具对我们的编码进行转码和打包, 再建立一个简单的 http server, 便可以通过 [url](https://hijiangtao.github.io/Force-Directed-Layout/) 访问示例页面, 查看力导向布局可视化实现的效果了.

## 总结

### 1 项目结构

* 项目文件结构如下, 实现库源代码置于 `src` 文件夹中, `index.js` 为样例页面引用脚本文件, `forceLayout.js` 为项目主代码入口;

``` linux
Force-Directed-Layout
├── default.css
├── dist
│   ├── home.js
│   └── home.js.map
├── index.html
├── LICENSE
├── package.json
├── README.md
├── README_zh.md
├── src
│   ├── data.js
│   ├── Elements.js
│   ├── forceLayout.js
│   ├── index.js
│   ├── Spring.js
│   └── Vector.js
└── webpack.config.js
```

由于项目在编写中尽力在每个函数前都有注释说到各自的用途, 所以整体来说项目代码的结构比较清晰明朗, 希望在参考时能够对你有所帮助.
