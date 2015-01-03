---
date: 2014-06-30 15:00:00
layout: post
title: Python学习笔记：快速入门
thread: 135
categories: Tutorial
tags: [python]
---

**前言**：之前一直用Python写过一些程序，但总体来说不太系统总是零零星星的拼凑，正好有想法在微博挖掘这一块做一个系统的小玩意，除了用到D3等呈现模块，对于前期的数据爬取Python也是必不可少的轻量级工具，所以便找了一本书从头开始系统整理自己的知识库，也便有了这个学习笔记。

----

##安装与调试

Python的安装是非常傻瓜式的（对于Windows环境来说），点击[下载](http://www.python.org/ftp/python/2.7.6/python-2.7.6.msi)Python2.7.6版本，然后到环境变量里加上`C:\Python27\`，打开CMD就可以开始运行测试了，以下为我测试了10+20的运算结果以及打印'hello world'的信息：

```
C:\Users\OopsTao>python
Python 2.7.6 (default, Nov 10 2013, 19:24:18) [MSC v.1500 32 bit (Intel)] on win32
Type "help", "copyright", "credits" or "license" for more information.
>>> 10+20
30
>>> print 'hello world'
hello world
```

----

##使用技巧

当然，我们不可能任何命令都在命令行里即时编辑、即时输出。保存起来以后用于执行是必不可少的。达到这一步请学会以下三个步骤：

1. 下载一款文本编辑器Notepad++/Sublime Text;
2. 在文本编辑器中新建文本，输好代码后保存为codename.py（要求：以.py结尾，文件名只能是英文字母、数字和下划线的组合）;
3. 打开命令行，运行.py文件。

Windows环境下无法像.exe文件一样直接运行.py文件，但是在Mac和Linux上这是可以实现的，方法是在.py文件第一行加上:

```
#! /path python
```

然后通过命令执行：

```
$ chmod a+x codename.py
```

Windows下普通的Python运行命令如下：

```
python /path/codename.py
```

当然，以上所说的是在CMD下的运行操作方法，如果要在python IDLE中运行，我现在只找到了一种方法——execfile，打开Python IDLE，输入：

```
execfile('/path/codename.py')
```

----

##输入与输出

* print

print后面可以跟上一个或多个字符串（用''括起），中间用逗号隔开（在输出中表示为一个空格），也可以直接打印整数或算术表达式。

* raw_input()

这是Python提供的输入字符串函数，输入以回车结束，比如：

```
>>> name = raw_input()
```

当我们完成输入后，结果便存在了变量name中。但是这样一来在输入的时候用户是得不到任何提醒的，所以如下书写会更加友好：

```
name = raw_input('please enter your name: ')
```

----

##基础知识

* 以#开头的的语句是注释；
* 每一行都是一个语句，当语句以冒号“:”结尾时，缩进的语句视为代码块；
* Python程序对大小写敏感；
* `print r'\\t\\'`，用`r''`表示内部字符串不转义；
* Python允许用`'''...'''`的格式表示多行内容，`...`放于除第一行外的每一新行的开头。
* Python的布尔值：True/False, 布尔值可以用and、or和not运算。
* 空值是Python里一个特殊的值，用**None**表示。None不能理解为0，因为0是有意义的，而None是一个特殊的空值。
* 当我们执行万以下语句后，b的值为ABC：

```
a = 'ABC'
b = a
a = 'XYZ'
print b
```

* Python一般用大写表示常量，但其数值任然可以被改变，所以本质上仍为一个变量。
* 有关字符编码可以查看廖雪峰的文档：

>ASCII编码是1个字节，而Unicode编码通常是2个字节。

>字母A用ASCII编码是十进制的65，二进制的01000001；

>字符0用ASCII编码是十进制的48，二进制的00110000，注意字符'0'和整数0是不同的；

>汉字中已经超出了ASCII编码的范围，用Unicode编码是十进制的20013，二进制的01001110 00101101。

>你可以猜测，如果把ASCII编码的A用Unicode编码，只需要在前面补0就可以，因此，A的Unicode编码是00000000 01000001。

>新的问题又出现了：如果统一成Unicode编码，乱码问题从此消失了。但是，如果你写的文本基本上全部是英文的话，用Unicode编码比ASCII编码需要多一倍的存储空间，在存储和传输上就十分不划算。

>所以，本着节约的精神，又出现了把Unicode编码转化为“可变长编码”的UTF-8编码。UTF-8编码把一个Unicode字符根据不同的数字大小编码成1-6个字节，常用的英文字母被编码成1个字节，汉字通常是3个字节，只有很生僻的字符才会被编码成4-6个字节。如果你要传输的文本包含大量英文字符，用UTF-8编码就能节省空间。

* 以Unicode表示的字符串： 

```
u'...'
```

* 把u'xxx'转换为UTF-8编码的'xxx':

```
>>> u'ABC'.encode('utf-8')
```

* len()函数可以返回字符串的长度：

```
>>> len(u'中文')
```

* 把UTF-8编码表示的字符串'xxx'转换为Unicode字符串u'xxx'：

```
>>> 'abc'.decode('utf-8')
```

* 当Python解释器读取源代码时，为了让它按UTF-8编码读取，我们通常在文件开头写上这两行：

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
```

第一行注释是为了告诉Linux/OS X系统，这是一个Python可执行程序，Windows系统会忽略这个注释；

第二行注释是为了告诉Python解释器，按照UTF-8编码读取源代码，否则，你在源代码中写的中文输出可能会有乱码。

* 格式化案例

```
>>> '%2d-%02d' % (3, 1)
' 3-01'
>>> '%.2f' % 3.1415926
'3.14'
```

* 用%%来表示一个%。