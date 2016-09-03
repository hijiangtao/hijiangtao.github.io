---
date: 2014-03-21 20:00:00
layout: post
title: Linux环境下R语言安装笔记
thread: 89
categories: Tutorial
tags: [R, Linux]
excerpt: 
---

## 一、硬件环境

**操作系统**：Linux ubuntu-13.04-desktop-i386

**jdk安装版本**：jdk-7u51-linux-i586

**硬件虚拟机搭设环境**：IBM塔式服务器x3500M3 MT:7380

----

## 二、安装步骤

**R语言软件准备**：在R语言官网<http://www.r-project.org/>找到R-3.0.0版本下载下来。然后用以下命令解压缩R压缩包到你设定的工作目录：

```
sudo tar -xzvf '/home/master/下载/R-3.0.0.tar.gz'
```

此时，R压缩包解压在根目录，所以用以下命令进入R源文件目录：

```
cd R-3.0.0
```

执行如下命令（--prefix是关键，R是自建文件夹，可根据需要自行修改）。

```
./configure --prefix /home/work/R
```

由于我折腾的经验，这里很大程度会出问题，并且提示错误信息为

>“configure: error: No F77 compiler found”

执行命令yum install gcc-gfortran解决。再次执行./configure，报错：

>“configure: error: --with-readline=yes (default) and headers/libs are not available”

如果在这个时候执行命令`./configure --with-readline=no`，会继续报错：

>“configure: error: –with-x=yes (default) and X11 headers/libs are not available”

尝试执行命令`./configure --with-readline=no --with-x=no`能通过，只是会提示警告信息：

```
configure: WARNING: you cannot build DVI versions of the R manuals
configure: WARNING: you cannot build DVI versions of all the help pages
configure: WARNING: you cannot build info or HTML versions of the R manuals
configure: WARNING: you cannot build PDF versions of the R manuals
configure: WARNING: you cannot build PDF versions of all the help pages
```

而如果以上最后两个问题暂时这样解决的话，后面会出现更大的问题：**进入R命令行界面，可以操作。但是tab自动补全以及上下左右等方向键都无法使用。**

所以，这里我们找到报错的原因：其实是相关的依赖项没有安装，所以按照提示安装好就是了。

 * 如果系统会提示未找到G77编译器的错误，需要安装一个gfortran，运行命令

```
sudo apt-get install build-essential
sudo apt-get install gfortran
```

 * 如果出现错误：
 
>configure: error: –with-readline=yes (default) and headers/libs are not available

需要安装libreadline6-dev：

```
sudo apt-get install libreadline6-dev
```

* 如果出现错误：

>configure: error: –with-x=yes (default) and X11 headers/libs are not available

需要安装libxt-dev：

```
sudo apt-get install libxt-dev
```

所有依赖包安装好之后，配置就可以成功，此时进行编译就能成功，执行如下两行命令：

```
make
sudo make install
```

配置环境变量，命令如下：

```
sudo vi /etc/profile
```

打开文件后，在PATH=后再加 :${HOME}/R/bin（这里的bin别丢了哦），并另起一行加上HOME的路径，对于我来说是`/home/hadoop/software`


重新登入，然后就可以用了。（或者执行： `source /etc/profile`就不用重新登入了）

进入R命令行界面，可以操作。

----

R语言算是安装好了，休息一会儿继续配置RHadoop，生命在于不停的奋斗啊！