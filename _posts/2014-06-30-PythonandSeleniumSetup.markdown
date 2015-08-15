---
date: 2014-06-30 22:30:00
layout: post
title: Python+Selenium环境配置教程
thread: 136
categories: Tutorial
tags: [python]
excerpt: 
---

周六的时候去中传媒听了沈浩老师组织的《大数据挖掘的理论、工具与实践研讨沙龙》，期间收获颇大，有些之前自己想弄明白的零星技术也在沙龙上被打通了。会上一个研究生介绍了他从微博数据爬取到统计呈现的过程，说是用到了selenium来实现模拟登陆与爬取过程，于是晚上不想做些别的什么了，挺感兴趣的也开始弄弄安装selenium了。

**安装环境**：

* Windows 7 （64位）
* python 2.7.6
* jdk 1.7.0_21

----

##配置过程

* 安装python：安装过程可以查看[Python学习笔记：快速入门](http://hijiangtao.github.io/2014/06/30/PythonStudyNode-FastRead/)，此处不做过多描述。
* 下载Setuptools：[下载地址](https://pypi.python.org/packages/2.7/s/setuptools/)。点击进去下载setuptools-0.6c11.win32-py2.7.exe并安装，一切按照默认来操作。
* 下载pip-1.5.6：[下载地址](https://pypi.python.org/pypi/pip)。下载pip-1.5.6.tar.gz (md5, pgp)并解压至默认目录C:\pip-1.5.6。
* 打开CMD，进入C:\pip-1.5.6，输入命令：

```
python setup.py install
```

* 安装完成后，下载java并安装：[下载地址](http://www.java.com/zh_CN/)
* 打开CMD，进入python的scripts路径，如我的**C:\Python27\Scripts**,然后输入命令安装pip：

```
easy_install pip
```

* 安装完毕后输入命令安装selenium：

```
pip install -U selenium
```

* 安装Chrome Driver:下载chromedriver_win32.zip并将其中.exe文件解压至chrome的默认路径，如我的电脑上的**C:\Program Files (x86)\Google\Chrome\Application**，同时将这个路径加到你的环境变量Path中去。Chrome driver[下载地址](http://chromedriver.storage.googleapis.com/index.html?path=2.9/).
* 由于使用了一些配置，随意为了即时生效最好这个时候重新启动一下。
* 此时，打开一个.py文档，在其中写下：

```
# coding = utf-8

from selenium import webdriver

driver = webdriver.Chrome()

driver.get('http://hijiangtao.github.io')

print driver.title

driver.quit()
```

然后python运行，如果正常弹出一个新窗口，页面加载成功，那么环境你就已经配好了哦。