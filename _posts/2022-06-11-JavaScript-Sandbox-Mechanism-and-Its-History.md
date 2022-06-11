---
title: 面向微前端，谈谈 JavaScript 隔离沙箱机制的古往今来
layout: post
thread: 279
date: 2022-06-11
author: Joe Jiang
categories: Document
tags: [微前端, 隔离, 沙箱机制, JavaScript 运行环境, iframe, Proxy, ShadowRealm]
excerpt: 随着微前端的不断发展、被更多的团队采用，越来越多开始对沙箱这个概念有所了解。沙箱，即 sandbox，意指一个允许你独立运行程序的虚拟环境，沙箱可以隔离当前执行的环境作用域和外部的其他作用域，外界无法修改该环境内任何信息，沙箱内的东西单独运行，环境间相互不受影响。本文计划谈谈微前端的 JavaScript 隔离，即沙箱机制的古往今来。
header:
  image: ../assets/in-post/2022-06-11-JavaScript-Sandbox-Mechanism-and-Its-History-Teaser.png
  caption: "©️hijiangtao"
---

## 前言

随着微前端的不断发展、被更多的团队采用，越来越多开始对沙箱这个概念有所了解。**沙箱，即 sandbox，意指一个允许你独立运行程序的虚拟环境，沙箱可以隔离当前执行的环境作用域和外部的其他作用域，外界无法修改该环境内任何信息，沙箱内的东西单独运行，环境间相互不受影响。**本文计划谈谈微前端的 JavaScript 隔离，即沙箱机制的古往今来。

要实现一个 JavaScript 沙箱，可以有很多种分类方式，比如按照具体的实现方式来区分，就至少包含如下：

1. 基于 Proxy 快照存储 + window 修改的实现
2. 基于 Proxy 代理拦截 + window 激活/卸载的实现
3. 基于普通对象快照存储的 window 属性 diff 实现
4. 基于 iframe + 消息通信的实现
5. 基于 ShadowRealm 提案的实现
6. 基于 with + eval 的简单实现
7. ……

![](/assets/in-post/2022-06-11-JavaScript-Sandbox-Mechanism-and-Its-History-1.png )

本文主要考虑沙箱机制在实现时所用到的主要 Web 技术，计划大致分为四类实现方案分别介绍，结合之下，本文目录如下：

1. 前言
2. 基于 Proxy 实现的沙箱机制
    1. 简要谈谈 Proxy API
    2. 基于 Proxy 的沙箱实现考虑
    3. 结合微前端框架 qiankun 介绍两类沙箱实现
3. 基于属性 diff 实现的沙箱机制
4. 基于 iframe 实现的沙箱机制
    1. 基于 Proxy 及 diff 的沙箱机制边界考虑
    2. 利用 iframe 实现沙箱机制的几点思考
    3. 一段 iframe 沙箱的示例代码
5. 各类沙箱机制对比
6. 基于 ES 提案 ShadowRealm API 介绍
    1. 什么是 JavaScript 的运行环境实例
    2. ShadowRealm API 简介
    3. ShadowRealm 的错误捕获与更多应用场景
7. 总结
8. 参考

希望通过我自己的项目实践、阅读代码、提案梳理等方式对 JavaScript 隔离（沙箱机制）进行系统整理，其中会结合一些开源框架的实现来辅助解读，但不会针对微前端框架深入介绍，也不会就某一个沙箱机制的具体细节实现（比如如何构建闭包环境、属性读取、DOM 操作等众多边界处理）进行剖析。

如果你想了解关于 CSS 样式隔离的内容可以搜索 Shadow DOM 相关内容进一步查阅；如果你想了解微前端的主子应用加载、运行机制，可以参考 single-spa 文档、qiankun 文档、ShadowRealm 提案等内容；如果你想了解文中涉及的一些概念与 API 用法可以在 MDN 进行搜索查阅，大部分均有对应介绍。

本文在撰写中尽力保证文章的思路流畅和通俗易懂，但由于个人正从事基于微前端方案的开发，可能有些概念会潜意识认为所有读者均已了解，未能详尽每个涉及名词的统一处理或解释，此处针对一些通用的概念进行铺垫：

