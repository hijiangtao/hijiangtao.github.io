---
title: 让我们在2019年重新认识 Flutter
layout: keynote
thread: 210
date: 2019-01-17
author: Joe Jiang
categories: Presentation
tags: [2019, Flutter, 移动开发, Dart, 跨平台技术, 前端]
excerpt: 现在是2019年，让我们认真来看看备受瞩目的 Flutter，重新认识一下它。本文首先简要回顾移动开发（跨平台开发）的发展历史，并谈谈不同阶段跨平台解决方案的优劣；接着从 WHAT / HOW / WHY 三个方面详细来聊聊 Flutter，并结合简单的 Dart 代码说说开发者该如何上手，随后展示几个 Demo App；最后会就本次分享进行一段小结。Flutter 到底是什么，它的来临对前端又意味着什么？
iframe: https://hijiangtao.github.io/slides/s-Fliggy/Hello-Flutter-at-Beginning-of-2019.html#/
---

> [扫码或点击链接查看](https://hijiangtao.github.io/slides/s-Fliggy/Hello-Flutter-at-Beginning-of-2019.html#/)

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019.png)

现在是2019年，让我们认真来看看备受瞩目的 Flutter，重新认识一下它。本文首先简要回顾移动开发（跨平台开发）的发展历史，并谈谈不同阶段跨平台解决方案的优劣；接着从 WHAT / HOW / WHY 三个方面详细来聊聊 Flutter，并结合简单的 Dart 代码说说开发者该如何上手，随后展示几个 Demo App；最后会就本次分享进行一段小结。Flutter 到底是什么，它的来临对前端又意味着什么？让我们接着往下看。

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-1.png )

## 一、移动开发历史回顾

当下的移动互联网仿佛给我们营造一种假象—— Android 和 iOS 已经存在许多年。而回首过往，才发现 Android 刚和我们度过第一个十年。十年前我们更多的讨论桌面应用与 Web，十年后我们专注在一个小屏幕，享受移动应用给我们带来的多彩世界。

移动应用（即我们日常所说的「原生」应用程序），通常是指某一移动平台所特有的应用程序。通过使用特定平台所支持的开发工具和语言进行开发，你可以直接调用系统提供的一些 SDK API。当下流行的移动操作系统中，我们使用 Java 或 Kotlin 调用 Android SDK 开发 Android 应用，或通过 Objective-C 或 Swift 调用 iOS SDK 开发可以上架 App Store 的应用。凡事没有银弹，移动开发也是如此。简要来看，原生应用开发具有以下优势：

1. 可获取平台全部开放功能，比如摄像头，蓝牙等；
2. 用户访问应用的感受通常是速度快、性能高、体验好的；

而其缺点也很明显，主要有：

1. 为特定平台开发，综合成本高，不同平台维护需要人力成本；
2. 动态化能力弱，大多数情况下，新功能更新只能发版；

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-2.png )

说到动态化，一次编码便可运行在任何平台的 Web 让我们记忆深刻。而针对移动端存在的这些问题，为了在提高体验的同时赋予应用动态化能力，诞生了一批又一批的跨平台移动开发解决方案。根据实现方式的不同，我将它划分为三个时代：

1. 青铜时代。在该时代的框架主要采用 Webview 容器（广义）进行内容渲染，并借助原生代码预置用以暴露给 JavaScript 调用的一部分系统能力，而这类协议则为我们通常说的 JavaScript Bridge；这个时代的框架在 Web 与 Native 间还有比较明显的界限，大家各司其职（UI 渲染与系统功能调用）；
2. 白银时代。在这个阶段我们仍然用 JavaScript 开发，但绘制已经交由 Native 接管，展现在用户面前的 UI 借助的是 JavaScript VM 的解析与 Native Widgets 的组合展示；
3. 黄金时代。不同于前一个时代，由于 Native Widgets 在 UI 上的「不尽如人意」，这个时代对方案起了一个新概念——自绘引擎，通过它在底层的绘制实现上来抹平不同平台上界面开发的差异，UI 上真正做到了「每一个像素点可控」。虽然涉及到平台层时还是需要原生开发介入实现相应插件，但这已是三种跨平台移动开发方案中最灵活的一种了。

## 二、问题

我们常说 Web 最终将一统天下，也常听见 Web 在离我们远去的声音。但至今在终端 UI 上也没有迎来一个完美的解决方案，这是因为在不同阶段、不同实现上，都存在很多现实问题。让我们再回顾一下这三个时代：

1. 青铜时代：采用 Webview 渲染的方案虽然成本低、部署迅速，但仍难以 cover 富交互的用户界面与复杂手势的快速响应；
2. 白银时代：利用 JavaScript 调用 Native 代码操作 UI 的方案虽然解决了不少渲染问题，但是跨平台 Native Widgets 的差异仍然是个问题，这使得我们在 UI 上要做一些「妥协」，而存在于 JavaScript 与 Native 间的通信成本在一些场景下仍会使这种方案成为「累赘」；
3. 黄金时代：直接使用底层 API 进行绘制在执行效率上大步迈进，看似已经是终极解决方案，但大家是否想过，为什么被世人「不堪」的 Web 存在这么多年，不但没有消亡反而愈发繁荣，以至于我们常说「任何能用 JavaScript 实现的应用，最终都必将用 JavaScript 实现」；

