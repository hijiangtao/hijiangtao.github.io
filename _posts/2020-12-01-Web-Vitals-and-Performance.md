---
title: Performance 与 Web Vitals 介绍
layout: post
thread: 258
date: 2020-12-01
author: Joe Jiang
categories: Document
tags: [2020, Google, Performance, 前端, 监控]
excerpt: Performance 与 Web Vitals 介绍
header:
  image: ../assets/in-post/2020-12-01-Web-Vitals-and-Performance-Teaser.png
  caption: "@hijiangtao"
---

本文结构如下：

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-23.png )

## 1 / Processing Model 和 Performance Timing API

### W3C 定义的 Processing Model

- Navigation Timing [https://www.w3.org/TR/navigation-timing/#:~:text=The timing attribute represents the,defined by the PerformanceTiming interface](https://www.w3.org/TR/navigation-timing/#:~:text=The%20timing%20attribute%20represents%20the,defined%20by%20the%20PerformanceTiming%20interface)
- Navigation Timing Level 2 [https://www.w3.org/TR/navigation-timing-2/](https://www.w3.org/TR/navigation-timing-2/)

![Performance%20%E4%B8%8E%20Web%20Vitals%20%E4%BB%8B%E7%BB%8D%20ba0da8d57b59479ba5ad99812a9e4b25/Untitled.png](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-1.png )

Navigation Timing

![Performance%20%E4%B8%8E%20Web%20Vitals%20%E4%BB%8B%E7%BB%8D%20ba0da8d57b59479ba5ad99812a9e4b25/Untitled%201.png](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-2.png )

Navigation Timing Level 2

### Web API

- PerformanceNavigationTiming [https://developer.mozilla.org/en-US/docs/Web/API/PerformanceNavigationTiming](https://developer.mozilla.org/en-US/docs/Web/API/PerformanceNavigationTiming)

`Performanceresourcetiming` 接口扩展了 `Performance Timeline` 中的 `PerformanceEntry` 接口，提供了用于存储和检索有关浏览器文档事件的指标的方法和属性。 例如，此接口可用于确定加载或卸载文档需要多少时间。

通过 `performance.getEntries()` 可以访问页面上每个资源的一组关键网络计时属性，之后便可以用 `responseEnd` 和 `startTime` 之间的差值来计算所用的时间。

此外，我们可以依此计算出众多指标。以 FPT 为例，我们会用到如下两个属性进行复合：

- responseEnd: HTTP 响应全部接收完成的时间（获取到最后一个字节），包括从本地读取缓存
- fetchStart: 浏览器准备好使用 HTTP 请求抓取文档的时间，这发生在检查本地缓存之前

比如 DOM 解析耗时：

- domInteractive: 完成解析 DOM 树的时间，Document.readyState 变为 interactive，并将抛出 readystatechange 相关事件
- responseEnd: HTTP 响应全部接收完成的时间（获取到最后一个字节），包括从本地读取缓存

以上所提及两个指标，分别用前者属性值减去后者属性值，即能得到指标取值。

### 兼容性表现

![Performance%20%E4%B8%8E%20Web%20Vitals%20%E4%BB%8B%E7%BB%8D%20ba0da8d57b59479ba5ad99812a9e4b25/Untitled%202.png](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-3.png )

数据截取自 [https://caniuse.com/?search=PerformanceNavigationTiming](https://caniuse.com/?search=PerformanceNavigationTiming) (2020.12.01)

## 2 / Performance Metrics

**到底如何准确衡量网站的性能？我们拆解成四个部分**：

1. **是否发生？** 导航是否成功启动？服务器是否有响应？
2. **是否有用？** 是否已渲染可以与用户互动的足够内容？
3. **是否可用？** 用户可以与页面交互，还是页面仍在忙于加载？
4. **是否令人愉快？** 交互是否顺畅而自然，没有滞后和卡顿？

### **第一个问题，是否发生**

当用户访问一个网站的时候，关心的第一个问题永远是“是否发生”——浏览器是否成功地把我的请求发送出去，而服务器是否已经知道并开始处理我的请求？

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-4.webp )

1. **TTFB (Time to First Byte)** 首字节到达的时间点。
2. **FP (First Paint)** 首次绘制，标记浏览器渲染任何在视觉上不同于导航前屏幕内容的时间点。
3. **FCP (First Contentful Paint)** 首次内容绘制，标记浏览器渲染来自 DOM 第一位内容的时间点，内容可能是文本、图像等元素。

TTFB、FP 和 FCP 这些指标标记出浏览器开始绘制内容的时间点，这些时刻等同于告诉用户：**“浏览器已经开始处理服务器的返回了，你的请求已经发生了！”**

### **第二个问题，是否有用**

当用户确定自己的请求发生了后，就会开始关心第二个问题：“是否有用？”

例如，用户在使用天气应用，在确定页面有反应了后，就开始关心，什么时候能展现有用的内容，从而得知今天的天气。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-5.webp )

1. **FMP (First Meaningful Paint)** 首次有效绘制，是指首次绘制对用户有用内容的时间点。有用的内容，是指 Youtube 上的视频；Twitter 上的推文；天气应用中的天气预测......这些内容或元素，也被称为主角元素**（Hero Elements）**，能够向用户提供有用的内容。但是这些元素难以界定，所以后来用 LCP 来取代 FMP。
2. **LCP (Largest Contentful Paint** 最大内容绘制时间，计算从页面开始加载到用户与页面发生交互（点击，滚动）这段时间内，最大元素绘制的时间，该时间会随着页面渲染变化而变化，因为页面中的最大元素在渲染过程中可能会发生改变。
3. **SI (Speed Index)** 速度指标，填充页面内容的速度，取开始加载到最后完成渲染，每一时刻页面未完成度的积分。页面的视觉完成度（visually complete）是基于 SSIM(Structural similarity Index) 计算的。

以下为 LCP 的示意图。LCP 标记出浏览器绘制最大内容的时间点，并默认认为页面中最大的元素是对用户最有用的内容。LCP 试图标记出用户是在什么时刻得到有用内容的，而越早得到有用内容，用户的体验自然就越好。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-6.webp )

SI 反应出填充页面内容的速度。例如下图，虽然都是最后时刻填充完内容，但显然，上面会有种页面加载更快的感觉。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-7.webp )

### **第三个问题，是否可用**

在用户得到了有用的信息后，用户就会基于得到的信息作出反应，这就是页面“是否可用？”例如看到了新闻后，想要评论；知道了天气后，想要转发提醒朋友等等。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-8.webp )

