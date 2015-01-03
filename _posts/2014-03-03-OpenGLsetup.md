---
date: 2014-03-03
layout: post
title: Ubuntu下配置OpenGL教程
thread: 56
categories: Tutorial
tags: [OpenGL]
---

想想当时配Hadoop的痛苦经历，现在一要配置新的环境就会有一种莫名的紧张感。但这次感觉挺好的，前后没花多久时间就搞定了。今天是开学第一天，新学期开了一门课叫《计算机图形学及可视化计算》，需要配置OpenGL环境，于是网上搜搜资料，配置好了，安装笔记记录在下面。

----

**系统配置：** Linux ubuntu-13.04-desktop-i386

----

##一、建立基本环境

安装OpenGL Library

```
sudo apt-get install build-essential
```

安装OpenGL Utilities：OpenGL Utilities 是一组建构于 OpenGL Library 之上的工具组，提供许多很方便的函式，使 OpenGL 更强大且更容易使用。

```
sudo apt-get install libgl1-mesa-dev
```

安装OpenGL Utility Toolkit：OpenGL Utility Toolkit 是建立在 OpenGL Utilities 上面的工具箱，除了强化了 OpenGL Utilities 的不足之外，也增加了 OpenGL 对于视窗介面支援。

```
sudo apt-get install libglu1-mesa-dev
```

然后执行：

```
sudo apt-get install libglut-dev
```

我在操作过程中出现了以下情况，shell提示：

>正在读取软件包列表... 
>完成正在分析软件包的依赖关系树       
>正在读取状态信息... 完成       
>E: 未发现软件包 libglut-dev

没有找到原因，但通过网上所说将该`sudo apt-get install libglut-dev`改成如下命令即可正确通过了。

```
sudo apt-get install freeglut3-dev
```

----

##二、编译样例

```
#include <GL/glut.h>
void init();
void display();

int main(int argc, char* argv[])
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE);
    glutInitWindowPosition(0, 0);
    glutInitWindowSize(300, 300);
    glutCreateWindow("OpenGL 3D View");

    init(); glutDisplayFunc(display);
    glutMainLoop();
    return 0;
}

void init()

{
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glMatrixMode(GL_PROJECTION);
    glOrtho(-5, 5, -5, 5, 5, 15);
    glMatrixMode(GL_MODELVIEW);
    gluLookAt(0, 0, 10, 0, 0, 0, 0, 1, 0);
}

void display()
{
    glClear(GL_COLOR_BUFFER_BIT);
    glColor3f(1.0, 0, 0);
    glutWireTeapot(3);
    glFlush();
}  
```

安装完毕后，在样例文件也保存过后，我所需要做的就是告诉编译器环境中有安装 OpenGL 函式库，编译程式时要连结这些函式库。使用命令：

```
gcc -o example example.c -lGL -lGLU -lglut
```

另一方面，因为我们安装了 OpenGL Utility Toolkit ，它是建立在 OpenGL Utilities 与 OpenGL Library 之上，因此我们可以简单连结 OpenGL Utility Toolkit 的函式库就可以达到我们的目地了。下面的编译参数跟上面的是同样效果：

```
gcc -o example example.c -lglut
```

执行之后，如果没有报错，我们就打开example看看，执行命令：

```
./example
```

如果看到红线描绘的茶壶图片，那就代表成功了! 

----