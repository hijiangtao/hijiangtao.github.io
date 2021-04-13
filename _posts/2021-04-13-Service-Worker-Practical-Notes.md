---
title: Service Worker 实践指南
layout: post
thread: 262
date: 2021-04-13
author: Joe Jiang
categories: Document
tags: [2020, JavaScript, 前端监控, chrome, iframe, ServiceWorker, postMessage, MessageChannel, IndexedDB, Web, 前端]
excerpt: 本文就利用 Service Worker 解决问题的过程中遇到的不少问题加以总结，进行记录，主要关注点在 Service Worker 的注册注销、运行时判断、线程间通信及调试几方面，涉及的内容从技术细节上包含 postMessage、MessageChannel、IndexedDB 及开发者调试工具等。
header:
  image: ../assets/in-post/2021-04-13-Service-Worker-Practical-Notes-Teaser.png
  caption: "©️hijiangtao"
---

当我们谈到 Service Worker 的时候，往往是和 PWA 绑在一起说出来的，但即便不用来做渐进式增强 Web 应用，我们也可以利用 Service Worker 的全局拦截能力，来自定义一个满足我们需要的全局代理。

本文就利用 Service Worker 解决问题的过程中遇到的不少问题加以总结，进行记录，主要关注点在 Service Worker 的注册注销、运行时判断、线程间通信及调试几方面，涉及的内容从技术细节上包含 postMessage、MessageChannel、IndexedDB 及开发者调试工具等。

目录如下：

1. Service Worker 的注册与注销
2. 页面内 Service Worker 的受控状态检测
3. postMessage、MessageChannel 及线程间通信
4. Service Worker 中的全局变量
5. Service Worker 中客户端环境判断
6. Service Worker 中的持久化存储
7. Service Worker 的运行与调试
8. 几则参考

