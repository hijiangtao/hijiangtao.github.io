---
date: 2014-02-13
layout: post
title: Ubuntu系统网络管理器显示“设备未托管”解决方法
thread: 26
categories: Tutorial
tags: [ubuntu]
excerpt: 
---

**系统环境**：Linux ubuntu-13.04-desktop-i386

###解决方案

在hadoop环境配置过程中由于增加了一个用户组，对sudoers进行了修改，导致Network Manager显示“设备未托管”，即ubuntu无法正常联网。从谷歌搜到如下解决方案：

* 修改如下位置文件（将`false`改成`true`）：

```
/etc/NetworkManager/NetworkManager.conf
```

```
[ifupdown]
managed=true
```

* 重新启动ubuntu即可。

###原因

Linux里面有两套管理网络连接的方案：

1. `/etc/network/interfaces（/etc/init.d/networking）`

2. `Network-Manager`

两套方案是冲突的，不能同时共存。

第一个方案适用于没有X的环境，如：服务器；或者那些完全不需要改动连接的场合。

第二套方案使用于有桌面的环境，特别是笔记本，搬来搬去，网络连接情况随时会变的。

他们两个为了避免冲突，又能共享配置，就有了下面的解决方案：

1. 当Network-Manager发现/etc/network/interfaces被改动的时候，则关闭自己（显示为未托管），除非managed设置成 true。

2. 当managed设置成 true 时，/etc/network/interfaces，则不生效。

----

整理自：[Ubuntu10.10网络管理器问题](http://www.cnblogs.com/babykick/archive/2011/03/25/1996006.html)