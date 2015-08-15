---
date: 2014-02-14
layout: post
title: 搭建Hadoop环境配置所需软件汇总
thread: 28
categories: Tutorial
tags: [hadoop, ssh]
excerpt: 
---

搭了两天的Hadoop集群环境了最后还是死在ssh配置上了，记忆中没错的话我就是一步步按照教程来的，但看到`Permission Denied`和进入另一台主机时需要输入密码，我真的快要绝望了。忙了一天怕是晚上再在这上面死耗下去，不仅没进展还会拖死下周一的汇报。

算了，还是整理整理这两天hadoop搭建过程中学到的一些知识吧，理清些思路。

**Hadoop搭建系统环境**：三台完全一样的Linux ubuntu-13.04-desktop-i386系统，其中一个做Namenode，另外两个做Datanode。（三个ubuntu系统均搭建在硬件虚拟机上）

**Hadoop安装目标版本**：Hadoop2.2.0

----------

##1. Vim编辑器

因为在开机维护模式下或者一些特殊情况中gedit不能使用，所以最好还是用vim来编辑。Vim的安装比较简单，一行搞定。

```
sudo apt-get install vim
```

使用起来也很方便，一般`sudo vim /*你需要编辑的文件的路径*/`打开你的文件，然后使光标移动到相应位置按下`i`进行插入操作。编辑完毕按下`Esc`进入命令模式，然后`:w`保存，`:q`退出文件。

其中需要注意的是，如果`:w`无法保存文件，可以尝试在命令后加一个`!`试试，这是强制执行的意思。

----------

##2. SSH配置

配置ssh的好处是这样会使得虚拟机的管理变得非常方便。

安装的时候以下两行代码中任取一行即可。

```
sudo apt-get install openssh-server /*1st method*/
sudo apt-get install ssh /*2nd method*/
```

安装完ssh后最重要的一点就是要实现它的<font color="#dd0000">local免密码登录</font>。.ssh无密码登录本机，也就是说ssh到本机不需要密码，而这也是配置好之后登陆的检验标准之一。

这一块工作分为两项：

* ssh密钥生成。

```
ssh-keygen
```

执行以上代码，在过程中连续按下三次回车键即可产生密钥。通过`ssh-copy-id`命令把密钥复制到`.ssh`的`authorized_keys`中，这个key在这里相当于白名单。

```
ssh-copy-id namenode
/*namenode为本机的hostname，可根据不同情况相应修改*/
```

2. ssh密钥复制给datanode。

除了自己需要，还要让datanode知道自己是可信任的，所以这里需要把namenode产生的密钥复制给每一个datanode。

网上介绍了一个通过`scp`实现的复制过程，在这种方法里，命令行中需要执行的代码为：

```
scp authorized_keys slave1@node1:~/.ssh/authorized_keys
```

我不推荐使用这个语句，还是和之前一样`ssh-copy-id`可以实现这一目的。

```
ssh-copy-id slave1
```

你唯一需要注意的是后面跟的名字要写对，之后输入slave1对应的密码，不出差错的话应该就复制成功了。

以上两步的检验可以通过以下语句实现：

```
ssh localhost
ssh slave1
```

如果再不要求输入密码的情况下出现了Welcome语句，那么恭喜你ssh这一步你已经打通了。

----------

##3. 关闭防火墙

在ubuntu系统中通过以下语句即可实现该功能，需要注意的是该功能重启后生效。

```
ufw disable
```

而redhat中通过以下语句实现：

```
/etc/init.d/iptables stop //关闭防火墙。
chkconfig iptables off //关闭开机启动。
```

----------

##4. JDK&Hadoop&Pig下载地址

网上找个教程辛辛苦苦跟着做了一段时间最后发现下载地址没有，真是气愤，如下贴上hadoop安装过程中用得到的几个软件的官方下载地址。

* [jdk-7-linux-i586.tar.gz](http://www.oracle.com/technetwork/cn/java/javase/downloads/java-se-jdk-7-download-432154-zhs.html)

* [hadoop-2.2.0](http://mirrors.sonic.net/apache/hadoop/common/hadoop-2.2.0/)

* [pig-0.11.1](http://www.apache.org/dist/pig/pig-0.11.1/)