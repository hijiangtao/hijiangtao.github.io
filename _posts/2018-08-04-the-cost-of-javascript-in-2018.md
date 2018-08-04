---
title: 精读 The Cost of JavaScript In 2018
layout: post
thread: 200
date: 2018-08-04
author: Joe Jiang
categories: Documents
tags: [前端, Web, JavaScript, PWA, 页面交互成本]
excerpt: 如今，JavaScript 仍然是我们向移动终端分发页面时成本最高的资源，因为它可以在很大程度上延迟页面的交互性。一个页面在开发时都要考虑哪些问题，用户实际访问页面的效果与感受又是如何，Google 开发 Lighthouse 的初衷以及其具体用途，JavaScript 的成本究竟有多高，如何降低 JavaScript 成本与优雅的持续集成实践等等。
header:
  image: ../assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-teaser.jpeg
  caption: "From medium.com"
---

如今，JavaScript 仍然是我们向移动终端分发页面时成本最高的资源，因为它可以在很大程度上延迟页面的交互性。一个页面在开发时都要考虑哪些问题，用户实际访问页面的效果与感受又是如何，Google 开发 Lighthouse 的初衷以及其具体用途，JavaScript 的成本究竟有多高，如何降低 JavaScript 成本与优雅的持续集成实践等等。

