---
date: 2014-05-06 12:00:00
layout: post
title: 通过ModelGoon生成java类图
thread: 119
categories: Tutorial
tags: [eclipse, java]
excerpt: 
---

**前言：**课程汇报用到了Eclipse的一个插件，感觉还不错，就把使用方法记录了下来。

----

需求：让Eclipse中现有的java类自动生成类图

###一、什么是ModelGoon？

**工具性质：**它是一个Eclipse插件，用于基于UML图的模型设计，以及逆向工程（即从已有源代码生成类图）。

**解决问题：** Java 包的依赖分析的Eclipse插件，用来显示项目中Java包与包之间的依赖关系。

**特点：**直接拖拽即可使用。



###二、安装

下载ModelGoon-4.4.1-site.zip到电脑，从eclipse中选择help->install new software.在work with->Add选择已经下载的ModelGoon-4.4.1-site.zip，一路next即可完成安装。

下载地址：[ModelGoon-4.4.1-site 链接地址](http://pan.baidu.com/s/1c0vMYPU)  

提取密码: b78v

###三、使用

安装成功后，在eclipse中File-->new-->other-->ModelGoon Diagrams选择Class Diagram，在自己Java工程中创建一个后缀是.mgc的文件，用它来生成类图。

用法很简单，直接把Java类拖拽到这个文件视图中，就会自动生成UML类图。

除此之外，这个插件总共包含有如下三种关系的挖掘生成方案：

1. Class Diagram
2. Interaction Diagram
3. Package Dependencied Diagram

----

**补充**：为什么选择ModelGoon而不是其他的插件？

其他的UML插件也能完成类似的功能，但是在安装使用的过程中会碰到种种问题。

常有人推荐EclipseUML这个插件，但是目前这个项目的主页无法打开，似乎已停止维护；还有Slime UML据说也不错，但是找不到下载源；此外还有AgileJ口碑也不错，可惜是付费的，没有免费版；至于papyrusuml，只是单向的，做模型设计、绘制UML图时使用，而并不支持逆向工程。