---
date: 2014-02-17
layout: post
title: Hadoop1.2.1伪分布模式安装教程
thread: 36
categories: Tutorial
tags: [hadoop]
excerpt: 
---

## 一、硬件环境
    
**Hadoop搭建系统环境**：一台Linux ubuntu-13.04-desktop-i386系统，既做Namenode，又做Datanode。（ubuntu系统搭建在硬件虚拟机上）

**Hadoop安装目标版本**：Hadoop1.2.1

**jdk安装版本**：jdk-7u40-linux-i586

**Pig安装版本**：pig-0.11.1

**硬件虚拟机搭设环境**：IBM塔式服务器x3500M3 MT:7380

**eclipse安装版本**：eclipse-standard-kepler-SR1-linux-gtk

----------

## 二、软件环境准备
    
    
### 2.1 Hadoop

Hadoop Release 1.2.1(stable)版本，下载链接：<http://mirror.nexcess.net/apache/hadoop/common/hadoop-1.2.1/>，选择hadoop-1.2.1-bin.tar.gz文件下载。

### 2.2 Java

Java使用的jdk1.7版本，当然可以使用1.6的，下载链接：<http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html>，选择Linux x86的 jdk-7u40-linux-i586.tar.gz版本下载（因为我的Linux机器是32位的）。如果Linux机器是64的就必须选择64位的下载，不同的机器必须要配置不同的jdk版本。

### 2.3 Eclipse

Eclipse选择Linux 32位下载：<https://www.eclipse.org/downloads/>

----

## 三、安装步骤
    
    
### 3.1 添加一个专门为hadoop使用的用户

* 命令行输入：

```
sudo addgroup hadoop
sudo adduser -ingroup hadoop hadoop
```

* 设置hadoop用户的sudo权限：

```
sudo vim /etc/sudoers
```

* 在`root ALL=(ALL:ALL) ALL`下面加一行`hadoop ALL=(ALL:ALL) ALL`

* 切换到hadoop用户：`su hadoop`

### 3.2 创建目录并解压安装包

* 建立目录

```
sudo mkdir /home/hadoop/install
sudo mkdir /home/hadoop/software/hadoop /*该目录存储hadoop程序文件*/
sudo mkdir /home/hadoop/software/java /*该目录存储jdk程序文件。*/
sudo mkdir /home/hadoop/software/eclipse /*该目录存储eclipse程序文件。*/
```

* 解压安装压缩包

```
sudo tar -xzvf '/home/master/下载/jdk-7u40-linux-i586.tar.gz' -C /home/hadoop/software/java/    
sudo tar -xzvf '/home/master/下载/hadoop-1.2.1-bin.tar.gz' -C /home/hadoop/software/hadoop/
```

### 3.3 配置Hadoop

* 配置Java环境

添加JAVA_HOME,CLASSPATH环境变量。使用`sudo vi /etc/profile`命令编辑profile文件，在文件末尾加上以下内容：

```
HADOOP_INSTALL=/home/hadoop/software/hadoop/hadoop-1.2.1/
JAVA_HOME=/home/hadoop/software/java/jdk1.7.0_40
PATH=$JAVA_HOME/bin:$HADOOP_INSTALL/bin:$PATH
CLASSPATH=$JAVA_HOME/lib
export JAVA_HOME PATH CLASSPATH HADOOP_INSTALL
```

然后保存退出，使用`source /etc/profile`使刚刚的更改立即生效。

然后使用`java –version`命令，查看是否配置成功，如果成功会出现以下信息：

>java version “1.7.0_40″

>Java(TM) SE Runtime Environment (build 1.7.0_40-b43)

>Java HotSpot(TM) Client VM (build 24.0-b56, mixed mode)

* 配置SSH环境

使用以下命令设置ssh无密码连接：

```    
ssh-keygen
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
ssh localhost
```

最后一行代码为测试使用。首次运行会提示是否继续，输入yes，回车，如果不要求输入密码，就表示成功了。

* 配置hadoop环境

通过`cd /home/hadoop/software/hadoop/hadoop-1.2.1/conf`进到conf这个目录，看到haddoop-env.sh,core-site.xml,mapred-site.xml,hdfs-site.xml这四个文件以及需要在完全分布模式配置的slaves和masters文件。

1.**配置hadoop-env.sh**：找到JAVA_HOME关键字所在的行，把前面的#号去掉，然后填写实际的JAVA_HOME地址：

```
export  JAVA_HOME=/home/hadoop/software/java/jdk1.7.0_40
```

2.**配置core-site.xml**：用`vi core-site.xml`打开core-site.xml文件，然后在configuration标签中加入以下内容：

```
<property>
<name>fs.default.name</name>
<value>hdfs://localhost:9000</value>
</property>
<!—fs.default.name：用来配置namenode,指定HDFS文件系统的URL，通过该URL我们可以访问文件系统的内容，也可以把localhost换成本机IP地址；如果是完全分布模式，则必须把localhost改为实际namenode机器的IP地址；如果不写端口，则使用默认端口8020。 –>
<property>
<name>hadoop.tmp.dir</name>
<value>/home/hadoop/tmp/hadoop_tmp</value>
</property>
<!– hadoop.tmp.dir：Hadoop的默认临时路径，这个最好配置，如果在新增节点或者其他情况下莫名其妙的DataNode启动不了，就删除此文件中的tmp目录即可。不过如果删除了NameNode机器的此目录，那么就需要重新执行NameNode格式化的命令。该目录必须预先手工创建。–>
```

