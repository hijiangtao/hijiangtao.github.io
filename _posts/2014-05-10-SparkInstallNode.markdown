---
date: 2014-05-10 15:00:00
layout: post
title: Spark的单机部署与测试笔记
thread: 122
categories: Tutorial
tags: [spark, data]
excerpt: 
---

**前言**：Spark作为最有可能代替mapreduce的分布式计算框架，正受到广泛的关注。相比Hadoop来说，Spark的中间计算结果存于内存无疑给计算过程节省了很多时间，于是想试试看其与Hadoop有什么不一样的地方，就有了这篇Spark的单机部署与测试笔记。

----

## 一、硬件环境

* 操作系统： ubuntu-13.04-desktop-i386
* JAVA： jdk1.7
* SSH配置： openssh-server

----

## 二、资源准备

什么是Spark?以下为Spark官网的一句话简介：

Apache Spark™ is a fast and general engine for large-scale data processing. 

Spark包资源下载地址：[点击进入下载页面](http://spark.apache.org/downloads.html)

我安装的版本是：0.9.1版本，源码包为：spark-0.9.1.tgz

Spark有以下四种运行模式：

* **local**：本地单进程模式，用于本地开发测试Spark代码
* **standalone**：分布式集群模式，Master-Worker架构，Master负责调度，Worker负责具体Task的执行
* **on yarn/mesos**：运行在yarn/mesos等资源管理框架之上，yarn/mesos提供资源管理，spark提供计算调度，并可与其他计算框架(如MapReduce/MPI/Storm)共同运行在同一个集群之上
* **on cloud(EC2)**：运行在AWS的EC2之上

Spark支持local模式和cluster模式，local不需要安装mesos；如果需要将spark运行在cluster上，需要安装mesos。

----

## 三、安装部署

先把Scala和git装好，因为之后的sbt/sbt执行的是使用spark自带的sbt编译/打包。

```
sudo apt-get update
sudo apt-get install scala
```

我们需要做的其实就两步，解压缩与编译。

```
$tar -zxvf spark-0.9.1.tgz -C /home/hadoop/software/spark
$cd /home/hadoop/software/spark/spark-0.9.1
$sbt/sbt assembly
```

这一段时间等的会比较长，耐心些。

----

## 四、检验测试

Spark有两种运行模式。

### 4.1 Spark-shell

此模式用于interactive programming，具体使用方法如下(先进入bin文件夹)。

```
$ ./spark-shell
```

出现如下信息：

```
	14/05/10 14:18:23 INFO HttpServer: Starting HTTP Server
	Welcome to
		  ____              __
		 / __/__  ___ _____/ /__
		_\ \/ _ \/ _ `/ __/  '_/
	   /___/ .__/\_,_/_/ /_/\_\   version 0.9.1
		  /_/

	Using Scala version 2.10.3 (Java HotSpot(TM) Server VM, Java 1.7.0_51)
	Type in expressions to have them evaluated.
	Type :help for more information.
	14/05/10 14:18:34 INFO Slf4jLogger: Slf4jLogger started
	14/05/10 14:18:34 INFO Remoting: Starting remoting
	14/05/10 14:18:34 INFO Remoting: Remoting started; 
	……
	Created spark context..
	Spark context available as sc.
```

然后输入如下信息：

```
scala> val days = List("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
days: List[java.lang.String] = List(Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday)

scala> val daysRDD = sc.parallelize(days)
daysRDD: spark.RDD[java.lang.String] = ParallelCollectionRDD[0] at  parallelize at <console>:14

scala> daysRDD.count()
```

在经过一系列计算后，显示如下信息：

>res0: Long = 7

### 4.2 Run脚本

用于运行已经生成的jar包中的代码，如Spark自带的example中的SparkPi.

```
$./bin/run-example org.apache.spark.examples.SparkPi local[3]  
```

local代表本地，[3]表示3个线程跑。

计算结果如下：

>Pi is roughly 3.1444

----

## 五、学习建议

在配置过程中看到他人给的一些建议，于是搜集起来供以后学习参考。

* 如何写一些spark application？

多看一些spark例子，如：<http://www.spark-project.org/examples.html>,<https://github.com/mesos/spark/tree/master/examples>
 
* 遇到问题怎么办？

首先是google遇到的问题，如果还是解决不了就可以到spark google group去向作者提问题：<http://groups.google.com/group/spark-users?hl=en>

* 想深入理解spark怎么办？

阅读spark的理论paper:<http://www.eecs.berkeley.edu/Pubs/TechRpts/2011/EECS-2011-82.pdf>

阅读spark源代码：<https://github.com/mesos/spark>

----

## 声明

本文已经成功投稿至36大数据网站，于2014-05-13发表。[链接地址](http://www.36dsj.com/archives/8001)