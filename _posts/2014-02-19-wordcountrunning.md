---
date: 2014-02-19
layout: post
title: Hadoop第一个样例Wordcount运行笔记
thread: 39
categories: Documents
tags: [hadoop]
excerpt: 
---

## 一、硬件环境
    
    
**Hadoop搭建系统环境**：三台完全一样的Linux ubuntu-13.04-desktop-i386系统，其中一个做Namenode和Datanode，另外两个做Datanode。

**Hadoop安装目标版本**：Hadoop1.2.1

----------
   
## 二、运行步骤
      
### 2.1 进入bin目录

```
cd /home/hadoop/software/hadoop/hadoop-1.2.1/bin
```

### 2.2 新建输入文件内容

在当前目录新建一个文件夹叫input，在文件夹里新建三个文件f1.txt,f2.txt,f3.txt，并分别写入一些内容。

```
sudo mkdir input
sudo sh -c 'echo "hello hadoop" > input/f1.txt'
sudo sh -c 'echo "hello java" > input/f2.txt'
sudo sh -c 'echo "hello world" > input/f3.txt'
```

### 2.3 在运行的hadoop中创建文件夹

注意在操作之前，一定要保证这个时候hadoop已经正常运行，datanode、jodtracker、namenode等必要信息均显示正常。

使用如下的命令创建文件夹

```
hadoop dfs -mkdir /home/hadoop/input
/*注意相对路径，这里的/home/hadoop是我当前用户的目录，可根据自己具体情况进行改动*/
```

然后查看我们在hadoop中是否已经成功创建了该文件夹：

```
hadoop dfs -ls /home/hadoop
```

如果我们能看到类似`drwr-xr-x ....../home/hadoop/input`字样那表明我们这一步已经成功了。

### 2.4 把文件复制到hadoop中

```
hadoop dfs -put input/* /home/hadoop/input
/*记住此时用户所在的还是之前的bin文件夹，上面一行的/*表示文件夹所有文件，并非注释*/
```

然后查看文件是否在hadoop中，并查看文件内容是否和输入的一致：

```
hadoop dfs -ls /home/hadoop/input
hadoop dfs -cat /home/hadoop/input/f1.txt
```

注：我们可以通过`10.1.151.168：50070/dfshealth.jsp`来从浏览器中查看整个hdfs文件系统的目录，打开namenode的链接，点击其中的`Browse the filesystem`超级链接，就可以看到相应的目录结构了。

### 2.5 运行example例子

我们要运行的例子在hadoop的安装目录下，名称叫做hadoop-examples-1.2.1.jar。到了这一步，无疑是出错率最高的时候，运行命令如下：

```
./hadoop jar ../hadoop-examples-1.2.1.jar wordcount /home/hadoop/input /home/hadoop/output
/*请记住上述命令中三个比较重要的参数，请务必改成自己电脑中相应的examples所在路径、input、output所在路径*/
```

其中，output是输出文件夹，必须不存在，它由程序自动创建，如果预先存在output文件夹，则会报错。

在操作之前，请务必多次检查如下内容：

1. 自己的input目录是否已经存入输入内容；

2. output文件夹是否存在；

3. 运行的hadoop用jps查看一下是否所有应该运行的进程都存在；

4. 如果之前开过hadoop运行，这不是第一次开的话。可以试试先`./stop-all.sh`，然后把core-site.xml中的hadoop.tmp.dir的value所在路径，即`/home/hadoop/tmp/hadoop_tmp`删除，然后重新建立一遍，如果你是新建的hadoop用户，最好用chown指令再把文件的所属更改一下。如上一样的操作对hdfs-site.xml中的dfs.data.dir的value路径做一遍。最好对所有datanode和namenode也做一遍，保险起见。因为，我就是这些小细节上出了问题，由于之前运行导致这些本应该空的文件夹中存在文件，而频繁报错。

5. 如果之前运行过wordcount报错记住还要用命令`hadoop dfs -rmr output/*output为你的输出文件夹路径*/`把output文件夹删除。报错内容如下：

```
Exception inthread "main" org.apache.hadoop.mapred.FileAlreadyExistsException:Output directory output already exists
        atorg.apache.hadoop.mapreduce.lib.output.FileOutputFormat.checkOutputSpecs(FileOutputFormat.java:134)
        atorg.apache.hadoop.mapred.JobClient$2.run(JobClient.java:830)
        atorg.apache.hadoop.mapred.JobClient$2.run(JobClient.java:791)
        atjava.security.AccessController.doPrivileged(Native Method)
        at javax.security.auth.Subject.doAs(Subject.java:415)
        atorg.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1059)
        atorg.apache.hadoop.mapred.JobClient.submitJobInternal(JobClient.java:791)
        atorg.apache.hadoop.mapreduce.Job.submit(Job.java:465)
        atorg.apache.hadoop.mapreduce.Job.waitForCompletion(Job.java:494)
        atorg.apache.hadoop.examples.WordCount.main(WordCount.java:67)
        atsun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
        atsun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        atjava.lang.reflect.Method.invoke(Method.java:601)
        at org.apache.hadoop.util.RunJar.main(RunJar.java:156)
```