*注：「累赘」问题可详见 Flutter 中文网关于移动开发技术一章的[介绍](https://book.flutterchina.club/chapter1/mobile_development_intro.html)。*

其他还有一些问题值得思考，比如：

* 在今天，针对每个移动平台单独开发一套代码，成本是否太高？
* 自绘引擎在操控 UI 上已经足够自由，但当初这种解决方案为什么没有火起来？
* 快速开发与部署、多端可访问的 Web 开发模式，在当下以及未来是否还会持续过去的增长势头？

## 三、What is Flutter

带着这些疑问，我们走进全文的主角——Flutter。从2017年第一个 Alpha 版到上个月 Flutter Live 发布的 1.0 版本，Flutter 正获得越来越多的关注目光。很多听到这个词的同学可能会感慨，似乎 UI 技术迎来了终极解决方案。我们先看看官方对它的定义：

> Flutter 是 Google 用以帮助开发者在 iOS 和 Android 两个平台开发高质量原生 UI 的移动 SDK。Flutter 兼容现有的代码，免费并且开源，在全球开发者中广泛被使用。

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-3.png )

看看 Flutter GitHub Star 的变化趋势，会发现每一个陡增都预示着 Flutter 的一次重要版本发布。在深入了解之前，我们来看几个用 Flutter 做的 App，感受下官方所述的 Beautiful 到底是什么样子的。

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-4.png )

## 四、How is Flutter

看上去好像还不错，但 Flutter 究竟有哪些与众不同呢？我们按照官方描述的四个方面，分别来说说：

1. Beautiful - Flutter 允许你控制屏幕上的每一寸像素，这让「设计」不用再对「实现」妥协；
2. Fast - 一个应用不卡顿的标准是什么，你可能会说 16ms 抑或是 60fps，这对桌面端应用或者移动端应用来说已足够，但当面对广阔的 AR/VR 领域，60fps 仍然会成为使人脑产生眩晕的瓶颈，而 Flutter 的目标远不止 60fps；借助 Dart 支持的 AOT 编译以及 Skia 的绘制，Flutter 可以运行的很快；
3. Productive - 前端开发可能已经习惯的开发中 hot reload 模式，但这一特性在移动开发中还算是个新鲜事。Flutter 提供有状态的 hot reload 开发模式，并允许一套 codebase 运行于多端；其他的，再比如开发采用 JIT 编译与发布的 AOT 编译，都使得开发者在开发应用时可以更加高效；
4. Open - Dart / Skia / Flutter (Framework)，这些都是开源的，Flutter 与 Dart 团队也对包括 Web 在内的多种技术持开放态度，只要是优秀的他们都愿意借鉴吸收。而在生态建设上，Flutter 回应 GitHub Issue 的速度更是让人惊叹，因为是真的快（closed 状态的 issue 平均解决时间为 0.29天）；

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-5.png )

*注：数据源自 [Flutter 还有4116个Issue，是否成熟？](https://zhuanlan.zhihu.com/p/54725499)*

## 五、Why use Flutter

为什么要使用 Flutter？仅仅因为他是「Google 下一代操作系统」Fuchsia OS 的内置 UI SDK 么？

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-6.png )

让我们看的再详细一些，上一张 Flutter 系统架构图，根据之前在问题「开发跨平台app推荐React Native还是flutter？」下的[回答](https://www.zhihu.com/question/307298908/answer/569471390)，我尝试简单解读一下：

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-7.png )

从上至下分别为 Framework，Engine 和 EmEmbedder：

* Framework 层是框架使用者需要直接面对的，包含文本/图片/按钮等基础 Widgets、渲染、动画、手势等。如果你写 Flutter 应用，那么大致可以理解为调用这些 package 然后再用 Dart 「拼装」些自己的代码。
* Engine 层使用 C++ 实现，这一层包含 Skia，Dart 和 Text。后两个不太熟，说说 Skia。这是一个二维图形库，提供了适用于多种软/硬件平台的通用 API，既是 Chrome，Chrome OS，Android，Firefox，Firefox OS 等产品的图形引擎，也支持 Windows 7+，macOS 10.10.5+，iOS8+，Android4.1+，Ubuntu14.04+ 等平台；Dart 可能包含 Dart Runtime 等（JIT/AOT），Text 则负责文字渲染部分。
* Embedder 是一个嵌入层，做的事情是 Flutter to Platforms。比如渲染 Surface，线程设置，插件等。Flutter 的平台层很低，比如 iOS 只是提供一个画布，剩余的所有渲染相关的逻辑都在 Flutter 内部，而这就是 Flutter 所宣传的可以精准控制每一个像素的原因；但不可否认，对于插件部分，还是需要特定操作系统底层的建设（比如支付、地图等）。

