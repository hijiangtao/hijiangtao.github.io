---
title: 2018 Google 移动技术最新进展速览
layout: post
thread: 198
date: 2018-07-14
author: Joe Jiang
categories: Documents
tags: [Google, 2018, 前端, Web, Android, 设计, AI, PWA, AMP]
excerpt: 这周在 Google 上海办公室参加了一场分享会，他们的华人工程师向与会人员同步了 Google 在移动技术上的最新动态。我尝试从一名前端开发者的视角总结了这次分享会的内容，如有理解不准确的地方欢迎指出。
header:
  image: ../assets/in-post/2018-07-14-Google-Mobile-Express-teaser.png
  caption: "From www.ucas.ac.cn"
---

# 2018 Google 移动技术最新进展速览

这周在 Google 上海办公室参加了一场分享会，他们的华人工程师向与会人员同步了 Google 在移动技术上的最新动态。虽说大部分内容在今年的 Google IO 都有提及，但由于 “Mobile first to AI first” 的大背景，很大一部分目光都被聚焦到了 AI related，单独来一场移动技术的专场分享可以说明移动技术仍在其技术布局中占据举足轻重的地位。

在 Google，移动技术泛指与 Android 与 Web 相关的技术领域。我尝试从一名前端开发者的视角总结了这次分享会的内容，如有理解不准确的地方欢迎指出。

整个分享会包含以下几个主题，涵盖有安卓新特性介绍、Material Design、机器学习、AMP/PWA、Google Play 最佳实践等：

* What’s new in Android
* 揭秘 Material Design
* 安卓开发之机器学习
* 用 AMP/PWA 构建现代移动网站
* Google Play Best Practices

## 一、What's new in Android (Android P 新特性速览)

开篇便是自家 Android 系统的新特性介绍。显然 Android P 新增了很多交互方式，例如为了帮用户减少无效的使用时间而推出的 Wellbeing 功能，新增的 Home 手势，锁屏支持天气显示等等。但分享者主要还是从技术角度谈了谈与开发者切身相关的一些新特性。整体分为两个方面，一方面是通用功能的增强与更新，另一方面则与 UI/UX 相关。首先来看看一些通用功能的更新。

### 1.1 全新的 notification panel

可以对单个应用在通知消息中更细粒度的控制，比如提取应用内多条信息进行分层展示，并提供给开发者可定制的用户快捷回复功能。

举一个常见的社交场景：当用户在同时与不同好友进行聊天时，在 Android 8.1 上只会在通知面板显示该应用的未读信息，但 Android P 开始让应用通知有能力同时提供上下文信息，方便用户理解并提供有开发者定义的快捷回复允许用户进行快捷回应。下图为 Android P 与 Android 8.1 在此场景下的展示差异。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-1.jpg "")

同时在 Android P 中，通知面板里的图片展示有了更好的布局，可见下图。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-2.png "")

### 1.2 Android 现在更加安全啦

为了更好地保证隐私，在 Android P DP1 中，系统会限制后台闲置应用对麦克风、摄像头和传感器的访问权限，「某某应用悄悄打开麦克风、摄像头收集用户信息」的现象将在 Android P 中得到根除。若是开发者想持续使用录音、相机等功能，那就必须在前台进行调用了。

### 1.3 Kotlin 与 SDK

Kotlin 的优化与更新这一部分，引用 Google 开发者自己的一段介绍：

