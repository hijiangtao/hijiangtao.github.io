---
date: 2014-03-04
layout: post
title: Windows VS2012下OpenGL配置笔记
thread: 58
categories: Tutorial
tags: [OpenGL]
excerpt: 
---

什么是OpenGL？

OpenGL(Open Graphics Library)，是一个可视化工具。它是一个3D的API，具有120个图形函数，成为目前三维图形开发标准。

OpenGL相比DirectX更优越的特性：

1. 与C紧密相结合；
2. 强大的可移植性；
3. 高性能的图形渲染。

----

上面部分是我看老师课件整理的一些小知识点，没地方放所以干脆就搁在这了。

前几天在Linux上以光速配置好了OpenGL，今天准备在Windows上配置时出了点小麻烦，期间遇到的一些麻烦以及安装笔记都记录在下面。

----

##一、下载工具包

下载GLUT：[下载地址](http://www.opengl.org/resources/libraries/glut/glutdlls37beta.zip)

----

##二、配置路径

1. 将下载的压缩包解开，将得到5个文件。

2. 把glut.h 解压缩到`x:\……\Microsoft \Visual Studio 11.0\VC\include\GL`文件夹中,如果没有GL这个文件夹则可以自己新建一个；

3. 把glut32.lib和glut.lib复制到`X:\……\Microsoft Visual Studio 11.0\VC\lib`中；

4. 最后把glut32.dll和glut.dll复制到`C:\Windows\System32`中.

以上步骤中若难以找到文件夹可以使用微软的搜索功能（好吧，这可能使句废话）。

----

##三、测试环境

OK，重新打开vs2012，选择File->New->Project，然后选择Win32 Console Application，选择一个名字，然后按OK。 在谈出的对话框左边点Application Settings，找到Empty project并勾上，选择Finish。 然后向该工程添加一个代码文件，取名为“OpenGL.cpp”。代码如下：

```c
//#include "stdafx.h"
#include <gl/glut.h>
#include <math.h>
//圆周率宏
#define GL_PI 3.1415f
//获取屏幕的宽度
GLint SCREEN_WIDTH=0;
GLint SCREEN_HEIGHT=0;
//设置程序的窗口大小
GLint windowWidth=400;
GLint windowHeight=300;
//绕x轴旋转角度
GLfloat xRotAngle=0.0f;
//绕y轴旋转角度
GLfloat yRotAngle=0.0f;
//显示回调函数
void renderScreen(void){
	GLfloat x,y,z,angle;
	//把整个窗口清理为当前清理颜色：黑色
	glClear(GL_COLOR_BUFFER_BIT);
	//将当前Matrix状态入栈
	glPushMatrix();
	//坐标系绕x轴旋转xRotAngle
	glRotatef(xRotAngle,1.0f,0.0f,0.0f);
	//坐标系绕y轴旋转yRotAngle
	glRotatef(yRotAngle,0.0f,1.0f,0.0f);
	//开始绘点
	glBegin(GL_POINTS);
	z=-50.0f;
	//绘制四个螺纹
	for(angle=0.0f;angle<=((2.0f*GL_PI)*4.0f);angle+=0.05f){
		x=50.0f*sin(angle);
		y=50.0f*cos(angle);
		glVertex3f(x,y,z);
		z+=0.2f;
	}
	//结束绘点
	glEnd();
	//恢复压入栈的Matrix
	glPopMatrix();
	//交换两个缓冲区的指针
	glutSwapBuffers();
}
//设置Redering State 
void setupRederingState(void){
	//设置清理颜色为黑色
	glClearColor(0.0f,0.0,0.0,1.0f);
	//设置绘画颜色为绿色
	glColor3f(0.0f,1.0f,0.0f);
}
//窗口大小变化回调函数
void changSize(GLint w,GLint h){
	//横宽比率
	GLfloat ratio;
	//设置坐标系为x(-100.0f,100.0f)、y(-100.0f,100.0f)、z(-100.0f,100.0f)
	GLfloat coordinatesize=100.0f;
	//窗口宽高为零直接返回
	if((w==0)||(h==0))
		return;
	//设置视口和窗口大小一致
	glViewport(0,0,w,h);
	//对投影矩阵应用随后的矩阵操作
	glMatrixMode(GL_PROJECTION);
	//重置当前指定的矩阵为单位矩阵　
	glLoadIdentity();
	ratio=(GLfloat)w/(GLfloat)h;
	//正交投影
	if(w<h)
		glOrtho(-coordinatesize,coordinatesize,-coordinatesize/ratio,coordinatesize/ratio,-coordinatesize,coordinatesize);
	else
		glOrtho(-coordinatesize*ratio,coordinatesize*ratio,-coordinatesize,coordinatesize,-coordinatesize,coordinatesize);
	//对模型视图矩阵堆栈应用随后的矩阵操作
	glMatrixMode(GL_MODELVIEW);
	//重置当前指定的矩阵为单位矩阵　
	glLoadIdentity();
}

void sPecialkeyFuc(int key,int x,int y){

	if(key==GLUT_KEY_UP){
		xRotAngle-=5.0f;
	}
	else if(key==GLUT_KEY_DOWN){
		xRotAngle+=5.0f;
	}
	else if(key==GLUT_KEY_LEFT){
		yRotAngle-=5.0f;
	}
	else if(key==GLUT_KEY_RIGHT){
		yRotAngle+=5.0f;
	}
	//重新绘制
	glutPostRedisplay();
}

int main(int argc, char* argv[])
{
	//初始化glut 
	glutInit(&argc,argv);
	//使用双缓冲区模式
	glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA|GLUT_DEPTH);
	//获取系统的宽像素
	SCREEN_WIDTH=glutGet(GLUT_SCREEN_WIDTH);
	//获取系统的高像素
	SCREEN_HEIGHT=glutGet(GLUT_SCREEN_HEIGHT);
	glutCreateWindow("PointsDemo");
	//设置窗口大小
	glutReshapeWindow(windowWidth,windowHeight);
	//窗口居中显示
	glutPositionWindow((SCREEN_WIDTH-windowWidth)/2,(SCREEN_HEIGHT-windowHeight)/2);
	//窗口大小变化时的处理函数
	glutReshapeFunc(changSize);
	//设置显示回调函数 
	glutDisplayFunc(renderScreen);
	//设置按键输入处理回调函数
	glutSpecialFunc(sPecialkeyFuc);
	//设置全局渲染参数
	setupRederingState();
	glutMainLoop();
	return 0;
}
```

这段代码是我从网上摘选的一个代码样例，他是在VS2012下使用glut绘制一些列点的示例程序，绘制的是四个螺纹，按电脑键盘上的UP,DOWN,LEFT,RIGHT按键可以从不同的角度查看螺纹。效果图如下所示：

![](/assets/2014-03-04-windowsopenglexample.png "Windows下OpenGL测试效果图")
<center>Windows下OpenGL测试效果图</center>

----

##四、错误及解决方案

看上去安装步骤实在是简单到不行，但是运行时还是出了一些小插曲。比如代码第一行我注释掉的#include "stdafx.h"就是一个比较扰人的东西。网上给的代码这段时没有注释的，所以当初我运行时报错如下：

>opengl:错误: 无法打开包括文件:“stdafx.h”: No such file or directory

经过网上查找资料，我发现这个文件在有的时候会自动生成，有的时候又会没有，网上提供的解决方案是注释掉，于是我就照做了。

另一个错误是由于我粗心在新建工程时把控制台程序选成了Win32应用程序所致：

>error LNK2019: 无法解析的外部符号 \_WinMain@16，该符号在函数 \___tmainCRTStartup 中被引用

报错如上是你就要看看你新建的是不是控制台程序了。当然，如果有关这方面你仍有疑惑的话，可以看看[《error LNK2019: 无法解析的外部符号 \_WinMain@16，该符号在函数 \___tmainCR》](http://blog.csdn.net/playstudy/article/details/6661868)这篇文章，它对具体这个问题的产生和解决方法都有很详细的介绍。