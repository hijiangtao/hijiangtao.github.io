---
date: 2014-02-14
layout: post
title: Hadoop2.2.0安装配置文件修改教程
thread: 30
categories: Documents
tags: [hadoop]
excerpt: 
---

Hadoop全分布式部署最后很重要的一点就是hadoop的安装与配置。

**Hadoop搭建系统环境**：三台完全一样的Linux ubuntu-13.04-desktop-i386系统，其中一个做Namenode，另外两个做Datanode。（三个ubuntu系统均搭建在硬件虚拟机上）

**Hadoop安装目标版本**：Hadoop2.2.0

----------

当你进行到这一步的时候，由于hadoop集群在每个机器上面的配置基本相同，所以你可以先在namenode上面进行配置部署，然后再复制到其他datanode节点。

## 1. 解压文件

将[搭建Hadoop环境配置所需软件汇总](http://hijiangtao.github.io/2014/02/14/hadoopsetupsoftware)中下载的hadoop-2.2.0.tar.gz解压到/home/master路径下，然后你就可以将压缩文件删了，如果你的电脑存储空间紧张的话。

----------

## 2. 新建文件夹

这里要涉及到的配置文件有7个：

>~/hadoop-2.2.0/etc/hadoop/hadoop-env.sh

>~/hadoop-2.2.0/etc/hadoop/yarn-env.sh

>~/hadoop-2.2.0/etc/hadoop/slaves

>~/hadoop-2.2.0/etc/hadoop/core-site.xml

>~/hadoop-2.2.0/etc/hadoop/hdfs-site.xml

>~/hadoop-2.2.0/etc/hadoop/mapred-site.xml

>~/hadoop-2.2.0/etc/hadoop/yarn-site.xml

以上个别文件默认不存在的，可以复制相应的template文件获得或者在命令行中直接输入`sudo vim /*相应的文件名*/`来新建。

----------

## 3. 修改配置文件（一）

* 配置文件：hadoop-env.sh

修改JAVA_HOME值（`export JAVA_HOME=/usr/local/jvm/jdk1.7.0`）

* 配置文件：yarn-env.sh

修改JAVA_HOME值（`export JAVA_HOME=/usr/local/jvm/jdk1.7.0`）

* 配置文件：slaves （这个文件里面保存所有slave节点）

写入nisuoyoudeslave节点的名字（假设有两个node节点）：

```
node1
node2
```

以上代码中路径方面的疑惑可参考文章：[jdk安装与配置教程](http://hijiangtao.github.io/2014/02/14/hadoopjdk)

----------

## 4. 修改配置文件（二）

* core-site.xml（假设主机hostname名为master）

```
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://master:9000</value>
</property>
<property>
<name>io.file.buffer.size</name>
<value>131072</value>
</property>
<property>
<name>hadoop.tmp.dir</name>
<value>file:/home/hadoop/tmp</value>
<description>Abase for other temporary directories.</description>
</property>
<property>
<name>hadoop.proxyuser.hduser.hosts</name>
<value>*</value>
</property>
<property>
<name>hadoop.proxyuser.hduser.groups</name>
<value>*</value>
</property>
</configuration>
```

* hdfs-site.xml

```
<configuration>
<property>
<name>dfs.namenode.secondary.http-address</name>
<value>master:9001</value>
</property>
       
<property>
<name>dfs.namenode.name.dir</name>
<value>file:/home/hadoop/dfs/name</value>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>file:/home/hadoop/dfs/data</value>
</property>
<property>
<name>dfs.replication</name>
<value>3</value>
</property>
<property>
<name>dfs.webhdfs.enabled</name>
<value>true</value>
</property>
</configuration>
```

* mapred-site.xml

```
<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
<property>
<name>mapreduce.jobhistory.address</name>
<value>master:10020</value>
</property>
<property>
<name>mapreduce.jobhistory.webapp.address</name>
<value>master:19888</value>
</property>
</configuration>
```

* yarn-site.xml

```
<configuration>
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
<property>
<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
<value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
<property>
<name>yarn.resourcemanager.address</name>
<value>master:8032</value>
</property>
<property>
<name>yarn.resourcemanager.scheduler.address</name>
<value>master:8030</value>
</property>
<property>
<name>yarn.resourcemanager.resource-tracker.address</name>
<value>master:8031</value>
</property>
<property>
<name>yarn.resourcemanager.admin.address</name>
<value>master:8033</value>
</property>
<property>
<name>yarn.resourcemanager.webapp.address</name>
<value>master:8088</value>
</property>
</configuration>
```

----------

## 5. 复制到其他节点

复制可以通过以下语句实现，据体育局根据具体情况而定。以下语句中假设本机hadoop设置存在`/home/hadoop/hadoop-2.2.0`路径中，而对方hostname为`master`，对方IP地址为`192.168.0.3`。

```
    scp –r /home/hadoop/hadoop-2.2.0 master@192.168.0.3:/home/hadoop/
```

最后的话，那么，祝福你的hadoop安装工作一蹴而就。
