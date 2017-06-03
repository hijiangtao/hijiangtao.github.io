---
title: 您的第一个 Progressive Web App 实践笔记
layout: post
thread: 174
date: 2017-06-03
author: Joe Jiang
categories: documents
tags: [JavaScript, PWA, Web]
excerpt: Google 在 Web 领域持续投入的两个技术 PWA 和 AMP 吸引了很多人的目光, 我今天尝试通过 Google 的介绍文档体验了一个构建 PWA 应用的过程, 以下为实践过程中对 PWA 结构与开发关键细节的整理笔记.
---

Google 在 Web 领域持续投入的两个技术 PWA 和 AMP 吸引了很多人的目光, 我今天尝试通过 Google 的介绍文档 [您的第一个 Progressive Web App](https://developers.google.com/web/fundamentals/getting-started/codelabs/your-first-pwapp/) 体验一个构建 PWA 应用的过程, 以下为实践过程中对 PWA 结构与开发关键细节的整理笔记.

本笔记仅为操作过程中对原文的摘要整理, 由于不具有详细连贯性, 不建议作为教程阅读.

## 简介

Progressive Web App 是 PWA 的全称, 官方网站称它为一种基于 Web 向用户提供非凡体验的方式 (A new way to deliver amazing user experiences on the web), 具有可依赖性, 快速和吸引人的性质. 其特点网上也能搜到很多, 但其中有几点需要额外注意:

* 渐进式 - 适用于选用任何浏览器的所有用户，因为它是以渐进式增强作为核心宗旨来开发的
* 连接无关性 - 能够借助于服务工作线程在离线或低质量网络状况下工作。
* 类似应用 - 由于是在 App Shell 模型基础上开发，因此具有应用风格的交互和导航，给用户以应用般的熟悉感。

## 服务器与 App Shell

Progressive Web App 可以运行在自己的网络服务器上, 但除此外 Chrome 也提供有插件 [Web Server for Chrome](https://chrome.google.com/webstore/detail/web-server-for-chrome/ofhbbkphhbklhfoeikjpcbhemlocgigb) 允许用户建立本地服务器进行测试.

> App“shell”是支持用户界面所需的最小的 HTML、CSS 和 JavaScript，如果离线缓存，可确保在用户重复访问时提供即时、可靠的良好性能。这意味着并不是每次用户访问时都要从网络加载 App Shell。 只需要从网络中加载必要的内容。

有关 App Shell 的详细介绍可以查看[这里](https://developers.google.com/web/fundamentals/architecture/app-shell). PWA 采用 App Shell 架构的好处即在于其将应用基础架构和 UI 和数据分离, 使得可以实现即时加载和定期更新的功能. 以下为 App Shell 的示意图.

![](/assets/in-post/2017-06-03-My-First-Progressive-Web-App-Coding-Notes.png )

实现一个 App Shell 需要的代码包含 HTML, 必要的样式表以及连接应用的 JavaScript 代码, 从描述上这和普通的 Web 应用没有区别.

## 构建 PWA 的关键点

Progressive Web App 应启动迅速，并且立即就能使用。在开发一个 PWA 应用时有几点需要额外注意:

### 应用在运行时应区分首次运行 

用户首选项应利用 IndexedDB 或其他快速存储机制存储在本地。所以应用应该具备这样的逻辑: 在启动的时候检查本地存储中是否存有数据, 如果存储了应该解析本地数据并展现; 如果没有, 则启动初始化程序生成虚假数据填充, 同时向网络请求更新数据源.

### 服务工作线程

服务工作线程是浏览器在后台独立于网页运行的脚本，它打开了通向不需要网页或用户交互的功能的大门。现在，它们已包括如推送通知和后台同步等功能。将来，服务工作线程将会支持如定期同步或地理围栏等其他功能。它支持离线体验，广泛的利用了 promise 实现。具体可以见 [服务工作线程简介](https://developers.google.com/web/fundamentals/getting-started/primers/service-workers).

利用**服务工作线程预缓存 App Shell 和应用数据**是实现 PWA 在线、离线以及间歇性、慢速连接下工作的两个重要手段. 首先需要检测浏览器是否支持服务工作线程:

```javascript
if ('serviceWorker' in navigator) {
    navigator.serviceWorker
         .register('./service-worker.js')
         .then(function() { console.log('Service Worker Registered'); });
}
```

一个服务工作线程需要包含以下几个部分:

* install: 启动安装服务工作线程, 从服务器获取文件, 并响应添加到缓存中

```javascript
self.addEventListener('install', function(e) {
  console.log('[ServiceWorker] Install');
  e.waitUntil(
    caches.open(cacheName).then(function(cache) {
      console.log('[ServiceWorker] Caching app shell');
      // filesToCache 为 App Shell 所需的文件列表
      return cache.addAll(filesToCache);
    })
  );
});
```

* activate: 服务工作线程启动时触发, 用于更新缓存

```javascript
self.addEventListener('activate', function(e) {
  console.log('[ServiceWorker] Activate');
  e.waitUntil(
    caches.keys().then(function(keyList) {
      return Promise.all(keyList.map(function(key) {
        if (key !== cacheName) {
          console.log('[ServiceWorker] Removing old cache', key);
          return caches.delete(key);
        }
      }));
    })
  );
  return self.clients.claim();
});
```

*注: 从根本上说，只要页面有打开的标签，以前的服务工作线程就会继续控制页面。为了解决可能存在的线程 waiting 状态, 可以在 service worker 中点击 skipWaiting 或者勾上 Update on Reload 复选框强制页面重载时更新*

* fetch: 由内而外对触发抓取事件的网络请求进行评估，判断是用已有缓存作响应还是利用 fetch 从网络获取

> 服务工作线程提供了拦截 Progressive Web App 发出的请求并在服务工作线程内对它们进行处理的能力。

```javascript
self.addEventListener('fetch', function(e) {
  console.log('[ServiceWorker] Fetch', e.request.url);
  e.respondWith(
    caches.match(e.request).then(function(response) {
      return response || fetch(e.request);
    })
  );
});
```

在缓存优先于网络策略中, 我们还需要缓存应用数据. 对于此需要注意:

* 缓存优先于网络意味着我们需要发起两个异步请求，一个发向缓存，一个发向网络。我们通过应用发出的网络请求不需要做多大的改动，但我们需要修改服务工作线程，以先缓存响应，然后再将其返回 (我们需要检查并确保 caches 对象存在)。
* 将应用数据与 App Shell 分离。更新 App Shell 并清除较旧缓存时，我们的数据将保持不变，可随时用于实现超快速加载。
* 在更新数据时, 需要通过指定字段来区分当前使用数据是否需要得到更新。

## 本机集成

### 应用安装横幅

通过 manifest.json 文件声明应用清单, 内容包括启动动画, 主体颜色, 添加图标等等. 在生成该文件后, 需要在 HTML 页面 `<head>` 中添加清单链接, 例如:

```html
<link rel="manifest" href="/manifest.json">
```

深入阅读: [使用应用安装横幅](https://developers.google.com/web/fundamentals/engage-and-retain/simplified-app-installs/)

iOS 和 Windows 的图标需要在 HTML 页面额外指定:

```html
<!-- Add to home screen for Safari on iOS -->
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black">
<meta name="apple-mobile-web-app-title" content="Weather PWA">
<link rel="apple-touch-icon" href="images/icons/icon-152x152.png">

<!-- Windows -->
<meta name="msapplication-TileImage" content="images/icons/icon-144x144.png">
<meta name="msapplication-TileColor" content="#2F3BA2">
```

### 额外考虑

> 缩小关键样式并将它们直接内联到 index.html 中。PageSpeed Insights 建议在请求的前 15k 字节中提供首屏内容。