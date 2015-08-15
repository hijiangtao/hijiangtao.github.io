---
date: 2014-03-10 15:00:00
layout: post
title: Processing学习笔记：实现数据可视化之柱状图2
thread: 74
categories: Tutorial
tags: [Processing]
excerpt: Simple Tutorial of Using Processing.
---

Processing是个感受很棒的数据可视化软件，经过学习，本系列笔记记录的是柱状图的学习笔记，共分三部分，分别是：

1. [Processing学习笔记：实现数据可视化之柱状图1](http://hijiangtao.github.io/2014/03/10/ProcessingChart1)
2. [Processing学习笔记：实现数据可视化之柱状图2](http://hijiangtao.github.io/2014/03/10/ProcessingChart2)
3. [Processing学习笔记：实现数据可视化之柱状图3](http://hijiangtao.github.io/2014/03/10/ProcessingChart3)

本文是第二部分。一个标准的统计图表都应该有x轴和y轴标注的。首先我们要做在柱状图的四周给坐标轴空出位置。底部和右边各留出20，这样柱状图占的空间就变成380×130。我们用screen_width和screen_height来表示sketch的大小，right_margin和bottom_margin来表示留白，用函数line来画坐标轴。为了和背景区别开来，我们用灰色(100,100,100)作为坐标轴的颜色。

```c
void setup()
{
    int screen_width = 400;
    int screen_height = 150;
    int left_margin = 20;
    int bottom_margin = 20;
  
    size(screen_width, screen_height);
    background(0);
  
    int[] numbers = { 2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 1, 4, 2, 5 };
  
    int w = (screen_width-left_margin)/numbers.length;
    int max_number = max(numbers);
    int h = (screen_height-bottom_margin)/max_number;
  
    stroke(100,100,100);//设定坐标轴刻画的颜色
    line(left_margin, (screen_height-bottom_margin), screen_width, (screen_height-bottom_margin));
    line(left_margin, (screen_height-bottom_margin), left_margin, 0);
 
    fill(255,255,255);//设定填充条形的颜色
    for(int i=0;i<numbers.length;i++){
        rect(left_margin+i*w, (screen_height-bottom_margin), w, -h*numbers[i]);
    }
}
```

图像效果如下所示：

![](/assets/2014-03-10-ProcessingPic5.png)

坐标轴上的文字标识用text(s, x, y)来现实。 s是要显示的文字，x，y分别是文字的坐标。如果我们要显示4个标识，包括0点。每个标识之间间隔的距离就是(screen_height-bottom_margin)/(4-1)。文字应该是对应的数值大小。因为最大值是max_number，每个分隔就是max_number/(4-1)。我们需要一个循环来显示这些标识。同时我们想要在每个标识画辅助线来帮助了解每个长方形对应的数的大小。现在这个程序是这样的：

```c
void setup()
{
    int screen_width = 400;//设定刻画的屏幕画布大小
    int screen_height = 150;
    int left_margin = 20;//设定图与屏幕的间隔边缘
    int bottom_margin = 20;
    int y_num_ticks = 4;//设定标识数
 
    size(screen_width, screen_height);
    background(0);
 
    int[] numbers = { 2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 1, 4, 2, 5 };
 
    int w = (screen_width-left_margin)/numbers.length;//刻画柱状图时的宽度、数值最大值以及高度基本单位
    int max_number = max(numbers);
    int h = (screen_height-bottom_margin)/max_number;
 
    stroke(100,100,100);//刻画坐标轴
    line(left_margin, (screen_height-bottom_margin), screen_width, (screen_height-bottom_margin));
    line(left_margin, (screen_height-bottom_margin), left_margin, 0);
 
    int y_tick_h = (screen_height-bottom_margin)/(y_num_ticks-1);
    int y_tick_val = max_number / (y_num_ticks-1);
 
 
    for(int i=0;i<y_num_ticks;i++){//刻画坐标轴以及纵坐标刻度文字
        line(left_margin, (screen_height-bottom_margin)-i*y_tick_h, screen_width, (screen_height-bottom_margin)-i*y_tick_h);
        text(i*y_tick_val, 0, (screen_height-bottom_margin)-i*y_tick_h);
    }
 
    fill(255,255,255);
    for(int i=0;i<numbers.length;i++){//刻画横坐标刻度文字以及柱状图描绘
        rect(left_margin+i*w, (screen_height-bottom_margin), w, -h*numbers[i]);
        text(i, left_margin+i*w, screen_height);
    }
}
```

图像效果如下所示：

![](/assets/2014-03-10-ProcessingPic6.png)

我们发现最上面的那条辅助线因为和sketch的边框重合，看不见了。所以在右边和上边我们也要空出一定空间。我们定义了right_margin =10和top_margin=10。在上面的程序里我们反复的用（screen_height-bottom_margin)和left_margin来表示柱状图的原点位置。所以让程序更简洁和易读的做法是定义新的变量chart_x, chart_y来存放这俩个数值。

还有，文字标识位置并没有对的很好。此时，我们用到textAlign()函数来定义文字的对齐模式。对于x轴的文字我们用textAlign(CENTER, TOP)。这样显示的文字就会以我们调用text()函数时给的x坐标为中点对齐，以y坐标向上对齐。因此我们的x和y也要相应改变。

新的代码如下所示，至此我们已经可以制作出一个基本的柱状图了：

```c
void setup()
{
    int screen_width = 400;//屏幕及画笔的一些参数设置
    int screen_height = 150;
    int left_margin = 20;
    int bottom_margin = 20;
    int right_margin = 10;
    int top_margin = 10;
    int y_num_ticks = 4;
    int tick_padding = 5;
 
    int chart_x = left_margin;//间距变量设定
    int chart_y = screen_height-bottom_margin;
    int chart_width = screen_width - left_margin - right_margin;
    int chart_height = screen_height - top_margin - bottom_margin;
 
    size(screen_width, screen_height);
    background(0);
 
    int[] numbers = { 2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 1, 4, 2, 5 };
 
    int w = chart_width/numbers.length;
    int max_number = max(numbers);
    int h = chart_height/max_number;
 
    stroke(100,100,100);
    line(chart_x, chart_y, chart_x+chart_width, chart_y);
    line(chart_x, chart_y, chart_x, chart_y-chart_height);
 
    int y_tick_h = chart_height/(y_num_ticks-1);
    int y_tick_val = max_number / (y_num_ticks-1);
 
    textAlign(RIGHT, CENTER);//调整文字对齐方式
    for(int i=0;i<y_num_ticks;i++){
        line(chart_x, chart_y-i*y_tick_h, chart_x+chart_width, chart_y-i*y_tick_h);
        text(i*y_tick_val, chart_x-tick_padding, chart_y-i*y_tick_h);
    }
 
    fill(255,255,255);
    textAlign(CENTER, TOP);//调整文字对齐方式
    for(int i=0;i<numbers.length;i++){
        rect(chart_x+i*w, chart_y, w, -h*numbers[i]);
        text(i, chart_x+i*w+w/2, chart_y+tick_padding);
    }
}
```

图像效果如下所示：

![](/assets/2014-03-10-ProcessingPic7.png)