---
title: 动态创建 Web Worker 实践指南
layout: post
thread: 215
date: 2019-03-21
author: Joe Jiang
categories: Document
tags: [2019, Worker, Blob, Web, Promise, 前端, 计算]
excerpt: 网上有很多关于 Web Worker 的入门介绍与示例，但要在实际工程中引入，往往还需要一些额外的工作。
header:
  image: ../assets/in-post/2019-03-21-Create-A-Dynamic-Web-Worker-With-Blob-teaser.png
  caption: "Screenshot from caniuse.com"
---

作为前端，在消费接口提供的数据时，往往由于数据实际分布在不同地方（如一部分存储在 ODPS ，而另一部分可能更适合在应用初始化时从本地载入内存）而需要对数据进行区分处理。当然，交互的实现可能也会需要很重的计算逻辑，而为了加速计算、不阻塞渲染线程，Web Worker 不失为一个很好的选择。

网上有很多关于 Web Worker 的入门介绍与示例，但要在实际工程中引入，往往还需要一些额外的工作。相比 MDN 上提供的 demo 示例，在实际工程中，我们可能更希望 Web Worker 能解决如下几个问题：

* 可根据不同业务属性动态创建不同的 Web Worker；
* API 简单易用，例如通过 `Promise` 链式调用替换相对较为繁琐的事件监听处理逻辑；
* 代码可复用，且最好不需对项目所依赖的构建工具进行更改；

本文结构如下：

1. 一些约定
2. 谈及 Web Worker
3. Web Worker 构造方法举例
4. 动态 Worker 的简单封装
5. 调用区分优化
6. 总结
7. 进一步阅读

以下开始正文。

## 0 / 一些约定

