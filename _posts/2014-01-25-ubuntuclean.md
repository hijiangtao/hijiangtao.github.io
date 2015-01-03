---
date: 2014-01-25
layout: post
title: ubuntu系统垃圾清理小结
thread: 18
categories: Tutorial
tags: [linux]
---

**前言：**

由于更换电脑的缘故，重行安装了linux系统，但安装ubuntu不足一星期，系统就提醒我系统空间已经不足600MB，确实被震惊了，我给ubuntu分配了20GB大小空间啊，之前一直用的15GB都一直够用，于是开始谷歌各种系统瘦身方法，成功清理了1GB左右的垃圾，摘取了自己尝试过的一些方法记在下面。

----

回顾这几天，我几乎没干什么大事，唯一记忆深刻的是ubuntu自动更新提示我有新的版本，于是我点了确定……记得当时哪个安装包挺大的，于是我就朝着这条路去寻找线索。

###1.删除多余的内核。

* 查看系统存在的内核：输入以下命令。

```
dpkg -l|grep linux
dpkg –get-selections|grep linux
```

网上说的两个命令都有用，但我只使用了第一行命令，当我输入`dpkg –get-selections|grep linux`时，终端提示：

```
dpkg: error: 需要一个指示操作的选项

输入 dpkg --help 可获得安装和卸载软件包的有关帮助 [*]；
使用 dselect 或是 aptitude 就能在友好的界面下管理软件包；
输入 dpkg -Dhelp 可看到 dpkg 除错标志的值的列表；
输入 dpkg --force-help 可获得所有强制操作选项的列表；
输入 dpkg-deb --help 可获得有关操作 *.deb 文件的帮助；

带有 [*] 的选项将会输出较大篇幅的文字 - 可使用管道将其输出连接到 less 或 more ！
```

可以看出是我dpkg命令使用语法上出了问题，不管他了，按照第一个命令执行后，找到如下所示的带image的文件名，有image的就是内核文件，删除其中的老的内核文件：`sudo apt-get remove 内核文件名` （例如：`linux-image-2.6.27-2-generic`）。从我的提示信息中可以看出，我之前安装的是3.8.0-19内核，而之后更新的是3.8.0-35内核版本，所以我挺好奇的是：为什么linux自动更新后不会把旧的内核版本自动删除？

```
rc  linux-image-3.8.0-19-generic              3.8.0-19.30                              amd64        Linux kernel image for version 3.8.0 on 64 bit x86 SMP
ii  linux-image-3.8.0-35-generic              3.8.0-35.50                              amd64        Linux kernel image for version 3.8.0 on 64 bit x86 SMP
rc  linux-image-extra-3.8.0-19-generic        3.8.0-19.30                              amd64        Linux kernel image for version 3.8.0 on 64 bit x86 SMP
ii  linux-image-extra-3.8.0-35-generic        3.8.0-35.50                              amd64        Linux kernel image for version 3.8.0 on 64 bit x86 SMP
ii  linux-image-generic                       3.8.0.35.53                              amd64        Generic Linux kernel image
```

好吧，内核删除，释放空间了，应该能释放130－140M空间。

###2.清理下载的缓存包。

通过apt安装软件时下载的包都缓存在 /var/cache/apt/archives/ 目录中，如要清理掉这些缓存包，可以执行：

* sudo apt-get autoclean（已卸载软件的安装包）
* sudo apt-get clean（未卸载软件的安装包）
* sudo apt-get autoremove （清理系统不再需要的孤立的软件包）

###3.卸载：Tracker

Tracker不仅会产生大量的cache文件而且还会影响开机速度。所以执行`sudo apt-get remove tracker`即可。

###4.删除浏览器缓存文件。

opera firefox的缓存文件目录分别是：

* `~/.opera/cache4`
* `~/.mozilla/firefox/*.default/Cache`

###5.缩略图删除

如果启用了文件缩略图模式的话，`~/.thumbnails`里面会累积不少缩略图，可以删除。

----

另外，利用磁盘管理工具，我发现/usr/share这个文件夹很大，于是网上搜了linux的文件结构：

* `/usr/bin` 大多数用户命令–包含标准Linux工具程序,也就是说在恢复模式下并不需要二进制文件 
* `/usr/games` 游戏和教育软件 
* `/usr/include` C程序包含的头文件 
* `/usr/lib` 库文件 
* `/usr/local` 本地文件层次结构–包含对本地重要的文件和目录,这些文件和目录都是后来添加到系统的(而不是系统自带的).其子目录有:bin、games、include、lib、sbin、share和src。 
* `/usr/man` 联机手册 
* `/usr/share` 体系结构无关数据

其中对share文件夹的描述是：体系结构无关数据。但没有表明能不能删除，既然不清楚那就暂时留着了，之前的操作也节省了很多空间，暂时够用了。

----

以下还有一些技术博客提供的别的清理方法，我还没试过。

###1.清理无用的语言文件。

```
sudo apt-get install localepurge
```

注：此软件请在看清说明的前提下谨慎使用。

在对软件配置时，使用空格键可以选择需要保留的区域配置，其他的则会被删除。当以后在安装程序时，此工具也会自动执行，勿需再次配置。若需重新配置：

```
sudo dpkg-reconfigure localepurge
```

###2.清理无用的翻译内容。

安装trans-purge这组小工具来清理 *.desktop、mime-database、gconf schema 中的无用翻译内容。

###3.清理孤立软件包。

`sudo apt-get install gtkorphan`，运行gtkorphan，第一个选项中的都可以删除。

###4.删除孤立的库文件。

```
sudo apt-get install deborphan
sudo deborphan
```

用以上命令查看孤立（没有依赖关系）库文件，运行下面命令删除它们：`sudo deborphan | xargs sudo apt-get -y remove --purge`.

----

参考：[ubuntu清理系统垃圾与备份](http://www.cnblogs.com/yc_sunniwell/archive/2010/07/15/1778265.html)

