---
title: JavaScript 考古史闲聊
layout: post
thread: 231
date: 2019-08-31
author: Joe Jiang
categories: Document
tags: [2019, 前端, JavaScript, Web,]
excerpt: 今天在整理 JavaScript 月刊新一期内容时，看到一篇文章感觉不错，遂推荐一下。文章标题是 How JavaScript Grew Up and Became a Real Language，讲述的是 JavaScript 一路走来是如何一步步成为一门真正的编程语言的故事。
header:
  image: ../assets/in-post/2019-08-31-Some-Words-about-JavaScript-History-Teaser.jpg
  caption: "@PrimitivePic"
---

今天在整理 JavaScript 月刊新一期内容时，看到一篇文章感觉不错，遂推荐一下。文章标题是 [How JavaScript Grew Up and Became a Real Language](https://medium.com/young-coder/how-javascript-grew-up-and-became-a-real-language-17a0b948b77f)，讲述的是 JavaScript 一路走来是如何一步步成为一门真正的编程语言的故事。

说到 JavaScript 的历史，最耳熟能详的便是网景公司在1995年雇佣 Brendan Eich，后者花了10天便设计出初版 JavaScript 的故事了。一方面由于设计之初的理念所致，另一方面受限于沙箱机制所隔离的能力，JavaScript 在很长一段时间内并没有在编程语言界「转正」的迹象。

说来也怪，就在 JavaScript 依旧被认为是一门玩具语言、只能被用来实现一些简单的网页效果之际，IE 也可以说是微软，竟救了 JavaScript，用的武器是做 Outlook 网页版所实现的 XMLHttpRequest，但随后 IE 并没有把握好这次窗口，而后来 IE 的缓慢发展及 Windows 的高市场占有率也使得 Web 开发者长期忍受着 IE 兼容的苦，当然这都是后话了。

之后，2006年横空出世的 jQuery 给 JavaScript 开发者带来了福音，而后真正接下微软这一棒继续推举 JavaScript 发展大旗的却是 Google。作为一家年轻的公司，Google 于2008年推出 JavaScript 引擎 V8。得益于 V8 的高性能, Node.js 和 Electron 顺势而出。之后随着 HTML5 草案推出，JavaScript 开发者的能力得到进一步拓展，可以触及到诸如本地存储、音频操作和后台任务等 API。

20年间，诸如 Java applets, Flash, 甚至 Silverlight 等无数的对手都倒在了 JavaScript 面前。直到现在，我们不得不承认，是的，JavaScript 已成为世界上最流行的编程语言之一。

而此刻的 JavaScript 依旧走在发展的快车道，除了在 Web server 和桌面端上攻城略地外，我们还能看到 TypeScript 和 WebAssembly 的发展为 JavaScript 提供更多能力的未来。

文中还提到很多其他不为人知的细节，比如 Eich 和网景公司在语言设计初衷上的分歧，比如早期沙箱机制对 JavaScript 的限制。感兴趣的话直接移步 [medium](https://medium.com/young-coder/how-javascript-grew-up-and-became-a-real-language-17a0b948b77f) 查看。想起另一个很有趣的视频 [The Birth & Death of JavaScript](https://www.destroyallsoftware.com/talks/the-birth-and-death-of-javascript)，为什么在 PyCon 2014 上 Gary Bernhardt 就「断言」JavaScript 会在2035年寿终正寝，感兴趣可以看看。

用 Brendan Eich 说过一句话结束这篇碎碎念：Always bet on JavaScript.
