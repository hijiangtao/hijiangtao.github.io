---
date: 2014-03-10 14:00:00
layout: post
title: Processing学习笔记：实现数据可视化之柱状图1
thread: 73
categories: Tutorial
tags: [Processing]
excerpt: Simple Tutorial of Using Processing.
---

Processing实在是很好用的一个工具，不仅简单，而且艺术设计感特别棒。最要提的一句就是：相比Hadoop繁琐的使用与配置，Processing简直棒。

从[视物|致知](http://www.vizinsight.com/)博客上看到一些有用的简单可视化实现的资料，于是自己手动操作了一下。在简单实现后决定把学到的东西记录下来。

笔记记录的是柱状图的学习笔记，共分三部分，分别是：

1. [Processing学习笔记：实现数据可视化之柱状图1](http://hijiangtao.github.io/2014/03/10/ProcessingChart1)
2. [Processing学习笔记：实现数据可视化之柱状图2](http://hijiangtao.github.io/2014/03/10/ProcessingChart2)
3. [Processing学习笔记：实现数据可视化之柱状图3](http://hijiangtao.github.io/2014/03/10/ProcessingChart3)

本文是第一部分。柱状图是由一系列长方形组成的，所以首先应该知道如何画长方形。我们要定义Sketch的大小，这就好比画布的大小。我们设的大小是200×200。 我们要定义Sketch的背景的颜色，用的是函数background(r, g, b)。

画长方形的函数是rect(x, y, w, h)。这里x和y是长方形起点的坐标，w是长方形的宽度，而h是长方形的高度。

如同之前文章《[Processing快速入门学习笔记](http://hijiangtao.github.io/2014/03/01/processing-startnode/)》里介绍过：Processing里Sketch的坐标系。下图是200×200的Sketch。左上角是坐标原点（0, 0)。 然后右下角是(200, 200)。Sketch的中心点坐标是（100，100）。

![Processing坐标系示意图](/assets/2014-03-10-ProcessingXyz.png "Processing坐标系示意图")

<em>Processing坐标系示意图</em>

画长方形的时候，从起点（x,y）出发，向x轴正方向延伸w，就是宽；向y轴正方向延伸h，就是高。所以长方形的其他三个顶点就是（x+w, y), (x, y+h), (x+w, y+h)。有关长方形的生长方向可以尝试对rect的第四个参数进行修改，查看效果。其中，被注释的`rectMode(CENTER);`是用来对长方形进行对其操作的，可以尝试去除注释看看效果。以下为一段例子代码：

```c
size(200, 200);//设置画布大小
background(0, 0, 0);//设置背景颜色
fill(255, 255, 255);//设置填充画笔颜色
//rectMode(CENTER);
rect(100, 100, 50, 80);
```

![正常长方形效果图](/assets/2014-03-10-ProcessingPic1.png "正常长方形效果图")

<em>正常长方形效果图</em>

![经过对齐的长方形效果图](/assets/2014-03-10-ProcessingPic2.png "经过对齐的长方形效果图")

<em>经过对齐的长方形效果图</em>

现在可以来开始画柱状图了。柱状图就是把一组数可视化成一排长方形。通常长方形的宽度相同，而高度由相对应的数决定。数字越大就越高。

随便选择一些数，把他们这些数放在Processing的数组中：

```c
int[] numbers = { 2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 1, 4, 2, 5 };
```

由于只想让程序执行一遍，所以把描述性的语句放在setup()函数中，完整代码如下：

```c
void setup()
{
     size(200,200);
     background(0);
     int[] numbers = { 2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 1, 4, 2, 5 };
     fill(255,255,255);
     for(int i=0;i<numbers.length;i++){
         rect(i*5, 200, 5, -numbers[i]);
     }
}
```

效果图如下所示：

![](/assets/2014-03-10-ProcessingPic3.png)

我们会发现，在这样的情况下，显然长方形都太小了，不但看不清，而且没有很好的利用空间。我们现在想要柱状图填满整个Sketch。要做的是根据Sketch的大小来设置长方形的宽和高。柱状图通常很少有正方形的。让我们首先改变Sketch的大小，变成400×150。因为一共有numbers.length个长方形，每个的宽度就应该是400/numbers.length。对于高度，我们想要最高的长方形能从顶天立地，所以我们需要知道数组里的最大值：max(numbers)。然后单位高度就是150/max(numbers)。新的程序：

```c
void setup()
{
    size(400,150);//定义新画布
    background(0);
    int[] numbers = { 2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 1, 4, 2, 5 };
    int w = 400/numbers.length;//定义条形统计图宽度
    int max_number = max(numbers);//查找数组中最大值
    int h = 150/max_number;//计算画图时的单位高度
    fill(255,255,255);
    for(int i=0;i<numbers.length;i++){
       rect(i*w, 150, w, -h*numbers[i]);//画图
    }
}
```

得到的结果：

![](/assets/2014-03-10-ProcessingPic4.png)