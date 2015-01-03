---
date: 2014-02-15
layout: post
title: Linux静态IP设置与正常网络设置的区别
thread: 31
categories: Documents
tags: [linux, ip]
---

Hadoop平台依旧没有搭好，传说中的SSH出错到现在也没有找到错误原因在哪，毕竟我在两台机器上的操作和文件存储结果都是一样的喂。不过昨天配置时在IP设置这上面还是折腾了不久，遇到了点问题记录在下面，等待解决方法。

Hadoop安装过程中建议对安装的每台虚拟机设置固定的IP，以便之后的连接与操作。文中写到用`sudo vim /etc/network/interfaces`打开文件，然后添加以下内容：

```
    auto eh0
    iface eth0 inet static
    address 192.168.0.2
    gateway 192.168.0.220
    netmask 255.255.255.0
```

文件中本身带有：

```
    # interfaces(5) file used by ifup(8) and ifdown(8)
    auto lo
    iface lo inet loopback
```

当我保存了操作后，重新启动发现只有主机的连着的`10.1.151.*`可以PING通，`192.168.0.2`却PING不通，于是我想起了上面的操作，于是默默的把`# interfaces(5) file used by ifup(8) and ifdown(8)   auto lo`这两行注释掉了。

重启之后，`192.168.0.2`PING通了，但是`10.1.151.*`却PING不通了。我记得192.168.0开头的不是本地地址么？好吧，难道我没有给自己设置静态本地IP地址的权限？

疑问留在这，等待日后有时间搜索资料来解决，或者正在阅读此文的高手帮忙解答一下。谢过。