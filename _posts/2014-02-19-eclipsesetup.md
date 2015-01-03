---
date: 2014-02-19
layout: post
title: Linux上Eclipse安装教程
thread: 40
categories: Tutorial
tags: [linux]
---

本来下午写了许多关于Spark语法学习的心得和一些对大数据理解的东西，但不知怎么心里一股烦躁的情绪总是无法褪去，于是就一行行最后还是删了，想到hadoop搭好了但是eclipse还没有安装，于是就把eclipse安装了，安装笔记记载在下面了。

----

##一、硬件环境

**操作系统环境**：Linux ubuntu-13.04-desktop-i386

**eclipse安装版本**：eclipse-standard-kepler-SR1-linux-gtk

----

##二、安装步骤
    
###2.1 下载eclipse安装包
    
下载地址可以到我博客[Hadoop1.2.1伪分布模式安装教程](http://hijiangtao.github.io/2014/02/17/hadoopsetup/)中找到，经过下载我们把它放在`/usr/local/`里。

###2.2 解压并配置环境变量

```
sudo tar -zxvf '/usr/local/eclipse-standard-kepler-SR1-linux-gtk.tar.gz' -C /home/hadoop/software/eclipse
sudo /etc/profile
```

在profile中加入如下语句：

```
PATH=$PATH:/home/hadoop/software/eclipse/eclipse
export PATH
```

###2.3 启动eclipse

重启或者使用命令`source /etc/profile`，然后命令行输入eclipse就可以打开了。

虽然输入eclipse可以启动eclipse，但是每次输入eclipse后，在终端下就不能进行其它的操作了。当然，你可以每次在eclipse命令后加上“&”，让其在后台运行，但是每次这样很是烦人。这个问题可以这样解决，在终端下输入：alias eclipse='eclipse&'，这样每次直接输入eclipse就可以让eclipse在后台运行了.这个也要在/etc/profileh或者.bashrc文件中配置，否则退出终端时将失效。

----

**小技巧**

在配置诸如/etc/profile这类文件时，可将其备份，重命名为.default格式，当配置错误时，将文件删除,将.default格式改为原来的名字即可，即将后缀.default去掉即可。