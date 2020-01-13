---
title: 响应式编程入门指南 - 通俗易懂 RxJS
layout: post
thread: 237
date: 2020-01-13
author: Joe Jiang
categories: Document
tags: [响应式编程, RxJS, Stream, 流]
excerpt: 本文从初学者的角度出发，希望由浅入深全面的梳理一下有关 RxJS 的各个方面
header:
  image: ../assets/in-post/2020-01-13-RxJS-Introduction-and-Actions-Teaser.jpg
---

> 全文篇幅较长，建议选取一段独立的时间来阅读此文。

RxJS 是 Reactive Extensions for JavaScript 的缩写，起源于 Reactive Extensions，是一个基于可观测数据流 Stream 结合观察者模式和迭代器模式的一种异步编程的应用库。RxJS 是 Reactive Extensions 在 JavaScript 上的实现。

按照正常的节奏，听到 RxJS 时，我第一时间是打开官方文档阅读的，但在没实际上手操作之前，文档的诸多描述和关键词让我读的有些摸不着头脑。RxJs 是干什么的、它解决了什么问题，只有找到这两个问题的答案我才能对 RxJS 有所体感。

网上存在各式各样的教程或者讲解，但正如大部分文章所述，虽然 RxJS 如此强大，但概念众多、一切皆为流的思想又贯穿始终，便存在「学习门槛过高｜的错觉。本文从初学者的角度出发，希望由浅入深全面的梳理一下有关 RxJS 的各个方面，本文编排顺序如下：

1. 初识 RxJS 的做事方法 - 先用一个字符串输入和处理显示的例子简单演示如何用 RxJS 实现我们的日常需求；
2. 知识点扫盲与提振信心 - 然后将一系列学习 RxJS 之前需要了解的前置知识点梳理一遍，比如同步/异步、观察者模式、响应式编程、迭代器模式、Stream 等等，这有点像写论文中的 related work。毕竟，上来各种听不懂的名词，很容易使初学者望而却步；
3. RxJS 核心概念与示例 - 接着顺势引入 RxJS 及其相关核心概念，比如 Observable、Observer、Subscription、Schedulers、Operator 和 Subject 等等，并附带一些个人理解和通俗易懂的示例；
4. 一些其他示例，比如 Hot/Cold Observable、单播与多播示例等等，希望帮助你熟悉 RxJS 的更多用法；

想想连我都能学会，你还怕什么呢，那么我们开始吧。

> 转载请注明作者与本文地址 <https://hijiangtao.github.io/2020/01/13/RxJS-Introduction-and-Actions/>, 你也可以在知乎查看此文 <https://zhuanlan.zhihu.com/p/102446217>。

# 一、一个控制数据流动的示例

我们看一个简单示例。假设我们的页面中有一个输入框，我们想将用户的输入打印出来，但有个条件，若是输入字符长度小于3我们则忽略处理，即控制台输出的第一个值应为 "hel" 字符串。现在我们要用 RxJs 来实现，该怎么做呢？

    // 输入 "hello world"
    var input = Rx.Observable.fromEvent(document.querySelector('input'), 'input');
    
    // 过滤掉小于3个字符长度的目标值
    input.filter(event => event.target.value.length > 2)
      .map(event => event.target.value)
      .subscribe(value => console.log(value)); // 订阅输出值

我们先不细探 Rx.Observable 的创建方式以及链式调用声明控制台输出的写法，简而言之以上便是 RxJS 可以做的一件事情，把 DOM 中的用户输入通过事件转化为经过逻辑处理的控制台输出结果。

文档对 RxJS 的介绍只有一句话，**它是使用 Observables 的响应式编程的库，它使编写异步或基于回调的代码更容易。**但从以上例子看，貌似 RxJS 对回调的处理没有什么特别，你可能在想，不知道 RxJs 之前，我们完全可以写一个传统的事件监听器，并填入处理逻辑。那么它到底强在哪，为什么使响应式编程更容易了呢？解答这个问题之前，我们先把前置需要了解的概念梳理一下。

# 二、前置知识点

### 2.1 同步与异步

我们先看分布式网络系统中的同步/异步。分布式网络系统中，各个参与方节点的运行是相互独立的，没有共享内存，没有全局时钟。各节点通过消息来进行沟通。在传统的理念中，我们会把这样的网络根据他们通信方式描述成同步和异步的。

- 同步（Synchronous）就是整个处理过程顺序执行，当各个过程都执行完毕，并返回结果。是一种线性执行的方式，执行的流程不能跨越。一般用于流程性比较强的程序，比如用户登录，需要对用户验证完成后才能登录系统。
- 异步（Asynchronous）则是只是发送了调用的指令，调用者无需等待被调用的方法完全执行完毕；而是继续执行下面的流程。是一种并行处理的方式，不必等待一个程序执行完，可以执行其它的任务，比如页面数据加载过程，不需要等所有数据获取后再显示页面。

而介绍如上概念之前，作为前端工程师，最被大家熟知的“同步/异步”概念大概如图所示

![](/assets/in-post/2020-01-13-Introduction-of-JavaScript-Sync-Async-Example.png )

而同步/异步编程和同步/异步网络又有什么区别呢？传统的同步编程是一种请求响应模型，调用一个方法，等待其响应返回.。而异步编程就是，发出一个任务，不等待结果，就继续发出下一个任务。至于上一个任务的执行结果，我们可以通过两种方式获得，一个是主动轮询，另一个是单独开一个线程去等待结果接收并回调执行。

### 2.2 响应式编程

响应式编程，即 Reactive Programming。它是一种基于事件模式的模型。在上面的异步编程模式中，我们描述了两种获得上一个任务执行结果的方式，一个就是主动轮询，我们把它称为 Proactive 方式；另一个就是被动接收反馈，我们称为 Reactive 方式。简单来说，在 Reactive 方式中，上一个任务执行结果的反馈就是一个事件，这个事件的到来会触发下一个任务的执行。

网上有一大堆定义，理论化或者泛泛而谈，对于初学者来说一句话概括，**响应式编程是使用异步数据流进行编程。**

> 响应式编程的思路大概如下：你可以用包括 Click 和 Hover 事件在内的任何东西创建 Data stream（也称“流”，后续章节详述）。Stream 廉价且常见，任何东西都可以是一个 Stream：变量、用户输入、属性、Cache、数据结构等等。举个例子，想像一下你的 Twitter feed 就像是 Click events 那样的 Data stream，你可以监听它并相应的作出响应。

