---
date: 2014-04-19 12:00:00
layout: post
title: HEAP[xxx.exe]:Invalid Address specified to RtlValidateHeap 报错解决方法
thread: 113
categories: Documents
tags: [debug]
---

写了一个OpenGL作业：两个类和一个测试程序，看上去都挺和谐的，运行时却报错：

>你的程序引发了一个断点。

挖到输出窗口一看：

>HEAP[xxx.exe]:Invalid Address specified to RtlValidateHeap

非话说多了也没用，直接找原因。

首先在运行时发现，每次运行到我的矩阵操作类的结尾return TRUE释放vector的时候，都会报错：user breakpoint called from code at  xxxxxxxxxxxxx，并在Debug的提示框中出现：

>HEAP[xxx.exe]:Invalid Address specified to RtlValidateHeap

这是单步调试发现的错误，但是如果直接运行连错误都不报，一个断点信息告诉你就没下文了。

网上查了下，基本上是说dll和exe在不同的地方开辟了空间，在不同的地方释放的问题。

所以有了下面：

##解决方案一

由于一个可能的原因是：在不同模块（工程）之间传递 C++ 类，而这两个模块用了不同的运行时库（Runtime Library）设置。例如：EXE 模块调用 DLL 模块里传递 C++ 类的函数，但 DLL 模块使用静态链接（Release 是 Multi-threaded (/MT) 、Debug 是 Multi-threaded Debug (/MTd) ）方式编译，而 EXE 模块使用动态链接（Release 是 Multi-threaded DLL (/MD) 、Debug 是 Multi-threaded Debug DLL (/MDd) ）方式编译。

可以对比这两个模块的工程属性 - C/C++ - 代码生成 - Runtime Library ，看看设置是否一样，如果不一样要改成一样的。

----

##解决方案二

至少我自己，用了上述方法没有解决，所以接下来继续看。

有人说遇到该问题的原因是，托管代码和非托管代码之间的分配机制不同，两者之间可以进行互操作，下面是查到的相关内容。

>经过一段时间对MSDN的钻研，终于明白C++/CLI互操作共分三种：

>1. P/Invoke 
>2. Com interop 
>3. C++ interop

>我想版主推荐的是指采用C++ interop方式。代码过程如下：

>1. 将非托管结构和函数放在#pragma unmanaged 内，像这样

{% highlight cpp %}
#pragma unmanaged
struct cUserNestedStruct
{
	.........
} ;

extern "C" int DllFunction(UserDefinedStruct**);
{% endhighlight %}

>2. 然后，在托管代码中就可以直接调用了。

{% highlight cpp %}
#pragma
managed
int main()
{
	UserDefinedStruct*   mystruct = new UserDefinedStruct();
	int num = DLLFunction(&mystruct);
}
{% endhighlight %}

>上述是调用Dll，进行互操作的情况。

>在我们的项目中，使用托管和非托管混合的方法，通过头文件，直接调用非托管程序。这里需要注意的是：托管代码的内存管理和非托管的内存管理是不同的。在内存堆的分配上也是不同的，所以，两者之间不能直接进行内存的互调用，例如：

>1. 在非托管代码中不能释放托管代码申请的内存；
>2，在非托管代码中申请的内存，在函数结束后就被释放，如果被return到托管环境里，是无效的地址。外层被使用的内存，可以在外层定义后传参到非托管函数，在内部赋值后，在外层被调用，然后被释放；在内部被申请的空间，需在内部显式的的释放，避免造成内存泄露，这样就不会出现上述两种错误。

解决方法是：是外层被使用的内存，可以在外层定义后传参到非托管函数，在内部赋值后，在外层被调用，然后被释放；在内部被申请的空间，需在内部显式的的释放，避免造成内存泄露，这样就不会出现上述两种错误。

----

##解决方案三

Dll之间由于由于空间分配和删除引起的

>invalid address specified to rtlvalidateheap

在外层模块中定义了一个变量，传入内层模块赋值，用完后在外层模块释放时出错。

又或者：析构函数出问题

其原因可能是堆被损坏，这说明 XXXX.exe 中或它所加载的任何 DLL 中有 Bug。一般是野指针导致。

到这里，我想到我的析构函数里写了一段`delete[] pt;`，好吧，删除。问题解决。

----

查找方法时找到一个小Tips分享一下:崩溃的时候进入调试，按**Alt+7键**可以查看Call Stack里面从上到下列出的对应从里层到外层的函数调用历史，而双击某一行可将光标定位到此次调用的源代码处。