3.**配置hdfs-site.xml**：在configuration标签中加入以下内容：

```
<property>
<name>dfs.data.dir</name>
<value>/home/hadoop/appdata/hadoopdata</value>
</property>
<!–配置HDFS存储目录,数据存放目录,用于datanode存放数据–>
<property>
<name>dfs.name.dir</name>
<value>/home/hadoop/appdata/hadoopname</value>
</property>
<!—用来存储namenode的文件系统元数据，包括编辑日志和文件系统映像，如果更换地址的话，则需要重新使用hadoop namenode –format命令格式化namenode–>
<property>
<name>dfs.replication</name>
<value>1</value>
</property>
<!—用来设置文件系统冗余备份数量，因为只有一个节点，所有设置为1，系统默认数量为3–>
```

注：之前在网上查到的资料显示有*所有不存在的目录都要预先创建*，但在实际操作中格式化过程经常出现错误，结果为namenode无法跑起来，多次经过查看错误日志发现是hadoopdata和hadoopname的配置存在，使得hadoop不允许格式化，所以当hadoop配置不成功时，建议查看一下日志，可以尝试将这两个文件夹删除再运行一次。

**hdfs-site.xml配置中两个文件夹不能提前建立的原因**：感谢网友**上海-草头**的提醒，hadoop为了防止错误格式化已存在的集群，在这两个文件夹存在时，是不允许格式化的。

4.**配置mapred-site.xml**：在configuration标签中加入以下内容：

```
<property>
<name>mapred.job.tracker</name>
<value>localhost:9001</value>
</property>
<!—该项配置用来配置jobtracker节点，localhost也可以换成本机的IP地址；真实分布模式下注意更改成实际jobtracker机器的IP地址–>
```

----

## 四、启动hadoop
    
    
### 4.1 测试hadoop配置是否成功
   
通过以下命令，当我们看到hadoop的版本时则表明配置无误。
   
```
hadoop version
``` 
   
### 4.2 格式化namenode
   
```
cd /home/hadoop/software/hadoop/hadoop-1.2.1/bin
./hadoop namenode –format
``` 
   
### 4.3 启动hadoop进程
   
```
cd /home/hadoop/software/hadoop/hadoop-1.2.1/bin
./start-all.sh
```
   
通过java的`jps`命令来查看进程是否启动成功，成功启动SecondaryNamenode，JobTracker，NameNode，DataNode，TraskTracker五个进程则OK。

如果有一个进程没有启动成功，就表示整个集群没有正常工作，进入`/home/hadoop/software/hadoop/hadoop-1.2.1/libexec/../logs/`目录下可以查看失败日记。
   
### 4.4 从浏览器查看hadoop信息
   
**查看jobtracker信息**:

可以从本机或者其他机器的浏览器访问hadoop，输入如下网址：<http://10.1.151.168:50030/jobtracker.jsp>，其中10.1.151.168为我该机器的IP地址。

**查看namenode信息**：

<http://10.1.151.168:50070/dfshealth.jsp>

**查看trasktracker信息**：

<http://10.1.151.168:50060/tasktracker.jsp>

----

## 错误笔记
    
    
* **password:localhost:permission denied,please try again**

碰到这种情况大都是没有给hadoop用户赋予sudo权限所致。所以打开你的`/etc/sudoers`加上`hadoop ALL=(ALL:ALL) ALL`吧。

* **Tasktracker无法正常启动**

通过查找logs中tasktracker的错误日志发现其中有一个warn是相应目录下`temp/hadoop_tmp.mapred/local/`文件的权限被设置成`not writable`了。于是通过修改权限解决了上述的问题，命令如下：

```
sudo chmod 777 /home/hadoop/temp/hadoop_tmp.mapred/local/
```

* **每次开机都需要把/etc/profile重新source一遍，不然就显示没装jdk**

这个问题还是没有解决，因为还没找到原因所在。怎么办呢，算了，每次繁琐一点source一遍吧，暂时先这样了。

* **SafeMode: ON - HDFS unavailable**，导致nodes显示为0，没有namenode启动。

经过查询是hdfs-site.xml配置中的dfs.name.dir的value所在的目录出了问题，显示是：xxx is in an inconsistent state: storage directory does not exist or is not accessible.其中xxx代表那个目录，不断的重启与格式化总是不能解决这个问题，删不删除这个目录也都无济于事。是的，我疯了，你看到我疯狂的眼神了么？终于，突然想到了`chown`的作用，于是我执行了如下指令：

```
sudo  chown -R hadoop:hadoop /home/hadoop/appdata/
```

重新格式化，然后start-all.sh，搞定了！总结为文件的权限问题。

----

## 后记
    
    
Hadoop1.2.1单机版搞定，老泪纵横啊！要是早一天我就可以向老师汇报我的胜利果实了！明天加油搞定全分布式集群配置！

感谢这段时间被我不断骚扰的中南学长和伍翀学长。

----

## 声明

本文已经成功投稿至36大数据网站，于2014-02-19发表。[链接地址](http://www.36dsj.com/archives/6088)
