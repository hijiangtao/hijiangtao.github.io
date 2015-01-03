---
date: 2014-03-23 20:00:00
layout: post
title: Ubuntu开机报错Could not update ICEauthority file /.ICEauthority解决方案
thread: 91
categories: Documents
tags: [linux]
excerpt: Solution of Could not update ICEauthority file /.ICEauthority.
---

学长说的一句话特别有用：别怕碰到问题。问题总是要解决的，你现在碰到总比你以后碰到要好。

于是今天非常愉悦的碰到了Ubuntu开机报错的问题。无法登录，输入账号密码后显示：

>Could not update ICEauthority file /home/hadoop/.ICEauthority

无法更新，这是什么意思？到网上查了一下ICEauthority的含义，发现可能是由于权限出错的问题所致。于是，Ctrl+Alt+F2先从窗口模式进入命令行模式（F2换成F7即为命令行模式换为桌面模式）。

使用如下代码将权限换成自己的用户名

```
sudo chown user -R /home/user
/*此处user为你的用户名*/
```

我这次出现的问题就是这个，/home/hadoop目录的用户变成了root，所以无法更新才导致的开机警告，一登陆就提示我注销。

除此之外，还有其他两个以供参考的方法：

###一、修改文件所属以及权限值

```
sudo chown user:user /home/user/.ICEauthority
sudo chmod 644 /home/user/.ICEauthority
/*此处user为你的用户名*/
```

###二、组别更换与权限修改

首先，要查看/home/目录的用户和组是不是属于root用户的，这个目录必须是属于root用户和root组的。

```
ls -l /home/user
```

如果不是的话,变更组为root，用户为root。

```
sudo chgrp -R root /home //改变组为root
sudo chown -R root /home //改变用户为root
```

其次,变更/home目录的权限为755

```
sudo chmod 755 /home
```

再次,变更/home/用户名/.dmrc权限为644

```
sudo chmod 644 /home/user/.ICEauthority
```