1. **主应用**：在微前端方案中，区分主子应用，主应用通常负责全局资源的加载、隔离、控制运行，用户登陆信息等全局状态的管理等等，也被称为基座、微前端全局环境等；
2. **子应用**：微前端方案中可以独立加载运行的一个 Web 应用，通常需要一个完备的隔离环境供其加载，文中提到的沙箱激活/卸载也是为其服务，也称微应用；
3. **沙箱**：意指一个允许你独立运行程序的虚拟环境，沙箱可以隔离当前执行的环境作用域和外部的其他作用域，外界无法修改该环境内任何信息，沙箱内的东西单独运行，环境间相互不受影响，英文对应 sandbox，此名词常与 JavaScript 隔离一起使用；
4. **qiankun**：一款开源方案，基于 [single-spa](https://github.com/CanopyTax/single-spa) 的[微前端](https://micro-frontends.org/)实现库；

以下开始正文。

## 基于 Proxy 的沙箱机制

Proxy 是当下做 JavaScript 隔离用到的最主要的手段之一，接下来我们详细说说基于 Proxy 的沙箱机制。

### 简要谈谈 Proxy API

**Proxy 是一个标准 Web API，在 ES6 版本中被推出，这个对象可以用于创建一个对象的代理，从而实现基本操作的拦截和自定义（如属性查找、赋值、枚举、函数调用等）**，我们可以通过一个简单的例子来解释说明 Proxy 的作用：

```jsx
const handler = {
    get: function(obj, prop) {
        return prop in obj ? obj[prop] : 37;
    }
};

const p = new Proxy({}, handler);
p.a = 1;
p.b = undefined;

console.log(p.a, p.b);      // 1, undefined
console.log('c' in p, p.c); // false, 37
```

在上例中，我们定义了一个 handler，其中包含一个 get 拦截器，它的作用是在属性查找时，如果对象对应属性不存在时返回数值 37，此后我们通过 Proxy 对一个空对象进行了代理，分别打印了其中的 a、b、c 属性，可以发现，其中 c 属性由于不存在而返回了 37。

![](/assets/in-post/2022-06-11-JavaScript-Sandbox-Mechanism-and-Its-History-3.jpeg )

### 基于 Proxy 的沙箱实现考虑

既然 Proxy 可以用于代理对象，那么我们同样可以用其代理 window——Web 应用运行中最重要的上下文环境。每个 Web 应用都会与 window 交互，无数的 API 也同样挂靠在 window 上，要达到允许独立运行的微前端环境，首先需要 window 隔开。

在采用 Proxy 作为沙箱机制方案时，主要还是基于 get、set、has、getOwnPropertyDescriptor 等关键拦截器对 window 进行代理拦截（如下如有涉及代码，我们主要关注 get 与 set 两类拦截器）。为了让沙箱的代理拦截完备，除了 window 外，我们通常都需要关注几方面，比如一些难以代理（或者说没必要代理）的 Web API，如 Array、Number、Promise 等，此外还需要保证通过 with、eval、new Function 等方式执行的代码作用域不会逃逸，动态加载的 JavaScript 代码也算一个。

谈到这里，我们首先看看通过 Proxy 进行属性查找时的一些处理逻辑。除了在拦截器中进行一些常规的无需拦截 case 判断外，还需要对 Symbol.unscopables 属性 get 拦截器的返回值做些定义，以方便 with 等方式下代码的执行作用域正常处理，如下是个简单的例子：

```jsx
const unscopables = {
  Array: true,
  Object: true,
  String: true,
  Promise: true,
  requestAnimationFrame: true,
  ...
};

// ...

{
  get: (target: FakeWindow, p: PropertyKey): any => {
    // Symbol.unscopables 属性
    if (p === Symbol.unscopables) return unscopables;

    // 无需拦截的 Web API
    if (p === 'eval') {
      return eval;
    }
  }
}
```

如上代码中，关于 eval 的拦截判断很好理解，这里我们停下简要介绍一下一个概念： `Symbol.unscopables`。

`Symbol.unscopables` 属性，指用于指定对象值，其对象自身和继承的从关联对象的 with 环境绑定中排除的属性名称。当我们在 `unscopables` 对象上将属性设置为 true，将使其 *unscopable* 并且因此该属性也将不会在词法环境变量中出现。我们来看一个简单例子，以了解其效果：

```jsx
const object1 = {
  property1: 42
};

object1[Symbol.unscopables] = {
  property1: true
};

with (object1) {
  console.log(property1);
  // expected output: Error: property1 is not defined
}
```

*注：在微前端环境下，通常需要对一些全局变量与属性进行更全面的梳理，此处可以参考 qiankun 的实现 [https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/proxySandbox.ts#L255](https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/proxySandbox.ts#L255)* 

### 结合微前端框架 qiankun 介绍两类沙箱实现

微前端框架 qiankun 中一共存在三类沙箱，基于 Proxy 实现方式不同以及是否支持多实例，可以分为两类：

1. 支持子应用单实例沙箱（LegacySandbox）
2. 支持子应用多实例沙箱（ProxySandbox）

当我们只针对全局运行环境进行代理赋值记录，而不从中取值，那么这样的沙箱只是作为我们记录变化的一种手段，而实际操作仍在主应用运行环境中对 window 进行了读写，因此这类沙箱也只能支持单实例模式，qiankun 在实现上将其命名为 LegacySandbox。

我们先假设我们的沙箱实现上包含这几个变量（此处以 qiankun 实现为例）：

```jsx
/** 沙箱期间新增的全局变量 */
private addedPropsMapInSandbox = new Map<PropertyKey, any>();

/** 沙箱期间更新的全局变量 */
private modifiedPropsOriginalValueMapInSandbox = new Map<PropertyKey, any>();

/** 持续记录更新的(新增和修改的)全局变量的 map，用于在任意时刻做 snapshot */
private currentUpdatedPropsValueMap = new Map<PropertyKey, any>();
```

这类沙箱的激活与卸载思路可以通过如下两个函数代码解释。首先是激活函数，当沙箱被激活时，我们通过曾经记录好的更新过的全局变量（也可以称为快照）来还原子应用所需要的沙箱环境（即上下文）：

```tsx
active() {
  if (!this.sandboxRunning) {
    this.currentUpdatedPropsValueMap.forEach(
       (v, p) => this.setWindowProp(p, v)
    );
  }

  this.sandboxRunning = true;
}
```

等到需要卸载时，沙箱需要做两件事，一是将子应用运行时修改过的全局变量还原，另一个是删除子应用运行时新增的全局变量：

```jsx
inactive() {
  this.modifiedPropsOriginalValueMapInSandbox.forEach(
    (v, p) => this.setWindowProp(p, v)
  );
  
  this.addedPropsMapInSandbox.forEach(
    (_, p) => this.setWindowProp(p, undefined, true)
  );

  this.sandboxRunning = false;
}
```

*注：详尽代码可以参考 qiankun 实现 [https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/legacy/sandbox.ts#L51-L73](https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/legacy/sandbox.ts#L51-L73)*

**如上所述，LegacySandbox 的思路在于虽然建立了沙箱代理，但在子应用运行过程中，所有的赋值仍旧会直接操作 window 对象，代理所做的事情就是记录变化（形成快照）；而针对激活和卸载，沙箱会在激活时还原子应用的状态，而卸载时还原主应用的状态，以此达到沙箱隔离的目的。**

LegacySandbox 由于会修改 window 对象，在多个实例运行时肯定会存在冲突，因此，该沙箱模式只能在单实例场景下使用，而当我们需要同时起多个实例时，ProxySandbox 便登场了。

ProxySandbox 的方案是同时用 Proxy 给子应用运行环境做了 get 与 set 拦截。沙箱在初始构造时建立一个状态池，当应用操作 window 时，赋值通过 set 拦截器将变量写入状态池，而取值也是从状态池中优先寻找对应属性。由于状态池与子应用绑定，那么运行多个子应用，便可以产生多个相互独立的沙箱环境。

由于取值赋值均在建立的状态池上操作，因此，在第一种沙箱环境下激活和卸载需要做的工作，这里也就不需要了。关于状态池的设计，可以参考代码 [https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/proxySandbox.ts#L81](https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/proxySandbox.ts#L81)

![](/assets/in-post/2022-06-11-JavaScript-Sandbox-Mechanism-and-Its-History-4.jpeg )

## 基于属性 diff 的沙箱机制

由于 Proxy 为 ES6 引入的 API，在不支持 ES6 的环境下，我们可以通过一类原始的方式来实现所要的沙箱，即利用普通对象针对 window 属性值构建快照，用于环境的存储与恢复，并在应用卸载时对 window 对象修改做 diff 用于子应用环境的更新保存。在 qiankun 中也有该降级方案，被称为 SnapshotSandbox。当然，这类沙箱同样也不能支持多实例运行，原因也相同。

这类方案的主要思路与 LegacySandbox 有些类似，同样主要分为激活与卸载两个部分的操作。

```tsx
// iter 为一个遍历对象属性的方法

active() {
  // 记录当前快照
  this.windowSnapshot = {} as Window;
  iter(window, (prop) => {
    this.windowSnapshot[prop] = window[prop];
  });

  // 恢复之前的变更
  Object.keys(this.modifyPropsMap).forEach((p: any) => {
    window[p] = this.modifyPropsMap[p];
  });

  this.sandboxRunning = true;
}
```

在激活时首先将 window 属性遍历存储起来（作为还原 window 所需的快照），然后在 window 上恢复子应用所需的属性变更，是的，直接修改 window 对象。

```tsx
inactive() {
  this.modifyPropsMap = {};

  iter(window, (prop) => {
    if (window[prop] !== this.windowSnapshot[prop]) {
      // 记录变更，恢复环境
      this.modifyPropsMap[prop] = window[prop];
      window[prop] = this.windowSnapshot[prop];
    }
  });

  this.sandboxRunning = false;
}
```

而等到卸载时，将此时 window 上所包含的属性遍历存储起来（作为以后还原子应用所需的快照），然后从先前保存的 window 对象中将环境恢复。

由于未使用到 Proxy，且只利用 Object 的操作来实现，这个沙箱机制是三类机制中最简单的一种。

*注：SnapshotSandbox 参考代码 [https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/snapshotSandbox.ts](https://github.com/umijs/qiankun/blob/dbbc9acdb0733b3ab28e0470c969d65b57653ff0/src/sandbox/snapshotSandbox.ts)*

## 基于 iframe 的沙箱机制

### 基于 Proxy 及 diff 的沙箱机制边界考虑

不论是基于 Proxy 还是 diff，其沙箱机制的方案都是通过模拟和代理来实现一个环境隔离的沙箱，只是所有 API 不同。由于是模拟，因此不可避免的在使用中需要考虑一些边界 case，我们简单来看两个问题。首先看一段代码：

```tsx
var foo = "hello";

function foo() {}
```

如上代码大家都很熟悉，在无沙箱环境下两种写法可以自动提升为 `[window.foo](http://window.foo)`，但是 Proxy 沙箱下这类代码就需要注意，由于代码执行作用域发生了变更，所以生效的环境不再是全局 window，这时通过 proxy 的 get 拦截器大概率就会返回 undefined，于是便会产生疑问“我本地运行是有值的，为什么到微前端里就 undefined 了呢？”，对于后者，诸如 qiankun 框架中可以通过 window.proxy 获取对应上下文来取值达到目的，但前者由于限制，必须显式的定义为 window.foo 否则无法获取。

对于不了解微前端框架的同学来说，这无疑会增加了解成本。对于同类问题，我们再看一个问题描述：

> 我的子应用新建了一个 iframe 来做些 JavaScript 逻辑，但在里面通过 window.parent.xxx 无法获取子应用 window 上的全局变量？
但这个变量实际上是存在的，我在子应用中可以把它打印出来的。
> 

造成这个问题的原因类似，由于 iframe 中的 JavaScript 不在沙箱里执行，会读到外面真实的 window 上。而当你在子应用中定义了一个全局变量，方法是在沙箱里面拦截定义的，也就是方法实现写在沙箱里、方法调用读在沙箱外。解决方法有两种：

1. 把变量做白名单处理，强制写在外面真实的 window 上；
2. 在 iframe 中用 window.parent.proxy 来获取对应的变量；

以上所述的问题源自模拟，既然是模拟那么就可能存在难以抹平的边界情况，那么有没有更好一些的解决方案呢，iframe 虽然有那么多缺点，但他就是浏览器原生提供的一个隔离环境呢，有可能吗？

常规思路下，大家想到的 iframe 都是在页面内起一个 iframe 元素，然后将需要加载的 url 填入进行加载，由于体验上的割裂，这种方式并不为大家认可，这也是为什么基于 Proxy 和 diff 的沙箱机制被提出的原因。

让我们再想想，iframe 都有什么优点？

1. 使用简单，一个 url 即可，不需要其他微前端方案那样手动写入很多钩子以适配在微前端环境中的运行；
2. 利用浏览器的设计，可以实现样式、DOM、JavaScript 代码执行的完美隔离；
3. 页面原则上可以起无数多个 iframe 标签来加载应用，所以可以实现多应用共存；
4. 通过 iframe 实现的沙箱可以绕过 eval 执行的限制，比如当我们的代码中使用了原生 es modules 的写法时（eval 中不支持 `import()`），如果不做转译，代码便会抛出异常；

基于这个思路，如果我们不用 iframe 来加载应用，而是只将其作为一个 JavaScript 运行环境，问题是不是就解决了？

### 利用 iframe 实现沙箱机制的几点思考

我们知道，iframe 标签可以创造一个独立的浏览器级别的运行环境，该环境与主环境隔离，并有自己的 window 上下文；在通信机制上，也可以利用 postMessage 等 API 与宿主环境进行通信。具体来说，在执行 JavaScript 代码上，我们不需要做什么处理，但是要让 iframe 成为符合我们要求的沙箱，还需要重新设计。其中，和沙箱机制有关的几点包含：

- **应用间运行时隔离；**
- **应用间通信；**
- **路由劫持；**

我们一一来看看。**首先，是对运行环境的代理与隔离**，这也是大多数沙箱必备的基础之一。由于利用了 iframe，所以我们几乎不用担心 JavaScript 的代码运行会给沙箱外环境带来什么影响，因为在 iframe 中运行的 JavaScript 代码都是直接操作 iframe 的 window 上下文，但这里却需要考虑另一方面：如何将一些必要的操作传递出沙箱，因此也需要用到 Proxy 来做一些共享，比如路由、DOM操作等，这涉及到 location、history 等对象。通过将主应用环境下的对象透传给 iframe 中 JavaScript 使用，可以保证子应用在执行操作时，返回前进等操作可以同步到浏览器 top level 层面。此外，对于动态执行的 JavaScript 脚本（比如动态增加一个 script 元素），也需要单独考虑限制作用域，以使 script 中代码在执行时可以对应上具体的全局环境，这里可以通过为 script 包裹一层以锁定作用域内的部分全局变量取值：

```tsx
const scriptInstance = document.createElement('script');
const script = `(function(window, self, document, location, history) {
    ${scriptString}\n
  }).bind(window.proxyWindow)(
    window.proxyWindow,
    window.proxyWindow,
    window.proxyShadowDom,
    window.proxyLocation,
    window.proxyHistory,
  );`;

scriptInstance.text = script;
document.head.appendChild(scriptInstance);
```

其他方面，由于上文已经提到过关于 Proxy 对 get/set 拦截器的实现，本部分不再赘述。

**刚刚提到的 DOM 操作，我们在这里多做一些介绍。**当 JavaScript 操作 DOM 时，我们肯定需要让其中的操作透传到 iframe 外部进行实现，因为 iframe 里面我们不构建 DOM。如果想在隔离方案上一步到位，这里可以使用 Shadow DOM 作为样式隔离的方案，来构建子应用渲染所需的 DOM 结构，而回到 DOM 操作本身，依旧是通过 Proxy 对 iframe document 进行拦截和替换来实现的，这里依据你的样式隔离方案，来决定 document 究竟是指向主应用中的 Shadow DOM Root 节点，还是其他代理的 document 对象。此外，诸如 MutationObserver 这类的操作也需要通过代理保证在主应用上进行。

**其次，再说说通信。**一个完备的微前端方案需要考虑主子应用间的通信（与沙箱的通信），这样才可以对框架内的的全局状态或者子应用状态进行感知与响应，我们从同域 iframe 环境看起。

通过如下代码我们可以构建一个同域的 iframe 元素，此时，iframe 内外通信并不会存在障碍，通过各自 window 便能方便的获取对应属性值；因为是同域环境，从中取出对应的`contentWindow`便可以对 iframe 内容属性进行随意读取，而与此同时还与外部环境隔离。

```jsx
const iframe = document.createElement('iframe',{url:'about:blank'});
document.body.appendChild(iframe);
const sandboxGlobal = iframe.contentWindow;
```

而如果要单独构建通信机制，也可以利用自定义 props、event 等方式实现，或者通过 Web API 诸如 postMessage 或者 BroadcastChannel 来实现，关于此部分我在曾经的一篇文章中稍有提及，感兴趣的话可以查看《**[Service Worker 实践指南](https://hijiangtao.github.io/2021/04/13/Service-Worker-Practical-Notes/)**》。

**说回路由状态**，要保证 JavaScript 沙箱环境内与主应用路由状态保持一致，我们有两种实现方案：

1. 让 JavaScript 沙箱内路由变更操作在主应用环境生效；
2. 同步沙箱内路由变化至主应用环境；

其中，针对第一种情况，我们需要做的是将诸如 location 、history 等变量代理到沙箱环境中，在这种情况下，因为我们不关心 iframe 自身的路由变化，便可以自由设置 src 属性，比如 `about:blank` 的方式来构建 iframe，而在沙箱实现上我们可以通过前述的 Proxy 来拦截实现。

但稍微考虑下实际生产环境便会发现，第一种情况存在的限制较多，最基本的便是对沙箱内网络请求发送的处理，所以这就需要我们考虑第二种情况的实现，在这种操作下，我们的路由变化会同步到 iframe 上下文，所以我们需要针对 iframe 路由添加一个监听器，在监听到变化时处理主应用的路由，以实现两者路由同步。当然，这种情况下，我们需要针对主应用所在域名设计一个 iframe 的同域方案，比如同一域名+自定义 path 或者 hash 的实现就很简单易懂，这样也不存在跨域限制，此处不再展开。

### 一段 iframe 沙箱的示例代码

以下简单写了一个 iframe 沙箱的实现伪代码，核心依旧在 window 隔离与共享对象的处理上，主要的实现手段依旧是完善 Proxy 的 get/set 拦截器：

```jsx
class SandboxWindow {
    constructor(context, frameWindow) {
        return new Proxy(frameWindow, {
            get(target, name) {
                if (name in context) {
                    return context[name];
                } else if(typeof target[name] === 'function' && /^[a-z]/.test(name) ){
                    return target[name].bind && target[name].bind(target);
                } else {
                    return target[name];
                }
            },
            set(target, name, value) {
                if (name in context) {
                    return context[name] = value;
                }
                target[name] = value;
            }
        })
    }
}

// 需要全局共享的变量
const context = { 
    document: window.document, 
    history: window.history, 
    location: window.location,
}

// 创建 iframe
const userInputUrl = '';
const iframe = document.createElement('iframe',{url: userInputUrl});
document.body.appendChild(iframe);
const sandboxGlobal = iframe.contentWindow;

// 创建沙箱
const newSandboxWindow = new SandboxWindow(context, sandboxGlobal); 
```

但需要注意的是，iframe 方案下，JavaScript 沙箱只是其中一部分，还需要通过完备的 HTML/JavaScript 代码拆分等方案辅助达到微前端环境的目的，这部分实现可参考 kuitos 的开源库 [import-html-entry](https://github.com/kuitos/import-html-entry)；同样的，之前的几类沙箱方案也需要考虑与这些方案组合。

*注：在实现上，如果需要区分 iframe 与主应用环境，可以通过代码 `window.parent !== window` 进行判断。*

![](/assets/in-post/2022-06-11-JavaScript-Sandbox-Mechanism-and-Its-History-6.png )

## 各类沙箱机制对比

通过对比 Proxy 的两类实现、属性 diff 的一种实现以及 iframe 实现方案，可以发现几类沙箱的主要特点在于（以下部分方案用 qiankun 中对三类沙箱的命名方式作为沙箱机制名称）

|  | 多实例运行 | 语法兼容 | 不污染全局环境（主应用） |
| --- | --- | --- | --- |
| LegacySanbox | ❌ | ❌ | ❌ |
| ProxySandbox | ✅ | ❌ | ✅ |
| SnapshotSandbox | ❌ | ✅ | ❌ |
| iframe | ✅ | ✅ | ✅ |

## 基于 ES 提案 **ShadowRealm 实现**

**ShadowRealm 是一个 ECMAScript 标准提案，旨在创建一个独立的全局环境，它的全局对象包含自己的内建函数与对象（未绑定到全局变量的标准对象，如 Object.prototype 的初始值），有自己独立的作用域**，方案当前处于 stage 3 阶段。提案地址 [https://github.com/tc39/proposal-shadowrealm](https://github.com/tc39/proposal-shadowrealm)

### 什么是 JavaScript 的运行环境实例

谈及提案之前，我们简单来看看什么是 Realm，下面是 Alex 附上的一个例子：

```tsx
<body>
  <iframe>
  </iframe>
  <script>
    const win = frames[0].window;
    console.assert(win.globalThis !== globalThis); // (A)
    console.assert(win.Array !== Array); // (B)
  </script>
</body>
```

在前面 iframe 沙箱机制中我们也有介绍，由于每个 `iframe` 都有一个独立的运行环境，于是在执行时，当前 html 中的全局对象肯定与 `iframe`的全局对象不相同（A），类似的，全局对象上的 `Array`与 `iframe` 中获取到的 `Array` 也不同（B）。

这就是 realm，一个 JavaScript 运行环境（JavaScript platform）实例：包含其所必须的全局环境及内建函数等。

### ShadowRealm API 简介

ShadowRealm API 由一个包含如下函数签名的类实现：

```tsx
declare class ShadowRealm {
  constructor();
  evaluate(sourceText: string): PrimitiveValueOrCallable;
  importValue(specifier: string, bindingName: string): Promise<PrimitiveValueOrCallable>;
}
```

**每个 `ShadowRealm` 实例都有自己独立的运行环境实例，在 realm 中，提案提供了两种方法让我们来执行运行环境实例中的 JavaScript 代码：**

- `.evaluate()`：同步执行代码字符串，类似 `eval()`。
- `.importValue()`：返回一个 `Promise` 对象，异步执行代码字符串。

通过 evaluate 执行代码与 eval 类似，比如：

```tsx
const sr = new ShadowRealm();
console.assert(
  sr.evaluate(`'ab' + 'cd'`) === 'abcd'
);
```

但存在一些细微的差别，比如执行作用域、调用方式以及传值类型等。例如，如果 `.evaluate()` 返回一个函数，则该函数会被包装，这样我们就可以从外部调用它，而逻辑在 ShadowRealm 中运行，我们可以通过观察下面的 console.assert 来效果：

```tsx
globalThis.realm = 'incubator realm';

const sr = new ShadowRealm();
sr.evaluate(`globalThis.realm = 'child realm'`);

const wrappedFunc = sr.evaluate(`() => globalThis.realm`);
console.assert(wrappedFunc() === 'child realm');
```

说到另一个 API `.importValue()`，我们可以利用它导入一个外部模块，它会通过一个 Promise 异步返回其执行内容，和 `.evalute()`函数一样，这个函数被包装，以允许我们在外部调用，而实际代码在 ShadowRealm 中执行，我们可以看看下面这个例子，很好的解释了这个 API 的功能：

```tsx
// main.js
const sr = new ShadowRealm();
const wrappedSum = await sr.importValue('./my-module.js', 'sum');
console.assert(wrappedSum('hi', ' ', 'folks', '!') === 'hi folks!');

// my-module.js
export function sum(...values) {
  return values.reduce((prev, value) => prev + value);
}
```

### ShadowRealm 的错误捕获与更多应用场景

ShadowRealm API 提案暂未针对错误捕获做详细设计，整体看上去比较简洁，因为这些在未来还有可能变化，以下为 Alex 针对当前提案下代码执行错误给出的两个例子，可以看出其中并不包含错误的原始调用堆栈等：

```tsx
> new ShadowRealm().evaluate('someFunc(')
SyntaxError: Unexpected end of script

> new ShadowRealm().evaluate(`throw new RangeError('The message')`)
TypeError: Error encountered during evaluation
```

由于没有实践经历，这里仅对 ShadowRealm 提案及相关概念进行了简要介绍，但可以看出，这个提案的落地可能对于一个更完美的 JavaScript 沙箱设计有所帮助，当然，这个提案的应用场景远不止此，比如：

- **Web 应用诸如 `IDE` 或绘图等程序可以运行第三方代码，允许其以插件或者配置的方式引入；**
- **利用 `ShadowRealms` 建立一个可编程环境，来运行用户的代码；**
- **服务器可以在 `ShadowRealms` 中运行第三方代码；**
- **在 ShadowRealms 中可以运行测试运行器（Test Runner），这样外部的 JS 执行环境不会受到影响，并且每个套件都可以在新环境中启动（这有助于提高可复用性），这种场景类似于微前端的 JavaScript 沙箱；**
- **网页抓取和网页应用测试等；**

![](/assets/in-post/2022-06-11-JavaScript-Sandbox-Mechanism-and-Its-History-5.png )

## 总结

如果按照沙箱机制在实现时所用到的主要 Web 技术不同，当下已经论证、开源或者存在实现可能性的 JavaScript 沙箱机制可以分为以下几类：

1. 基于 ES6 API Proxy 实现
2. 基于属性 diff 实现
3. 基于 iframe 实现
4. 基于 ES 提案 ShadowRealm 实现

本文基于个人项目实践、阅读代码梳理等方式对每类沙箱机制均进行了介绍，部分引用了 qiankun 的代码实现，部分写了伪代码解释，部分引用了最新 ECMAScript 提案示例，但仍未能详尽每一处细节，比如没有针对微前端框架深入介绍，也不会就某一个沙箱机制的具体细节实现（比如如何构建闭包环境、属性读取的边界处理等）进行剖析，但这些对于从更大的层面了解微前端机制都不可或缺。

如果你想了解关于 CSS 样式隔离的内容可以搜索 Shadow DOM 相关内容进一步查阅；如果你想了解微前端的主子应用加载、运行机制，可以参考 single-spa 文档、qiankun 文档、ShadowRealm 提案等内容；如果你想了解文中涉及的一些概念与 API 用法可以在 MDN 进行搜索查阅，大部分均有对应介绍。

![](/assets/in-post/2022-06-11-JavaScript-Sandbox-Mechanism-and-Its-History-2.jpeg )

## 参考

1. [https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Proxy](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Proxy)
2. [https://single-spa.js.org/](https://single-spa.js.org/)
3. [https://github.com/umijs/qiankun](https://github.com/umijs/qiankun)
4. [https://tsejx.github.io/javascript-guidebook/standard-built-in-objects/fundamental-objects/symbol/unscopables/](https://tsejx.github.io/javascript-guidebook/standard-built-in-objects/fundamental-objects/symbol/unscopables/) 
5. [https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Symbol/unscopables](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Symbol/unscopables)
6. [https://juejin.cn/post/6981374562877308936](https://juejin.cn/post/6981374562877308936)
7. [https://micro-frontends.org/](https://micro-frontends.org/)
8. [https://2ality.com/2022/04/shadow-realms.html](https://2ality.com/2022/04/shadow-realms.html) 
9. [https://github.com/tc39/proposal-shadowrealm](https://github.com/tc39/proposal-shadowrealm)
10. [https://qiankun.umijs.org/guide](https://qiankun.umijs.org/guide)