这周在完善师兄 PWA Demo 时查阅了不少资料，对页面性能优化也做了一些比较有意思的尝试。而如上这些问题 Addy 在 [The Cost of JavaScript In 2018](https://medium.com/@addyosmani/the-cost-of-javascript-in-2018-7d8950fbb5d4) 一文中都给出了很详实的介绍，并分享了在保证用户友好交互体验的前提下如何高效分发 JavaScript 的开发经验。正巧 JavaScript Weekly 看到这篇文章，2天 Meidum 鼓掌17k+，内容非常丰富，便尝试结合自己的理解做一次导读。

作者首先将全文的内容压缩成几条观点总结出来，之后从用户体验为 Web 带来的变化开始说起，到 JavaScript 的成本有哪些、它们为何如此高昂、如何降低开销以及持续集成，全文形成一个非常完整的优化流程。我将原文拆分为如下几节进行叙述（由于拆分了原文结构，对此在意的同学可以直接阅读原文或观看 Addy 油管演讲）：

0. \#0 写在开头的话
1. \#1 tl;dr:
2. \#2 膨胀的 JavaScript 与 Web 现状
3. \#3 JavaScript 的成本所在
4. \#4 页面交互性解释与建议
5. \#5 处理 JavaScript 成本为何如此昂贵
6. \#6 千差万别的移动用户与应对策略
7. \#7 分发更少 JavaScript 的常见技巧
8. \#8 持续集成四部曲

原文地址见 <https://medium.com/@addyosmani/the-cost-of-javascript-in-2018-7d8950fbb5d4>，视频地址见 <https://www.youtube.com/watch?v=63I-mEuSvGA>，以下开始正文。

## #0 写在开头的话

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-1.png)
*上图为通过 [WebPageTest](https://webpagetest.org) ([src](http://bit.ly/jscost-wpt)) 测定的 CNN.com 中 JavaScript 处理时间。高端机型 (iPhone 8) 的脚本处理时长在4秒以内。与之相对应的是长达13秒处理时长的[一般机型](https://infrequently.org/2017/10/can-you-afford-it-real-world-web-performance-budgets/) (Moto G4) 和36秒之久的2018款低端机型 (Alcatel 1X)。*

如今，**[可交互性](https://philipwalton.com/articles/why-web-developers-need-to-care-about-interactivity/)**已经成为构建网站时不可或缺的一个考虑点，而作为最重要的实现手段，你需要将 JavaScript 代码分发到用户的设备上。考虑到此，你是否曾经历过用手机打开一个网页，当你想点击其中的链接或者滑动屏幕时，页面却没有任何响应？

## #1 tl;dr:

* **想要保持页面的快速运行，你需要仅加载当前页面所需的 JavaScript 代码**。优先考虑用户所需，之后运用[代码分离](https://webpack.js.org/guides/code-splitting/)懒加载其他内容。
* **拥抱性能估算并学会与他相处。**比如为自己的网页下一个目标——[压缩后的 JS 代码体积小于 170KB](https://infrequently.org/2017/10/can-you-afford-it-real-world-web-performance-budgets/)。
* **学会如何[审查](https://nolanlawson.com/2018/03/20/smaller-lodash-bundles-with-webpack-and-babel/)并修剪你的 JavaScript bundle。**比如你只用到了一个函数，但最终却引入了一整个三方库；又或者你为了做老旧浏览器的兼容实现了 polyfill，但最终发现你的用户都在用现代浏览器。
* **请记住每次交互都是一次新的 ‘Time-to-Interactive’ 的开始，以此进行代码优化。**
* **如果用户端的 JavaScript 并没有提升用户体验，你则需要问问自己这些代码是否多余。**比如，服务端渲染 HTML 或许更适合你？

## #2 膨胀的 JavaScript 与 Web 现状

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-2.jpeg)

当用户访问你的网站时，为了达到预期的交互体验，你需要向他分发各类资源文件，其中脚本就占据了很大一部分。即便我们都很喜欢 JavaScript，但它一直都是网站数据传输成本中最高的那一部分，作者举了几个数据来说明这个问题：

* 资源大小与耗时：当下网页传输的[压缩过的 JavaScript 资源平均大小为 350KB](https://beta.httparchive.org/reports/state-of-javascript#bytesJs)，解压后的资源大小则会超过 1MB；而[处理这么多 JavaScript 代码直至网页具备交互性]((https://beta.httparchive.org/reports/loading-speed#ttci))会耗费移动设备超过14秒的时间。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-3.jpeg)
*数据源自 [HTTP Archive state of JavaScript report, July 2018](https://httparchive.org/reports/state-of-javascript)*

* 移动网络现状：来自 [OpenSignal](https://opensignal.com/reports/2018/02/global-state-of-the-mobile-network) 的全球4G网络可用性统计表明，很多国家依旧经历着比我们想象还要慢的连接速度，而这还不包括很多未列入统计范畴的国家与地区。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-4.png)

* 现实情况：一些著名网站例如 Google、Facebook、LinkedIn 等所需加载的脚本大小早已远超平均大小 350KB，桌面端的 Facebook 站点 JavaScript 解压后可以达到 7.1MB。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-5.jpeg)
*数据源自 [Bringing Facebook.com and the web up to speed](https://www.youtube.com/watch?v=XhOIE3l8GEY)*

## #3 JavaScript 的成本所在

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-6.jpeg)

由此作者提出了一个疑问：我们真的可以负担起这么多 JavaScript 么？一般来说，庞杂的 JS bundle 中包括：

* 运行于客户端的框架或者 UI 库；
* 状态管理方案（例如 Redux）；
* Polyfills；
* 完整的工具库或者分割过的其中一部分方法代码；
* 一套 UI 组件，按钮、导航栏等等；

代码越多，你的页面加载时间就越长，JavaScript 的成本主要取决于三个因素。**分别是 Is it happening? Is it useful? Is it usable?**

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-7.png)

* ***Is it happening*** - 在这个时期，你可以开始往屏幕上分发内容（*页面是否开始跳转？服务端是否开始响应？*）。

* ***Is it useful*** - 在这个时期，你已经完成了文本或内容的绘制，并允许用户从其中获取价值与有用信息。

* ***Is it usable*** - 在这个时期，用户可以与页面进行实际操作，并能产生一些有意义的交互。

## #4 页面交互性解释与建议

作者反复在文中提到交互性，在他看来，一个页面具有交互性的条件是它必须具有快速响应用户输入的能力。即不论用户点击一个链接，或者滚动页面时，他们都需要获得一些反馈以响应他们的操作。一个解释交互性的示意图如下所示：

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-8.gif)

Chrome 中提供了 LightHouse 可以对页面的各项性能指标（比如 Time-to-Interactive）进行评估：

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-9.png)

而说到 JavaScript 的实际成本所在，则不得不说说的浏览器的线程。当浏览器在处理你在 JavaScript 中定义的各种事件时，它可能同时在该线程上还在处理用户的输入，而这就是我们所说的主线程。关于浏览器与线程的具体细节可以参考[《聊聊 JavaScript 与浏览器的那些事 - 引擎与线程》](https://hijiangtao.github.io/2018/01/08/JavaScript-and-Browser-Engines-with-Threads/)，这里就不展开叙述了。

总之作者想让大家清楚的一点是，我们可以通过 [Web Worker](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) 来处理部分 JavaScript 逻辑或者通过 [Service Worker](https://developers.google.com/web/fundamentals/primers/service-workers/) 来缓存资源，以达到减轻 JavaScript 成本的目的。尽量避免阻塞主线程，了解更多这一方面的细节可以移步 [Why web developers need to care about interactivity](https://philipwalton.com/articles/why-web-developers-need-to-care-about-interactivity/)。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-10.jpeg)
*一些 JavaScript 影响页面交互性的例子，比如 Google Search 中的各类 Tab 或者 Button*

通过 WebPageTest 和 Lighthouse ([源](https://docs.google.com/spreadsheets/d/1x0LQV5oQsX3MdYe1lcy_gw3FzdJ0kNPUP2-cAl4N2g4/edit?usp=sharing))测得到移动端 Google News 的 Time-to-Interactive 数据显示，不同机型在完成交互性上存在巨大差异，高端机型需花费7秒才能让页面具备交互性，而针对同一场景低端机型则需要55秒之久。我们都希望页面的可交互性可以越快越好，但怎样为交互性定义一个好的目标呢？

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-11.jpeg)

**作者提出一个评估基线，即我们应该让页面在慢速3G网络下也能达到五秒之内具备可交互性。**而一些公司已经开始尝试分发更少的 JavaScript 并减少 Time-to-Interactive 耗时：

* [Pinterest 将 JavaScript bundle 从 2.5MB 降低到小于 200KB，而 Time-to-Interactive 时间则从23秒降到5.6s](https://medium.com/dev-channel/a-pinterest-progressive-web-app-performance-case-study-3bd6ed2e6154). 收入增长44％，注册增长753％，[移动互联网周活跃用户增长103％](https://medium.com/@Pinterest_Engineering/a-one-year-pwa-retrospective-f4a2f4129e05)。
* [AutoTrader 将 JavaScript bundle 大小降低了 56% 并将达到 Time-to-Interactive 的时长缩短了一半](https://engineering.autotrader.co.uk/2017/07/24/how-we-halved-page-load-times.html)。
* [Nikkei  将 JavaScript bundle 大小降低了 43% 并将 Time-to-Interactive 耗时缩短了13秒](https://youtu.be/Mv-l3-tJgGk?t=1967)。

## #5 处理 JavaScript 成本为何如此昂贵

当我们在浏览器中输入一串 URL，实际都发生了些什么？这是一个经典的面试题，作者借由这个问题尝试解释为什么 JavaScript 成本如此高昂。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-12.gif)

当一个请求发送给了服务端，它会返回一些标记文件。之后，浏览器则解析这些标记（通常是 HTML），并从中找到必要的 CSS，JavaScript 与图片资源引用，然后向服务端再次获取这些额外资源并处理。如上描述正是 Chrome 的现有实现逻辑，我们希望浏览器快速绘制，然后使页面具备可交互性，而事实则为 JavaScript 会成为整个过程的瓶颈。**那么如何避免 JavaScript 成为现代交互体验的瓶颈呢？**

作为一名开发者，我们必须知道：如果我们想让 JavaScript “变快”，我们必须让下载、解析、编译和执行 JavaScript 的整个过程都变快。所以我们不仅要保证快速的网络传输，还要保证快速的脚本处理能力。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-13.png)

来看作者提供的一些数据，[V8](https://developers.google.com/v8/)（Chrome 的 JavaScript 引擎）在处理包含脚本的页面时花费时间的细分统计图如下：

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-14.png)

橙色代表的是解析 JavaScript 所用的时间，黄色代表的是编译耗时。两者加到一起占了大部分页面 JavaScript 执行的30%的时间。尽管从 Chrome 66 开始，V8 [开始在后台线程编译代码](https://v8project.blogspot.com/2018/03/v8-release-66.html)，但依旧很少看到大型 JavaScript 代码能够在50ms内完成解析与编译过程。

**还有一个老生常谈的话题，即作者提醒我们：执行一个200KB的脚本和一个200KB的图片成本会相差很大。它们可能占用相同的下载时长，但在执行上并不是所有的字节都占用相同的成本。**

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-15.jpeg)

一张 JPEG 图片需要被解码、栅格化然后绘制在屏幕上，而一段 JavaScript bundle 需要被下载、解释、编译然后被执行 — 与此同时还有很多其他的[环节](https://www.youtube.com/watch?v=5nmpokoRaZI)。有关这部分可以参考[[译] JavaScript 引擎基础：Shapes 和 Inline Caches](https://hijiangtao.github.io/2018/06/17/Shapes-ICs/)
。

## #6 千差万别的移动用户与应对策略

移动设备市场广阔，我们无法保证自己的用户都在使用平均水平以上的设备。而对于低端机型来说，缓存大小、CPU、GPU 规格都会成为限制处理诸如 JavaScript 资源速度的瓶颈。[你的低端手机用户群甚至可能大部分都在美国](https://www.androidauthority.com/android-go-usa-market-773723/)。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-16.png)

**[Android 手机正变得越来越便宜，但却没有越来越快](https://twitter.com/slightlylate/status/919989184881876992)。**这些设备的 CPU L2/L3 缓存依旧很小，请不要高估了你的用户群体。让我们再回到文章开头 那张 CNN.com 中 JavaScript 处理时间统计图上看看。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-17.png)

**iPhone 8（采用 [A11](https://en.wikipedia.org/wiki/Apple_A11) 芯片）在完成 JavaScript 上比中端机型快9秒**。而通过对比三类机型的 filmstrips 片段，能看出低端机型甚至都不能用简单的慢来形容了，我们必须要摒弃曾经一度以为的**“我们用户网络环境一直很好、很快”**的天真想法。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-18.png)

既然如此，那么在实际开发中，我们便要想办法在真实机型和网络环境中进行测试。如果你不方便购买一堆中低端设备用于测试，类似 [webpagetest.org/easy](https://www.webpagetest.org/easy) 这样的模拟配置可以为你提供便利。此外，不同网络环境的测试也同样重要，Chrome Devtools 就提供有多种模拟网络环境用于开发测试。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-19.jpeg)

并不是所有网站都需要在2G网络或者低端机型上表现良好，这取决于你的实际用户群，这也是当下大家一直都在说的“用数据说话”。但请记住，即便高端机型用户也可能会遇到弱网环境，所以 JavaScript 下载时间至关重要，请善用压缩技术（例如 [gzip](https://www.gnu.org/software/gzip/), [Brotli](https://github.com/google/brotli), [Zopfli](https://github.com/google/zopfli)）。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-20.jpeg)

在用户重复访问时利用好缓存，低配 CPU 在解析上是非常耗时的。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-21.jpeg)

## #7 分发更少 JavaScript 的常见技巧

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-22.png)

[代码分离](https://survivejs.com/webpack/building/code-splitting/) 技术是一个可选项。其思想是说，取而代之一次下发所有 JavaScript bundle，我们将代码分离开，针对每个页面只下发正好保证其运行的最小 JavaScript 代码。

代码分离可以是页面级别、路由级别或者组件级别的，很多现代框架或工具库也对他有很好的支持，比如 [webpack](https://webpack.js.org/concepts/), [Parcel](https://parceljs.org/) 以及 [React](https://reactjs.org/docs/code-splitting.html), [Vue.js](https://router.vuejs.org/guide/advanced/lazy-loading.html) 和 [Angular](https://angular.io/guide/lazy-loading-ngmodules)。有关代码分离的更多细节也可以参考[[译] 超大型 JavaScript 应用的设计哲学](https://hijiangtao.github.io/2018/04/20/Designing-Very-Large-JavaScript-Applications/)。来看一段示意代码：

```javascript
// 优化前
import OtherComponent from './OtherComponent';

const MyComponent = () => (
  <OtherComponent/>
);

// 优化后
import Loadable from 'react-loadable';

const LoadableOtherComponent = Loadable({
  loader: () => import('./OtherComponent'),
  loading: () => <div>Loading...</div>,
});

const MyComponent = () => (
  <LoadableOtherComponent/>
);
```

很多团队在投入代码分离后都获得了不小的收益。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-23.jpeg)

在这些团队的项目改造中，除了代码分离，代码审查也是它们关注的一点。由于 JavaScript 生态的繁荣，已经有很多工具可以帮助我们实现这一点，例如 [Webpack Bundle Analyzer](https://www.npmjs.com/package/webpack-bundle-analyzer), [Source Map Explorer](https://www.npmjs.com/package/source-map-explorer) 和 [Bundle Buddy](https://github.com/samccone/bundle-buddy)。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-24.png)
*常规审查方式*

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-25.png)
*审查结果举例*

## #8 持续集成四部曲

### #8.1 度量与优化

如果您不确定自己的 JavaScript 消耗是否有任何问题，可以试试 [Lighthouse](https://developers.google.com/web/tools/lighthouse/):

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-26.jpeg)

Lighthouse 已经集成到 Chrome 开发者工具中。当然，你也可以使用 [Chrome 插件](https://chrome.google.com/webstore/detail/lighthouse/blipmdconlkpinefehnmjammfjpmpbjk?hl=en)。它为你提供了深入的性能分析，并给出了一些潜在可以提高性能的建议。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-27.png)

LightHouse 最近添加了一个功能，即对 “[高启动时间 JavaScript](https://developers.google.com/web/updates/2018/05/lighthouse#javascript_boot-up_time_is_high)” 的标记支持。你可以利用它分析出当前代码中有哪些 JavaScript 会导致解析/编译耗时过长并延迟交互性，并据此拆分和优化你的代码。

你可以做的另一件事是确保没有将未使用到的代码分发给用户：

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-28.jpeg)

同样，[代码覆盖](https://developers.google.com/web/updates/2017/04/devtools-release-notes#coverage)也是 DevTools 提供的一个新特性，你可以在 Chrome 中尽情使用。

如果你正在寻找一种为用户提供高效的 JavaScript 分发模式，可以试试 [PRPL 模式](https://developers.google.com/web/fundamentals/performance/prpl-pattern/)。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-29.jpeg)

PRPL 即推送，渲染，预缓存和懒加载。结合 [service worker](https://developers.google.com/web/fundamentals/primers/service-workers/) 使用更加。例如这周给师兄完善 PWA Demo 的一个小功能时，就用到了 React 在服务端渲染时采用的 renderToString 方法，在这个过程中，就是利用 HTML 在未加载 JavaScript 等资源的情况 下使用 App Shell 优化页面首次访问时的白屏体验。还挺有意思，有时间可以细说一下这个事。

### #8.2 监控

为了防止多人协作或持续集成时的合作混乱，作者建议大家采用 [**performance budget](https://timkadlec.com/2013/01/setting-a-performance-budget/)** 来进行管理与度量。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-30.jpeg)

在表现性能预估这方面也有相应的 CI 工具提供支持——[Lighthouse CI](https://github.com/ebidel/lighthouse-ci)。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-31.png)

**开发时的性能考虑是一方面，但实际运行时用户端的表现又是怎样的呢？所以，这要求网站必须同时具有[理论数据和实际表现数据的支持](https://developers.google.com/web/fundamentals/performance/speed-tools/)。**

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-32.png)

在真实的用户场景监控上，作者有两点建议：

1. [Long Tasks](https://w3c.github.io/longtasks/) — 利用这个 API 你可以收集那些耗时超过50毫秒、可能会阻塞主线程的任务（及其脚本），并将其数据记录用于后续分析
2. [First Input Delay](https://developers.google.com/web/updates/2018/05/first-input-delay) (FID) 是一个度量标准，用于衡量用户首次与你的网站互动（即点击按钮时）到浏览器实际能够响应该互动的时间。虽然它还是一个新标准，但已经有 [polyfill](https://github.com/GoogleChromeLabs/first-input-delay) 实现。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-33.jpeg)

众所周知，第三方 JavaScript 代码也是影响页面加载性能的重要因素之一，如果这是你当前需要考虑的因素之一，Google 提供有一份优化指导，可以移步 [Third-party JavaScript](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/loading-third-party-javascript/) 查看更多。

### #8.3 如此往复

**性能是一段旅程。许多微小的变化却可以带来巨大的收益。**确保用最少的 JavaScript 代码为用户提供真正的价值，减少他们在访问网站时的困惑。不断的重复如上步骤，精益求精。

![](/assets/in-post/2018-08-04-the-cost-of-javascript-in-2018-34.jpeg)

**后记**：原文对如上所述的很多方面提供了详尽的介绍，感兴趣可以移步 [The Cost of JavaScript In 2018](https://medium.com/@addyosmani/the-cost-of-javascript-in-2018-7d8950fbb5d4) 精读。

## 参考

* [Can You Afford It?: Real-world Web Performance Budgets](https://infrequently.org/2017/10/can-you-afford-it-real-world-web-performance-budgets/)
* [Progressive Performance](https://www.youtube.com/watch?v=4bZvq3nodf4&list=PLNYkxOF6rcIBTs2KPy1E6tIYaWoFcG3uj&index=18&t=0s)
* [Reducing JavaScript payloads with Tree-shaking](https://developers.google.com/web/fundamentals/performance/optimizing-javascript/tree-shaking)
* [Ouch, your JavaScript hurts!](https://speedcurve.com/blog/your-javascript-hurts/)
* [Fast & Resilient — Why carving out the “fast” path isn’t enough](https://docs.google.com/presentation/d/169gop22hzmu-NEUiNQyoIZ_oRiMqNLFMKNJVvX42iC8/edit?usp=drivesdk)
* [Web performance optimization with Webpack](https://developers.google.com/web/fundamentals/performance/webpack/)
* [JavaScript Start-up Optimization](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/javascript-startup-optimization/)
* [The Impact Of Page Weight On Load Time](https://paulcalvano.com/index.php/2018/07/02/impact-of-page-weight-on-load-time/)
* [Beyond The Bubble — Real-world Performance](https://building.calibreapp.com/beyond-the-bubble-real-world-performance-9c991dcd5342)
* [How To Think About Speed Tools](https://developers.google.com/web/fundamentals/performance/speed-tools/)
* [Thinking PRPL](https://houssein.me/thinking-prpl)
