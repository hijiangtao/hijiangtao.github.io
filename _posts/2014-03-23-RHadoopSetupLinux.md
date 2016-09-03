---
date: 2014-03-23 23:00:00
layout: post
title: Linux环境下RHadoop配置笔记
thread: 90
categories: Tutorial
tags: [R, hadoop, Linux]
excerpt: 
---

## 一、硬件环境

**操作系统**：Linux ubuntu-13.04-desktop-i386

**jdk安装版本**：jdk-7u51-linux-i586

**硬件虚拟机搭设环境**：IBM塔式服务器x3500M3 MT:7380

**R语言版本**：R-3.0.0

**Hadoop版本**：Hadoop-1.2.1

----

## 二、安装步骤

首先是安装包的下载，其中第一个包没有用上，但既然作为RHadoop一个整体，估计日后还是会用上的，所以先下载下来：

1. plyrmr-0.1.0：[下载链接](http://goo.gl/uIi2KS)
2. rmr-2.2.0：[下载链接](http://goo.gl/bhCU6)
3. rhdfs-1.0.8：[下载链接](https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.8.tar.gz?raw=true)
4. rhbase-1.2.0：[下载链接](https://github.com/RevolutionAnalytics/rhbase/blob/master/build/rhbase_1.2.0.tar.gz?raw=true)

好的，在正式开始前，我们需要确认

* Hadoop安装与配置成功（伪集群或者分布式环境均可）
* Java环境配置成功
* R的环境安装成功

RHadoop是RevolutionAnalytics的工程的项目，开源实现代码在GitHub社区可以找到。RHadoop包含三个R包 (rmr，rhdfs，rhbase)，分别是对应Hadoop系统架构中的MapReduce, HDFS, HBase 三个部分。除了rmr2安装包其他下载最新版的均没问题，点击[下载地址](https://github.com/RevolutionAnalytics/RHadoop/wiki/Downloads)了解更多。

额外需要提出的是，我在安装rmr2时最新版似乎总有不兼容的问题，所以最终决定装2.2.0版本的rmr，下载地址上面已经给出。

接下我们需要先安装这三个库的**依赖库**。

先把下载RHadoop相关的3个程序包复制到你的R目录，我的是`/home/hadoop/software/R/`.

```
sudo cp 原路径 目标路径
```

首先是rJava，运行以下命令，R的程序从系统变量中会读取Java配置。

```
R CMD javareconf
```

然后打开R程序，通过install.packages的方式，安装rJava。

```
R
install.packages("rJava")
install.packages("reshape2")
install.packages("Rcpp")
install.packages("iterators")
install.packages("itertools")
install.packages("digest")
install.packages("RJSONIO")
install.packages("functional")
```

然后是**安装rhdfs库**，但是在这之前最好把HADOOP_CMD设置到环境变量，由于我第一次把它放在/etc/environment没什么反应，然后放在/etc/profile就有用了，让我很是不解，所以最好还是在两个文件里都加上比较保险。

```
HADOOP_CMD=/home/hadoop/software/hadoop/hadoop-2.1.0/bin/hadoop
HADOOP_STREAMING=/home/hadoop/software/hadoop/hadoop-2.1.0/contrib/streaming/hadoop-streaming-2.1.0.jar
```

*注：以上路径你最好根据自己的实际情况进行相应的修改再加入环境变量文件中。*

如果你不想重新启动让配置文件生效的话，那么请记得使用`source /etc/profile`和`source /etc/environment`命令执行一下。然后就是**安装rhdfs库**：

```
R CMD INSTALL /root/R/rhdfs-1.0.8.tar.gz
```

紧接着就是rmr的安装：

```
R CMD INSTALL rmr2_2.1.0.tar.gz
```

在以上过程中我遇到了很多方面的问题，比如进入R之后用library载入rhdfs或者rmr2时发现系统提示不存在该库，这里遇到的问题有几点解决方法：

* 你的R语言目录并没有设置成当前的/home/hadoop/software/R，而是最初系统默认的/usr/local/R，所以你的rhdfs，rJava，rmr2以及那些依赖项都装到系统默认文件路径里了，所以你现在需要做的一件事是通过cp命令把默认路径中的library文件夹拷到目标路径中library中。
* 如果你的当前用户没有root权限的话，进入R中有些操作是无法成功的，所以最好还是在/etc/sudoer里面给自己的用户设上全部权限。

**安装rhbase库 (暂时跳过)**

----

## 三、检验用例

安装好rhdfs和rmr两个包后，我们就可以使用R尝试一些hadoop的操作了。

首先，是基本的hdfs的文件操作。

* **查看hdfs文件目录**

hadoop的命令：hadoop fs -ls /usr
R语言函数：hdfs.ls("/usr/")

*注：R语言操作应该放到R打开里面进行操作*

* **查看hadoop数据文件**

hadoop的命令：hadoop fs -cat /home/hadoop/output/part-m-00000
R语言函数：hdfs.cat("/home/hadoop/output/part-m-00000")

----

## 四、典例分析

这里我们看两个典型例子，一个是rmr写的小程序，一个是hadoop上经典的wordcount程序。

首先普通的R语言程序，不需要进入R环境就可以执行：

```
> small.ints = 1:10
> sapply(small.ints, function(x) x^2)
```

MapReduce的R语言程序，需要进入R后进行操作：

```
> small.ints = to.dfs(1:10)
> mapreduce(input = small.ints, map = function(k, v) cbind(v, v^2))
> from.dfs("/tmp/RtmpEtxz71/file5deb791fcbd5")
```

因为MapReduce只能访问HDFS文件系统，先要用to.dfs把数据存储到HDFS文件系统里。MapReduce的运算结果再用from.dfs函数从HDFS文件系统中取出。

其中上述程序需要额外注意的是`/tmp/RtmpEtxz71/file5deb791fcbd5`是我电脑上用来储存输出文件的路径与文件名，这个在不同的电脑上不同时间与不同用户的操作都有区别，具体文件名与位置需要你在执行完前一个语句时留意查看，在执行from.dfs之前系统会在屏幕中打印出output文件的位置。

然后是wordcount，对文件中的单词计数。

```
> input<- '/home/hadoop/input/f1.txt'
> wordcount = function(input, output = NULL, pattern = " "){

  wc.map = function(., lines) {
            keyval(unlist( strsplit( x = lines,split = pattern)),1)
    }

    wc.reduce =function(word, counts ) {
            keyval(word, sum(counts))
    }         

    mapreduce(input = input ,output = output, input.format = "text",
        map = wc.map, reduce = wc.reduce,combine = T)
}
> wordcount(input)
> from.dfs("/tmp/RtmpfZUFEa/file6cac626aa4a7")
```

其中input文件夹和之前hadoop的操作类似，这里就不过多阐述，相关内容可以参考《[Hadoop第一个样例Wordcount运行笔记](http://hijiangtao.github.io/2014/02/19/wordcountrunning/)》，另外，`/tmp/RtmpfZUFEa/file6cac626aa4a7`依旧因人而异，所以需要你查看具体的路径是什么。

----

## 五、代码操作实践

### rhdfs包的使用

进入R环境之后，输入如下命令操作：

```
> library(rhdfs)
/*成功启动后会提示你hdfs.init()需要开启，执行以下语句即可*/
> hdfs.init()
```

rhdfs查看hadoop目录

```
> hdfs.ls("/usr/")
```

命令查看hadoop数据文件（在hadoop环境）

```
hadoop fs -cat /home/hadoop/input/f1.txt
```

rhdfs查看hadoop数据文件

```
>  hdfs.cat("/home/hadoop/output/part-m-00000")
```

### rmr2包的使用

如下命令启动程序

```
> library(rmr2)
```

启动成功会有如下信息提示：

>Loading required package: Rcpp
>Loading required package: RJSONIO
>Loading required package: digest
>Loading required package: functional
>Loading required package: stringr
>Loading required package: plyr
>Loading required package: reshape2

执行r任务

```
> small.ints = 1:10
> sapply(small.ints, function(x) x^2)
```

执行完结果如下所示：

>[1]   1   4   9  16  25  36  49  64  81 100

其他两个程序上面已经给过演示，故此处省略。

----

## 相关资料

由于RHadoop的安装配置与R语言、Hadoop的安装配置有几分相似，所以列上几篇可能有用的资料以供参考。

1. [Linux环境下R语言安装笔记](http://hijiangtao.github.io/2014/03/21/RSetupinLinux/)
2. [Hadoop2.2.0安装配置文件修改教程](http://hijiangtao.github.io/2014/02/14/hadoopconfmodify)
3. [Hadoop1.2.1伪分布模式安装教程](http://hijiangtao.github.io/2014/02/17/hadoopsetup)
4. [Hadoop1.2.1伪分布式升级全分布式集群改装笔记](http://hijiangtao.github.io/2014/02/18/hadoopclustersetup)

----

好了好了，终于搞定了一个小的阶段性成果，收拾收拾，睡觉去了。明天上课还有一大堆事，对了，还有给老师汇报。新的一周啊，我是那么的不想让你来呢。

最后，感谢统计之都[丹张](http://weibo.com/cosname)的文字资料帮助。感谢中南学长在我漫长的安装过程中接受我的频繁询问与打扰，感谢张桢学姐的理解哈哈。