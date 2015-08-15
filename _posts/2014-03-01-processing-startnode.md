---
date: 2014-03-01
layout: post
title: Processing快速入门学习笔记
thread: 55
categories: Tutorial
tags: [Processing]
excerpt: 
---

![Processing Logo](/assets/2014-03-01-processing-logo.png "Processing Logo")
<em>Processing Logo</em>

前几天听朋友说了Processing这个非常棒的可视化工具，不仅效果显著而且简单易懂，想想数据分析最后一步就是数据可视化，与其之后再来看不如现在先了解一点。于是今天花了一点时间来学学这个，虽然还不会编写，但玩玩已有的效果已经不成问题了。

学习期间参考了《Processing中文开发教程》，结合自己的操作记下这篇使用笔记。

----

##一、什么是Processing？

**Processing维基百科简介**：Processing是一种开源编程语言，专门为电子艺术和视觉交互设计而创建，其目的是通过可视化的方式辅助编程教学，并在此基础之上表达数字创意。Processing也指Processing语言的集成开发环境(IDE)。2001年，MIT媒体实验室的 Casey Reas 和 Benjamin Fry 发起了此计划。其固定目标之一便是作为一个有效的工具，通过激励性的可视化反馈帮助非程序员进行编程的入门学习。Processing语言建立在Java语言的基础之上，但使用简化的语法和图形编程模型。

**Processing豆瓣小组简介**：

1. Processing 是一个开放原始码的程序语言及开发环境，提供给那些想要对影像、动画、声音进行程序编辑的工作者。此外，学生、艺术家、设计师、建筑师、研究员以及有兴趣的人，也可以用来学习，开发原型及制作。
2. 开发这套软件的目的，是为了教导学习者一些以视觉呈现为主的计算机程序基础，并且将这套软件看作是一个软件的描绘本，以及专业的制作工具。 
3. Processing是由一群艺术家及设计师所开发的，在相同的领域上，是其它商业性软件开发工具之外，另一个可以选择的工具。 

**Processing官方网站**：<http://Processing.org/>

----------

##二、下载安装Processing

这一步可以说是最简单、最傻瓜的操作了，配置过OpenCV或者Hadoop集群的朋友就会知道，那种软件的配置或者说是环境变量的设置有多麻烦了，但是Processing的安装使用简直会让你惊讶到不行。

根据你电脑操作系统的不同，下载相应的Processing版本，官网提供Windows 64-bit、Windows 32-bit、Linux 64-bit、Linux 32-bit、Mac OS X等五种系统版本的下载。

Processing软件下载地址：[Processing](http://Processing.org/download/)

由于我是在Windows上运行的，于是我下载的是Windows64-bit下的一个压缩包，下载完毕解压缩。

还有什么？没了！直接打开**Processing.exe**就可以运行了。

----------

##三、语法综述

###3.1 Sketch简介

每一个Processing project都会被视为一个sketch，而我们使用的Processing语法则被视为画笔，所以用艺术家的角度来说，我们是在用程序作画。每个sketch在电脑中是以一个文件夹的形式存在的。文件夹中存放sketch相关的代码（.pde文件）以及影音资料（存放在data文件夹中）。

###3.2 processing语法结构

* 准备工作

```
void setup(){
//准备动作，在程序一开始执行，只执行一次
}

void draw(){
//开始作画，紧接着setup()执行，会不断执行直到程序终止
}
```

* 如何停止作画

使用delay()或者用noLoop()告诉电脑只执行一次都可以。

* 其他

```
void mousePressed(){
//滑动鼠标控制的事件
}

void keyPressed(){
//键盘控制的事件
}
```

* 变量

Processing支持int、float、string、boolean四种类型的变量声明，除了以下规则外，其他和你学习C语言时基本一样。

1. 只可以使用英文字母、阿拉伯数字以及下划线（_）；
2. 开头第一个字母不能是数字；
3. 区分字母大小写；
4. 中间不能存在空格；
5. 不能使用（.）。


* 注释与循环

Processing支持的大部分语法规则和C几乎是一样的，包括注释（使用//）和循环（while,for）。

----------

##四、一些实例

在给出一些实例之前先说说processing的坐标设置。

我们知道如果要画一个三维的图形，肯定要确定它的三维位置。在数学上，X轴是向右递增的，Y轴是向上递增的，Z轴是向外递增的；

![数学上坐标的规定](/assets/2014-03-01-processing-xyz-math.png "数学上坐标的规定")

<em>数学上坐标的规定</em>

在processing程序中，X轴是向右递增的，Y轴是向下递增的，Z轴是向外递增的。

![Processing上坐标的规定](/assets/2014-03-01-processing-xyz-pro.png "Processing上坐标的规定")

<em>Processing上坐标的规定</em>

在Processing中绘画基本的几何图形非常简单，只需要调用现有的方法即可实现。指令参考：[Processing Reference](http://www.Processing.org/reference/)

----

下面有几个简单的例子，可以复制粘贴到Processing里Run一下试试效果。

* 样例：四个圆

```
void setup() {
size(200, 200);
noStroke();
background(255);
fill(0, 102, 153, 204);
smooth();
noLoop();
}
void draw() {
circles(40, 80);
circles(90, 70);
}
void circles(int x, int y) {
ellipse(x, y, 50, 50);
ellipse(x+20, y+20, 60, 60);
}
```

* 样例：用鼠标实现移动对称的两个方块

```
void setup() {
size(200, 200);
rectMode(CENTER);
noStroke();
int r = 0;
int g = 102;
int b = 153;
int alpha = 204;
fill(r, g, b, alpha);
}
void draw() {
background(255);
rect(width-mouseX, height-mouseY, 50, 50);
rect(mouseX, mouseY, 50, 50);
}
```

* 样例：复杂操作

```
int k;

void setup(){
    size(200, 200);
    noStroke();
}

void draw(){
    background(102);

    // Draw gray bars
    fill(255);
    k=60;
    for(int i=0; i < mouseX/20; i++) { //重复次数由滑动鼠标的x轴位置（除以20）决定
        rect(25, k, 155, 5);
        k= k + 10;
    }

    // Black bars
    fill(51);
    k = 180;
    for(int i=0; i < mouseY/15; i++) { //重复次数由滑动鼠标的y轴坐标（除以15）决定
        rect(105, k, 30, 5);
        k = k - 10;
    }
}
```

----

##五、学习更多

**Processing官方资料**

<http://Processing.org/exhibition/>

<http://Processing.org/reference/>

<http://Processing.org/learning/>

<http://Processing.org/hacks/>

**Processing作品收集**

<http://www.processingblogs.org/>

<http://www.openprocessing.org/>

**Processing样例**

<http://builtwithprocessing.org/browser/browse.php>

**网页动画/JavaScript**

<http://processingjs.org/>