在解释这些指标之前，我们先要理解为什么页面有时候不能及时响应用户。

**1. Long Tasks** 

耗时任务。浏览器是单线程，所有任务会被添加到主线程的队列中逐个执行。如果有任务耗时过长，主线程就会被阻塞，其他任务就只能等待，包括那些由用户交互产生的任务，从而无法及时响应用户。根据 Jakob Nielsen 的研究 ***Response Times: The 3 Important Limits***，页面应该在 100 ms 内响应用户输入，否则就会被用户认为卡顿。要实现小于 100 ms 的响应，单个任务必须在 50 ms 内完成。这样即使用户的输入行为发生在某个任务刚开始的时候，并且耗时 50 ms，在这个任务结束后，主线程仍有 50 ms 时间来响应用户输入，总响应时间在 100 ms 内。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-9.webp )

通过 Chrome DevTools 或 **Long Task API** 能方便地发现这些耗时任务。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-10.webp )

**2. TTI (Time to Interactive)**

可交互时间，用于标记页面已进行视觉渲染并能可靠响应用户输入的时间点。页面可能会因为多种原因而无法响应用户输入，例如页面组件运行所需的 Javascript 尚未加载，或者耗时较长的任务阻塞主线程。TTI 指标可识别页面初始 JavaScript 已加载且主线程处于空闲状态（没有耗时较长的任务）的时间点。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-11.webp )

