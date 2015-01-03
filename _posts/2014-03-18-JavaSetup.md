---
date: 2014-03-18 11:00:00
layout: post
title: JDK+Eclipse环境配置安装笔记
thread: 82
categories: Tutorial
tags: [Java, Eclipse]
---

由于课程要求需要使用Java环境进行开发，于是开始配置Java环境，下载JDK与Eclipse，简单配置后安装完成。

**操作系统**：Windows 7 旗舰版 Service Pack 1
**JDK版本**：jdk-7u51-windows-i586
**Eclipse版本**：eclipse-java-indigo-SR2-win32

----

##一、安装JDK

* 下载JDK（JDK：Java Development Kit，Java开发工具包）。可以到<http://www.oracle.com/technetwork/java/javase/downloads/index.html>下载最新的JDK，这里提供下载的是Java SE（标准版），我安装的是**jdk-7u51-windows-i586**。

*  执行下载的JDK安装文件，接受许可证协议，选择安装位置，其它设定根据需要设置，单击完成按钮，完成JDK的安装。

* **设置环境变量。**在JDK安装完成后，还要设置计算机系统的环境变量，以便其它要用到JDK的软件确定它的安装位置。
在我的计算机中，依次打开我的电脑-高级系统设置-高级-环境变量，然后找到系统变量依次加入JAVA_HOME、PATH、CLASSPATH(大小写无所谓)：

 * JAVA_HOME指明JDK的安装路径，即刚才安装时所选择的路径，比如我的：`D:\Program Files (x86)\Java\jdk1.7.0_51\`。

 * 设置Path，它指明了java和javac的目录，在Path的开头加上`.\;%JAVA_HOME%\bin;\%JAVA_HOME%\jre\bin;`。

 * 最后是CLASSPATH，它指明了Java加载类的路径。如果没有CLASSPATH则添加一个：加入如下信息`.\;%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\jre\lib\rt.jar`

* 环境变量设置成功后，重启电脑，然后打开命令行，输入`java –version和javac –help`来检验Java的配置是否正确。两种情况下，您都应该看到一段真实的结果，而不是有关未知命令的错误消息。

----

##二、安装Eclipse

我安装的版本是eclipse-java-indigo-SR2-win32，你可以根据自己的需要安装不同版本。

[Eclipse下载地址](http://www.eclipse.org/downloads/)

Eclipse是一款绿色软件，安装很方便，只要将下载的压缩包文件解压到指定目录即可。在Eclipse安装目录下找到eclipse.exe执行文件，双击就可以启动Eclipse。

启动后选择工作空间（即您用于存放项目文档的文件夹，就进入Eclipse的欢迎界面。至此，Eclipse就安装完成了。