首先作为入门，Google Developers 博客给出的几篇文章讲的还挺详细，如果对 Service Worker 生命周期以及工作机制不熟悉的话，可以提前过一遍了解一下 [https://developers.google.com/web/fundamentals/primers/service-workers](https://developers.google.com/web/fundamentals/primers/service-workers) 

### 1 / Service Worker 的注册与注销

注册 Service Worker，你需要指定文件路径、生效范围等，这个正常调用 API 就好，一个异步操作，没有特殊需要处理的地方：

```jsx
navigator.serviceWorker
  .register(swFilePath as string)
  .then((reg) => {
    tlog.info('Registration succeeded. Scope is ' + reg.scope)
  })
  .catch((error) => {
    tlog.error('Registration failed with ' + error)
  })
```

注销 Service Worker 之前，首先要获取到所有注册的实例，然后可以通过遍历 ServiceWorkerRegistration 来决定对那些实例执行注销操作，需要注意的是 unregister() 方法也是异步的。

```jsx
navigator.serviceWorker.getRegistrations().then((registrations) => {
  for (let registration of registrations) {
    if (
      registration.active?.scriptURL ===
      `${location.origin}/${DEFAULT_REPLAY_SW_FILENAME}`
    ) {
      registration.unregister()
    }
  }
})
```

### 2 / 页面内 Service Worker 的受控状态检测

通过 `navigator.serviceWorker.controller` 可以获得当前控制页面的 Service Worker 实例，这个实例是一个 [ServiceWorker](https://developer.mozilla.org/zh-CN/docs/Web/API/ServiceWorker) 对象，通过这个对象，你可以读取 `scriptURL` 获得序列化脚本的实际 URL，也可以读取 state 获取 Service Worker 当前的运行状态等等。如果当前页面内没有控制的 Service Worker 实例，那么其取值为 null。

由于注册是一个异步的过程，除了在回调中继续操作外（此时可以保证 Service Worker 处于可用状态），如果我们想单独在别处调用（比如在用户点击某个按钮时需要主动向 Service Worker 发送一条消息），需要在执行发送消息前检测当前页面内 Service Worker 是否已经准备就绪。通过 ECMAScript 的可选参数语言特性我们可以很好的规避一些 NPE 写法问题，如下所示：

```jsx
navigator.serviceWorker?.ready
      .then(() => {
        navigator.serviceWorker.controller?.postMessage(
          {
            ...
          }
        )
      })
```

需要注意的是，这样操作虽然可以保证应用状态安全，但却存在无法向 Service Worker 传递消息的风险。这是因为 `.ready` 的 Promise 可能会在 `navigator.serviceWorker.controller` 可用前就被 resolve，于是在 `.ready` resolve 之后调用并不能确保消息准确发出。利用 workbox 可以将 active 以及 controlling 加入 await 队列，从而解决如上所述问题。此外，我们也可以自己实现一个 Promise，来安排实现页面已经被 Service Worker 控制的通知，如下所示：

```jsx
window._controlledPromise = new Promise(function(resolve) {
  // Resolve with the registration, to match the .ready promise's behavior.
  var resolveWithRegistration = function() {
    navigator.serviceWorker.getRegistration().then(function(registration) {
      resolve(registration);
    });
  };

  if (navigator.serviceWorker.controller) {
    resolveWithRegistration();
  } else {
    navigator.serviceWorker.addEventListener('controllerchange', resolveWithRegistration);
  }
});
```

### 3 / postMessage、MessageChannel 及线程间通信

在 Service Worker 的执行过程中，难免会有一些需要 JavaScript 线程与 Worker 线程之间通信的场景。按照接收双方来分，大致可以分为这几类：

1. 客户端可能希望向 Service Worker 发送消息，一对一（单播）场景
2. Service Worker 可能希望将一些信息发送给与他传递消息的客户端，依旧是单播场景
3. Service Worker 可能希望向其控制下的每个客户端都发送信息，一对多（广播）消息
4. Service Worker 可能希望向发起请求的客户端发送消息，单播场景

我们按照实现手段，再一一来说说如何实现通信。

首先第一种情况，即客户端向 Service Worker 发送消息。客户端主动发送的消息，在 Service Worker 中可以通过监听 message 事件来捕获处理。

发送方如下调用：

```jsx
worker.postMessage(data)
```

而接收方如下监听即可：

```jsx
self.addEventListener('message', function handler(event: MessageEvent<any>) {
  console.log(event.data)
})
```

第二种情况，Service Worker 接收到客户端消息后还希望传回一些消息给客户端。利用 MessageChannel 可以达到这一点。在客户端这一侧，可以这么写：

```jsx
const messageChannel = new MessageChannel();

messageChannel.port1.addEventListener('message', replyHandler);
navigator.serviceWorker.controller.postMessage(data, [messageChannel.port2]);

function replyHandler (event) {
  console.log(event.data); // this comes from the ServiceWorker
}
```

Service Worker 侧收到消息以及返回消息的逻辑可以这么写：

```jsx
self.addEventListener('message', function handler(event) {
  self.messagePort = event.ports[0]

  postMessageToClientViaMessagePort({
    type: 'Test',
    data: JSON.stringify({}),
  })
})

export const postMessageToClientViaMessagePort = async (
  data: any,
) => {
  const port = self.messagePort

  if (!port) {
    console.error('Invalid MessagePort')
    return
  }

  port.postMessage(data)
}
```

使用 postMessage 传递消息，需要注意 postMessage 的执行对象可以是 MessagePort 也可以是 ServiceWorker。

所以，建立好 MessageChannel 后，客户端可以依旧按照之前所述实现向 Service Worker 传递消息，也可以通过 MessagePort 定向传递消息。当然，后者的成本是需要在 Service Worker 中建立对 MessagePort 的 `onmessage` 事件监听器，实现上如下所示。

```jsx
self.addEventListener('message', function handler(event) {
  if (!self.messagePort) {
    self.messagePort = event.ports[0]

    self.messagePort.onmessage = 
      (e)=>console.log('Got message from MessagePort')
  }

  // ...
})
```

从客户端向 Service Worker 发送消息后，如果存在需要反复通信的场景，需要在 Service Worker 中将收到的 MessagePort 给存储下来，以便之后需要与主线程通信时使用（ `messageChannel.port2`  在第一次通过 postMessage 调用后会被销毁），即如上 `self.messagePort` 变量的定义。

第三种情况，广播消息。在 Service Worker 中，你既可以对等的向请求发起方发送消息，也可以向所有Service Worker 控制下的每一个客户端广播消息

```jsx
// 广播消息
self.clients.matchAll()
  .then(all => 
    all.map(
      client => client.postMessage(data)
   )
  );
```

第四种情况，即向发起请求的客户端发送消息。这是一个一对一场景，我们可以利用如上所述的 MessageChannel 方案，在 fetch 监听事件回调里执行发送，也可以从 FetchEvent 上获取目标客户端 ID 实现发送。我们来说说后者，首先通过如下代码我们可以实现在 Service Worker 中向指定 clientId  客户端发送消息：

```jsx
self.on('fetch', function handler (event: FetchEvent) {
  fetch(event.request)
    .then(response => response.json())
    .then(function (data) {
      self.clients
        .match(event.clientId)
        .then(client => client.postMessage(data));
    });
});
```

在客户端中，监听事件这么写就好了：

```jsx
window.navigator.serviceWorker.onmessage = (event) => {
  // ...
}
```

需要注意的是，如果页面内同时有 iframe 存在，那么响应 fetch 内消息的客户端则需要考虑清楚，到底是 `window` 还是 `iframe.contentWindow`，概念不清时，容易写出很多低级 bug（比如我）。

如上列出了线程间通信的所有枚举情况，但实际如何组合使用，还要看各自的业务场景特征，比如有些场景需要保证从导航开始的所有请求拦截与通信，而有些场景只需要保证用户交互产生的数据可以得到监控与传输即可。

### 4 / Service Worker 中的全局变量

需要注意的是，Service Worker 在安装时会执行一遍 Service Worker 入口文件的所有逻辑，而其中各类事件监听器是按需调用的。如果为了保持一些状态而在你的 Service Worker 入口文件中定义了一些全局变量，那么需要注意的是当你关闭页面或判断需要执行清理逻辑时，将对应的全局变量重置一下，否则在下次 Service Worker 开始执行拦截工作时，应用状态可能并不对，比如你需要做一个页面请求数量的状态记录，在关闭页面后，你期望再次打开页面时，状态初始值从0开始，但如果不做清理工作，这个状态值实际上却是在前一次取值上累加的。

实现上，结合页面内的 `load` 和 `unload` 事件，你可以在页面的这两个生命周期中通过向 Service Worker 发送消息来主动执行全局变量的清理工作。原理较简单，此处不贴实现代码了。

### 5 / Service Worker 中客户端环境判断

我们直接先来看实现代码，关注针对 frameType 的判断即可：

```jsx
export const postMessageToClient = async (
  event: FetchEvent
) => {
  if (!event.clientId) {
    console.error('No available clientId for postMessage')
    return
  }

  const client: Client = await (self as any).clients.get(event.clientId)

  let windowClientId = '';
  let iframeClientId = '';

  // 一级页面
  if (client.frameType === "top-level") {
    windowClientId = client.id

  // iframe
  } else if (client.frameType === "nested") {
    iframeClientId = client.id
  }

  client.postMessage({windowClientId, iframeClientId})
}
```

为什么要这么处理呢？是因为当受到 Service Worker 控制的页面中同时也存在 iframe 时（同源页面），Service Worker 可以同时拦截到 iframe 内外两个环境下的所有请求，而如果需要对不同环境下的请求做差别处理的话，则需要在监听 fetch 事件时判断请求来自何方。此外，在主线程中接收 Servive Worker 传来的消息时，也需要注意事件监听器挂载的 window.navigator.serviceWorker 实例，否则可能一直接收不到数据。这个在线程间通信一节也已提过。

### 6 / Service Worker 中的持久化存储

由于 Service Worker 的实现基于 Promise，所以例如 localStorage 以及 XHR 等同步 API 在 Service Worker 中不可使用。

在数据存储方面，Service Worker 与主线程可以共用的存储是 IndexedDB，所以要读取 IndexedDB 的话写上逻辑即可，需要注意的是 IndexedDB 的读取是异步操作。

此外，利用 cache API 也可以存储数据。假设你有一个场景，需要拦截请求进行本地加工，而后重新执行一次所有请求并保证所有回放响应匹配，利用 cache API 可以很好的完成这点，这也是 PWA 相关教程中一定会提到的一个用法。但在涉及到与网络请求、外部数据存取相关的场景，cache 的操作会有些不太方便。

另外，Service Worker 内部也可以建立一些全局变量用来存储，记得提前定义好你的 self 结构，以配合 TypeScript 一起使用：

```jsx
declare var self: ServiceWorkerScope
```

此外，还需要注意下 Service Worker 内的全局变量的生命周期，做必要的清理逻辑，关于这一部分在全局变量一节也已经提过。

### 7 / Service Worker 的运行与调试

通过 chrome 开发者调试工具中的 application tab 可以查看当前页面的 Service Worker 的安装状态，并对网络、强制刷新以及绕过请求等能力做单独开关控制，当然，你也可以在这里手动触发 Service Worker 的注销等操作。

![](/assets/in-post/2021-04-13-Service-Worker-Practical-Notes-1.png )

通过 `chrome://inspect/#service-workers` 可以查看已安装过的 Service Worker 并选择其中一个进行检查调试或者销毁。当你点击 inspect 时，会弹出独立的开发者调试面板，允许你对 Service Worker 进行调试，但这里可以留意一点，如果你发现页面发出的网络请求没有经过 Service Worker，首先可以确认下是否为首次加载 Service Worker，其次，要看下 disable cache 是不是被你勾上了，最后检查下 Bypass for network 是不是被你勾上了。

![](/assets/in-post/2021-04-13-Service-Worker-Practical-Notes-2.png )

### 8 / 几则参考

MDN 以及 W3C 的文档介绍已经非常详细了，可以直接网上搜索。此处列一些个人在实践过程中参考的一些用法信息，算作一些非常规问题的参考吧。

1. [https://github.com/w3c/ServiceWorker/issues/799](https://github.com/w3c/ServiceWorker/issues/799) 
2. [https://stackoverflow.com/questions/63848494/how-to-differ-regular-and-iframe-requests-through-a-service-worker](https://stackoverflow.com/questions/63848494/how-to-differ-regular-and-iframe-requests-through-a-service-worker)
3. [https://developers.google.com/web/fundamentals/primers/service-workers](https://developers.google.com/web/fundamentals/primers/service-workers)