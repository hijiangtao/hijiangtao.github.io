---
date: 2014-04-26 21:00:00
layout: post
title: Hadoop关键组件与Mahout的阅读资料
thread: 115
categories: Documents
tags: [hadoop, Mahout]
---

**前言**：最近在做阶段性总结汇报，搜集了一些材料，于是罗列下来，以便查看。本文内容包括Hadoop关键组件HDFS与MapReduce的介绍，以及Mahout一些方面的介绍，可以算得上是故事型科普文章吧。

----

##Hadoop分布式文件系统 - HDFS

HDFS 是一个具有高度容错的分布式文件系统，是 GFS 的开源实现，由于它使用分布式的方式存储文件，因此能够提供高数据访问的吞吐量，适合存储由大文件组成的海量（PB 级）数据。HDFS 采用主从结构，也就是所谓的 Master/Slave结构。该文件系统由唯一的 NameNode 和数个 DataNode 组成，NameNode 作为主节点，所有的 DataNode 都是从节点，并且受 NameNode 管理。

**1)  NameNode**
 
NameNode 的功能是管理 HDFS 的名称空间以及对外部客户机访问文件数据的控制。NameNode 规定以怎样的方式将数据存储到 DataNode 上。一般而言对每个文件可有两个备份快，如果需要，可以更多。在这种情况下，通常的策略是将其中一个备份块放在同一机架的相异的节点上，而另一个则放在不同机架的节点上。而 DataNode 及数据块的文件映射的元数据都保存在 NameNode 节点上。在客户机请求创建新文件时，NameNode 会以新创建创建块的标识和该块所对应的DataNode 的 IP 地址响应操作。此外，NameNode 还会创建备份块及其相关信息，并通知备份块所在的 DataNode 接收数据。
 
所有关于文件系统名称空间的数据都被 NameNode 存放在在 FsImage 文件中，NameNode 将该文件及记录所有事务的文件 EditLog 存储在的 NameNode 所在节点的本地文件系统中。为了防止文件被损坏及 NameNode 系统故障，NameNode 对这两个文件也作了备份。 

**2)  DataNode**

HDFS 中通常以机架的形式组织 DataNode，机架之间又通过交换机联系起来，机架内部节点之间的传输速度快于机架间节点的传输速度，因此备份数据块通常会有一个被放在机架内的相异节点上，当某个节点发生故障，就可以快速的将该节点的数据从同一机架的备份中恢复到该机架中的另一个节点上。 

DataNode 不仅要响应 HDFS 的客户机的读写请求，还要对 NameNode 发送对块的操作命令作出响应；每个 DataNode 都会向 NameNode 发送心跳消息，每条消息包中都包含一个块信息相关的报告，NameNode 据此验证块映射和其他文件系统的元数据。如果 NameNode 在规定的时间内没有收到某个 DataNode 发送心跳消息，将对该 DataNode 上的数据将采取修复措施。

**3)  Block**

HDFS(Hadoop Distributed File System)默认的最基本的存储单位是64M的数据块。 

和普通文件系统相同的是，HDFS中的文件是被分成64M一块的数据块存储的。 

不同于普通文件系统的是，HDFS中，如果一个文件小于一个数据块的大小，并不占用整个数据块存储空间。

下面给出一个比较好理解的HDFS工作流程图:

![](/assets/2014-04-26-HadoopHDFS.png "HDFS工作流程图")

----

##MapReduce

作为大规模数据（TB级）计算的利器，MapReduce的主要思想是Map和Reduce，Map 负责将数据进行分散出去，Reduce 负责将计算结果进行聚集，用户只需要实现 map 和 reduce 两个接口，即可实现对 TB 级数据的计算。MapReduce 的计算模式通常被用于日志分析和数据挖掘等数据分析应用。

MapReduce 的实现也采用了主从结构。主节点叫做 JobTracker，从节点叫做TaskTracker。客户机提交的计算任务叫做 Job，使用 MapuReduce 的计算方式，每
一个 Job 会被分解成若干个 Tasks。JobTracker的主要工作是管理及调度调度客户端提交的所有的作业，并且随时监控着 TaskTracker 的运行状态，JobTracker 是整个MapReduce 系统中任务调度的核心。整个 MapReduce 系统中只有有一个JobTracke，这与 HDFS 类似。TaskTracker 主要负责完成完成用户定义的任务，包括 Map 和Reduce 这两种任务。TaskTracker 在运行任务程序的过程中需要定时向JobTracke 节点发送程序运行状态报告，同步任务的完成情况，JobTracker 根据收到所有TaskTracker 发送的任务运行状态报告，就能统计出作业的整体完成进度。

----

##Apache Mahout

Mahout从0.5版本开始加入了对Hadoop的支持，虽然在开源领域较为年轻，但在集群与CF两方面有大量的算法实现。

Mahout 的主要特性包括：

* Taste CF。Taste 是 Sean Owen 在 SourceForge 上发起的一个针对 CF 的开源项目，并在 2008 年被赠予 Mahout。
* 一些支持 Map-Reduce 的集群实现包括 k-Means、模糊 k-Means、Canopy、Dirichlet 和 Mean-Shift。
* Distributed Naive Bayes 和 Complementary Naive Bayes 分类实现。
针对进化编程的分布式适用性功能。
* Matrix 和矢量库。
* 上述算法的示例。

----

##举例：协同过滤推荐构建方法

Mahout 中实现分布式的推荐算法分为三步：构建用户向量、构造协同矩阵、产生推荐结果。

1.构建用户向量：为了将普通的非分布式的协同过滤算法转化为一个基于矩阵的分布式模型，需要把用户对项目的偏好看作是一个向量。在非分布式的算法中，当使用欧几里德距离来度量用户相似度时，只需把用户看成是空间里的点，而相似度就是点之间的距离。同样的，在分布式模型中，用户的偏好就是一个 n 维的向量，每个维度代表一个项目，向量的每个分量代表的是偏好值，0 代表用户对该项目无偏好。这个向量是稀疏的，很多分量都是 0，因为实际中的用户仅对很少的项目有偏好。为了完成推荐，每个用户首先需要这样一个向量。

2.构造协同矩阵：Mahout 中基于项目的协同过滤算法的分布式实现中，要使用到一个协同矩阵，该矩阵的行和列都是项目。而矩阵中的值则是行和列两个项目的协同因子，在这里它表示两个项目被多少个用户同时喜，这样就构造出一个协同矩阵。如有 n 个项目的项目相似度如表 3-1 所示

![](/assets/2014-04-26-MahoutExample.png "项目数为 n 的协同矩阵")
<center>表3-1 项目数为 n 的协同矩阵</center>

在表 3-1 中，项目 1 与项目 2 的协同因子是 3，表示项目 1 与项目 2 同时被 3个用户喜欢，如果两个项目没有同时被任何用户喜欢那么协同因子就是 0，如表3-1 中的项目 1 和项目 5，对于项目对自己的协同因子不用考虑。协同因子很像相似度，两个项目同时出现可以描述这两个项目的相似程度。所以，协同矩阵扮演了项目之间的相似度的角色。

3.产生推荐结果：第一步与第二步构建了推荐所需要的数据，产生结果的方式就是将用户向量与协同矩阵作矩阵乘法即可。

![](/assets/2014-04-26-MahoutResult.png "公式3-1")

式（3-1）是用户 i 的推荐计算结果，通过对R[i1] 到R[in] 排序得出给用户 i 推荐的前 k 个推荐项。

----

整理自：李龙飞，《基于 Hadoop+Mahout 的云应用推荐引擎的研究与实现》，2013