---
date: 2014-05-18 23:50:00
layout: post
title: 学习JavaScript的几点注意事项
thread: 125
categories: Documents
tags: [JavaScript]
---

###1、有关文档输出

请使用 document.write() 仅仅向文档输出写内容。
如果在文档已完成加载后执行 document.write，整个 HTML 页面将被覆盖：

```
	<html>
	<body>
	<h1>My First Web Page</h1>
	<p>My First Paragraph.</p>
	<button onclick="myFunction()">点击这里</button>
	<script>
	function myFunction()
	{
	document.write("糟糕！文档消失了。");
	}
	</script>
	</body>
	</html>
```

----

###2、有关变量声明

如果重新声明 JavaScript 变量，该变量的值不会丢失；在以下两条语句执行后，变量 carname 的值依然是 "Volvo"：

```
var carname="Volvo";
var carname;
```

JavaScript 变量分局部与全局变量。如果您把值赋给尚未声明的变量，该变量将被自动作为全局变量声明。

```
carname="Volvo";
```

将声明一个全局变量 carname，即使它在函数内执行。

----

###3、有关数字书写

JavaScript 只有一种数字类型。数字可以带小数点，也可以不带.极大或极小的数字可以通过科学（指数）计数法来书写：

```
var y=123e5;      // 12300000
var z=123e-5;     // 0.00123
```

----

###4、有关运算符

**用于字符串的 + 运算符**

如需把两个或多个字符串变量连接起来，请使用 + 运算符。

```
txt1="What a very";
txt2="nice day";
txt3=txt1+txt2;
```

在以上语句执行后，变量 txt3 包含的值是 "What a verynice day"。

而对字符串和数字进行加法运算，规则是：如果把数字与字符串相加，结果将成为字符串。

----

###5、有关For循环

JavaScript for/in 语句循环可以遍历对象的所有属性。

```
var person={fname:"John",lname:"Doe",age:25};

for (x in person)
{
  txt=txt + person[x];
}
```

----

###6、有关错误

**测试与捕捉**

try 语句允许我们定义在执行时进行错误测试的代码块，catch 语句允许我们定义当 try 代码块发生错误时，所执行的代码块。JavaScript 语句 try 和 catch 是成对出现的。例如：

```
try
{
  adddlert("Welcome guest!");
}
catch(err)
{
  txt="There was an error on this page.\n\n";
  txt+="Error description: " + err.message + "\n\n";
  txt+="Click OK to continue.\n\n";
  alert(txt);
}
```

**Throw语句**

throw 语句允许我们创建自定义错误。异常可以是 JavaScript 字符串、数字、逻辑值或对象。使用语法为

>throw exception

----

###7、JavaScript DOM

有关完整的 HTML DOM Style 对象属性，可以查看 [HTML DOM Style 对象参考手册](http://www.w3school.com.cn/jsref/dom_obj_style.asp)。

----

###8、HTML鼠标事件

**onload 和 onunload 事件**

onload 和 onunload 事件会在用户进入或离开页面时被触发。
onload 事件可用于检测访问者的浏览器类型和浏览器版本，并基于这些信息来加载网页的正确版本。

**onchange 事件**

onchange 事件常结合对输入字段的验证来使用。

**onmouseover 和 onmouseout 事件**

onmouseover 和 onmouseout 事件可用于在用户的鼠标移至 HTML 元素上方或移出元素时触发函数。

**onmousedown、onmouseup 以及 onclick 事件**

onmousedown, onmouseup 以及 onclick 构成了鼠标点击事件的所有部分。首先当点击鼠标按钮时，会触发 onmousedown 事件，当释放鼠标按钮时，会触发 onmouseup 事件，最后，当完成鼠标点击时，会触发 onclick 事件。

有关HTML DOM 事件的完整列表，可以参考 [HTML DOM Event 对象参考手册](http://www.w3school.com.cn/jsref/dom_obj_event.asp)。

----

###9、删除已有HTML元素

如需删除 HTML 元素，您必须首先获得该元素的父元素。但常用的解决方案：找到您希望删除的子元素，然后使用其 parentNode属性来找到父元素：

```
var child=document.getElementById("p1");
child.parentNode.removeChild(child);
```

----

###10、数字属性与方法

**属性：**

* MAX VALUE
* MIN VALUE
* NEGATIVE INFINITIVE
* POSITIVE INFINITIVE
* NaN
* prototype
* constructor

**方法：**

* toExponential()
* toFixed()
* toPrecision()
* toString()
* valueOf()

----

###11、有关Boolean 对象

如果逻辑对象无初始值或者其值为 0、-0、null、""、false、undefined 或者 NaN，那么对象的值为 false。否则，其值为 true（即使当自变量为字符串 "false" 时）。

----

###12、有关Math 对象

[JavaScript Math 对象的参考手册](http://www.w3school.com.cn/jsref/jsref_obj_math.asp)

----

###13、有关String 对象

[JavaScript String 对象参考手册](http://www.w3school.com.cn/jsref/jsref_obj_string.asp)

----

###14、有关JS正则表达式

[RegExp 对象参考手册](http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp)