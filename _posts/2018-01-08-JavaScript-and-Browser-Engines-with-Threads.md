---
title: 聊聊JavaScript 与浏览器的那些事 - 引擎与线程
layout: post
thread: 186
date: 2018-01-08
author: Joe Jiang
categories: Documents
tags: [JavaScript, 浏览器, 线程, 引擎]
excerpt: 聊聊 JavaScript 的单线程和浏览器的多线程。
---

如果你做过可视化开发，那么你是否遇到过这样一个棘手的问题：因为需要向页面中添加大量的图表或点线元素而导致页面卡顿、性能下降。一般来说你可能考虑一个方案，从 SVG 换到了 canvas，这或多或少可以解决你面临的痛点，但是背后的原因你到底了解多少？隐藏在浏览器背后的秘密到底有多少，内核和引擎我们又该了解到什么程度？换个方面来说，我们都知道 JavaScript 是单线程的，那么 HTML5 规范引入了一个叫 Web Worker 的标准是否意味着 JavaScript 真正跨入多线程编程的时代了呢？

今天在看《深入 HTML5 Web Worker 应用实践：多线程编程》一文时发现自己对 JavaScript 解释器和浏览器的线程机制理解的不是特别透彻，很容易混淆浏览器多线程机制并错误认为由于 Web Worker 的设计使得 JavaScript 拥有了多线程的能力。事后搜了不少资料进行学习，整理成此文，主要介绍浏览器的各个引擎、线程间的工作机制以及 JavaScript 单线程的一些事。

## 浏览器的那些引擎与内核

因为要谈到 JavaScript 的实现，必须先了解它的宿主环境，我们就从宿主环境之一——浏览器开始说起吧。

浏览器的主要功能是向服务器发送请求，在自身窗口中展示我们所选择的网络资源。一个浏览器的主要组件可分为如下几个部分：

1. **用户界面(User Interface)** - 包括地址栏、前进/后退按钮、书签菜单等。除了浏览器主窗口显示的您请求的页面外，其他显示的各个部分都属于用户界面。
2. **浏览器引擎(Browser engine)** - 在用户界面和呈现引擎之间传送指令。
3. **呈现引擎(Rendering engine)** - 负责显示请求的内容。如果请求的内容是 HTML，它就负责解析 HTML 和 CSS 内容，并将解析后的内容显示在屏幕上。
4. **网络(Networking)** - 用于网络调用，比如 HTTP 请求。其接口与平台无关，并为所有平台提供底层实现。
5. **用户界面后端(UI Backend)** - 用于绘制基本的窗口小部件，比如组合框和窗口。其公开了与平台无关的通用接口，而在底层使用操作系统的用户界面方法。
6. **JavaScript 解释器(JavaScript Interpreter)**。用于解析和执行 JavaScript 代码。
7. **数据存储(Data Persistence)**。这是持久层。浏览器需要在硬盘上保存各种数据，例如 Cookie。新的 HTML 规范 (HTML5) 定义了“网络数据库”，这是一个完整（但是轻便）的浏览器内数据库。

![](/assets/in-post/2018-01-08-JavaScript-and-Browser-Engines-with-Threads-1.png )

*注意：和大多数浏览器不同，Chrome 浏览器的每个标签页都分别对应一个呈现引擎实例。每个标签页都是一个独立的进程。*

作为一名前端工程师，我们会更注重呈现引擎和 JavaScript 解释器的部分，那么下面来详细解释下这两部分。

### 1.1 呈现引擎

**呈现引擎，又称渲染引擎，也被称为浏览器内核，在线程方面又称为 UI 线程**，它是由各大浏览器厂商依照 W3C 标准自行研发的，常见的浏览器内核可以分这四种：Trident、Gecko、Blink、Webkit。

* **Trident**：俗称 IE 内核，也被叫做 MSHTML 引擎，目前在使用的浏览器有 IE11 -，以及各种国产多核浏览器中的 IE 兼容模块。另外微软的 Edge 浏览器不再使用 MSHTML 引擎，而是使用类全新的引擎 EdgeHTML。

* **Gecko**：俗称 Firefox 内核，Netscape6 开始采用的内核，后来的 Mozilla FireFox（火狐浏览器）也采用了该内核，Gecko 的特点是代码完全公开，因此，其可开发程度很高，全世界的程序员都可以为其编写代码，增加功能。因为这是个开源内核，因此受到许多人的青睐，Gecko 内核的浏览器也很多，这也是 Gecko 内核虽然年轻但市场占有率能够迅速提高的重要原因。

