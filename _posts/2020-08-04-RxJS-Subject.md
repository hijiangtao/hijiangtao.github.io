---
title: RxJS Subject 及其变体一探究竟
layout: post
thread: 256
date: 2020-08-04
author: Joe Jiang
categories: Daily
tags: [2020, RxJS, Subject, 多播, BehaviorSubject, ReplaySubject, AsyncSubject]
excerpt: RxJS Subject 及其变体一探究竟
---

## 1. Subject

由于 Observable 在设计上就是单播的，所以如果你希望使多个订阅者收到相同的数据，那么用 Observable 可能会非常麻烦。而 Subject 可以帮助我们解决这个问题。

Subject 可以用来实现多播。这里需要明白单播和多播的区别：

- 单播的意思是，每个普通的 Observables 实例都只能被一个观察者订阅，当它被其他观察者订阅的时候会产生一个新的实例。也就是普通 Observables 被不同的观察者订阅的时候，会有多个实例，不管观察者是从何时开始订阅，每个实例都是从头开始把值发给对应的观察者。
- 多播的基本含义是：一个 Observable execution 可以在多个订阅者之间共享。

Subject 也可比作事件发射器（EventEmitter），其中注册了多个事件监听器。 当我们订阅 Subject 时，它并不会启动一个新的 execution 来传送数据。而是在现有观察者列表中注册一个新的观察者，仅此而已。

我们来看一个例子：

```jsx
import * as Rx from "rxjs";

// 新建一个 Subject 实例
const mySubject = new Rx.Subject();

// 对 mySubject 赋值
mySubject.next(1);

// 对 mySubject 进行订阅
const subscription1 = mySubject.subscribe(x => {
  console.log('From subscription 1:', x);
});

// 对 mySubject 赋值，此时只有 subscription1 处于订阅状态
mySubject.next(2);

// 对 mySubject 进行订阅
const subscription2 = mySubject.subscribe(x => {
  console.log('From subscription 2:', x);
});

// 对 mySubject 赋值
mySubject.next(3);

// 对 mySubject 取消订阅
subscription1.unsubscribe();

// 对 mySubject 赋值
mySubject.next(4);
```

以上代码的输出结果为：

```jsx
From subscription 1: 2
From subscription 1: 3
From subscription 2: 3
From subscription 2: 4
```

而 Subject 还存在其他几个变体用法。

## 2. BehaviorSubject

BehaviorSubject 是 Subject 的变体之一。BehaviorSubject 的特性就是它会存储“当前”的值。这意味着你始终可以直接拿到 BehaviorSubject 最后一次发出的值。

有两种方法可以拿到 BehaviorSubject “当前”的值：访问其 `.value` 属性或者直接订阅。因此，在定义一个 BehaviorSubject 时也需要有初始值。而当有新的观察者订阅时，也可以立即从 BehaviorSubject 那接收到“当前值”

```jsx
import * as Rx from "rxjs";

const subject = new Rx.BehaviorSubject(Math.random());

// 订阅者 A
subject.subscribe((data) => {
  console.log('Subscriber A:', data);
});

subject.next(Math.random());

// 订阅者 B
subject.subscribe((data) => {
  console.log('Subscriber B:', data);
});

subject.next(Math.random());

console.log(subject.value)

// 输出
// 
// Subscriber A: 0.24957144215097515
// Subscriber A: 0.8751123892486292
// Subscriber B: 0.8751123892486292
// Subscriber A: 0.1901322109907977
// Subscriber B: 0.1901322109907977
// 0.1901322109907977
```

## 3. ReplaySubject

它类似于 BehaviorSubject，可以发送旧值给新的订阅者，但是不仅是“当前值”，还可以是之前的旧值。另外，ReplaySubject 还有一个额外的特性就是它可以记录一部分的 observable execution，从而存储一些旧的数据用来“重播”给新来的订阅者。

当创建 ReplaySubject 时，你还可以指定存储的数据量以及数据的过期时间。

```jsx
import * as Rx from "rxjs";

const mySubject = new Rx.ReplaySubject(2);

mySubject.next(1);
mySubject.next(2);
mySubject.next(3);
mySubject.next(4);

mySubject.subscribe(x => {
  console.log('From 1st sub:', x);
});

mySubject.next(5);

mySubject.subscribe(x => {
  console.log('From 2nd sub:', x);
});

// 结果
From 1st sub: 3
From 1st sub: 4
From 1st sub: 5
From 2nd sub: 4
From 2nd sub: 5
```

## 4. AsyncSubject

BehaviorSubject 和 ReplaySubject 都可以用来存储一些数据，而 AsyncSubject 就不一样了。AsyncSubject 只会在 Observable execution 完成后，将其最终值发给订阅者。

```jsx
import * as Rx from "rxjs";

const subject = new Rx.AsyncSubject();

// 订阅者A
subject.subscribe((data) => {
  console.log('Subscriber A:', data);
});

subject.next(Math.random())
subject.next(Math.random())
subject.next(Math.random())

// 订阅者B
subject.subscribe((data) => {
  console.log('Subscriber B:', data);
});

subject.next(Math.random());
subject.complete();

// Subscriber A: 0.4447275989704571
// Subscriber B: 0.4447275989704571
```

## 5. 扩展阅读

1. 关于 RxJS Subject 一些误用场景的介绍 [https://medium.com/@benlesh/on-the-subject-of-subjects-in-rxjs-2b08b7198b93](https://medium.com/@benlesh/on-the-subject-of-subjects-in-rxjs-2b08b7198b93)
2. RxJS Subjects in Depth [https://blog.bitsrc.io/rxjs-subjects-in-depth-56dcfc1dc858](https://blog.bitsrc.io/rxjs-subjects-in-depth-56dcfc1dc858)
3. RxJS: Subjects, Behavior Subjects & Replay Subjects [https://www.digitalocean.com/community/tutorials/rxjs-subjects](https://www.digitalocean.com/community/tutorials/rxjs-subjects)