**3. TBT (Total Blocking Time** [https://web.dev/tbt/](https://web.dev/tbt/) **)**

总共阻塞时间，计算的是从 FCP 到 TTI 之间，主线程阻塞的总时间。阻塞时间是指单次任务占用主线程超过 50 ms 的部分。

例如下面的例子是页面加载过程中从 FCP 到 TTI 之间主线程的运行情况，一共执行了 5 个任务，分别耗时 250 ms，90 ms，35 ms，30 ms，155 ms，其中 3 个任务耗时超过 50 ms，将它们阻塞的时间累加起来 250 - 50 + 90 - 50 + 155 - 50 = 345 ms，得到 TBT。越低的 TBT 证明页面的有用性，可交互性越好。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-12.webp )

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-13.webp )

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-14.webp )

**4. FID (First Input Delay)**

首次输入延迟，指用户首次输入到页面响应的时间。我们都知道第一印象的重要性，网站亦是如此。首次输入延迟会成为用户对网站很重要的第一印象，决定用户有可能成为忠实用户或者弃之而去。值得注意的是，FID 仅关注用户离散的操作，如点击，轻击，按键等，其他交互如滚动和缩放，并不是 FID 关注的，因为通常浏览器会用一个单独的线程来处理它们。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-15.webp )

### **最后一个问题，是否令人愉快**

先来举个不愉快的例子。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-16.gif )

在这个例子中，你本想点击按钮 B，页面突然发生偏移，你不幸点到了按钮 A。“是否令人愉快？”是用户在整个应用使用过程中都会发生的问题，它不仅包含之前说的 Long Tasks，要包含一些不符合预期的布局偏移，即 CLS。

**1. CLS (Cumulative Layout Shift)**

累计布局偏移。测量在页面的整个生命周期中发生的每个意外的样式移动所造成的布局偏移分数的总和。某次布局偏移分数 = 影响分数 * 距离分数。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-17.webp )

不知道你有没有意识到一个问题，什么叫意外的偏移？如何区分下面两种情况，前者是意外的偏移，后者则是点击搜索按钮展开，是符合预期的。所以 CLS 在计算过程中会忽略用户交互后 0.5s 内的布局偏移；同时 CLS 也会忽略动画，忽略 transform 的变化。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-18.webp )

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-19.webp )

## 3 / Core Web Vitals

概括来说：

1. 是 Google 为了提升网络整体性能的努力；
2. 是 Web Vitals 的子集，其核心基础指标 LCP，FID 和 CLS；
3. 是未来网页排名算法中新的因子；