> Play Store 中用 Kotlin 开发的应用在去年增至 6 倍，在高级开发者中有 35% 的人选择使用 Kotlin 进行开发，而且这个数字正在逐月递增。我们会继续改善 Kotlin 在支持库、工具、运行时 (runtime)、文档以及培训中的开发体验。我们今天发布的 Android KTX，包含在 Android Jetpack 中，力图优化 Kotlin 开发者体验；同时继续改善 Android Studio、Lint 支持以及 R8 优化中的工具；而且对 Android P 中的运行时 (Android Runtime) 进行微调，以此加快 Kotlin 编写的应用的运行时间。我们已经在官方文档中列出了 Kotlin 代码片段，并且会在今天发布 Kotlin 版本的《API 参考文档》。 —— [谷歌开发者](https://mp.weixin.qq.com/s/qdgCG59HkqQJ6tI1CEatNg)

以上所述的几点链接：

* [Android KTX](https://developer.android.com/kotlin/ktx)
* [Kotlin API 参考文档](https://developer.android.com/reference/kotlin/packages)

还有几点更新：

* Google 正在逐步限制非 SDK 接口的使用：针对不同接口采取不同形式的限制，例如从 Android P Beta 开始，调用非 SDK 接口将会报错 (部分被豁免的私有 API 除外) ；
* Google Play 将要求所有应用在 2018 年 11 月之前针对 Android 8.x Oreo（targetSdkVersion 26 或更高版本）进行更新并在 2019 年前提供 64 位支持；

接下来就是关于 UI/UX 的部分了。

### 1.4 刘海

在 Google 手机的刘海布局又叫凹口屏，当下已经有多款机型（未来还会有更多机型）存在刘海设计，且涉及位置也是千奇百怪。所以对你的应用针对凹口屏测试是十分重要的，你可以在 [Android P Beta 的合作伙伴机型](https://juejin.im/post/5af3b98af265da0ba469cdde)上测试，也可以在 Android P 设备的开发者选项里打开对凹口屏的模拟，对您的应用做相应测试。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-6.png "")

几点需要注意的地方：

* Status Bar 硬代码的书写注意；
* 如何摆放全屏与处理刘海安全区（Google 提供有三种全屏展示的 API，开发者可按需使用），详情可参考 [Exploring Android P: Display Cutouts](https://medium.com/exploring-android/exploring-android-p-display-cutouts-42885e8a2a96)；

### 1.5 Android App Settings

* **App Actions**：可以出现在 Google Assistant、Google Search、All Apps、Smart Text Selection、Google Play 等位置，由开发者定义功能与行为、由系统控制显示方式与时机（比如在下午五点用户想回家时，在 Assistant 中输入回家，系统可以根据使用习惯建议用户使用打车功能，但需要注意的是有一个前提——即用户已经下载了该应用）。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-3.gif "")

* **Slices API**：一种显示 remote content 的新方式，暂定会出现在 Search 结果中，但需要注意的是这项功能仅供开发者尝鲜，确定暂时不会出现在用户端。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-4.gif "")

* **App Bundle**：我看有的文章也把他称作"Dynamic App"，根据不同用户环境进行动态构建，把原有经过开发者将所有内容打到一个 apk 包的过程拆分成 Base 与其他动态内容，实际触达用户端的 apk （包含具体 CPU 架构、应用语言、针对分辨率配置的资源文件等）具体由 Google Play （或其他应用市场）进行构建与分发，其主要的一个目的是为了减少 App 体积。当然，由于最后需要让 Google Play 替你进行应用打包，所以应用的签名是要给到 Google Console 的。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-5.png "")

*示意图来自 [[Session] Build the new, modular Android App Bundle](https://events.google.com/io/schedule/?section=may-8&sid=b9eabde0-be05-492c-bf9e-c3f772f1db7e)*

在进一步减少包大小的路上，还有一个实验功能叫 Dynamic features，其主要的一个目的其实是为了不把整个包所有功能第一次都分发给用户（比如用户初始不需要的功能），具体介绍见 [Deliver features on-demand, not at install](http://g.co/play/dynamicdeliverybeta)；

详情可参考：

* [App Bundle](https://developer.android.com/platform/technology/app-bundle/)
* [Getting started with App Actions (Google I/O '18)
](https://www.youtube.com/watch?v=lu3L6DxUBRA)
* [Android Slices: build interactive results for Google Search (Google I/O '18)](https://www.youtube.com/watch?v=a7IVH5aNwwc)
* [Integrating your Android apps with the Google Assistant (Google I/O '18)](https://www.youtube.com/watch?v=v0uYZ4rTOrk)


## 二、揭秘 Material Design

在 Google 的设计历史上曾经存在两条道路，以 Kennedy 代表的 Web 方向，Holo 代表的 Android 方向，直到 Material Design 出现。自从问世以来，Material Design 广受好评，市场上也能看到很多运用它的影子。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-7.png "")

有关 Material Design 的内容其实官网已经介绍的很详细了

* Tangible surfaces - layout
* Paper-like design - color
* Meaningful motion - motion
* Adaptive design - device

当然，如果都是老生常谈的内容未免太不 Google 了。由于太多应用在开发的过程中采用 Material Design 以致很多应用长得实在太像了，没有了自己的风格。为了解决这个问题，Google 提出了 Material Theming，这一部分包含两个内容，一个是 Material Components （这已经开源在 [GitHub](https://github.com/material-components)，并提供有 Android, iOS, Web, Flutter 四个版本），另一个则是 [Material Theme Editor](https://material.io/tools/theme-editor/)。

Material Design 官网 <https://material.io/>，关于这次的引入的新特性可以阅读 Pratik 的文章 [What’s new in Material Design?](https://uxplanet.org/whats-new-in-material-design-5308f62a4082)

## 三、安卓开发之机器学习

### 3.1 ML Kit

* 官网 <https://developers.google.com/ml-kit/>
* 第一点：提供开箱即用的一些 API: seamlessly build machine learning into your apps
* 第二点：在移动端进行模型压缩

让我们来看一个实际场景。闲鱼上的用户进行商品发布时需要提供商品图片，但是肯定会存在很多重复发布的图片。为了减轻服务器负担，那么就需要对图片进行去重检测，如果按照往常的思路那么就需要用户先把内容传到服务器，然后服务器进行检测。在弱网环境下，你可以想像一下那拙计的体验。 ML Kit 提供的 Image labeling API 便可以让开发者在本地设备上解决这个问题。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-8.png "")

### 3.2 Tensorflow Lite

在 Android 8.1 中引入神经网络 API，提供 Android 内置的机器学习，在 Android P 中又进一步扩展和改进 TensorFlow。

Tensorflow Lite 文档请移步 <https://www.tensorflow.org/mobile/tflite/>.

### 3.3 Neural Networks API

这是一个介于硬件层和应用层之间的一个手机厂商驱动的 API。需要在 Android 8.1 以上使用，若遇到不支持的环境则会直接调用 CPU/GPU 接口进行加速计算。

## 四、用 AMP/PWA 构建现代移动网站

整体来说，此场次分享介绍的新内容不多，所以对 AMP/PWA 有所了解的同学可以略过此章节。

作为一家从 Web 起步并在主要产品中大量运用 Web 技术的科技公司，Google 技术人员表示在他们看来，Web 和 Native 一样重要。分享主题从移动端 Web 存在的一些缺陷开始说起，当然这些内容其实你在很多介绍 AMP 或者 PWA 技术的开篇可能也都看过，例如“如果一个网站加载时间超过三秒，那么它就会丧失53%的访问用户，而其中50%的用户再也不会回到你的网站”，此处就不做赘述了。总结来看，三个出发点：速度、交互与转化率。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-9.jpg "")

这场分享其实是为商务准备的，所以 Google 还说了他们几点在新技术上所采取的倾向措施，以此希望推广这两项技术有更广的应用落地。倾向一、Google 爬虫会优先爬取移动端 site；倾向二、Google 排名会将移动端 site 的访问速度作为影响因素之一纳入考虑范畴。详情可见博文 <https://webmasters.googleblog.com/2018/03/rolling-out-mobile-first-indexing.html>

### 4.1 AMP

AMP 项目是一个开放源代码计划，旨在为所有人打造更好的网络体验。其主要组成分为三个部分：

* AMP HTML - 为确保可靠性能而具有某些限制的 HTML，AMP HTML 本质上是使用自定义 AMP 属性扩展的 HTML；
* AMP JS - 一个确保快速渲染 AMP HTML 网页的 JavaScript 库；
* (Google) AMP Cache - Google AMP Cache 是一种基于代理的内容交付网络，用于交付所有有效的 AMP 文档；

AMP 的加速原理体现在三个方面：

* 简化页面：通过在开发中加入限制，例如封装交互，使用更少的 JavaScript，In-line CSS 等等；
* 优化数据下载：在外部资源加载时优化图片尺寸；异步加载，用户需要的资源会优先出现在屏幕上；
* 缓存页面：AMP Cache，使用 CDN，爬取页面进行缓存优化，以降低访问成本；

在应用案例方面，AMP 也不仅仅局限于开发者常见的认知——只可运用于简单的信息展示类页面，包括 Aliexpress 以及 Trip.com 都已经广泛采用了 AMP 技术来优化自身产品的访问体验。Google 想让大家记住的事情是，规范使用 AMP 技术的 Web 页面可以达到“秒开”的效果。

一个页面运行在线上，必不可少的是统计页面运行状态与收集数据的功能。AMP 提供 Analytics 相关支持，具体可见 <https://www.ampproject.org/zh_cn/docs/analytics/analytics_amp>。由于 AMP 规范限制使用自定义 JavaScript 代码，Google 允许有困惑的开发者可以到 GitHub 上提Feature Issue，他们会认真考虑。

### 4.2 PWA

有关 PWA 是什么就不做过多介绍了，类似的内容已经非常多了，随便列举一些：

* [下一代 Web 应用模型 — Progressive Web App](https://huangxuan.me/2017/02/09/nextgen-web-pwa/)  
* [如何看待 Progressive Web Apps ？](https://www.zhihu.com/question/46690207)
* [Progressive Web Apps: Escaping Tabs Without Losing Our Soul](https://infrequently.org/2015/06/progressive-apps-escaping-tabs-without-losing-our-soul/)

从 Google 在印度浏览器市场的统计来看，Web 或者说浏览器还具有非常广泛的增长空间，排名第一的 UC 浏览器超出 Chrome 市场份额不少。PWA 技术体系可以为移动网站加入更多渐进增强式交互的功能，而从实际落地场景来看，PWA 可以为电商类公司提供一种可能性：通过 preload 一些优惠券，在本地进行倒计时与适时的新品发布。提到之前所述的 Android P 上对通知面板的更细粒度控制更新，分享者更是戏称这些在 Web 上通过 Push 功能早已实现。

国内

整体来看，今年令人兴奋的是 Apple 对 service worker 的态度转变与实际行动上，但一切都只是个开头，重点还是关注在几个关键 API 上。

来自 Google 的几个数据，但其实不是什么新鲜事了：

* 54% 用户在填写复杂表单时会放弃注册
* 92% 用户在忘记密码时会放弃网站

而利用**无缝登入 (Credential Management API)**来解决这个问题，可以大大提升用户的 Web 交互体验。API 细节见 MDN <https://developer.mozilla.org/en-US/docs/Web/API/Credential_Management_API>。

另一个 API 叫一点就付款 (Payment Request API)，API 细节见 W3C <https://www.w3.org/TR/payment-request/>。

对于 Native 应用来说，用户可能从应用商店下载你的应用后，就再也不会去更新它了。而这一点在 Web 上不是问题，用户每一次通过 URL 连上你的站点，都实在访问你提供的最新的内容。当然这也是 Web 的软肋之一，强依赖网络连接状态。

提一嘴这次分享没有谈到的 Web Push，这是一个原理不复杂但应用起来却很吃力的东西，原因就在于 Push Service（GCM/FCM）在国内是不可用的。UC 的同学在 2018 GMTC 上有提到通过客户端私有 Push 通道来实现 Web 端的预加载的思路。

> 页面服务器通过私有Push通道推送消息给客户端，客户端向Web引擎推送消息，Web引擎唤醒SW和触发onpush。页面处理onpush，提前fetch预加载资源。

详情可以移步[从UC内核角度谈谈PWA技术在阿里体系的实践及影响](https://yq.aliyun.com/articles/608837)。个人认为阅读这篇文章比参加这次分享会了解到的 PWA 相关内容收获还要大，哈哈。

对于 Push 的具体应用，分享者表示 Twitter 已经可以达到一天两亿的 Push 量。

在案例介绍方面，当然少不了饿了么的 PWA 改造。除此外，今年 Google 在国内新增的一例案例是与 ofo 的合作，在 Google 与 ofo 的合作下，已经实现了基于 PWA 的 ofo，可以实现扫码开车。

正如之前所说， Google 一直持有 Web 和 Android 同样重要的态度。在 Android 提供的功能，Google 努力希望通过浏览器将这些能力同样开放给 Web，未来预计开放的 Web API 包括蓝牙 API、硬件加速 API 等等。

一个不负责的爆料，PWA 未来将出现在 Google Play 中。

![](/assets/in-post/2018-07-14-Google-Mobile-Express-10.jpg "")

## 五️、Google Play 应用市场最佳实践

最后一个议题和 Google Play 有关，但技术上的介绍较少，主要是运营上的一些技巧与经验，便略去了。
