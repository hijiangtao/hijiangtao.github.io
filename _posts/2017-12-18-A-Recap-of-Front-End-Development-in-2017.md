---
title: \[译\] 2017前端技术发展回顾
layout: post
thread: 183
date: 2017-12-18
author: Joe Jiang
categories: documents
tags: [2017, JavaScript, FE, Translation]
excerpt: 前端领域在 2017 年再次以狂热的节奏向前发展。该文章列出过去的一年中最值得关注的一系列事情。
header:
  image: ../assets/in-post/2017-12-18-A-Recap-of-Front-End-Development-in-2017-teaser.png
  caption: "From Internet"
---

> 原文 - A recap of front-end development in 2017
>
> 原文作者 - Trey Huffine
>
> 原文地址 - <https://levelup.gitconnected.com/a-recap-of-front-end-development-in-2017-7072ce99e727>
> 
> 译者 - [hijiangtao](https://github.com/hijiangtao)
>
> 译文地址 - <https://hijiangtao.github.io/2017/12/18/A-Recap-of-Front-End-Development-in-2017/>

前端领域在 2017 年再次以狂热的节奏向前发展。以下列出过去的一年中最值得关注的一系列事情。

![](/assets/in-post/2017-12-18-A-Recap-of-Front-End-Development-in-2017-1.jpeg "Profile")

## React 16 和 MIT 协议

React 继续在前端领域占据着主导地位，并在 2017 年发布了最受期待的版本之一 - [React 16](https://edgecoders.com/react-16-features-and-fiber-explanation-e779544bb1b7)。 它包含了可以实现异步 UI 渲染的 fiber 架构。通过提供包括错误边界在内的[很多其他特性](https://edgecoders.com/react-16-features-and-fiber-explanation-e779544bb1b7)，这次发布使得 React 可以更容易的管理意外的程序故障。

让人意外的是，React 在去年所取得最重要的成就不是它推出的新特性，而是修改了它的开源协议。Facebook 放弃了导致很多公司远离 React 的 BSD 协议，转而采用[用户用好的MIT 协议](https://code.facebook.com/posts/300798627056246/relicensing-react-jest-flow-and-immutable-js/)。除此外，Jest、Flow、Immutable.js 和 GraphQL 授权也都改为 MIT 协议。

核心团队和主要贡献者包括 [Dominic Gannaway](https://medium.com/@trueadm)，[Dan Abramov](https://medium.com/@dan_abramov)，[Sophie Alpert](https://medium.com/@sophiebits)，[SebastianMarkbåge](https://medium.com/@sebmarkbage)，[Paul O'Shannessy](https://medium.com/@zpao)，[Andrew Clark](https://medium.com/@acdlite)，[Cheng Lou](https://medium.com/@chenglou)，Clement Hoang，Probably Flarnie，Brian Vaughn。

> [React v16.0 - React Blog](https://reactjs.org/blog/2017/09/26/react-v16.0.html)

## Progressive Web Apps

我们一直在寻找弥补 web 和其他客户端之间体验差距上的解决方案。Google 一直主导通过将 web 应用转换为 Progressive Web Apps(PWA) 来增强它的能力，而这一方法在 2017 年迅速获得采用。一个 PWA 应用利用现代浏览器技术来提供更像移动应用程序的 web 体验。它提供了改进的性能和离线体验，以及以前仅可用于移动的功能，例如推送通知。 PWA 的基础是一个 `manifest.json` 文件和对 [service workers](https://developers.google.com/web/fundamentals/primers/service-workers/) 的利用。

> [Progressive Web Apps: Great Experiences Everywhere (Google I/O ‘17)](https://www.youtube.com/watch?v=m-sCdS0sQO8)

## Yarn 的采用改善了 JS 包管理的生态系统

NPM 自从最初发布以来已经有了相当长的一段时间，但它仍然缺少一些关键特性，而这正是 Yarn 希望补充的。Yarn 的主要贡献是包缓存，一个确保确定性构建的锁文件，并行操作以及依赖关系。这些功能非常成功，以致于 NPM 在其 5.0 版本中实现了它们。Yarn 下载量超过 10 亿次（目前每月下载量达到了 125 万次）并拥有惊人的 [28000 多个 GitHub stars](https://github.com/yarnpkg/yarn)。即使你没在使用 Yarn，JavaScript 的包管理整体上由于 Yarn 的发布也得到了显著地提升 。

> [Yarn](https://yarnpkg.com/en/)

## CSS 网格布局

网格布局最终被 CSS 采纳为标准，浏览器也正在快速地采用它。过去，网格系统在 CSS 中曾被 `tables`、`float`、`flex` 以及 `inline-block` 实现过。原生的 CSS 网格布局擅长于将一个页面划分成几个主要的区域，并为内容创建列和行。查看 Rachel Andrew 写的 <https://gridbyexample.com/> 开始学习。

> [CSS Grid Layout](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout)

## WebAssembly 在所有主流浏览器中都得到了支持

[WebAssembly](http://webassembly.org/)（或者 *wasm*）正登陆所有主流浏览器。wasm 是一个用于浏览器内客户端脚本处理接近原生的 [字节格式](https://en.wikipedia.org/wiki/Bytecode) 。由于其接近原生，它具有令人难以置信的性能，但也提供了一个 [JavaScript API](http://webassembly.org/docs/js/)，以使得前端开发人员有一个更容易的切入点。Firefox 最近宣布对它的支持已经被所有（译者注：此处所有应该是指所有主流）浏览器内置。

> [
WebAssembly support now shipping in all major browsers - The Mozilla Blog](https://blog.mozilla.org/blog/2017/11/13/webassembly-in-browsers/)

## Serverless 架构

Serverless 应用在 2017 年以狂热的节奏流行开来。他们提供了一种以降低成本来提升性能的方法。你的客户端与服务端完全分离，这允许你可以专注在你的应用而不是基础设施上。一个常见的实现是将 AWS API 网关与 AWS Lambda 函数结合使用，后者作为一个 BaaS （后端作为一个服务）在你的客户端使用。你可以从 [Adnan Rahić](https://medium.com/@adnanrahic) 的精彩介绍开始。

> [
A crash course on Serverless with Node.js](https://hackernoon.com/a-crash-course-on-serverless-with-node-js-632b37d58b44)

## Vue.js 在流行中继续成长

即便 React 获得了巨大成功，[Vue](https://vuejs.org/)（作者[尤雨溪](https://medium.com/@youyuxi)）仍然越来越受欢迎。该框架提供了易基于组件的架构，是 React 的主要替代方案之一。它已经被包括 [GitLab](https://medium.com/@gitlab) 在内的大公司所采用，该公司回顾了[在过去的一年里使用该框架的故事](https://about.gitlab.com/2017/11/09/gitlab-vue-one-year-later/)。

![](/assets/in-post/2017-12-18-A-Recap-of-Front-End-Development-in-2017-2.png "Vue.js continuing to grow in popularity")

## CSS-in-JS 以及为即将到来的 CSS 圣战做准备

在我们目睹了 JavaScript 的快速发展之后，生态系统开始稳定下来。 不可避免的是，我们也会在 CSS 领域看到同样的不断进步，因为它赶上了现代 web 应用的需求。在 2017 年，主要的进步来自 CSS-in-JS 的明显改进与采用，其中所有样式都是通过代码而不是样式表进行构建的。目前还不清楚这是否将成为前端社区的最终方向，但这是目前最新的方法，似乎解决了构建基于组件的应用程序时遇到的许多问题。

2017 年见证了 [styled-components](https://www.styled-components.com/)（由 [Max Stoiber](https://medium.com/@mxstbr)、[Glen Maddern](https://medium.com/@glenmaddern) 和 [Phil Plückthun](https://medium.com/@philpl) 创建） 在流行程度上逐渐占据主导地位。[Emotion](https://github.com/emotion-js/emotion)（由 [Kye Hohenberger](https://medium.com/@tkh44) 创建）是最新的 JavaScript 库之一，但它已经被迅速采用。另一个可选方案是 [glamorous](https://glamorous.rocks/)（由 PayPal、Kent C. Dodds 和一群热情的[贡献者](https://github.com/paypal/glamorous/blob/master/README.md#contributors)创建），它封装了 [glamor](https://github.com/threepointone/glamor) 库。查看[这篇文章](https://alligator.io/react/css-in-js-roundup-styling-react-components/)，一篇关于许多CSS-in-JS 的可选方案的总结。

> [A Brief History of CSS-in-JS: How We Got Here and Where We’re Going](https://levelup.gitconnected.com/a-brief-history-of-css-in-js-how-we-got-here-and-where-were-going-ea6261c19f04)

## 静态网站生成方案

2017 见证了静态网站卷土重来。像 [Gatsby](https://www.gatsbyjs.org/) 这样的框架使您能够使用 React 和其他现代工具构建静态网站。不是每个网站都需要或应该成为一个复杂的现代 web 应用。由于采用与预构建标记（原文 prebuilt markup），静态网站生成方案使你获得服务器端渲染的好处和绝无仅有的速度。如果你正在寻找一个很好的例子，[React 官方文档](https://reactjs.org/)就是用 Gatsby 构建的。

静态网站生成方案引发了另一个被称为 JAMStack 的趋势：“JavaScript, APIs, Markup”。JAMStack 使用相同的静态预构建 HTML 文件以及可重复使用的 API  JavaScript 来处理请求/响应周期内任何的动态构建。[Netlify](https://medium.com/@Netlify) 是开始使用 JAMStack 和免费静态主机的绝佳选择。Brian Douglas写了一篇很棒的文章，通过构建 Hacker News 应用对比了 [JAMStack 和服务器端渲染应用的不同](https://www.netlify.com/blog/2017/06/06/jamstack-vs-isomorphic-server-side-rendering/)。

> [Modern static site generation with Gatsby](https://www.gatsbyjs.org/blog/2017-09-18-gatsby-modern-static-generation/)

## GraphQL 的火爆并使我们重新思考 API 的构建

GraphQL 似乎在 REST 之上迅速占据了一席之地，[Samer Buna](https://medium.com/@samerbuna) 甚至声称 [REST 已经死亡](https://medium.freecodecamp.org/rest-apis-are-rest-in-peace-apis-long-live-graphql-d412e559d8e4)。GraphQL 允许客户端声明式的定义所需的数据，并从一个断点中检索所有需要数据，而不是管理多个端点以及获取不必要的数据。

它非常流行，[GitHub](https://medium.com/@github) 已经使用 GraphQL 编写了[最新版本的 API](https://developer.github.com/v4/)，与此同时为了使 GraphQL 对所有开发人员可用，许多公司正在开发产品，例如 [Johannes Schickling](https://medium.com/@schickling) 开发的 [Graphcool](https://medium.com/@graphcool) 框架。

> [GraphQL: A query language for APIs.](http://graphql.org/)

## React Router 4

由 Ryan Florence 和 Michael Jackson 创建的 React Router，从为 React 提供的一个路由演变为一个真正的 React Router - 一个简单使用 React 组建的声明式路由。这是 React 团队认可的第一个版本。它的 API 已经稳定下来，[React Training](https://medium.com/@ReactTraining) 团队已经表示在该项目的整个生命周期中不会看到任何大的突变。

![](/assets/in-post/2017-12-18-A-Recap-of-Front-End-Development-in-2017-3.png "VReact Router 4")

## Angular 发布了 v4 版本，紧接着发布了 v5

在臭名昭著的因为没有维护 SEMVER 跳过了版本 3 之后，Angular 4 于3月23日正式发布。在第4版中，Angular 团队采纳了社区项目 Angular Universal - 它提供了一种服务器端渲染 Angular 应用的方法 - 作为 Angular 项目官方的一部分。Angular Animation 包从 `@angular/core` 中抽离出来，为了只在需要的时候导入。视图引擎中的前期编译在性能上已经重构，“在最大多数情况下将能减少 60% 左右的生成代码。”

v5 中看到了额外的期待已久的改进。归功于新的 `@angular/service-worker` 包，使用 Angular v5 创建一个 Progressive Web App 比以往的任何版本都要更加容易。Angular 编译器也得到了改进，在开发过程中实现了更快的构建/重建，Angular Router 现在公开了所有新的生命周期钩子，包括 `ActivationStart`，`ActivationEnd`，`ResolveStart` 和 `ResolveEnd`。

## TypeScript 和 Flow

[TypeScript](https://www.typescriptlang.org/) 赢得了很多 JavaScript 开发者的追捧，而 [Flow](https://flow.org/) 提供了一种在不需要激进的重构下更为灵活的方式来引入类型。JavaScript 中缺少类型一直是很多人的抱怨所在。TypeScript 由 Microsoft 创建，是新版 Angular 中的一项要求。Flow 是 Facebook 的工作结晶。

## gitconnected 为开发人员创建了交流社区

gitconnected 发起为开发人员和软件工程师创建社区。它提供了协作、分享文章和与其他开发者进行讨论的能力。此外，你可以在个性化的个人资料页面上无缝地显示项目和宣传页。 不要错过与其他人分享你的兴趣、互相帮助学习和成长的机会。

> [gitconnected - The community for developers and software engineers](https://gitconnected.com/)

*译者注：原文作者为 gitconnected 创始人，故对于最后一条事件是否具备前端年度代表性事件的影响力判断有失公允。但为了保留原文完整，故依旧做了翻译。*

## 2018，我们应该期待些什么

* 在我们想出如何处理基于组件应用中的样式的最佳方式时，CSS 的战斗就会激化。
* 越来越多的公司采用具有统一代码库的移动解决方案，如 [React Native](https://facebook.github.io/react-native/) 或 [Flutter](https://flutter.io/)。
* 因为离线能力和无缝的移动端体验，web 变得更加原生。
* WebAssembly 可以取得长足的进步，提供一个更好的 web 体验。
* GraphQL 正在并继续挑战 REST。
* 由于不再有对开源协议上的争议，React 强化了它的地位（是的，甚至更多）。
* Flow 和 TypeScript 采取更强大的举措，使 JavaScript 更具结构。
* Containerization 的影响在前端架构中变得越来越普遍。
* 虚拟现实使用类似 [A-Frame](https://aframe.io/)、[React VR](https://facebook.github.io/react-vr/) 和 [Google VR](https://developers.google.com/vr/?hl=en) 这样的库正在向前迈进。
* 人们使用区块链和 [web3.js](https://github.com/ethereum/web3.js/)（由 Marek Kotewicz 和 Fabian Vogelsteller 创建）构建了一些非常酷的应用程序。

如果我遗漏了任何大事件，请评论告知，我一定会加上的！

----

译者：我一直在维护一个项目 [FE-Cookbook](https://github.com/hijiangtao/FE-Cookbook)，个人想通过这个项目把自己持续关注的前端相关内容汇总收集，一方面方便自己和其他同学日后查看、另一方面希望与有同样兴趣的同学一起将该项目完善壮大。本项目持续更新中，如果觉得有用欢迎给项目添加 Star；如果觉得有任何需要改进或者需要完善的地方，欢迎贡献代码提请 PR，针对无冲突的内容我会快速合并。更多项目请关注我的 [GitHub](https://github.com/hijiangtao)。