---
date: 2014-02-15 20:00:00
layout: post
title: Ubuntu开机出现speech-dispatcher disabled解决办法
thread: 32
categories: Tutorial
tags: [linux]
excerpt: 
---

Hadoop平台依旧没有搭好，我都感觉我已经进入一种濒临崩溃的状态了。早上和老师通了邮件，老师给了我不少鼓励和经验。下午，老师安排了一个学长来帮我排查问题，一时间的崩溃似乎又有转暖的迹象。但是最后这貌似是由ssh引起的问题一直悬而未决，hadoop安装已经令我心灰意冷。

老师一直提醒我在解决问题时，遇到了问题和困难一定要及时记下来，而找到了解决方法后更是要认真总结并凝练成自己的思想。所以，接下来就说下在硬件虚拟机上安装ubuntu一直碰到的这个小问题。

----

安装好`Linux ubuntu-13.04-desktop-i386`桌面系后开机，在进入桌面前控制台又出现了`speech-dispatcher disabled`的提示：

>speech-dispatcher disabled; /etc/default/speech-dispatcher

> *Asking all remaining processes to terminate

虽然能开机，但每次碰到这个还是心烦，于是在进入桌面系统后打开终端，输入`sudo gedit /etc/default/speech-dispatcher `显示如下：

```
# Defaults for the speech-dispatcher initscript, from speech-dispatcher
　　
# Set to yes to start system wide Speech Dispatcher
RUN=no
```

RUN是no？既然控制台提示的是disabled 对应的这个RUN=no，那么将里面的RUN=no 改成RUN=yes好了。重启，问题解决。

最后补上一句：学长的名字真难写，不查字典都不知道怎么读。