* **Presto**：Presto 是挪威产浏览器 opera 的 “前任” 内核，最新的 opera 浏览器内核现为 Blink。

* **Webkit**：Safari 内核，也是 Chrome 内核原型，主要是 Safari 浏览器在使用的内核，也是特性上表现较好的浏览器内核。也被大量使用在移动端浏览器上。

* **Blink**： 由 Google 和 Opera Software 开发，在Chrome（28及往后版本）、Opera（15及往后版本）和Yandex浏览器中使用。Blink 其实是 Webkit 的一个分支，添加了一些优化的新特性，例如跨进程的 iframe，将 DOM 移入 JavaScript 中来提高 JavaScript 对 DOM 的访问速度等，目前较多的移动端应用内嵌的浏览器内核也渐渐开始采用 Blink。

由于移动互联网的普及，我们还可以单独说一说目前移动设备上浏览器常用的内核情况： iPhone 和 iPad 等苹果 iOS 平台主要是 WebKit，Android 4.4 之前的 Android 系统浏览器内核是 WebKit，Android4.4 系统浏览器切换到了Chromium，内核是 Webkit 的分支 Blink，Windows Phone 8 系统浏览器内核是 Trident。

呈现引擎最重要的作用就是“呈现”了，也就是在浏览器的屏幕上显示请求的内容。一开始它会从网络层获取请求文档的内容，内容的大小一般限制在 8000 个块以内。然后进行如下所示的基本流程：

![](/assets/in-post/2018-01-08-JavaScript-and-Browser-Engines-with-Threads-2.png )

呈现引擎将开始解析 HTML 文档，并将各标记逐个转化成“内容树”上的 DOM 节点。同时也会解析外部 CSS 文件以及样式元素中的样式数据。HTML 中这些带有视觉指令的样式信息将用于创建另一个树结构：**呈现树**。

呈现树包含多个带有视觉属性（如颜色和尺寸）的矩形。这些矩形的排列顺序就是它们将在屏幕上显示的顺序。

呈现树构建完毕之后，进入**“布局”**处理阶段，也就是为每个节点分配一个应出现在屏幕上的确切坐标。下一个阶段是**绘制** - 呈现引擎会遍历呈现树，由用户界面后端层将每个节点绘制出来。

需要着重指出的是，这是一个渐进的过程。为达到更好的用户体验，呈现引擎会力求尽快将内容显示在屏幕上。它不必等到整个 HTML 文档解析完毕之后，就会开始构建呈现树和设置布局。在不断接收和处理来自网络的其余内容的同时，呈现引擎会将部分内容解析并显示出来。

