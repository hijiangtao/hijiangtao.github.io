---
date: 2014-02-14
layout: post
title: jdk安装与配置教程
thread: 29
categories: Tutorial
tags: [hadoop, jdk]
excerpt: 
---

Hadoop全分布式部署很重要的一点就是jdk安装和JAVA的环境配置。

**Hadoop搭建系统环境**：三台完全一样的Linux ubuntu-13.04-desktop-i386系统，其中一个做Namenode，另外两个做Datanode。（三个ubuntu系统均搭建在硬件虚拟机上）

**Hadoop安装目标版本**：Hadoop2.2.0

**jdk安装版本**：jdk-1.7.0

----------

首先要先下载jdk，jdk-1.7.0的下载地址可以在文章[搭建Hadoop环境配置所需软件汇总](http://hijiangtao.github.io/2014/02/14/hadoopsetupsoftware)中找到。

然后，解压到特定位置。

```
sudo tar zxvf ./jdk-7-linux-i586.tar.gz  -C /usr/local/jvm/
```

我们这里解压到jvm文件夹里，以便之后的操作。（如果没有jvm文件夹可以用`mkdir`命令先创建一个jvm文件夹）

在安装hadoop过程中一般都推荐设置一个特定的用户专门用于hadoop使用与操作，我们这里假设新建的用户组为hadoop，则设置目录所属用户命令如下：

```
sudo chown -R hadoop:hadoop
```

之后就是设置环境变量。首先打开profile文件，

```
sudo vim /etc/profile
```

打开之后在空白处加上如下语句：

```
export JAVA_HOME=/usr/local/jvm/jdk1.7.0
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```

退出保存，执行如下语句使得操作立即生效：

```
source /etc/profile
```

最后可以通过`java -version`来验证你之前的安装工作是否正确。

如果之前的操作都是按步骤来进行的话，那么正确的显示结果应该是你当前的java版本号，到此，jdk的安装宣告成功。

最后需要注意的一点是：在hadoop全分布安装过程中每台机器需要执行相同操作，最后将java安装在相同路径下（不是必须的，但这样会使其他的配置方便很多），祝你hadoop安装成功。