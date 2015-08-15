---
date: 2014-06-30 16:30:00
layout: post
title: Python学习笔记：List和Tuple
thread: 136
categories: Tutorial
tags: [python]
excerpt: 
---

##List

list的普通定义用法和C语言中数组的定义类似，但list最后一个元素的访问可以通过len(list)-1来访问也可以通过-1做索引，直接获得。以此类推，-2可以获得倒数第二个元素等。

除此之外，list可以通过list.append('extra')的方法往末尾追加元素，也可以通过list.insert(1, 'me')来向指定位置插入特定元素；要删除list末尾的元素则采用pop()方法，pop(i)用于删除指定位置的元素.

定义list：

```
>>> classmates = ['Michael', 'Bob', 'Tracy']
```

----

##Tuple

tuple是一个有序列表，称为元组。tuple和list非常类似，但是tuple一旦初始化就不能修改，而也是这个特性使得tuple相对更加安全。

* 只有1个元素的tuple定义时必须加一个逗号,，来消除歧义：

```
>>> t = (1,)
```

* 看一个“可变的”tuple：

```
>>> t = ('a', 'b', ['A', 'B'])
>>> t[2][0] = 'X'
>>> t[2][1] = 'Y'
>>> t
('a', 'b', ['X', 'Y'])
```

此时需要理解数值虽变，但指向不变的含义。