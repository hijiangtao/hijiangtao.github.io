---
date: 2014-03-10 15:30:00
layout: post
title: Processing学习笔记：实现数据可视化之柱状图3
thread: 75
categories: Tutorial
tags: [Processing]
excerpt: Simple Tutorial of Using Processing.
---

Processing是个感受很棒的数据可视化软件，经过学习，本系列笔记记录的是柱状图的学习笔记，共分三部分，分别是：

1. [Processing学习笔记：实现数据可视化之柱状图1](http://hijiangtao.github.io/2014/03/10/ProcessingChart1)
2. [Processing学习笔记：实现数据可视化之柱状图2](http://hijiangtao.github.io/2014/03/10/ProcessingChart2)
3. [Processing学习笔记：实现数据可视化之柱状图3](http://hijiangtao.github.io/2014/03/10/ProcessingChart3)

本文是第三部分。笔记刚开始我们先换一组数据，在之前的代码上运行：

```c
int[] numbers = 
    {2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 
     1, 4, 2, 5, 2, 5, 3, 1, 6, 5, 31, 4,
     7, 3, 2, 5, 1, 4, 2, 5 };
```

图像效果如下所示：

![](/assets/2014-03-10-ProcessingPic8.png)

生成的柱状图有如下几个问题：

1. 图表的宽度和高度都没有用满。这是因为在计算每个长方形的宽度和单位高度的时候我们用了整型。所以，值的小数部分被强制去掉了，比如3.5就变成了3, 改用float就好了。
2. x轴的文字标识重叠在了一起。这是因为当数据变多的时候，每个长方形的宽度就变小了。而文字标识的字体大小是不变的。这个问题怎么解决呢？我们可以不用显示所有的标识，而根据Sketch的宽度和字体大小来显示部分标识。

```c
float w = float(chart_width)/numbers.length;//float型宽度设定
float h = float(chart_height)/max_number;//float型高度设定

float num_x_ticks = chart_width/textWidth(Integer.toString(numbers.length));//设定最长字符所需占位置长度

int x_tick_interval = ceil(numbers.length/num_x_ticks);//最小间隔

for(int i=0;i<numbers.length;i++) {
    rect(chart_x+i*w, chart_y, w, -h*numbers[i]);
    if(i%x_tick_interval==0) {
        text(i, chart_x+i*w+w/2, chart_y+tick_padding);
    }
}
```

效果如下：

![](/assets/2014-03-10-ProcessingPic9.png)

最后，数据可视化最重要的一点便是互动了。对于一个柱状图来说，当用户鼠标移动某个长方形上时，能显示对应的数值很有用。

第一步，我们要改动整个程序的结构。因为每次鼠标移动，标识的位置都不同，所以可视化必须不断的刷新。之前的程序只是在setup()函数里面画一次是不行的。我们要把画图的部分放到draw()函数里面。在processing里面，draw()函数会被不停的调用。为了让程序更快，我们把一些只用做一次的计算放到setup()里面，把变量都定义在最外面。

接着，画标识。在processing中，mouseX和mouseY存了鼠标的位置。我们先要确定鼠标在图表范围内。然后我们要找到鼠标所指向的长方形。别忘了，长方形是从chart_x开始。所以int selectedBarIndex = int((mouseX-chart_x)/w)。w是每个长方形的宽度。 链接标识和长方形的线从离长方形顶部5个像素的地方开始到标识下面5个像素。代码如下：

```c
if(mouseX>chart_x && mouseX<chart_x+chart_width) {  
    stroke(100,100,100);
    int selectedBarIndex = int((mouseX-chart_x)/w);
    textAlign(CENTER,BOTTOM);
    line(mouseX, top_margin-5, mouseX, chart_y-h*numbers[selectedBarIndex]-5);
    text(numbers[selectedBarIndex], mouseX, top_margin-10);
}
```

以下代码为视物 | 致知提供的源码，经过测试可以完美运行。

```c
//screen size
int screen_width = 400;
int screen_height = 150;
//margins
int left_margin = 20;
int bottom_margin = 20;
int right_margin = 10;
int top_margin = 30;
//number of ticks on y axis
int y_num_ticks = 4;
//space between tick labels and axis
int tick_padding = 5;
//chart position and size
int chart_x = left_margin;
int chart_y = screen_height-bottom_margin;
int chart_width = screen_width - left_margin - right_margin;
int chart_height = screen_height - top_margin - bottom_margin;
//data to be viusualized
int[] numbers = { 2, 5, 3, 1, 6, 5, 9, 4, 7, 3, 2, 5, 1, 4, 2, 5, 2, 5, 3, 1, 6, 5, 31, 4, 7, 3, 2, 5, 1, 4, 2, 5 };
//unit width and height of bars
float w;
float h;
//ticks on the axes
float num_x_ticks;
int x_tick_interval;
int y_tick_val;
int y_tick_h;
 
 
void setup()
{
  //define sketch
  size(screen_width, screen_height);
  smooth();
  //width and unit height of the bars
  w = float(chart_width)/numbers.length;
  int max_number = max(numbers);
  h = float(chart_height)/max_number;
   
  //ticks on y axis
  y_tick_val = max_number / (y_num_ticks-1);
  y_tick_h = int(y_tick_val*h);
  
  //ticks on x axis
  num_x_ticks = chart_width/textWidth(Integer.toString(numbers.length));
  x_tick_interval = ceil(numbers.length/num_x_ticks);
}//setup()


void draw(){
  background(0);
  //draw the axes
  stroke(100,100,100);
  line(chart_x, chart_y, chart_x+chart_width, chart_y);
  line(chart_x, chart_y, chart_x, chart_y-chart_height);
   
  //draw y axis ticks and labels
  textAlign(RIGHT, CENTER);
  for(int i=0;i<y_num_ticks;i++){
     line(chart_x, chart_y-i*y_tick_h, chart_x+chart_width, chart_y-i*y_tick_h);
     text(i*y_tick_val, chart_x-tick_padding, chart_y-i*y_tick_h);
  }

  //draw bars
  fill(255,255,255);
  textAlign(CENTER, TOP);
  for(int i=0;i<numbers.length;i++){
    rect(chart_x+i*w, chart_y, w, -h*numbers[i]);
    //draw labels along x axis
    if(i%x_tick_interval==0)
      text(i, chart_x+i*w+w/2, chart_y+tick_padding);
  }

  //draw label
  if(mouseX>chart_x && mouseX<chart_x+chart_width){  
    stroke(100,100,100);
    //find the bar that mouse pointed to
    int selectedBarIndex = int((mouseX-chart_x)/w);
    textAlign(CENTER,BOTTOM);
    line(mouseX, top_margin-5, mouseX, chart_y-h*numbers[selectedBarIndex]-5);
    text(numbers[selectedBarIndex], mouseX, top_margin-10);
  }
}//draw
```

运行效果：

![](/assets/2014-03-10-ProcessingPic10.png)