本教程将教你写一个可动态创建的可复用 Web Worker。在进一步阅读之前，我假设你已经掌握了关于 Web Worker 的一些基本用法，否则建议先阅读 MDN 提供的[使用 Web Workers](https://developer.mozilla.org/zh-CN/docs/Web/API/Web_Workers_API/Using_web_workers) 文档，了解一些基础概念。

与此同时，本文所创建的动态 Worker 均指专有 Worker，不涉及到共享 Worker 及其他类型 Worker 的内容。

## 1 / 谈及 Web Worker

我们常说「任何可以使用 JavaScript 来编写的应用，最终会由 JavaScript 编写」，但实际移植到 JavaScript 环境时仍然存在很多制约，比如浏览器兼容性、静态类型与运行性能等。 随着 JavaScript 引擎不断地优化，性能已不再是那个最大的瓶颈，而受到浏览器 JavaScript 运行时的单线程环境限制，最大的阻碍貌似来自语言本身。

好在从 HTML5 规范开始，Web Worker 概念地引入为 JavaScript 引入了线程技术。Web Worker 为 Web 内容在后台线程中运行脚本提供了一种简单的方法，你可以在后台执行任务而不干扰用户界面。例如触发长时间运行的脚本以处理计算密集型任务，同时却不会阻碍 UI 或其他脚本处理用户互动。对于 Web Worker 来说，最正常的创建方式无异于创建两个 js 文件，一个 `main.js` 用于 `Worker()` 构造器并处理与 worker 间消息的接受与发送：

```javascript
let myWorker = new Worker('worker.js');

myWorker.postMessage('Hi, this is a message from main.js');

myWorker.onmessage = (e) => {
  console.log('Message received from worker', JSON.stringify(e));
}
```

一个 `worker.js` 用于响应主线程的消息，包括处理与回传结果：

```javascript
onmessage = (e) => {
  console.log('Message received from main script');

  let workerResult = `Result: ${JSON.stringify(e)}`;
  console.log('Posting message back to main script');

  postMessage(workerResult);
}
```

## 2 / Web Worker 构造方法举例

在上例中，传入 Worker 构造函数的参数是一个具体路径，但除此外，我们还能传入其他路径达到创建 Web Worker 的目的，比如字符串，具体有如下三种方法：

* `Blob`: 该方式适用于 Chrome 8+, Firefox 6+, Safari 6.0+, Opera 15+ 等环境
* `data:application/javascript`: 该方式适用于 Opera 10.60 - 12
* `eval`: 适用于其他环境，比如 IE 10+

什么是 `Blob` 对象？它表示一个不可变、原始数据的类文件对象，但不局限于 JavaScript 原生格式的数据，常被用来存储体量很大的二进制编码格式的数据。你可以使用 `Blob()` 构造函数从一段字符串中创建一个 Blob 对象：

```javascript
const debug = {hello: "world"};
const blob = new Blob(
  [JSON.stringify(debug, null, 2)],
  {type : 'application/json'}
);
```

而利用 `URL.createObjectURL()` API 我们可以将 Blob 对象转换为一个对象 URL 传入 Worker 构造函数，如下：

```javascript
const worker = new Worker(URL.createObjectURL(blob));
```

那么什么又是 `data:application/javascript` 呢？Data URLs，即前缀为 `data:` 协议的的URL，其允许内容创建者向文档中嵌入小文件。这样的 URL 由四个部分组成：前缀(data:)、指示数据类型的 MIME 类型、如果非文本则为可选的 base64 标记、数据本身：

```
data:[<mediatype>][;base64],<data>
```

所以现在你应该知道 `application/javascript` 所指了，是的，利用这个 URL 我们可以这样创建 Web Worker：

```javascript
const response = "onmessage=function(e){postMessage('Worker: '+e.data);}";

const worker = new Worker(
  'data:application/javascript,' + encodeURIComponent(response) 
);

worker.onmessage = (e) => {
  alert('Response: ' + e.data);
};

worker.postMessage('Test');
```

而在 Safari (<6) 与 IE 10 中，`eval` 作为向后兼容的一种方式，你可以这样创建 Web Worker：

```javascript
const response = "onmessage=function(e){postMessage('Worker: '+e.data);}";

const worker = new Worker('Worker-helper.js');

worker.postMessage(response);
```

其中 `Worker-helper.js` 代码如下：

```javascript
onmessage = (e) => {
    onmessage = null; // Clean-up
    eval(e.data);
};
```

当然，在使用之前还需要对相应 API 进行兼容判断，比如 `window.URL || window.webkitURL` 或者 `window.Worker` 等，这里便不详述。

## 3 / 动态 Worker 的简单封装

我们先来写一个简单的 Web Worker 示例，假设我们在 Worker 收到数据时有一个简单的判断逻辑，即只处理 `method='format'` 的消息：

```javascript
window.URL = window.URL || window.webkitURL;

const response = `onmessage = ({ data: { data } }) => {
  console.log('Message received from main script');
  const {method} = data;
  if (data.data && method === 'format') {
    postMessage({
      data: {
        'res': 'I am a customized result string.',
      }
    });
  }
  console.log('Posting message back to main script');
}`;
const blob = new Blob([response], {type: 'application/javascript'});

const worker = new Worker(
  URL.createObjectURL(blob),
  { type: 'text/javascript' }
);

// 事件处理
worker.onmessage = (e) => {
  alert(`Response: ${JSON.stringify(e)}`);
};
worker.postMessage({
  method: 'format', 
  data: []
});
```

这个 Demo 会建立一个 Web Worker 并向其发送一段文本，而 Worker 在处理完毕后主线程会把结果弹窗显示出来。接下来，我们就用它继续操作。

一个动态 Worker 结构应该长成如下这样，包含构造函数、动态调用函数以及 Worker 销毁函数，而构造函数中至少应该定义好 Worker 用到的全局变量、数据处理函数以及 onmessage 事件处理函数：

```javascript
const BASE_DATASETS = '';
class DynamicWorker {
  constructor(worker) {
    /**
     * 依赖的全局变量声明
     * 如果 BASE_DATASETS 非字符串形式，可调用 JSON.stringify 等方法进行处理
     * 保证变量的正常声明
     */
    const CONSTS = `const base = ${BASE_DATASETS};`;
    
    /**
     * 数据处理函数
     */ 
    const formatFn = `const formatFn = ${worker.toString()};`;
    
    /**
     * 内部 onmessage 处理
     */
    const onMessageHandlerFn = `self.onmessage = ()=>{}`;

    /**
     * 返回结果
     * @param {*} param0 
     */
    const handleResult = () => {}
    
    const blob = new Blob(
      [`(()=>{${CONSTS}${formatFn}${onMessageHandlerFn}})()`], 
      { type: 'text/javascript' }
    );
    this.worker = new Worker(URL.createObjectURL(blob));
    this.worker.addEventListener('message', handleResult);

    URL.revokeObjectURL(blob);
  }

  /**
   * 动态调用
   */
  send(data) {}

  close() {}
}
```

以上代码有几点需要解释下，比如生成 `Blob` 对象时，由于入参是字符串数组，如果只是调用 `.toString()`，便无法拿到函数名，因此所有字符串采用变量命名的形式定义。接着我们调用 `URL.createObjectURL` 生成对象 URL，在创建完 Worker 后调用 `URL.revokeObjectURL()` 让浏览器知道不再需要对这个文件保持引用。

`URL.revokeObjectURL()` 静态方法用来释放一个之前通过调用 `URL.createObjectURL()` 创建的已经存在的 URL 对象。当你结束使用某个 URL 对象时，应该通过调用这个方法来让浏览器知道不再需要保持这个文件的引用了。详见 [MDN API](https://developer.mozilla.org/zh-CN/docs/Web/API/URL/revokeObjectURL).

内部接收与响应消息的函数应该做逻辑判断并发送对应信息返回主线程，我们这样完善 `onMessageHandlerFn`：

```javascript
const onMessageHandlerFn = `self.onmessage = ({ data: { data } }) => {
      console.log('Message received from main script');
      const {method} = data;
      if (data.data && method === 'format') {
        self.postMessage({
          data: formatFn(data.data)
        });
      }
      console.log('Posting message back to main script');
}`;
```

利用 Promise 的链式调用，我们可以隐藏较为琐碎的事件监听处理程序。来写一个 `send` 方法允许开发者动态调用，内部我们接收到数据后，改变 resolve 的状态，并返回这个 Promise：

```javascript
send(data) {
    const w = this.worker;
    w.postMessage({
      data,
    });

    return new Promise((res) => {
      this.resolve = res;
    })
}
```

我们定义一个 `this.resolve` 用于记录 Promise 的状态，然后在 Worker 收到响应后便判断 `this.resolve` 然后决定是否 resolve 计算结果：

```javascript
const handleResult = ({ data: { data } }) => {
      if (this.resolve) {
        resolve(data);
        this.resolve = null;
      }
}
```

如此一来，接下来我们就可以在主进程中这样调用 `DynamicWorker` 了：

```javascript
import DataWorker from './dynamicWorker.js';

const formatFunc = () => {
  return {
    'res': 'I am a customized result string.',
  }
}

const worker = new DataWorker(formatFunc);

const result = []; // demo 数据

worker.send({
  method: 'format', 
  data: result
}).then((e) => {
  alert(`Response: ${JSON.stringify(e)}`);
})
```

## 4 / 调用区分优化

当然，如果我们没有频繁调用 Worker，那么上面的代码貌似已经足够。但如果你需要短时间多次传输数据进行处理，那么调用的多个方法与对应的多个结果间可能会相互混淆。为什么呢，原因在于我们在构造函数中写的这行：

```javascript
this.worker.addEventListener('message', handleResult);
```

这个事件监听处理函数是区分不出每次调用的，在收到消息后它只会执行 resolve。那么该如何解决呢？其实也较为简单，加入一个标志位用于区分不同调用即可。

首先，在构造函数里我们加上这么一行：

```javascript
this.flagMapping = {};
```

简单起见，我们直接取日期作为标志位 key，改写后的 send 方法长成这样：

```javascript
send(data) {
    const w = this.worker;
    const flag = new Date().toString();
    w.postMessage({
      data,
      flag,
    });

    return new Promise((res) => {
      this.flagMapping[flag] = res;
    })
}
```

最后，根据 `flag` 传参我们改写 Worker 内部的 `onmessage` 函数以及返回结果函数的判断逻辑：

```javascript
const onMessageHandlerFn = `self.onmessage = ({ data: { data, flag } }) => {
  console.log('Message received from main script');
  const {method} = data;
  if (data.data && method === 'format') {
    self.postMessage({
      data: formatFn(data.data),
      flag
    });
  }
  console.log('Posting message back to main script');
}`;

// ...

const handleResult = ({ data: { data, flag } }) => {
  const resolve = this.flagMapping[flag];
  
  if (resolve) {
    resolve(data);
    delete this.flagMapping[flag];
  }
}
```

## 5 / 总结

至此，一个可动态创建、可复用的 Web Worker 便写完了，大致骨架见附录，完整代码见 GIST <https://gist.github.com/hijiangtao/22607ea9e5f4dfe504381a99d4134142>。

当然，本文还有很多内容没有涉及，比如创建 subworker、比如共享 worker 等等。在处理简单逻辑时，本文所述的 Web Worker 已够用，其他就留到下篇文章再去详细谈谈吧。

## 6 / 进一步阅读

* Web Workers <https://developer.mozilla.org/zh-CN/docs/Web/API/Web_Workers_API/Using_web_workers>
* How to create a Web Worker from a string <https://stackoverflow.com/questions/10343913/how-to-create-a-web-worker-from-a-string?rq=1>
* Blob API <https://developer.mozilla.org/zh-CN/docs/Web/API/Blob>
* Data URLs API <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/data_URIs>
* encodeURIComponent API <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent>

## 附录 - DynamicWorker 类

完整代码与示例见 <https://gist.github.com/hijiangtao/22607ea9e5f4dfe504381a99d4134142>.

```javascript
const BASE_DATASETS = '';

class DynamicWorker {
  constructor(worker) {
    /**
     * 依赖的全局变量声明
     * 如果 BASE_DATASETS 非字符串形式，可调用 JSON.stringify 等方法进行处理
     * 保证变量的正常声明
     */
    const CONSTS = `const base = ${BASE_DATASETS};`;
    
    /**
     * 数据处理函数
     */ 
    const formatFn = `const formatFn = ${worker.toString()};`;
    
    /**
     * 内部 onmessage 处理
     */
    const onMessageHandlerFn = `self.onmessage = ({ data: { data, flag } }) => {
      console.log('Message received from main script');
      const {method} = data;
      if (data.data && method === 'format') {
        self.postMessage({
          data: formatFn(data.data),
          flag
        });
      }
      console.log('Posting message back to main script');
    }`;

    /**
     * 返回结果
     * @param {*} param0 
     */
    const handleResult = ({ data: { data, flag } }) => {
      const resolve = this.flagMapping[flag];
      
      if (resolve) {
        resolve(data);
        delete this.flagMapping[flag];
      }
    }
    
    const blob = new Blob(
      [`(()=>{${CONSTS}${formatFn}${onMessageHandlerFn}})()`], 
      { type: 'text/javascript' }
    );
    this.worker = new Worker(URL.createObjectURL(blob));
    this.worker.addEventListener('message', handleResult);

    this.flagMapping = {};
    URL.revokeObjectURL(blob);
  }

  /**
   * 动态调用
   */
  send(data) {
    const w = this.worker;
    const flag = new Date().toString();
    w.postMessage({
      data,
      flag,
    });

    return new Promise((res) => {
      this.flagMapping[flag] = res;
    })
  }

  close() {
    this.worker.terminate();
  }
}

export default DynamicWorker;
```