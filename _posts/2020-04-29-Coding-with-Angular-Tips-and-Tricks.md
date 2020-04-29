---
title: Coding with Angular - Tips and Tricks
layout: keynote
thread: 244
date: 2020-04-29
author: Joe Jiang
categories: Presentation
tags: [2019, Angular, RxJS, TypeScript, 优化, 前端]
excerpt: 当你第一次从其他框架切换到 Angular 是否会有些迷茫，在感叹框架大而全的同时却对其中很多概念不尽了解？近期，为了给不断加入团队的新同学营造一个快速上手的环境，于是把团队的项目代码仔细阅读了一遍，从中挑出了一些在大家提交代码中反复会「犯的错误」，并总结成一系列值得 Angular 新手注意和学习的一些最佳实践。
iframe: https://hijiangtao.github.io/slides/s-YFD/Coding-with-Angular-Tips-and-Tricks.html#/

---

> [扫码或点击链接查看完整 Slides](https://hijiangtao.github.io/slides/s-YFD/Coding-with-Angular-Tips-and-Tricks.html#/)

[![](/assets/in-post/2020-04-29-Coding-with-Angular-qrcode.png)](https://hijiangtao.github.io/slides/s-YFD/Coding-with-Angular-Tips-and-Tricks.html#/)

当你第一次从其他框架切换到 Angular 是否会有些迷茫，在感叹框架大而全的同时却对其中很多概念不尽了解？近期，为了给不断加入团队的新同学营造一个快速上手的环境，于是把团队的项目代码仔细阅读了一遍，从中挑出了一些在大家提交代码中反复会「犯的错误」，并总结成一系列值得 Angular 新手注意和学习的一些最佳实践。

本分享共分为三个部分，首先会从中后台系统中最经典的部分——响应式表单开始，介绍表单在验证、控制可用性中的一些优化用法和避免死循环的建议，然后第二部分着重从书写规范和编码建议给出了一些用例、以方便大家在日后的开发过程中能有更好的 Code Review 体验，分享的最后一章会就 Angular 项目构建优化给出一些建议。

以下为分享大纲：

1. Reactive Forms
    * Control Validation
    * Infinite Loops
    * Control Disabling
2. Clean code
    * Variable and function names
    * Code comments
    * Subscribe in templates
    * Memory leaks
    * Imports with path aliases
3. Optimization
    * Lazy Loading for main bundle
    * Bundle Analyzer
    * Lazy Loading for images
    * Virtual Scrolling
    * Fonts, etc.

*注：本分享中提及的虚拟滚动意指 CDK，但未展开分享，感兴趣的同学可以自行搜索相关资料了解。*

## 参考

* <https://netbasal.com/angular-reactive-forms-tips-and-tricks-bb0c85400b58>
* <https://itnext.io/clean-code-checklist-in-angular-%EF%B8%8F-10d4db877f74>
* <https://itnext.io/how-to-optimize-angular-applications-99bfab0f0b7c>
* <https://blog.bitsrc.io/lazy-loading-images-using-the-intersection-observer-api-5a913ee226d>
* <https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API>
* <https://github.com/webpack-contrib/webpack-bundle-analyzer>