在这里，需要注意的是不同呈现引擎在主流程中会稍有不同，例如 CSS 样式表的解析时机，Webkit 内核下，HTML 和 CSS 文件的解析是同步的，而 Geoko 内核下，CSS 文件需要等到 HTML 文件解析成内容 Sink 后才进行解析。除此外，一些描述术语也会略有不同，详细内容可以查看《[浏览器的工作原理：新式网络浏览器幕后揭秘](https://www.html5rocks.com/zh/tutorials/internals/howbrowserswork/)》进行了解。

### 1.2 JavaScript 解释器

什么是 JavaScript 解释器？简单地说，JavaScript 解释器就是能够“读懂” JavaScript 代码，并准确地给出代码运行结果的一段程序。

**所以 JavaScript 解释器，又称为 JavaScript 解析引擎，又称为 JavaScript 引擎，也可以成为 JavaScript 内核，在线程方面又称为 JavaScript 引擎线程。**比较有名的有 Chrome 的 V8 引擎（用 C/C++ 编写），除此外还有 IE9 的 Chakra、Firefox 的 TraceMonkey。它是基于事件驱动单线程执行的，JavaScript 引擎一直等待着任务队列中任务的到来，然后加以处理，浏览器无论什么时候都只有一个 JavaScript 线程在运行 JavaScript 程序。

学过编译原理的人都知道，对于静态语言来说（如Java、C++、C），处理上述这些事情的叫编译器（Compiler），相应地对于 JavaScript 这样的动态语言则叫解释器（Interpreter）。这两者的区别用一句话来概括就是：编译器是将源代码编译为另外一种代码（比如机器码，或者字节码），而解释器是直接解析并将代码运行结果输出。 比方说，firebug 的 console 就是一个 JavaScript 解释器。但我们无需过多在这些点上纠结。因为比如像 V8，它其实是为了提高 JavaScript 的运行性能，会在运行之前将 JavaScript 编译为本地的机器码然后再去执行，这样速度就快很多，相信大家对 JIT（Just In Time Compilation）一定不陌生吧。

JavaScript 解释器和我们平时讨论的 ECMAScript 有很大关系，标准的 JavaScript 解释器会根据 ECMAScript 标准去实现文档中对语言规定的方方面面，但由于这不是一个强制措施，所以也有不按照标准来实现的解释器，比如 IE6，这也是一直困扰前端开发的一个来由——兼容问题。有关 JavaScript 解释器的部分不做过于深入的介绍，但是由于我们对它有了部分的了解，接下来可以介绍一个新的部分——线程。

## JavaScript 与浏览器的线程机制

### 2.1 单线程的 JavaScript

**JavaScript 是单线程的，但是，为什么呢？**

这是由 Javascript 这门脚本语言的用途决定的。作为浏览器脚本语言，JavaScript 主要用于处理页面中用户交互，以及操作 DOM 树、CSS 样式树（当然也包括服务器逻辑的交互处理）。这决定了它只能是单线程，否则会带来很复杂的同步问题。比如，假定 JavaScript 同时有两个线程，一个线程在某个 DOM 节点上添加内容，另一个线程删除了这个节点，这时浏览器应该以哪个线程为准？当然我们可以通过锁来解决上面的问题。但为了避免因为引入了锁而带来更大的复杂性，从一诞生，JavaScript 就是单线程，这已经成了这门语言的核心特征。

**到这里，我们可以回顾一下最开始所提的一个问题：Web Worker 真的让 JavaScript 拥有了多线程的能力吗？**

为了利用多核 CPU 的计算能力，在 HTML5 中引入的工作线程使得浏览器端的 JavaScript 引擎可以并发地执行 JavaScript 代码，从而实现了对浏览器端多线程编程的良好支持。Web Worker 允许 JavaScript 脚本创建多个线程，但是子线程完全受主线程控制，且不得操作 DOM 。所以，这个新标准并没有改变 JavaScript 单线程的本质。

### 2.2 页面卡顿的真正原因

由于 JavaScript 是可操纵 DOM 的，如果在修改这些元素属性同时渲染界面（即 JavaScript 线程和 UI 线程同时运行），那么渲染线程前后获得的元素数据就可能不一致了。为了防止渲染出现不可预期的结果，浏览器设置 UI 渲染线程与 JavaScript 引擎线程为互斥的关系，当 JavaScript 引擎线程执行时 UI 渲染线程会被挂起，UI 更新会被保存在一个队列中等到 JavaScript 引擎线程空闲时立即被执行。

于是，我们便明白了：假设一个 JavaScript 代码执行的时间过长，这样就会造成页面的渲染不连贯，导致页面渲染出现“加载阻塞”的现象。当然，针对 DOM 的大量操作也会造成页面出现卡顿现象，毕竟我们经常说：DOM 天生就很慢。

所以，当你需要考虑性能优化时就可以从如上的原因出发，大致有以下几个努力的方面：

* 减少 JavaScript 加载对 DOM 渲染的影响（将 JavaScript 代码的加载逻辑放在 HTML 文件的尾部，减少对渲染引擎呈现工作的影响）；
* 避免重排，减少重绘（避免白屏，或者交互过程中的卡顿）；
* 减少 DOM 的层级（可以减少渲染引擎工作过程中的计算量）；
* 使用 requestAnimationFrame 来实现视觉变化（一般来说我们会使用 setTimeout 或 setInterval 来执行动画之类的视觉变化，但这种做法的问题是，回调将在帧中的某个时点运行，可能刚好在末尾，而这可能经常会使我们丢失帧，导致卡顿）；

有关优化的方面可以查看《[
优化 JavaScript 执行](https://developers.google.com/web/fundamentals/performance/rendering/optimize-javascript-execution)》一文了解更多信息。

### 2.3 浏览器中的那些线程

前端某些任务是非常耗时的，比如网络请求，定时器和事件监听，如果让他们和别的任务一样，都老老实实的排队等待执行的话，执行效率会非常的低，甚至导致页面的假死。所以浏览器是多线程的，除了之前介绍的两个互斥的呈现引擎和 JavaScript 解释器，浏览器一般还会实现这几个线程：浏览器事件触发线程，定时触发器线程以及异步 HTTP 请求线程。

* **浏览器事件触发线程**：当一个事件被触发时该线程会把事件添加到待处理队列的队尾，等待 JavaScript 引擎的处理。这些事件可以是当前执行的代码块如定时任务、也可来自浏览器内核的其他线程如鼠标点击、AJAX 异步请求等，但由于 JavaScript 的单线程关系所有这些事件都得排队等待 JavaScript 引擎处理；
* **定时触发器线程**：浏览器定时计数器并不是由 JavaScript 引擎计数的, 因为 JavaScript 引擎是单线程的, 如果处于阻塞线程状态就会影响记计时的准确, 因此通过单独线程来计时并触发定时是更为合理的方案；
* **异步 HTTP 请求线程**：在 XMLHttpRequest 在连接后是通过浏览器新开一个线程请求， 将检测到状态变更时，如果设置有回调函数，异步线程就产生状态变更事件放到 JavaScript 引擎的处理队列中等待处理；

### 2.4 由定时触发器线程想到 JavaScript 的异步

有关 JavaScript 的异步特性，我们可以从上述的定时触发器线程举个例子来加深印象。看下如下代码：

```javascript
function synchronizedCode() {
    var last = new Date().getTime();
    var count = 0;
    while (true) {
        var now = new Date().getTime();
        if (now - last > 1000 * 2) {
            last = now;
            count++;
            console.log('the %dth count.',count);
        }
        if (count > 9) {
            console.log('exist while.');
            break;
        }
    }
}
(function() {
    setTimeout(function() {console.log('setTimeout 0 occured first.');},0);
    setTimeout(function() {console.log('setTimeout 0 occured second.');},0);

    synchronizedCode();
})();
```

如上代码运行结果如下所示：

```
the 1th count.
the 2th count.
the 3th count.
the 4th count.
the 5th count.
exist while.
setTimeout 0 occured first.
setTimeout 0 occured second.
```

看到结果你心里可能会产生几个疑问，我们一一来看。

* **为什么 while 运行了五秒钟，期间 setTimeout 一直没运行呢？**

JavaScript 代码中有帧的概念，对于同步代码是在当前帧运行的，异步代码是在下一帧运行的。针对上面的代码我们画一幅运行的帧顺序图，应该是这样的：

![](/assets/in-post/2018-01-08-JavaScript-and-Browser-Engines-with-Threads-3.png )

* **为什么是第一个setTimeout先触发，第二个后触发呢
？**

这里一个原因是代码的顺序，另一个原因也是延迟时间也就是 setTimeout 的第二个参数。

这里需要明白的是：JavaScript 引擎的工作机制是当线程中没有执行任何同步代码的前提下才会执行异步代码，setTimeout 是异步代码，所以 setTimeout 只能等 JavaScript 引擎空闲才会执行。

## 总结

总体来看，本文先介绍了浏览器的主要组件及各自功能，然后从前端开发的角度出发着重介绍了呈现引擎（也就是 UI 渲染线程）和 JavaScript 解释器（也就是 JavaScript 引擎线程）的作用以及各自的工作机制。

在介绍完浏览器引擎与内核之后，我们谈到了 JavaScript 的单线程机制实现以及设计初衷，之后结合 JavaScript 解释器以及呈现引擎的工作机制谈了谈造成页面卡顿的真正原因。最后我们聊了聊浏览器中的那些线程以及 JavaScript 的一些异步内容。

除此外，还有很多相关的内容没在本文提及，比如说 JavaScript 的事件循环机制。之后有时间再详细聊一聊吧。

## 参考

* [浏览器的工作原理：新式网络浏览器幕后揭秘](https://www.html5rocks.com/zh/tutorials/internals/howbrowserswork/)
* [FE-Cookbook](https://github.com/hijiangtao/FE-Cookbook/blob/master/Tricks.md)
* [浏览器渲染引擎「内核」](https://github.com/zwwill/blog/issues/2)
* [JS重塑学习
](https://www.kancloud.cn/digest/liao-js/149467)
* [深入 HTML5 Web Worker 应用实践：多线程编程](https://www.ibm.com/developerworks/cn/web/1112_sunch_webworker/index.html)
* [Javascript引擎线程](https://www.jianshu.com/p/202ec7e5bf74)
* [
优化 JavaScript 执行](https://developers.google.com/web/fundamentals/performance/rendering/optimize-javascript-execution)
* [js异步之惑](https://blog.whyun.com/posts/js/)
* [Javascript线程的理解](https://github.com/fredshare/blog/issues/38)