在**今年 5 月**，Google 在 **Chromium Blog** (https://blog.chromium.org/2020/05/introducing-web-vitals-essential-metrics.html) 中提出的 Web Vitals，旨在提供统一的指标来量化用户在站点上的体验，囊括了之前在性能指标上的努力。同时，Google 认为不用每个人都成为网站性能方面的专家，大家只需要关注那些最核心最有价值的指标即可，于是提出了 Core Web Vitals，它是 Web Vitals 的子集，包含 LCP (Largest Contentful Paint)，FID (First Input Delay) 和 CLS (Cumulative Layout Shift)。

评估用户体验质量涉及多个指标，评估用户体验质量涉及多个指标，尽管部分用户体验是跟网站和内容相关，但还是有些共通信号，而 **Core Web Vitals** 体现了最关键的几项指标。此类[核心用户体验需求](https://web.dev/user-centric-performance-metrics/#defining-metrics)包括页面内容的加载体验、交互性和视觉稳定性，这些方面共同组成 2020 Core Web Vitals 的基础。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-20.png )

- **[最大内容绘制](https://web.dev/lcp/)评估页面主要内容可能已完成加载时的感知加载速度，并在页面加载时间轴上标记时间点。**
- **[首次输入延迟](https://web.dev/fid/)评估用户首次尝试与网页交互时的网页响应速度，并量化用户感知体验。**
- **[累积布局偏移](https://web.dev/cls/)评估可见页面内容的视觉稳定性，并量化内容的意外布局偏移量。**

所有上述指标均捕获以用户为中心的重要体验结果，可[现场测量](https://developers.google.com/web/fundamentals/performance/speed-tools)，并具有支持性实验室诊断等效指标和工具。例如，虽然最大内容绘制是最重要的负载指标，但其也高度依赖于[首次内容绘制](https://web.dev/fcp/) (FCP) 和[首字节响应时间](https://web.dev/time-to-first-byte/) (TTFB)，这些指标对监控和改进均具有非常重要的意义。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-21.webp )

Google 用 75 分位来代表网站某一指标的整体结果 [6]。例如，网站 75% 的访问中，LCP 都小于 2s，那么网站的 LCP 指标就是好；相反，网站超过 25% 的访问中，FID 都超过 300ms，那么网站的 FID 就是差。

**为什么是 ≤ 2500ms, ≤ 100ms, ≤ 0.1？**

基于 Google 的调查研究 **The Science Behind Web Vitals** (https://blog.chromium.org/2020/05/the-science-behind-web-vitals.html)，满足上述标准的网站，是能给用户带来良好的体验。

其次，这些指标也是可以达到的，在推出这些指标和阈值之前，已经基于 CrUX (Chrome User Experience Report) 的数据发现有 10% 的网站是能满足上述指标。

**工具及周边**

以下为相关工具的支持情况。

![](/assets/in-post/2020-12-01-Web-Vitals-and-Performance-22.webp )

## 4 / 附录

**附1 PerformanceResourceTiming 属性表**

|属性                   |描述                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|entryType            |EntryType的类型resource                                                                                                                                  |
|name                 |resources URL                                                                                                                                         |
|startTime            |在资源提取开始的时间                                                                                                                                            |
|duration             |整个流程消耗的时间=responseEnd-startTime                                                                                                                       |
|initiatorType        |发起资源请求的类型                                                                                                                                             |
|nextHopProtocol      |获取资源的网络协议的字符串                                                                                                                                         |
|workerStart          |如果Service Worker线程已在运行,则在调用FetchEvent之前立即返回DOMHighResTimeStamp，如果尚未运行，则在启动Service Worker线程之前立即返回DOMHighResTimeStamp。 如果资源未被Service Worker拦截，则该属性将始终返回0|
|redirectStart        |初始重定向的开始获取时间                                                                                                                                          |
|redirectEnd          |紧接在收到最后一次重定向响应的最后一个字节后                                                                                                                                |
|fetchStart           |拉取资源开始时间，紧接在浏览器开始获取资源之前                                                                                                                               |
|domainLookupStart    |紧接在浏览器启动资源的域名查找之前                                                                                                                                     |
|domainLookupEnd      |表示浏览器完成资源的域名查找后的时间                                                                                                                                    |
|connectStart         |开始TCP连接：紧接在浏览器检索资源，开始建立与服务器的连接之前                                                                                                                      |
|connectEnd           |结束TCP连接：紧接在浏览器完成与服务器的连接以检索资源之后                                                                                                                        |
|secureConnectStart   |开始SSL连接：紧接在浏览器启动握手过程之前，以保护当前连接                                                                                                                        |
|requestStart         |紧接在浏览器开始从服务器请求资源之前                                                                                                                                    |
|responseStart        |紧接在浏览器收到服务器响应的第一个字节后                                                                                                                                  |
|responseEnd          |紧接在浏览器收到资源的最后一个字节之后或紧接在传输连接关闭之前，以先到者为准                                                                                                                |
|secureConnectionStart|SSL / 初始连接时间                                                                                                                                          |
|transferSize         |表示获取资源的大小（以八位字节为单位）的数字。 包括响应头字段和响应payload body的大小。                                                                                                    |
|encodedBodySize      |在删除任何应用的内容编码之前，从payload body的提取（HTTP或高速缓存）接收的大小（以八位字节为单位）的number                                                                                      |
|decodedBodySize      |在删除任何应用的内容编码之后，从消息正文( message body )的提取（HTTP或缓存）接收的大小（以八位字节为单位）的number                                                                                |
|serverTiming         |包含服务器时序度量( timing metrics )的PerformanceServerTiming 条目数组，可用于服务器传数据到前端                                                                                 |

**附2 部分性能基础指标计算方式**

|基础指标                 |描述                                                                                                                                                    |计算方式                                     |备注                                          |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------|--------------------------------------------|
|rs                   |准备新页面耗时                                                                                                                                               |fetchStart - navigationStart             |                                            |
|rdc                  |重定向时间                                                                                                                                                 |redirectEnd - redirectStart              |                                            |
|dns                  |DNS 解析耗时                                                                                                                                              |domainLookupEnd - domainLookupStart      |                                            |
|tcp                  |TCP 连接耗时                                                                                                                                              |connectEnd - connectStart                |                                            |
|ssl                  |SSL 安全连接耗时                                                                                                                                            |connectEnd - secureConnectionStart       |只在 HTTPS 下有效                                |
|ttfb                 |Time to First Byte（TTFB），网络请求耗时                                                                                                                       |responseStart - requestStart             |TTFB 有多种计算方式，ARMS 以 Google Development 定义为准 |
|trans                |数据传输耗时                                                                                                                                                |responseEnd - responseStart              |                                            |
|dom                  |DOM 解析耗时                                                                                                                                              |domInteractive - responseEnd             |                                            |
|res                  |资源加载耗时                                                                                                                                                |loadEventStart - domContentLoadedEventEnd|表示页面中的同步加载资源                                |
|fbt                  |首包时间                                                                                                                                                  |responseStart - domainLookupStart        |                                            |
|fpt                  |First Paint Time, 首次渲染时间 / 白屏时间                                                                                                                       |responseEnd - fetchStart                 |从请求开始到浏览器开始解析第一批 HTML 文档字节的时间差              |
|tti                  |Time to Interact，首次可交互时间（非准确，仅做参考）                                                                                                                    |domInteractive - fetchStart              |浏览器完成所有 HTML 解析并且完成 DOM 构建，此时浏览器开始加载资源      |
|load                 |页面完全加载时间                                                                                                                                              |loadEventStart - fetchStart              |load = 首次渲染时间 + DOM 解析耗时 + 同步 JS 执行 + 资源加载耗时|

## 5 / 参考

[1] Web performance made easy(Google I/O '18) https://www.youtube.com/watch?v=Mv-l3-tJgGk

[2] FMP, TTI, WTF? Making Sense of Web Performance https://www.youtube.com/watch?v=EIsk6pBNJ74

[3] User-centric performance metrics https://web.dev/user-centric-performance-metrics/#user-centric_performance_metrics

[4] Response Times: The 3 Important Limits https://www.nngroup.com/articles/response-times-3-important-limits/

[5] Annie Sullivan :: Understanding Cumulative Layout Shift :: #PerfMatters Conference 2020 https://www.youtube.com/watch?v=zIJuY-JCjqw&feature=youtu.be

[6] Defining the Core Web Vitals metrics thresholds https://web.dev/defining-core-web-vitals-thresholds/

[7] Tools to measure Core Web Vitals https://web.dev/vitals-tools/

[8] [https://developer.mozilla.org/en-US/docs/Web/API/Performance](https://developer.mozilla.org/en-US/docs/Web/API/Performance) 

[9] [https://developer.mozilla.org/en-US/docs/Web/API/PerformanceNavigationTiming](https://developer.mozilla.org/en-US/docs/Web/API/PerformanceNavigationTiming) 

[10] [https://github.com/zwwill/blog/issues/31](https://github.com/zwwill/blog/issues/31) 

[11] [https://mp.weixin.qq.com/s/Hmkod3gYRR38B6Qdp1Iu6g](https://mp.weixin.qq.com/s/Hmkod3gYRR38B6Qdp1Iu6g) 

[12] [https://www.w3.org/TR/navigation-timing/#:~:text=The timing attribute represents the,defined by the PerformanceTiming interface](https://www.w3.org/TR/navigation-timing/#:~:text=The%20timing%20attribute%20represents%20the,defined%20by%20the%20PerformanceTiming%20interface)

[13] [https://web.dev/vitals/](https://web.dev/vitals/) 

[14] [https://github.com/GoogleChrome/web-vitals/](https://github.com/GoogleChrome/web-vitals/)

[15] [https://github.com/GoogleChrome/web-vitals-extension/](https://github.com/GoogleChrome/web-vitals-extension/) 

[16] 附1源自 [https://juejin.cn/post/6844903972902273032](https://juejin.cn/post/6844903972902273032)

[17] 附2源自 [https://github.com/zwwill/blog/issues/31](https://github.com/zwwill/blog/issues/31)