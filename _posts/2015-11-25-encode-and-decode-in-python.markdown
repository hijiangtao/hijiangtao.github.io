---
title: Encode and decode in Python
layout: post
thread: 164
date: 2015-11-25
author: Joe Jiang
categories: documents
tags: [python]
excerpt: 汇总一下有关不同编码方式以及python中编码解码的内容。
---

每次涉及到编码解码的内容呢就是现查方法，而从来都记不住，所以总结记录下来方便以后查阅，节省点Google的时间吧，哎渣渣。

首先是各种常见的编码，有ASCII、Unicode和UTF-8，当然还有GBK，GB2312。ASCII码最容易理解，所有C语言书最后一页的附录里都会有的一张表，换行、空格分别对应着哪个数字在那里都有详细的解释；UTF-8在我看来是一个非常通用且流行的编码方式，它涵盖了当今世界上所有国家的字符集，全称Unicode TransformationFormat-8bit，允许含BOM，但通常不含BOM。BOM的区别即文件开头有没有 U+FEFF，知乎上一个朋友回答称「UTF-8 的网页代码不应使用 BOM，否则常常会出错」；而Unicode也是一种字符编码方法，不过它是由国际组织设计，可以容纳全世界所有语言文字的编码方案，GBK、GB2312和UTF8之间必须通过Unicode编码进行转换，这也是decode和encode起到的作用；GBK是国家标准GB2312基础上扩容后兼容GB2312的标准，GBK的文字编码是用双字节来表示的，即不论中、英文字符均使用双字节来表示，为了区分中文，将其最高位都设定成1。

而encode和decode的区别在于：

unicode encode-> string
string decode-> unicode

简单例子：

```
s=u"中文" 
print s 
```

Result:

```
print s.encode('gb2312') \\ 中文
print s.encode('utf8') \\ \xe4\xb8\xad\xe6\x96\x87
```

对了，抖个机灵。我经常在搜索资料时没时间打开文档来记录，如果和我有同样遭遇的话可以尝试下面的命令，在浏览器地址栏输入后敲击回车，浏览器就会成为你的一个临时记事本：

```
data:text/html, <html contenteditable>
```

END