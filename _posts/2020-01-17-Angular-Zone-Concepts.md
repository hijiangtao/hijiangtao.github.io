---
title: 关于 Angular NgZone 的一些介绍
layout: post
thread: 240
date: 2020-01-17
author: Joe Jiang
categories: Document
tags: [Angular, NgZone, RxJS, 前端, 性能优化]
excerpt: 要不是代码里看到 NgZone，我都不知道什么时候会接触到这个概念。今天来看看 NgZone 这个 API。
---

### 1. 从 Angular 的变更检测说起

要不是代码里看到 NgZone，我都不知道什么时候会接触到这个概念。我们知道，当下三大 UI 框架都存在变更检测，以此实现自己 UI 层的更新。在 Angular 中，若是逻辑代码存在如下事件时，便会触发框架的变更检测：

1. `Events` - 一些事件，例如 `click`、`change`、`input`、`submit` 等；
2. `XMLHttpRequests` - 网络请求；
3. `Timers` - `setTimeout()` 与 `setInterval()` API 等；

但有时我们并不想触发 Angular 变更检测，这时你大概率是在做应用的性能优化。没错，Angular 引入 Zone.js 以处理变更检测，Zone.js 通过对所有常见的异步 API打上了“补丁” 以追踪所有的异步操作，进而使 Angular 可以决定何时刷新 UI。

看看官网介绍

> An injectable service for executing work inside or outside of the Angular zone. —— [NgZone API](https://angular.io/api/core/NgZone#ngzone)

### 2. 解答几个问题

本文也不通篇大论叙述 Zone.js 的来世今生，为了让自己快速上手，我们解答几个关键问题。

1. **什么是 Zone？** Zone 是一种用于拦截和跟踪异步工作的机制。
2. **什么是 NgZone？** Zone.js 将会对每一个异步操作创建一个 task。一个 task 运行于一个 Zone 中。通常来说， 在 Angular 应用中，每个 task 都会在 "Angular" Zone 中运行，这个 Zone 被称为 NgZone。一个 Angular 应用中只存在一个 Angular Zone，而变更检测只会由 运行于这个 NgZone 中的异步操作触发。
3. **如何在代码中上手 NgZone？** 先了解 `run` 与 `runOutsideAngular` 两个 API 即可。

### 3. 几个应用示例

以上涉及到两个 API，再加上一些常见用法。我们来看看在不同场景下，代码都该怎么写。

首先，函数 `runOutsideAngular` 用于确保代码于 NgZone 之外运行，即保证 Angular 的变更检测不会因为相关代码而触发。

    constructor(private ngZone: NgZone) {
      this.ngZone.runOutsideAngular(() => {
        // 以下代码不会触发变更检测
        setInterval(() => doSomething(), 100)
      });
    }

`run` 方法的目的与 `runOutsideAngular` 正好相反：任何写在 run 里的方法，都会进入 Angular Zone 的管辖范围。

    // 此处的 num 会实时更新
    import { Component, NgZone } from '@angular/core';
    
    @Component({
      selector: 'my-app',
      template: `
      <p>
    	  <label>Count: </label>
        {{ num }}
      </p>  
      `
    })
    export class AppComponent {
      num = 0;
      constructor(private zone: NgZone) {
        this.zone.runOutsideAngular(() => {
          let i = 0;
          const token = setInterval(() => {
            this.zone.run(() => {
              this.num = ++i;
            })
            console.log(this.num);
            if (i == 10) {
              clearInterval(token);
            }
          }, 1000);
        })
      }
    }

如果做到 Zone 外的操作虽然不会实时触发变更检测，但在特定时机还是通知到 Angular Zone 内呢？或者换句话说，即在 Zone 外创建数据流、Zone 内订阅数据流？可以看看下面的 Subject 应用：

    export class AppComponent implements OnInit {
      notify$ = new Subject();
    
      ngOnInit() {
        this.notify$.subscribe(() => {
           this.message = 'timeout';
        })
      }
    
      constructor(private zone: NgZone) {
        localStorage.setItem('expiredDate', addMinutes(new Date(), 1).getTime().toString());
        this.zone.runOutsideAngular(() => {
          const i = setInterval(() => {
            const expiredDate = +localStorage.getItem('expiredDate');
            console.log(new Date().getTime() - expiredDate);
            if (new Date().getTime() - expiredDate > 0) {
              this.zone.run(() => {
                this.notify$.next();
              })
              clearInterval(i);
            };
          }, 1000)
        })
      }
    }

Zone.js 和 RxJS 一起使用的细节，详见 [https://github.com/angular/angular/blob/master/packages/zone.js/NON-STANDARD-APIS.md#usage](https://github.com/angular/angular/blob/master/packages/zone.js/NON-STANDARD-APIS.md#usage)

其他进一步阅读材料如下：

- [https://blog.thoughtram.io/angular/2017/02/21/using-zones-in-angular-for-better-performance.html](https://blog.thoughtram.io/angular/2017/02/21/using-zones-in-angular-for-better-performance.html)
- [https://blog.thoughtram.io/angular/2016/02/01/zones-in-angular-2.html](https://blog.thoughtram.io/angular/2016/02/01/zones-in-angular-2.html)
- [https://blog.thoughtram.io/angular/2016/01/22/understanding-zones.html](https://blog.thoughtram.io/angular/2016/01/22/understanding-zones.html)