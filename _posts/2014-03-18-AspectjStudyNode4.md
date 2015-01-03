---
date: 2014-03-18 19:30:00
layout: post
title: Aspectj操作与语法基础学习笔记（四）
thread: 85
categories: Documents
tags: [Aspectj]
excerpt: Simple explanations of Aspectj.
---

**前言：**本学习笔记原稿为CSDN大胡子的[aspectj的学习专栏](http://my.csdn.net/zl3450341)，想到根据自己的思想进一步凝练其中内容和为了以后巩固知识的需要，于是有了自己的这个学习笔记系列。

**Aspectj学习笔记系列：**

1. 《[Aspectj操作与语法基础学习笔记（一）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode1/)》
2. 《[Aspectj操作与语法基础学习笔记（二）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode2/)》
3. 《[Aspectj操作与语法基础学习笔记（三）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode3/)》 
4. 《[Aspectj操作与语法基础学习笔记（四）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode4/)》
5. 《[Aspectj操作与语法基础学习笔记（五）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode5/)》

----

本系列笔记会根据内容多少进行调整，并且其中的代码等内容与原专栏内容会有所改变，请注意。

我坚信开源与分享是助力学习与成长的最重要元素，所以也欢迎你基于我的笔记基础进行进一步增补与修改，以此帮助更多的人。

----

##控制流实践

###一、控制流

我不知道cflow是干什么用的，但是既然作者教了那么我就跟着学呗。大胡子这样说道：

>当初刚接触aspectj的时候，可谓是为之颠倒，不只大家是否有相同的感觉。但有一点不可否认的就是：他觉得（更正：绝对）是aspectj强大功能之一。 他可以做到Spring AOP无法做到的场景。

什么是控制流？我也不知道。所以先看一段代码：

```
package com.aspectj.demo.test;
import org.junit.Test;

public class TestCfow {

	public void foo(){
		System.out.println("foo......");
	}
	
	public void bar(){
		foo();
		System.out.println("bar.........");
	}
	
	@Test
	public void testMethod(){
		bar();
		foo();
	}
}
```

但是非常意外的是在`import org.junit.Test;`和`@Test`两处都出现了错误提示，这是什么意思？

查了资料发现是Lib添加不全的原因，于是按照项目右键->Build Path->Configure Build Path..->Libraries->Add Library->JUnit的顺序把JUnit4添加进去，下划线消失。

看着上面的代码，其实工作流就是testMethod开始->调用Bar()->bar内调用foo()->打印Foo->打印Bar->打印Foo->testMethod结束。cfow(execution(* testMethod())) 就是获取testMethod()的控制流。他将拦截到testMethod中的每行代码（包括：他流程里面调用的其它其他方法的流程，不管调用层次有多深，都属于他的控制流）。

**作者注：**其实这里说是每行代码是不准的，其实是每行代码编译后的字节码。比如System.out.println() 其实编译后是3句话。

----

###二、Demo操作

新建class CfowAspect，代码如下：

```
package com.aspectj.demo.aspect;  
  
public aspect CfowAspect {
  
    pointcut barPoint() : execution(* bar(..));  
    pointcut fooPoint() : execution(* foo(..));  
    pointcut barCfow() : cflow(barPoint());//cflow的参数是一个pointcut  
    pointcut fooInBar() : barCfow() && fooPoint();  //获取bar流程内的foo方法调用  
      
    before() : barCfow(){  
        System.out.println("Enter:" + thisJoinPoint);  
    }
}
```

但是运行一下在JUnit看到的是什么？是StackOverFow了。 现在想想为什么会溢出呢？其实是这样的：cflowAspect织入了 Bar(). 所以他也算是bar的控制流的一部分， 这样一来，他就自己拦截自己，形成一个死循环，所以就溢出了。

![Stackoverflow](/assets/2014-03-18-Aspectj-Stackoverflow.png "Stackoverflow")
<center>Problem:Stackoverflow</center>

如何解决？我们用within来修改代码：

```
pointcut barCfow() : cflow(barPoint()) && !within(CfowAspect);  
```

再次运行testMehtod()，打印结果如下：

```
Enter:execution(void com.aspectj.demo.test.TestCfow.bar())
Enter:call(void com.aspectj.demo.test.TestCfow.foo())
Enter:execution(void com.aspectj.demo.test.TestCfow.foo())
Enter:get(PrintStream java.lang.System.out)
Enter:call(void java.io.PrintStream.println(String))
foo......
Enter:get(PrintStream java.lang.System.out)
Enter:call(void java.io.PrintStream.println(String))
bar.........
foo......
```

每条打印，都可以看出是拦截的那句话，同时这个结果也验证了我给大家PS的那句话。始终要记得：aspectj是静态织入，所以他拦截的是字节码。

现在我们改变一下需求：  只拦截bar方法调用里面的foo()方法，也就是说我们testMethod()里面的foo() 调用不要拦截。

```
package com.aspectj.demo.aspect;  
  
public aspect CfowAspect {
  
    pointcut barPoint() : execution(* bar(..));  
    pointcut fooPoint() : execution(* foo(..));  
    pointcut barCfow() : cflow(barPoint()) && !within(CfowAspect);  
    pointcut fooInBar() : barCfow() && fooPoint();  //获取bar流程内的foo方法调用  
      
    before() : fooInBar(){  
        System.out.println("Enter:" + thisJoinPoint);  
    }
}
```

运行TestCflow结果如下所示：

```
Enter:execution(void com.aspectj.demo.test.TestCfow.foo())
foo......
bar.........
foo......
```

发现只有bar方法里面的foo()被拦截了，但同样的需求在Spring AOP却无法实现。

----

###三、总结

cflow()获取的是一个控制流程。他很少几乎不单独使用，一般与其他的pointcut 进行 &&运算。若要单独使用，一定要记得用!within()剔除asepct 本身。

----

OK，笔记就记到这里了。再次感谢CSDN小胡子的专栏原稿。再次说明，本笔记不做任何商业用途，只是为了自己知识整理和与他人分享技术这两个纯粹的目的。如果有任何疑问欢迎在下方留言，希望能认识到同样热爱技术的你，一起努力与进步。