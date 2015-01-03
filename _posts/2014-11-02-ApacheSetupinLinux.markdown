---
title: Linux下Apache环境配置笔记
thread: 156
date: 2014-11-02 19:00:00
categories: Documents
tags: [Apache]
layout: post
excerpt: Apache Environment in Linux Installation Nodes.
---

网上给的教程是：下载源代码，编译，完成，就可以开启服务了，一共如下几行代码。但开始配置的时候却发现远没有这么简单。

<!--more-->

```
tar zvxf httpd-2.2.21.tar.gz 
cd httpd-2.2.21
./configure --prefix=/usr/local/apache2 --enable-so --enable-rewrite
make
make install
```

首先是下载，到[Apache官网](http://httpd.apache.org/)找到源代码下载下来，我选用的是httpd-2.2.21，下载的tar.gz文件。如果按照上面的步骤走的话，那么在configure那一步就会出现：

>error: APR not found. Please read the documentation.

经查询才知道这是Apache的关联软件，在apr.apache.org网站上可以下载此软件(apr-1.4.5.tar.gz)；如果只补了这一步的操作，那么还会报错：

>configure: error: APR-util not found. Please read the documentation

所以具体把这个关联软件的安装步骤写在这里：

**1.解决apr not found问题**

APR和APR-UTIL的下载地址：<http://apr.apache.org/download.cgi>，下载完执行如下代码：

```
//解压该源代码包
tar -zxf apr-1.4.5.tar.gz
//进入该路径
cd apr-1.4.5/
//配置并编译
./configure --prefix=/usr/local/apr
make
make install
```

**2.解决APR-util not found问题**

用同样的方法对apr-util进行处理：

```
tar -zxf apr-util-1.3.12.tar.gz
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config
make
make install
```

**3.执行完上面两步后，当你输入./configure仍提示`APR-util not found`，这时需要在你的命令后面加上`--with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util`，但依旧不行。**

报错信息如下所示：

>configure: error: pcre-config for libpcre not found.
>PCRE is required and available from http://pcre.org/

执行`#./configure –help | grep pcre`发现还需要PCRE环境

```
—with-pcre=PATH Use external PCRE library
```

PCRE下载地址：<http://ftp.exim.llorien.org/pcre/>(记得下载zip格式的文件)

下载完后到下载路径中执行：

```
unzip -o pcre-8.10.zip
cd pcre-8.10
./configure --prefix=/usr/local/pcre
make
make install
```

但在如上命令执行之前你需要先执行如下代码，不然便会看到系统报错显示缺少C++环境：

```
sudo apt-get install build-essential
```

因为Ubuntu默认并不提供C/C＋＋的编译环境，因此还需要通过上述命令安装环境。如果你的yum环境配置成功，那么也可以用如下命令替代：

```
yum install -y gcc gcc-c++
```

**4.编译Apache**

执行如下代码完成：

```
./configure --prefix=/usr/local/apache2 --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/
make
make install
/usr/local/apache2/bin/apachectl start
```

但当你使用如下命令时仍会报错：

```
service httpd start
```

提示httpd:unrecognized service。这是由于你需要将apache 设成系统服务，方法如下：

```
cp /usr/local/apache2/bin/apachectl /etc/init.d/httpd
vi /etc/init.d/httpd
```

然后在第二行加入如下内容：

```
# chkconfig: 2345 85 15
# description: httpd is web server.
```

参数说明：2345表示在2345这四种启动级别里面加载这个服务，85表示启动(开机时)顺序号，15表示关闭(关机时)顺序号。
但是在ubuntu上默认是不支持chkconfig命令的，所以需要自己安装，安装包路径：<http://download.csdn.net/detail/hylongsuny/5276536>

下载完成后在存放目录执行：

```
dpkg -i chkconfig_11.0-79.1-2_all.deb
```

使用chkconfig管理服务的时候，出现了问题：

>chkconfig —list
>/sbin/insserv: No such file or directory

请执行：

```
# ln -s /usr/lib/insserv/insserv /sbin/insserv
```

*注：在debian和ubuntu中可以使用sysv-rc-conf来代替chkconfig,使用方法很简单，和chkconfig类似。*

那么好，接着chkconfig之前继续配置，继续输入命令即可完成：

```
chkconfig -add httpd
chkconfig --level 35 httpd on
```

之后便可以通过service httpd start开启Apache服务，通过浏览器<http://127.0.0.1/>来检验服务开启。

**附常用的apache命令：**

```
//Apache启动
service httpd start
//Apache关闭
service httpd stop
//Apache重新启动
service httpd restart
```