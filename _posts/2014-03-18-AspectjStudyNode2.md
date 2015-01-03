---
date: 2014-03-18 17:30:00
layout: post
title: Aspectj操作与语法基础学习笔记（二）
thread: 83
categories: Documents
tags: [Aspectj]
excerpt: Simple explanations of Aspectj.
---

**前言：**本学习笔记原稿为CSDN大胡子的[aspectj的学习专栏](http://my.csdn.net/zl3450341)，想到根据自己的思想进一步凝练其中内容和为了以后巩固知识的需要，于是有了自己的这个学习笔记系列。Aspectj第一篇学习笔记可以点击《[Aspectj操作与语法基础学习笔记（一）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode1/)》查看。

**Aspectj学习笔记系列：**

1. 《[Aspectj操作与语法基础学习笔记（一）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode1/)》
2. 《[Aspectj操作与语法基础学习笔记（二）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode2/)》
3. 《[Aspectj操作与语法基础学习笔记（三）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode3/)》 
4. 《[Aspectj操作与语法基础学习笔记（四）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode4/)》
5. 《[Aspectj操作与语法基础学习笔记（五）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode5/)》

本系列笔记会根据内容多少进行调整，并且其中的代码等内容与原专栏内容会有所改变，请注意。

我坚信开源与分享是助力学习与成长的最重要元素，所以也欢迎你基于我的笔记基础进行进一步增补与修改，以此帮助更多的人。

----

##一、pointcut基础语法

这一部分的介绍比较枯燥无味，不是说作者写的不好，而是从中我无法凝练出较多的技术实现，所以这一部分就一笔带过。其中比较有意义的一部分是：

pointcut基于正则的语法，支持通配符，含义如下：

1. *表示任何数量的字符，除了(.) 
2. ..表示任何数量的字符包括任何数量的(.) 
3. +描述指定类型的任何子类或者子接口
4. 同java一样，提供了一元和二元的条件表达操作符
5. 一元操作符：!
6. 二元操作符：||和&&
7. 优先权同java

----

##二、args带参数的pointcut实践

pointcut基本涵盖了Java程序的所有生命周期，这就意味着：我们可以控制到一个已经存在的Java程序的任何地方和环节。

为了演示，HelloWorld.java代码修改如下：

```
package com.aspectj.demo.test;  
  
public class HelloWorld {  
  
	public static void main(int i){
		System.out.println("int the main method i = " + i);
	}
	
    /** 
     * @param args 
     */  
    public static void main(String[] args) {  
    	main(5);
    }  
} 
```

运行结果如下：

```
Hello world
Hello world
int the main method i = 5
```

原作者的分析：

>我们增加了一个main(int i)的方法。再运行一下，发现拦截２次，也就是说：２个main()方法都被拦截，现在，leader说：我只要你拦截接受int参数的main()。怎么办？

接下来，我们修改一下HelloAspect。

```
pointcut HelloWorldPointCut() : execution(* com.aspectj.demo.test.HelloWorld.main(int)); 
```

再运行一下，发现只拦截了一次了。运行结果如下：

```
Hello world
int the main method i = 5
```

可leader这人比较烦，他又说：我现在要获取main()方法里面的参数值。于是继续修改，修改过后的代码如下：

```
package com.aspectj.demo.aspect;  
  
public aspect HelloAspect {  
  
	pointcut HelloWorldPointCut(int i) : execution(* com.aspectj.demo.test.HelloWorld.main(int)) && args(i);  
    
    before(int x) : HelloWorldPointCut(x){  
    	x+=5;  
        System.out.println("in the aspect   i = " +x);  
    }  
} 
```

运行一下，结果如下：

```
in the aspect   i = 10
int the main method i = 5
```

----

OK，笔记就记到这里了。再次感谢CSDN小胡子的专栏原稿。再次说明，本笔记不做任何商业用途，只是为了自己知识整理和与他人分享技术这两个纯粹的目的。如果有任何疑问欢迎在下方留言，希望能认识到同样热爱技术的你，一起努力与进步。