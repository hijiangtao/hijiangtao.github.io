---
title: Google I/O 2019 - Flutter for Web
layout: post
thread: 218
date: 2019-05-08
author: Joe Jiang
categories: Document
tags: [2019, Flutter, Web, Google, IO19, 跨平台框架, 移动开发]
excerpt: Google I/O 2019 来啦，作为一名 Web 开发，今年比较关注的是 Flutter 的动态，一起来看看都有哪些动态吧。
header:
  image: ../assets/in-post/2019-05-08-Flutter-for-Web-0.png
  caption: "@Google I/O 2019"
---

Google I/O 2019 来啦，作为一名 Web 开发，今年比较关注的是 Flutter 的动态，就现在来看今天的 Dev Keynote 上关于 Flutter 的部分有如下三个进展：

1. Flutter for Web
2. Flutter 1.5
3. #FlutterCreate (具体查看 https://www.youtube.com/watch?v=WLvpROMUjYQ)

![](/assets/in-post/2019-05-08-Flutter-for-Web-1.png)

如果这是你第一次听到 Flutter你一定很疑惑什么是 Flutter，在 IO19 之前它的目标是这样的：

> Flutter 是 Google 用以帮助开发者在 iOS 和 Android 两个平台开发高质量原生 UI 的移动 SDK。
它和其他跨平台框架比如 React Native 又有啥区别呢，如果你满脑子问号的话，可以先看看我之前写的这篇文章啦 - [让我们在2019年重新认识 Flutter](https://hijiangtao.github.io/2019/01/17/Say-Hello-to-Flutter-at-Beginning-of-2019/)

Google I/O 2019 关于 Flutter 的完整视频列表可见 <https://www.youtube.com/playlist?list=PLjxrf2q8roU2no7yROrcQSVtwbYyxAGZV>

接下来，我详细说说 Flutter for Web 的消息。

## Flutter - from Mobile to Multi-Platform

虽然当下只是 Technical Preview，但还是能看到不少动态。Flutter for Web 是 Flutter 基于标准 Web 技术（即 HTML，CSS 和 JavaScript）的一个兼容实现版本，使得「一次编写到处运行」的主角除了 JavaScript 外又多了一个选择——Dart。

![](/assets/in-post/2019-05-08-Flutter-for-Web-2.png)

## Flutter for Web 简介

根据 Flutter 放出的架构图可以看到，Flutter for Web 通过 DOM, Canvas 以及 CSS 实现了 Flutter 的核心绘图层，技术上是用的 Dart 以及 Dart 优化过的 JavaScript 编译器，将 Flutter 核心、框架层以及你的应用代码一起编译成 Web 代码。虽然该版本还处于开发阶段，但 Google 简单罗列了几个有价值的场景：

1. 与 PWA 的结合（由 Flutter for Web 生成的代码可以打包成 PWA 应用，以提供更优雅的用户体验）
2. 嵌入式互动内容的高效开发（比如数据可视化实现，在线 Web 工具实现等）
3. 向 Flutter 原生应用动态下发内容（Flutter for Web 希望通过 web view 的形式做到在线呈现与 app embedded 代码的动态发送，避免重写）

Flutter for Web 的代码长啥样呢，我们看看 Hello World 的实现：

```dart
import 'package:flutter_web/material.dart';

void main() {
  runApp(new Text('Hello World', textDirection: TextDirection.ltr));
}
```

## 预览版注意事项

在 IO19 放出更多关于 Flutter 的动态之前，关于 Flutter for Web 预览版有几点是需要注意的：

当下的 Flutter for Web 基于 Flutter 项目 fork 开发，以保证可以同步核心 Flutter 的迭代；
Google 已经开始将 Flutter for Web 代码合并到 Flutter core 中。最终愿景是将 Flutter 打造成一个适用于全平台的一套 SDK/Framework；
Flutter for Web API 与 Flutter API 一致，但当下项目中是单独打包的；
你可以直接将现有 Flutter 应用重新打包成 web 预览版，但会有一些警告，详见项目说明 flutter/flutter_web
Flutter for Web 现在还不接受 PR，但有任何建议是可以新建 issue 提出的，issue 统一通过打标提在 Flutter 项目中，而不是 Flutter for Web。

## Demo

![](/assets/in-post/2019-05-08-Flutter-for-Web-3.gif)

## 其他

1. https://developers.googleblog.com/2019/05/Flutter-io19.html
2. Developer Keynote (Google I/O '19) https://www.youtube.com/watch?v=LoLqSbV1ELU
3. Flutter for Web 项目地址 https://github.com/flutter/flutter_web
4. Gitter 聊天室 https://gitter.im/flutter/flutter_web
5. Flutter for Web https://flutter.dev/web
6. Bringing Flutter to the Web https://medium.com/flutter-io/bringing-flutter-to-the-web-904de05f0df0?linkId=67084023

更多细节可以关注 IO19 后续关于 Flutter 的议题 https://events.google.com/io/