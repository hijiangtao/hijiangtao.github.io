---
date: 2014-04-10 09:00:00
layout: post
title: Hadoop生态圈（Hadoop Ecosystem）
thread: 110
categories: Documents
tags: [hadoop]
excerpt: 
---

Hadoop有一套自己强大的生态系统，并且仍在不断壮大，系统的了解这个生态系统里的各个组件对于数据分析与挖掘工作来说必定是件好事。以下为我从一个论坛上看到的有关hadoop生态系统的介绍，故摘录过来以便以后学习查看。

![](/assets/2014-04-10-HadoopEcosystemMap.png "")

----

上图为Hadoop生态系统的图谱，以下详细列举在Hadoop生态系统中出现的各种数据工具。

这一切，都起源自Web数据爆炸时代的来临：

1. 数据抓取系统 － Nutch
2. 海量数据怎么存，当然是用分布式文件系统 － HDFS

数据怎么用呢？分析与处理：

1. MapReduce框架，让你编写代码来实现对大数据的分析工作；
2. 非结构化数据（日志）收集处理 － fuse,webdav, chukwa, flume, Scribe；
3. 数据导入到HDFS中，至此RDBSM也可以加入HDFS的狂欢了 － Hiho, sqoop；
4. MapReduce太麻烦，好吧，让你用熟悉的方式来操作Hadoop里的数据 – Pig, Hive, Jaql；
5. 让你的数据可见 － drilldown, Intellicus用高级语言管理你的任务流 – oozie, Cascading；
6. Hadoop当然也有自己的监控管理工具 – Hue, karmasphere, eclipse plugin, cacti, ganglia；
7. 数据序列化处理与任务调度 – Avro, Zookeeper
8. 更多构建在Hadoop上层的服务 – Mahout, Elastic map Reduce
9. OLTP存储系统 – Hbase