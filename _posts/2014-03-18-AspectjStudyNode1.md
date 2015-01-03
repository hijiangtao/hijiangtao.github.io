---
date: 2014-03-18 16:30:00
layout: post
title: Aspectj操作与语法基础学习笔记（一）
thread: 82
categories: Documents
tags: [Aspectj]
excerpt: Simple explanations of Aspectj.
---

**前言：**严格上说，这些内容应该算是我的一些学习摘要，在互联网上搜索到了CSDN大胡子的[aspectj的学习专栏](http://my.csdn.net/zl3450341)，按照上面的介绍我对Aspectj的了解有了不少增进，想到根据自己的思想进一步凝练其中内容和为了以后巩固知识的需要，于是有了自己的这个学习笔记系列。首先，还是要感谢大胡子在CSDN上的无私奉献，感谢他的跟我学Adpectj系列专栏。

**Aspectj学习笔记系列：**

1. 《[Aspectj操作与语法基础学习笔记（一）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode1/)》
2. 《[Aspectj操作与语法基础学习笔记（二）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode2/)》
3. 《[Aspectj操作与语法基础学习笔记（三）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode3/)》 
4. 《[Aspectj操作与语法基础学习笔记（四）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode4/)》
5. 《[Aspectj操作与语法基础学习笔记（五）](http://hijiangtao.github.io/2014/03/18/AspectjStudyNode5/)》

本系列笔记会根据内容多少进行调整，并且其中的代码等内容与原专栏内容会有所改变，请注意。

我坚信开源与分享是助力学习与成长的最重要元素，所以也欢迎你基于我的笔记基础进行进一步增补与修改，以此帮助更多的人。

----

##一、简介

**aspectj官方网站**：<http://www.eclipse.org/aspectj/>

从官网上不仅能下载到aspectj的最新安装包，而且能看到对这款软件的最权威定义：A seamless aspect-oriented extension to the Java<sup>[tm]</sup> programming language.

解释成中文就是一中面向切片编程的语言，而他能干的一些事情包括：错误检查和处理，同步，上下文敏感的行为，性能优化，监控和记录，调试支持，多目标的协议等。

**AOP术语解释**：

1. pointcut：是一个（组）基于正则表达式的表达式，有点绕，就是说他本身是一个表达式，但是他是基于正则语法的。通常一个pointcut，会选取程序中的某些我们感兴趣的执行点，或者说是程序执行点的集合。
2. joinPoint：通过pointcut选取出来的集合中的具体的一个执行点，我们就叫JoinPoint。
3. Advice：在选取出来的JoinPoint上要执行的操作、逻辑。关于５种类型，我不多说，不懂的同学自己补基础。
4. aspect：就是我们关注点的模块化。这个关注点可能会横切多个对象和模块，事务管理是横切关注点的很好的例子。它是一个抽象的概念，从软件的角度来说是指在应用程序不同模块中的某一个领域或方面。又pointcut 和advice组成。
5. Target：被aspectj横切的对象。我们所说的joinPoint就是Target的某一行，如方法开始执行的地方、方法类调用某个其他方法的代码。

----

##二、开发环境搭建

我们需要两个东西，Aspectj和AJDT。Aspectj就不解释了，AJDT是一个eclipse插件，开发aspectj必装，他可以提供语法检查，以及编译。下载请戳：[Aspectj下载地址](http://www.eclipse.org/aspectj/downloads.php)，而AJDT的下载我们可以直接在eclipse里的Help菜单的Eclipse Markerplace中搜索下载，我下载的是AJDT的indigo版（这一步要感谢陈小贱同学的指导，我的好闺蜜）。

----

##三、第一个项目——Hello World

创建一个新项目，选择File->New->Aspectj Project，然后命名为aspectjDemo。

然后在src中new两个package，分别命名为com.aspectj.demo.aspect和com.aspectj.demo.test，前者用来放apsect，后者用来放测试类。

**在test中创建HelloWorld.java**

```
package com.aspectj.demo.test;  
  
public class HelloWorld {  
    /** 
     * @param args 
     */  
    public static void main(String[] args) {  
    }  
}  
```

**在aspect中建立HelloAspect.aj**

.aj文件新建可以右击相应路径New->Aspect,然后输入相应的文件名，Finish则新建成功。

```
package com.aspectj.demo.aspect;  
  
public aspect HelloAspect {  
    pointcut HelloWorldPointCut() : execution(* com.aspectj.demo.test.HelloWorld.main(..));  
    before() : HelloWorldPointCut(){  
        System.out.println("Hello world");  
    }  
} 
```

右键HelloWorld.java，Run一下发现运行结果：Hello world。

**结果分析**：在Line Number那里显示有一个深色的箭头。移上去，发现提示`advices HelloWorld.main(String[])`。意思是说：横切了HelloWorld的main(String[])方法。同样在HelloWorld这边也有箭头，这个箭头的方向不同。鼠标移上去，`advised by HelloAspect.before(): HelloWorldPointCut..`

从这个demo我们可以看出，Aspectj真的是很简单，不需要继承任何类和接口，只要编写一个pointcut和advice就ok了。

----

OK，笔记就记到这里了。再次感谢CSDN小胡子的专栏原稿。再次说明，本笔记不做任何商业用途，只是为了自己知识整理和与他人分享技术这两个纯粹的目的。如果有任何疑问欢迎在下方留言，希望能认识到同样热爱技术的你，一起努力与进步。