> 在这个基础上，你还有令人惊艳的函数去组合、创建、过滤这些 Streams，这就是函数式魔法的用武之地。Stream 能接受一个，甚至多个 Stream 为输入，你可以融合两个 Stream，也可以从一个 Stream 中过滤出你感兴趣的 Events 以生成一个新的 Stream，还可以把一个 Stream 中的数据映射到一个新的 Stream 中。——摘自[《响应式编程介绍》](https://zhuanlan.zhihu.com/p/27678951)

### 2.3 Stream / 流

作为响应式编程的核心，流的本质是一个按时间顺序排列的进行中事件的序列集合。它可以发送三种不同的事物：

- 某种类型的值
- 错误（Error）
- 已完成信号（"Completed" Signal）

下图是点击按钮的一个事件流示意图

![](/assets/in-post/2020-01-13-Introduction-of-RxJS-Stream-Example.png )

该示意图使用 ASCII 重画长成这样：

    --a---b-c---d---X---|->
    
    a, b, c, d are emitted values
    X is an error
    | is the 'completed' signal
    ---> is the timeline

我们可以针对它做一些处理，将它转化为一个新的 stream，比如做一个能记录一个按钮点击了多少次的计数器 Stream。在常见的响应式编程库中，每个 stream 都会有多个方法，map、filter、scan 等等。当你调用其中一个方法时，例如 `clickStream.map(f)`，它就会基于原来的 click stream 返回一个新的 `stream`。它不会对原来的 `click steam` 作任何修改。这个特性就是不可变性(Immutability)，它之于响应式编程 Stream，就如糖浆之于薄煎饼。我们也可以对方法进行链式调用如 `clickStream.map(f).scan(g)`.

    clickStream: ---c----c--c----c------c-->
                   vvvvv map(c becomes 1) vvvv
                   ---1----1--1----1------1-->
                   vvvvvvvvv scan(+) vvvvvvvvv
    counterStream: ---1----2--3----4------5-->

为了展示RP真正的实力，让我们假设你想得到一个包含双击事件的Stream。为了让它更加有趣，假设我们想要的这个Stream要同时考虑三击 (Triple clicks)，或者更加宽泛，连击 (Multiple clicks)。我们先不讨论它的实现，用示意图来表示这个 stream 它应该长成这样：

![](/assets/in-post/2020-01-13-Introduction-of-RxJS-Stream-Multiple-Click-Event-Example.png )

### 2.4 观察者模式

观察者模式又叫发布订阅模式（Publish/Subscribe），它是一种一对多的关系，让多个观察者（Obesver）同时监听一个主题（Subject），这个主题也就是**被观察者（Observable）**，被观察者的状态发生变化时就会通知所有的观察者，使得它们能够接收到更新的内容。观察者模式主题和观察者是分离的，不是主动触发而是被动监听。

网上有个例子解释的不错：购房者一直在密切的关注房价，而房价随时间波动，购房者可能会根据波动的房价而采取一系列的行动，比如购入或者继续观望。购房者与房价的这样一种关系其实就构成了一种观察者关系。这里，购房者担任观察者的角色，房价是被观察的角色，当房价信息发生变化，则自动推送信息给购房者。

先记得这个例子，后面介绍 RxJS 时我们会继续用到。

### 2.5 迭代器模式

迭代器（Iterator）模式又叫游标（Sursor）模式，迭代器具有 next 方法，可以顺序访问一个聚合对象中的各个元素，而不需要暴露该对象的内部表现。迭代器模式可以把迭代的过程从从业务逻辑中分离出来，迭代器将使用者和目标对象隔离开来，即使不了解对象的内部构造，也可以通过迭代器提供的方法顺序访问其每个元素。

例如在 JavaScript 中，可以通过 iterator 方法来获取一个迭代对象，然后调用迭代对象的 next 方法去迭代得到一个个的元素：

    var iterable = [1, 2];
    var iterator = iterable[Symbol.iterator]();
    iterator.next(); // => { value: "1", done: false}
    iterator.next(); // => { value: "2", done: false}
    iterator.next(); // => { value: undefined, done: true}

在了解了如上概念之后，我们回过头再看看 RxJS 解决了哪些核心问题：

- 同步和异步的统一写法
- 数据变更过程的组合拆分
- 数据和视图的精确绑定
- 条件变更后，对应数据自动重新计算

没有全明白也没关系，接下来了解 RxJs 的核心概念也就容易一些了。

# 三、RxJS 核心概念与内容概览

不管是官方文档的概览，还是网上搜的各种入门教程，关于 RxJS 的核心概念就这几个，也是文档中提到的：

- **Observable (可观察对象):** 表示一个概念，这个概念是一个可调用的未来值或事件的集合。
- **Observer (观察者):** 一个回调函数的集合，它知道如何去监听由 Observable 提供的值。
- **Subscription (订阅):** 表示 Observable 的执行，主要用于取消 Observable 的执行。
- **Operators (操作符):** 采用函数式编程风格的纯函数 (pure function)，使用像 `map`、`filter`、`concat`、`flatMap` 等这样的操作符来处理集合。
- **Subject (主体):** 相当于 EventEmitter，并且是将值或事件多路推送给多个 Observer 的唯一方式。
- **Schedulers (调度器):** 用来控制并发并且是中央集权的调度员，允许我们在发生计算时进行协调，例如 `setTimeout` 或 `requestAnimationFrame` 或其他。

罗列知识点对理解如何使用并不会有太大帮助，所以我也简单说说自己的体会，以下的内容会开始结合 RxJS 的相关内容。

### 3.1 理解 RxJS 中的 Observer 与 Observable

首先，如何理解 Observer 和 Observable 呢？我们回到之前的购房者例子。将那个例子套用到观察者模式中：

- 房价即为 Observable 对象；
- 购房者即为 Observer 对象；
- 而购房者观察房价即为 Subscribe（订阅）关系；

再结合买房的例子，我们可以很学术的描述 Observable 和 Observer 的行为：

- Observable ****可被观察，即房价被购房者关注，并且随时间变化发出 (emit) 不同值，表现为房价波动；
- Observer 可以观察 Observable，即购房者关注房价，并在 Observable （房价）发出不同值（房价波动）时做出响应，即买房或观望；
- Observable 和 Observer 之间通过订阅（Subscription）建立观察关系；
- 当 Observable 没有 Observer 的时候，即使发出了值，也不会产生任何影响，即无人关注房价时，房价不管如何波动都不会有响应；

### 3.2 Observer, Observable 与 Subscription 示例

Observable 是多个值的惰性推送集合。回到 RxJS 我们用一个例子来看看如何构建一个 Observable：

    import { Observable } from 'rxjs';
    
    const observable = Observable.create(observer => {
      observer.next('foo');
      observer.next('bar');
    })

我们可以调用 `Observable.create` 方法来创建一个 Observable，这个方法接受一个函数作为参数，这个函数叫做 `producer` 函数， 用来生成 Observable 的值。这个函数的入参是 observer，在函数内部通过调用 `observer.next()` 便可生成有一系列值的一个 Observable。当一个 Observable 被建立后，它能被多个 observer 订阅，每个订阅关系相互独立、互不影响。

但是运行这段代码后并不会发生任何事情，如上所述，我们需要一个 observer 去订阅这个 observable，此后基于 observable 发出的值，observer 才会响应。因此，在如上代码末尾，我们再加上一行：

    observable.subscribe(console.log);

 运行代码，console.log 函数便会依次打印出 'foo' 和 'bar' 了。

Subscription 是表示可清理资源的对象，通常是 Observable 的执行。Subscription 有一个重要的方法，即 unsubscribe，它不需要任何参数，只是用来清理由 Subscription 占用的资源。依旧是官方的一个示例，把其作用表述的已经很明确了：

    var observable = Rx.Observable.interval(1000);
    var subscription = observable.subscribe(x => console.log(x));
    // 稍后：
    // 这会取消正在进行中的 Observable 执行
    // Observable 执行是通过使用观察者调用 subscribe 方法启动的
    subscription.unsubscribe();

### 3.3 Subject

什么是 Subject？RxJS 中 Subject 是一种特殊类型的 Observable，它允许将值多播给多个观察者，所以 Subject 是多播的，而普通的 Observables 是单播的(每个已订阅的观察者都拥有 Observable 的独立执行)。不理解「单播」这个词可以先跳过，明白 subject 是一种 observable 即可。

对于 Subject，你可以提供一个观察者并使用 subscribe 方法，就可以开始正常接收值。从观察者的角度而言，它无法判断 Observable 执行是来自普通的 Observable 还是 Subject 。在这里，subscribe 类似于 JavaScript 中的 addEventListener；与此同时，每个 Subject 又都是观察者。Subject 是一个有如下方法的对象： `next(v)`、 `error(e)` 和 `complete()` 。要给 Subject 提供新值，只要调用 `next(theValue)` 方法。

    var subject = new Rx.Subject();
    
    subject.subscribe({
      next: (v) => console.log('observerA: ' + v)
    });
    subject.subscribe({
      next: (v) => console.log('observerB: ' + v)
    });
    
    subject.next(1);
    subject.next(2);

如上代码的控制台输出为：

    observerA: 1
    observerB: 1
    observerA: 2
    observerB: 2

### 3.4 Operators

操作符是函数，它基于当前的 Observable 创建一个新的 Observable。这是一个无副作用的操作：前面的 Observable 保持不变。

操作符本质上是一个纯函数 (pure function)，它接收一个 Observable 作为输入，并生成一个新的 Observable 作为输出。订阅输出 Observable 同样会订阅输入 Observable 。我们来看一个例子，这里会用到两个操作符，分别是[创建操作符](https://cn.rx.js.org/manual/overview.html#creation-operators) interval 以及转换操作符 map：

    import { Observable, interval } from 'rxjs';
    import { map } from 'rxjs/operators';
    
    const observable = interval(1000).pipe(map(value => value * 10));
    
    const subscription = observable.subscribe(console.log);

关于这两个操作符的作用这里简单解释一下： `interval` 的作用是创建一个 Observable ，该 Observable 使用指定的 IScheduler 并以指定时间间隔发出连续的数字，而后 `map` 的作用字如其名，即将给定的函数应用于源 Observable 发出的每个值，并将结果值作为 Observable 发出。

由于 RxJS 涉及到的概念和知识点比较宽泛和复杂，关于操作符的介绍这里就不一一列举了。但在实际使用中，宝石图（也有称弹珠图，原文为 marble diagram）是个非常有用的工具，能够帮助你快速了解对应操作符的作用，地址见 [https://rxmarbles.com/](https://rxmarbles.com/)。在官网文档中， 大多数操作符都会附有宝石图。 只要会看宝石图，学起操作符来会非常的快。比如 `map` 的宝石图便如下：

![](/assets/in-post/2020-01-13-Introduction-of-RxJS-Stream-Map-Operator-Example.png )

RxJS 6 及更新版本提供了可链式调用（Pipeable）的 RxJS 操作符，假设 source 是一个已定义的 observable，一个简单示例如下：

    source.pipe(
      map(x => x + x),
      mergeMap(n => of(n + 1, n + 2).pipe(
        filter(x => x % 1 == 0),
        scan((acc, x) => acc + x, 0),
      )),
      catchError(err => of('error found')),
    ).subscribe(console.log);

### 3.5 Schedulers

什么是调度器？调度器控制着何时启动 subscription 和何时发送通知。使用 `subscribeOn` 来调度 `subscribe()` 调用在什么样的上下文中执行。 默认情况下，Observable 的 `subscribe()` 调用会立即同步地执行。然而，你可能会延迟或安排在给定的调度器上执行实际的 subscription ，使用实例操作符 `subscribeOn(scheduler)`，其中 scheduler 是你提供的参数。我们来看一个同步变异步执行的例子：

    var observable = Rx.Observable.create(function (observer) {
      observer.next(1);
      observer.next(2);
      observer.next(3);
      observer.complete();
    })
    .observeOn(Rx.Scheduler.async);
    
    console.log('just before subscribe');
    observable.subscribe({
      next: x => console.log('got value ' + x),
      error: err => console.error('something wrong occurred: ' + err),
      complete: () => console.log('done'),
    });
    console.log('just after subscribe');

这段代码的输出结果如下：

    just before subscribe
    just after subscribe
    got value 1
    got value 2
    got value 3
    done

调度器类型一共有四种，详见文档 [https://cn.rx.js.org/manual/overview.html#h214](https://cn.rx.js.org/manual/overview.html#h214)。

# 四、若干示例

### 4.1 将数组转化为 Observable

    import { from } from 'rxjs';
    
    const array = [10, 20, 30];
    const result = from(array);
    
    result.subscribe(x => console.log(x));

### 4.2 单播与多播

单播示例

    let observable = Rx.Observable.create(function subscribe(obsever) {
      observer.next(1)
      observer.next(2)
    })
    observable.subscribe(v => console.log(v))
    observable.subscribe(v => console.log(v))
    
    // 输出两份 1, 2

多播示例

    let observable = Rx.Observable.create(function subscribe(obsever) {
      observer.next(1)
      observer.next(2)
    })
    let subject = new Rx.Subject()
    subject.subscribe(v => console.log(v))
    subject.subscribe(v => console.log(v))
    observable.subscribe(subject)
    
    // 输出 1, 1; 2, 2;

### 4.3 Hot Observable 与 Cold Observable

> Hot Observable 无论有没有 Subscriber 订阅，事件始终都会发生。当 Hot Observable 有多个订阅者时，Hot Observable 与订阅者们的关系是一对多的关系，可以与多个订阅者共享信息。

> 然而，Cold Observable 只有 Subscriber 订阅时，才开始执行发射数据流的代码。并且 Cold Observable 和 Subscriber 只能是一对一的关系，当有多个不同的订阅者时，消息是重新完整发送的。也就是说对 Cold Observable 而言，有多个Subscriber的时候，他们各自的事件是独立的。—— [Cold Observable 和 Hot Observable](https://www.jianshu.com/p/12fb42bcf9fd)

Cold observable 示例与打印结果

    const obs$ = Rx.Observable
      .from(['🍕', '🍪', '🍔', '🌭', '🍟'])
      .map(val => {
        return `Miam ${val}!`;
      });
    
    const sub1 = obs$.subscribe(val => {
      console.log('From sub1:', val);
    }, null, () => {
      console.log('done ----------------');
    });
    
    const sub2 = obs$.subscribe(val => {
      console.log('From sub2:', val);
    }, null, () => {
      console.log('done ----------------');
    });
    
    // 输出结果
    From sub1: Miam 🍕!
    From sub1: Miam 🍪!
    From sub1: Miam 🍔!
    From sub1: Miam 🌭!
    From sub1: Miam 🍟!
    done ----------------
    From sub2: Miam 🍕!
    From sub2: Miam 🍪!
    From sub2: Miam 🍔!
    From sub2: Miam 🌭!
    From sub2: Miam 🍟!
    done ----------------

Hot Observable 示例

    const obs$ = Rx.Observable.fromEvent(document, 'click')
      .map(event => ({ clientX: event.clientX, clientY: event.clientY }));
    
    const sub1 = obs$.subscribe(val => {
      console.log('Sub1:', val);
    });
    
    setTimeout(() => {
      console.log('Start sub2');
      const sub2 = obs$.subscribe(val => {
        console.log('Sub2:', val);
      });
    }, 4000);

关于 Hot Observable 示例的输出，这里解释一下。两个订阅者共享同一 stream，但是第二个订阅只会在4秒后才会响应输出。

注

1. JavaScript 同步/异步示意图取自 [https://www.bbsmax.com/A/1O5Ev9xad7/](https://www.bbsmax.com/A/1O5Ev9xad7/)
2. Stream 示意图取自 [https://github.com/benjycui/introrx-chinese-edition/blob/master/introrx.md](https://github.com/benjycui/introrx-chinese-edition/blob/master/introrx.md)

参考

- [https://cn.rx.js.org/](https://cn.rx.js.org/manual/overview.html)
- [https://github.com/xufei/blog/issues/44](https://github.com/xufei/blog/issues/44)
- [https://www.jianshu.com/p/035db36c5918](https://www.jianshu.com/p/035db36c5918)
- [https://zhuanlan.zhihu.com/p/27678951](https://zhuanlan.zhihu.com/p/27678951)
- [https://hateonion.me/posts/19jul16/](https://hateonion.me/posts/19jul16/)
- [https://rxmarbles.com/](https://rxmarbles.com/#interval)

> 转载请注明作者与本文地址 <https://hijiangtao.github.io/2020/01/13/RxJS-Introduction-and-Actions/>, 你也可以在知乎查看此文 <https://zhuanlan.zhihu.com/p/102446217>。

（完）