---
date: 2013-12-08
layout: post
title: GIF头文件解析
thread: 15
categories: Documents
tags: [数字图像处理, gif]
excerpt: GIF header explanation.
---

## Doc Info

数字图像处理 作业

## The history of GIF

CompuServe introduced the GIF format in 1987 to provide a color image format for their file downloading areas, replacing their earlier run-length encoding (RLE) format, which was black and white only.

The original version of the GIF format was called **87a**.In 1989, CompuServe devised an enhanced version, called **89a**.

GIF was one of the first two image formats commonly used on Web sites.

## Gif header

![](/assets/2013-12-08-gif.png "头文件结构")

GIF的文件头只有六个字节，其结构定义如下：

```c
typedef struct gifheader
{
  BYTE bySignature[3];
  BYTE byVersion[3];
}GIFHEADER;
```

其中，bySignature为GIF文件标示码，其固定值为“GIF”，我们可以通过该域来判断一个图像文件是否是GIF图像格式的文件。

byVersion表明GIF文件的版本信息。其取值固定为“87a”和“89a”。分别表示GIF文件的版本为GIF87a或GIF89a。

逻辑屏幕（Logical Screen）是一个虚拟屏幕（Virtual Screen），它相当于画布，所有的操作都是在它的基础上进行的，同时它也决定了图像的长度和宽度。逻辑屏幕描述块共占有七个字节，其具体结构定义如下：

```c
typedef struct gifscrdesc 
{
unsigned short wWidth;        //逻辑屏幕的宽度
unsigned short wDepth;        //逻辑屏幕的高度
struct globalflag        	  //Packed Fields
{
	BYTE PalBits   : 3;    	  //全局调色板的位数
	BYTE SortFlag  : 1; 	  //全局调色板中的RGB颜色值是否按照使用率进行从高到底的次序排序的
	BYTE ColorRes  : 3; 	  //图像的色彩分辨率
	BYTE GlobalPal : 1; 	  //指明GIF文件中是否具有全局调色板，其值取1表示有全局调色板，为0表示没有全局调色板
}GlobalFlag;
BYTE byBackground;    		  //逻辑屏幕的背景颜色，也就相当于是画布的颜色
BYTE byAspect;        		  //逻辑屏幕的像素的长宽比例
}GIFSCRDESC;
```