---
date: 2014-03-18 18:00:00
layout: post
title: Aspectj操作与语法基础学习笔记（三）
thread: 84
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

##pointcut语法与实践进阶

###一、call和execution

execution语法结构如下：

* execution(public \*.\*(..))　　所有的public方法。
* execution(\* hello(..))            所有的hello()方法
* execution(String hello(..))   所有返回值为String的hello方法。
* execution(\* hello(String))  　　所有参数为String类型的hello()
* execution(\* hello(String..))      至少有一个参数，且第一个参数类型为String的hello方法
* execution(\* com.aspect..\*(..))  　所有com.aspect包，以及子孙包下的所有方法
* execution(\* com..\*.\*Dao.find\*(..))　　com包下的所有一Dao结尾的类的一find开头的方法

call捕获的joinpoint是签名方法的调用点，而execution捕获的则是执行点。具体实现效果在如下的demo中可以发现。

HelloWorld.java沿用之前的代码：

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

而HelloAspect改成如下所示：

```
package com.aspectj.demo.aspect;  
  
public aspect HelloAspect {  
  
	pointcut HelloWorldPointCut() : call(* main(int)); 
    
    before() : HelloWorldPointCut(){  
    	System.out.println("Entering : " + thisJoinPoint.getSourceLocation()); 
    }  
} 
```

运行结果如下所示：

```
Entering : HelloWorld.java:13
int the main method i = 5
```

其中，这里用到了一内置的对象：thisJoinPoint,他表示当前jionPoint.　跟我们在java中的this其实是差不多的。getSourceLocation()表示原代码的位置。其中13表示行号。

接下来我们把HelloAspect中的call改为execution，发现运行结果如下所示：

```
Entering : HelloWorld.java:5
int the main method i = 5
```

所以可以总结：一个是调用的地方，一个是执行的地方。其中，**thisJoinPoint.getSourceLocation()　这段代码将会在大胡子教程以后的Demo中会经常用到，这是一个跟踪调试的好办法。**

----

###二、within和withincode

现在假设你有另一个包含main()方法的class：

```
package com.aspectj.demo.test;  
  
public class HelloAspectDemo{  
      
      
    public static void main(String[] args) {  
        System.out.println("Hello aspectj");  
    }  
}  
```

而HelloAspect如下所示：

```
package com.aspectj.demo.aspect;  

public aspect HelloAspect {  
    pointcut HelloWorldPointCut() : execution(* main(..));  
    before() : HelloWorldPointCut(){  
       System.out.println("Entering : " + thisJoinPoint.getSourceLocation());  
    }  
}  
```

运行HelloAspectDemo结果如下所示：

```
Entering : HelloAspectDemo.java:4
Hello aspectj
```

这样，便会把HelloAspectDemo的main方法捕获到，如果现在告诉你HelloAspectDemo不需要捕获，那怎么办？

这个时候就用到了我们的within了。修改一下HelloAspect：

```
package com.aspectj.demo.aspect;
import com.aspectj.demo.test.HelloAspectDemo;

public aspect HelloAspect {  
    pointcut HelloWorldPointCut() : execution(* main(..)) && !within(HelloAspectDemo);  
    before() : HelloWorldPointCut(){  
       System.out.println("Entering : " + thisJoinPoint.getSourceLocation());  
    }  
}  
```

运行一下，结果为`Hello aspectj`，你会发现他没有被拦截到。

withincode与within相似，不过withcode()接受的signature是方法，而不是类。用法、意思都差不多，只不过是使用场合不同。

----

OK，笔记就记到这里了。再次感谢CSDN小胡子的专栏原稿。再次说明，本笔记不做任何商业用途，只是为了自己知识整理和与他人分享技术这两个纯粹的目的。如果有任何疑问欢迎在下方留言，希望能认识到同样热爱技术的你，一起努力与进步。