### 2.6 查看运行结果

我们可以查看output文件夹的内容来检查程序是否成功创建文件夹，通过查看output文件里面的part-r-00000文件的内容来检查程序执行结果：

```
./hadoop dfs -cat /home/hadoop/output/part-r-00000
```

正常显示结果会像如下样式一样：

>hadoop   1

>hello       3

>jave         1

>world      1

我们可以看到hadoop出现一次，hello出现3次，java出现一次，world出现一次，这跟预期是一样的，说明执行成功。

### 2.7 关闭hadoop进程

如果我们要关闭hadoop集群，则只需要运行stop-all.sh：

```
cd /data/software/hadoop/hadoop-1.2.1/bin
./stop-all.sh
```

再次运行jps时，只有一个jps进程在运行，其它hadoop的进程都已经关闭了。

----

## 错误笔记

**1. 启动时发现莫名其妙的datanode没有启动。**

从logs日志中看到`Incompatible namespaceIDs in /home/hadoop/tmp/hadoop_tmp`，想起来这个文件夹是自己新建的，是不是伪分布式时在里面产生了垃圾？于是sudo rm -rf然后sudo mkdir重来了一次，想想不安全我再把其他的之前新建的文件夹全部重新按照这个方法操作了一次；最后-format然后./start-all.sh，搞定啦。Datanode、JobTracker、SecondaryNameNode、Jps、TaskTracker、NameNode全部启动。

**2. 遇到sudo重定向权限不够的问题。**

众所周知，使用 echo 并配合命令重定向是实现向文件中写入信息的快捷方式。比如要向 test.asc 文件中随便写入点内容，可以：

```
echo "信息" > test.asc
echo "信息" >> test.asc
/*以上两种写法都可以*/
```

下面，如果将 test.asc 权限设置为只有 root 用户才有权限进行写操作，则：

```
sudo chown root.root test.asc
```

然后，我们使用 sudo 并配合 echo 命令再次向修改权限之后的 test.asc 文件中写入信息： 

```
sudo echo "又一行信息" >> test.asc
-bash: test.asc: Permission denied
```

这时，可以看到 bash 拒绝这么做，说是权限不够。这是因为重定向符号 “>” 和 ">>" 也是 bash 的命令。我们使用 sudo 只是让 echo 命令具有了 root 权限，但是没有让 “>” 和 ">>" 命令也具有 root 权限，所以 bash 会认为这两个命令都没有像 test.asc 文件写入信息的权限。

解决办法如下：

```
sudo sh -c 'echo "又一行信息" >> test.asc'
echo "第三条信息" | sudo tee -a test.asc
/*以上两行任选一行即可实现*/
```

**3. snappy native library not loaded**

出现这种情况可能是你core-site.xml中文件路径写的不一致造成的，比如我的hadoop一致路径是/tmp/hadoop_tmp，但是在里面错写成了/temp，修改保存，重新格式化重启即可解决。

**4. org.apache.hadoop.security.UserGroupInformation: PriviledgedActionException**

报错样式类似如下：

```
2014-02-18 23:36:22,717 ERROR org.apache.hadoop.security.UserGroupInformation: PriviledgedActionException as:hadoop cause:java.io.IOException: File /usr/hadoop_dir/tmp/mapred/system/jobtracker.info could only be replicated to 0 nodes, instead of 1

2014-02-18 23:36:22,718 INFO org.apache.hadoop.ipc.Server: IPC Server handler 4 on 49000, call addBlock(/usr/hadoop_dir/tmp/mapred/system/jobtracker.info, DFSClient_NONMAPREDUCE_1570390041_1, null) from 10.1.151.168:56700: error: java.io.IOException: File /usr/hadoop_dir/tmp/mapred/system/jobtracker.info could only be replicated to 0 nodes, instead of 1
```

从网上搜了一下这个问题，解决方案可以试试如下几个：

* 将masters与slaves中的主机配置为IP地址。

* 网上也有说防火墙没有关，也请检查一下。

* 重新格式化namenode hadoop namenode -format，并检查version文件中的ID

* 检查core-stite.xml mapred-site.xml 文件地址换成IP

* 检查相关日志，查看错误信息

* 注意datanode目录权限一定是 755

* 也有可能是java的bug引起的

**5. 其他N多错误**

我在运行中也出现过其他很多方面的错误，最有效且最快找到出错的方法就是查看log文件了，哪个地方没有正常开启，就去对应进程的.log文件查看。比较烦人的是.log文件内容是按照日期递增顺序进行写入内容的，意思就是你每次要查看最新的运行信息必须要往下翻翻翻。

---

衷心感谢在hadoop伪分布式到全分布式转换调试过程中一直被我烦着的中南和伍翀两位学长！感谢Google拥有的海量资料给我提供的帮助。

----

## 声明

本文已经成功投稿至36大数据网站，于2014-02-26发表。[链接地址](http://www.36dsj.com/archives/6118)