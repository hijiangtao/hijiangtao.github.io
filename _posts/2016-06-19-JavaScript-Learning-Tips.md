---
title: JavaScript 使用中的一些小提示
layout: post
thread: 166
date: 2016-06-19
author: Joe Jiang
categories: documents
tags: [JavaScript]
excerpt: Some JavaScript Tips.
---

### JS对象

 - ECMAScript中5种简单数据类型（基本数据类型）: Undefined、Null、Boolean、Number和String, 1种复杂数据类型: Object;
 - typeof是一个操作符而不是函数, 对未初始化和未声明的变量执行typeof操作符都会返回undefined值;
 - Null类型只有一个值, null;
 - 永远不要测试某个特定的浮点数值，浮点数值的最高精度是17位小数，但在进行算术计算时其精确度远远不如整数。例如，0.1加0.2的结果不是0.3，而是0.30000000000000004;
 - 计算结果超出JavaScript数值范围的值会表示为Infinity或者-Infinity;
 - NaN数值用于表示一个本来要返回数值的操作数未返回数值的情况，NaN还具有以下特性：任何涉及NaN的操作均返回NaN，NaN和任何数值都不相等;
 - for-in语句是一种精准的迭代语句，可以用来枚举对象的属性;
 - switch语句在比较值时使用的是全等操作符;

### 一些有用的函数 

 - `Boolean()` //将一个值转换为其对应的Boolean值;
 - `Number.MIN_VALUE / Number.MAX_VALUE` //分别代表ECMAScript中能表示的数值最小值和最大值;
 - `isFinite()` //查看数值是否无穷，返回true或者false;
 - `isNaN()` //查看结果是否不是数值;
 - 把非数值转化为数值的函数：`Number()`、`parseInt()`和`parseFloat()`，第一个函数，即转型函数Number()可以用于任何数据类型，而另两个函数则专门用于把字符串转换成数值;
 
*Attention: parseInt 允许我们自定义接受参数的进制格式.比如以0开头的字符串很少会被用于八进制格式化(特别是在用户输入中). 为了处理这类问题, parseInt 接受第二个参数,基数.它可以指出第一个字符串参数要被如何解析.特别指出,第二个参数如果是 10 , parseInt 函数将解析第一参数字符串只能为十进制，例如`parseInt(col, 10)`*

 - `valueOf()` // 返回对象的初始值;
 - 把一个值转换为一个字符串有两种方式: 使用值的toString()方法; 使用转型函数String()，该函数能够将任何类型的值转换为字符串;
 - `result = variable instanceof constructor` // 查看variable是否为constructor类型;

### Reference

 1. [Javascript Type-Conversion](http://www.jibbering.com/faq/faq_notes/type_convert.html)
 2. Nicholas, C. Zakas. "JavaScript 高级程序设计." (2006): 1-616.