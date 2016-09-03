---
date: 2014-02-18
layout: post
title: Hadoop1.2.1伪分布式升级全分布式集群改装笔记
thread: 38
categories: Tutorial
tags: [hadoop]
excerpt: 
---

## 一、硬件环境
    
**Hadoop搭建系统环境**：三台完全一样的Linux ubuntu-13.04-desktop-i386系统，其中一个做Namenode和Datanode，另外两个做Datanode。（三个ubuntu系统均搭建在硬件虚拟机上）

**Hadoop安装目标版本**：Hadoop1.2.1

**jdk安装版本**：jdk-7u40-linux-i586

**Pig安装版本**：pig-0.11.1

**硬件虚拟机搭设环境**：IBM塔式服务器x3500M3 MT:7380

**eclipse安装版本**：eclipse-standard-kepler-SR1-linux-gtk

----------
   
## 二、改装步骤
   
   
### 2.1 创建两个Datanode节点系统

先用VMware vsphere client将一个ubuntu系统复制两份，系统分别命名为node1和node2。VMware vsphere client使用可以查看[VMware vsphere client安装笔记](http://hijiangtao.github.io/2014/02/18/vmwaresetup)。

### 2.2 修改Datanode系统中IP与主机名

在打开每个系统的hostname文件，分别将名字改为node1和node2。

```
sudo vim /etc/hostname
```

在每个系统的hosts文件中加入如下内容，以使联机运作时各节点能够被识别：

```
10.1.151.168   master
10.1.151.178   node1
10.1.151.188   node2
```

### 2.3 修改hadoop配置文件

* **core-site.xml**

将之前填写的localhost替换为master主机的实际IP，修改成果如下：

```
<property>
<name>fs.default.name</name>
<value>hdfs://10.1.151.168:9000</value>
</propety>
<property>
<name>hadoop.tmp.dir</name>
<value>/home/hadoop/tmp/hadoop_tmp</value>
</property>
```

* **hdfs-site.xml**

将节点数由1改为3：

```
<property>
<name>dfs.data.dir</name>
<value>/home/hadoop/appdata/hadoopdata</value>
</property>
<property>
<name>dfs.name.dir</name>
<value>/home/hadoop/appdata/hadoopname</value>
</property>
<property>
<name>dfs.replication</name>
<value>3</value>
</proerty>
```

* **mapred-site.xml**

localhost修改如下：

```
<property>
<name>mapred.job.tracker</name>
<value>10.1.151.168:9001</value>
</property>
```

### 2.4 namenode配置

进入conf目录修改masters文件，填写集群master名如：

```
master
```

保存退出然后打开slaves文件，添加作为slave的主机名，一行一个。

```
master
node1
node2
```

----

## 三、测试运行

### 3.1 格式化namenode

```
./hadoop namenode –format
```

### 3.2 启动hadoop进程

```
./start-all.sh
```

检验方法和伪分布式相同，此处不再赘述。相关操作可以查看[Hadoop1.2.1伪分布模式安装教程](/2014/02/17/hadoopsetup)。

----

## 错误笔记

1. 启动时发现莫名其妙的datanode没有启动，从logs日志中看到`Incompatible namespaceIDs in /home/hadoop/tmp/hadoop_tmp`，想起来这个文件夹是自己新建的，是不是伪分布式时在里面产生了垃圾？于是sudo rm -rf然后sudo mkdir重来了一次，想想不安全我再把其他的之前新建的文件夹全部重新按照这个方法操作了一次；最后-format然后./start-all.sh，搞定啦。Datanode、JobTracker、SecondaryNameNode、Jps、TaskTracker、NameNode全部启动。