有没有对 Flutter 更清晰一些？

如果说再举一点可以打动你使用 Flutter 的地方，那就是 animation 了。利用 Flare 你可以轻松构建支持 Flutter 的动画效果。这有点像十年前用 Flash 做关键帧动画的感觉。

当然，Flutter 和 Dart 团队的不断努力和优化更是说服你选择 Flutter 的理由之一。在刚不久前结束的 D2 上，Google 工程师介绍了为什么 Flutter 可以如此快，比如 Dart 在运行时更少的 malloc，Flutter 应用运行时有更少的处理环节（跳过 Android/Chromium），Flutter 在渲染布局上更高效的遍历过程等等。

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-8.png )

面向未来，让你在 Flutter 上下注的因素更少不了 HummingBird 和 Flutter for Desktop。STAY TUNED FOR GOOGLE I/O 2019!

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-9.png )

## 六、Code with Dart

利用 Flutter 提供的脚手架，做一个简单的 Demo 你甚至只需要写更改两个文件：main.dart 和 pubspec.yaml。作为前端，你可以将它们比做 index.js 与 package.json 吧。详尽的代码可见 <https://gist.github.com/hijiangtao/2b58ab07d3d7ed96aa0f868140c906e5>.

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-10.png )

## 七、Take away

人的记忆是短暂的，说了这么多，如果说本文想给大家带去些什么思考的话，我觉得可以总结成下面五句话：

1. RECAP / 在移动端跨平台开发方案的历史更迭中，我们从 Webview 加 Bridge 到 React Native 再到如今吸引大家目光的 Flutter，终端 UI 技术是否真的迎来了终极解决方案我们不得而知，但通过简单回顾了这条历史长河上出现过的几场光辉，希望借他们的发展身影能给从事前端的大家带去一些跳出业务代码的全局思考；
2. WHAT / Flutter 是什么：Google’s Portable UI Toolkit。它起源于移动端，但目光远不止眼前的苟且。
3. HOW / Flutter 有四个特点，分别是 Fast, beautiful, productive 以及 open。这些能力源于其背后 Dart、skia 和更多技术的支持，了解这些有助于帮助我们更清楚一个完整的 UI 系统由哪几个部分构成，以使我们对上层建筑有更立体的感受。
4. WHY / 为什么选择 Flutter，我在分享中介绍了不少原因，有系统设计的分析，有开放的学习态度，也有面向未来的 Mobile and beyond.
5. END / 如果你对 Flutter 感兴趣请不要忘记对 Google I/O 保持关注。对身边的新技术时刻保持好奇，做一个快乐的 Geek！

大浪淘沙，下一个十年我们又将身在何方？希望我的分享能让你有所收获。文中有误的地方欢迎评论指出，关于 Flutter 的更多内容欢迎一起讨论。谢谢。

![](/assets/in-post/2019-01-17-Say-Hello-to-Flutter-at-Beginning-of-2019-11.png )

**背后的故事1**：很多前端工程师在最初听到 Flutter 时都充满疑惑，为什么 Flutter 选用了 Dart，而不是使用 Web 技术或者是 JavaScript 语言来实现 Flutter 框架。其实 Flutter 中有不少内容便是吸收自 Web 社区，比如 tree shaking 和 hot reload。但 Flutter 另一个鲜为人知的故事是团队中大部分成员都具有 Web (Chromium) 背景。如果你看过 Flutter Live，应该知道 Flutter 与 Dart 团队的人数并不多，大致就头像墙中列出的那些，在最初设计上，他们也曾反复考虑 Web 技术，而在语言选型上也考虑过 JavaScript。应该不会有人比他们更了解 JavaScript 与 Web 了吧，但你看看这些开发过 Chromium 的人最后还是放弃了 JavaScript，我们有理由相信他们是经过深思熟虑后做出的决定。按照 Google 工程师的话来说就是「我们关注包括 Web 技术在内的很多技术，我们取其精华并勇敢地扔掉历史包袱。」

**背后的故事2**：在去年一年中，我们听到的 Flutter 声音更多是源自客户端开发者，但自 1.0 发布后，吸引到了来自前端同学越来越多的关注。这一点和嘤嘤在「2019 前端技术规划该包含什么？」中[回答](https://www.zhihu.com/question/308348507/answer/571204744)提到的现象类似。但前端同学有没有想过，Flutter 起源于移动端，现有 Flutter 虽然来自曾经 Chromium 团队，但整体对客户端开发的友好度是要高于前端开发的，毕竟有一个平台层插件摆在那里，再看看 Flutter 即将推出的 HummingBird，乍一看是 Web 的福音，但这也只是为 Flutter to Web 提供了途径，而非为前端提供了增强 Web 的可能。从某种意义上说，Web 的疆土正在逐渐缩小。这一次，我们是否真的要失业了呢？

*注：关于 Google 工程师的一段话描述意译自 Google 工程师在 Flutter 圆桌会上的相关言论，有出入。*