---
date: 2014-04-02 19:00:00
layout: post
title: Mahout安装与配置笔记
thread: 101
categories: Tutorial
tags: [Mahout]
---

##一、硬件环境

**操作系统**：Linux ubuntu-13.04-desktop-i386

**jdk安装版本**：jdk-7u51-linux-i586

**Hadoop版本**：Hadoop-1.1.1（一个Namenode，三个Datanode部署）

----

##二、安装步骤

在Mahout安装之前读过几篇有关机器学习的文章，面对协同过滤、分类聚类等算法的讲解我是深感无力啊，那么深奥的算法实现简直看着就要哭了好嘛，但庆幸的是Mahout的安装配置非常简单，甚至比Hadoop伪集群配置还要简单。

进入Mahout官网找到下载路径，我们下载[0.9版本](http://archive.apache.org/dist/mahout/0.9/)。

首先要做的是解压：

```
tar -zxvf mahout-distribution-0.9.tar.gz /home/mhadoop/software 
```

然后是配置环境变量。在/etc/profile配置文件中加入

```
MAHOUT_HOME=/home/mhadoop/software/mahout-distribution-0.9
PATH=$MAHOUT_HOME/bin
CLASSPATH=$MAHOUT_HOME/lib
export MAHOUT_HOME
```

然后在单机上检验Mahout是否安装完成。使用如下命令看是否能呈现出Mahout中一些集成的算法。

```
mahout -help
```

----

##三、Mahout运行测试

先下载一个数据包作为准备：synthetic_control.data，[下载地址](http://archive.ics.uci.edu/ml/databases/synthetic_control/synthetic_control.data)，并把这个文件放在$MAHOUT_HOME目录下。

然后启动Hadoop：

```
start-all.sh
```

创建测试目录testdata，并把数据导入到这个tastdata目录中（这里的目录的名字只能是testdata）：

```
hadoop fs -mkdir testdata #
hadoop fs -put /home/mhadoop/software/mahout-distribution-0.9/synthetic_control.data testdata
```

运行使用kmeans算法执行程序：

```
hadoop jar /home/mhadoop/software/mahout-distribution-0.9/mahout-examples-0.9-job.jar org.apache.mahout.clustering.syntheticcontrol.kmeans.Job
```

等几分钟过后，查看结果：

```
hadoop fs -lsr output
```

如果在一大堆文件中看到以下结果那么算法即运行成功，你的Mahout安装也就成功了。

>clusteredPoints  clusters-0  clusters-1  clusters-10  clusters-2  clusters-3  clusters-4 clusters-5  clusters-6  clusters-7  clusters-8  clusters-9  data

----

##四、单节点向全分布式转换

Mahout没有Hadoop那么繁琐与复杂，只要你在一台单机上配好环境之后，当你将这个系统复制到其他虚拟机上时，即可直接使用，不需要进行任何配置。

有关Hadoop的配置等资料可以参考：

1. [Linux环境下RHadoop配置笔记](http://hijiangtao.github.io/2014/03/23/RHadoopSetupLinux/)
2. [Hadoop1.2.1伪分布模式安装教程](http://hijiangtao.github.io/2014/02/17/hadoopsetup/)
3. [Hadoop1.2.1伪分布式升级全分布式集群改装笔记](http://hijiangtao.github.io/2014/02/18/hadoopclustersetup/)
4. [搭建Hadoop环境配置所需软件汇总](http://hijiangtao.github.io/2014/02/14/hadoopsetupsoftware/)

----

##附：Mahout简介

Mahout 是一套具有可扩充能力的机器学习类库。它提供机器学习框架的同时，还实现了一些可扩展的机器学习领域经典算法的实现，可以帮助开发人员更加方便快捷地创建智能应用程序。通过和 Apache Hadoop 分布式框架相结合，Mahout 可以有效地使用分布式系统来实现高性能计算。

Mahout 现在提供 4 种使用场景的算法。

• 推荐引擎算法：通过分析用户的使用行为的历史记录来推算用户最可能喜欢的商品、服务、套餐的相关物品。实现时可以基于用户的推荐(通过查找相似的用户来推荐项目)或基于项目的推荐(计算项目之间的相似度并做出推荐)。

• 聚类算法：通过分析将一系列相关的物品等划分为相关性相近的群组。

• 分类算法：通过分析一组已经分类的物品，将其他未分类的其他物品按同样规则归入相应的分类。

• 相关物品分析算法：识别出一系列经常一起出现的物品组(经常一起查询、放入购物 车等)。

Mahout 算法所处理的场景，经常是伴随着海量的用户使用数据的情况。通过将 Mahout 算法构建于 MapReduce 框架之上，将算法的输入、输出和中间结果构建于 HDFS 分布式文件系统之上，使得 Mahout 具有高吞吐、高并发、高可靠性的特点。最终，使业务系统可以高效快速地得到分析结果。

**MapReduce 应用场景**

• 视频分析和检索

使用 Hadoop Map/Reduce 算法，将存放在视频图片库中的海量数据并行分析检索，并可以将分析结果实时汇总，以提供进一步的分析及使用。Map/Reduce 算法使得原来需要几天的分析计算缩短到几个小时，如果需要甚至可以通过添加服务器的方式线性增加系统的处理能力。新的算法，比如数字城市中的车牌识别、套牌分析、车辆轨迹分析等应用，都通过 Map/Reduce 算法部署到服务器集群中。

• 客户流失性分析

风险分析需要在不同数据源的海量数据中使用模式识别技术寻找出具有风险倾向的个体或公司。海量数据的存储、搜索、读取和分析都是需要高计算能力和高吞吐量的系统来实现。使用 Map/Reduce算法可以将复杂的计算动态地分布到服务器集群中的各台服务器上并行处理，可以通过服务器的线性扩充轻易突破计算能力的瓶颈，解决海量数据高性能计算的问题。某运行商将所有的通讯记录实时导入到 HBase 中，一方面通过 HBase 提供实时的通讯记录查询功能，另一方面通过Map/Reduce 分析用户的历史通讯记录以识别出优质客户;当他们的通讯量显著减少时，意味着这些用户可能已转移到其他运行商，从而可以采取特定优惠措施留住这些用户。

• 推荐引擎

推荐引擎工具用于找出物品之间的相关性，然后推荐给用户相似的物品，从而达到进一步吸引用户，提高用户粘性的目的。某购物网站采用 Map/Reduce 分析大量用户的购买记录，计算购买记录间的相似性，从而找出商品间的相关度。然后以商品为索引列出相关的其他商品。在用户购买了某一个商品后，网站根据分析结果推荐给用户可能感兴趣的其他商品。由于用户的购买记录是海量数据，要在特定时间内及时得到分析结果，必需采取 Map/Reduce 的方法对购买记录进行并行统计和汇总。