---
title: 结合 React Fiber 结构与 chrome 插件，谈谈无侵入自动化表单的技术尝试
layout: post
thread: 292
date: 2023-11-30
author: Joe Jiang
categories: Document
tags: []
excerpt: 
toc: true
header:
  image: ../assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-Teaser.png
  caption: "©️hijiangtao"
---

> 本文亦有分享 Slides，详见 <https://hijiangtao.github.io/slides/s-Common/Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-chrome-plugins.pdf> 或扫二维码查看。

![二维码](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-Slides.png)

## 前言

作为一名前端工程师，不论你处于什么业务方向，肯定都与表单打过交道，当然如果你是服务端、产品、测试同学，想必也早已接触过表单这类场景。让我们试想一下，如果研发需求的功能测试依赖一个复杂表单的填写而得以继续，那么频繁的表单填写在研发自测和 QA 验证过程中就会占用过多碎片化的时间，此类需要频繁执行以生成测试数据或推进执行流程的事情，简单一想貌似规则可循、可以被工具替代。既然可以自动化来实现，那为什么还要我们一个个手动点呢？

不要着急，这篇文章的目的，就是想与大家分享一下这样一个自驱型技术产品的诞生故事。这其中既包括技术与实现细节，同时也涵盖这个产品的设计过程。

## 问题初探：表单场景究竟麻烦在哪

首先，让我们来看看表单，到底麻烦在哪了。

从前端开发者视角看去，表单是由一个表单组件包裹多个表单控件组成，用 JSX 语法层层嵌套实现，当需求开发完成后需要自测时，最直接且简便的用法当属用 initialValue 属性或者 form 实例上提供的 API 方法（比如 `setFieldsValue` API）来赋值；但是等代码部署到开发/测试环境，想要这么灵活的变更初始数据就不太可能了，频繁的发布部署流程会让变更测试成本直线上升。

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-0.png)

另一方面，在产品测试等同学的眼中，表单并不涉及到代码形态，只是一个有很多输入项的丰富 UI 页面，通过点击、输入、选择等操作，来完成数据的输入，是一个需要消耗一定时间的流程。而当表单项很多时，花费的时间也直线上升。

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-1.png)

通过抽象，我们可以列举几个从前端角度观察到的例子，以方便我们更熟悉填写表单时涉及到的各类复杂场景：

1. 对接完产品需求，终于把字段与各类逻辑组装进表单，想自测看看交互效果，简单来做，可以代码写一些 mock 拦截来实现
2. 功能提测后，为了测试新功能，需要先填一遍复杂表单，造数据，但这个时候 Form 里嵌套 FormList，完成功能开发就用了很久了，现在造数据还需要再来一遍
3. 每次填写表单，由于某个字段是存储主键，每次填写不能完全一致，即在特定规则下随机生成一些字符串，可能是年龄、中文姓名或者邮箱等
4. 登陆态过期太频繁，一过期就要重新输入用户名密码再点击按钮登陆一遍，当然，现有的工具中我们可以通过 chrome 的记住密码来实现，但我们仍然需要在填充完成后点击确定按钮进行登录操作

总结来看，以上这些场景按照用途可以汇总成以下几类：

1. 研发功能开发自测
2. 测试数据构造
3. 符合规则的个性化填写
4. 日常操作，比如登陆

## 技术调研：开源社区与插件是市场的已有技术实现

在明确了需求之后，在是否需要动手之前，我们需要先调研看看有没有现有技术或者工具可以帮助我们达到目的，毕竟，反复造轮子在哪里都是被抵触的。开发工具的目的是为了解决问题，如果问题已经有了解决方案，我们就不需要自己去实现了。

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-2.png)

回顾一下表单需求，仔细想想，可能存在几种解决思路呢？首先是辅助工具，比如浏览器插件这种，作为业务开发无感知，无接入成本（无侵入式）的技术方案，其特征也显而易见：

1. 不依赖 UI 框架，通用性强
2. 无需具体业务感知，对业务代码无侵入，接入成本低
3. 识别与填充成功率低，支持控件有限，尤其在当下很多 UI 库针对不同表单控件会有自己的实现（以及事件拦截），只能支持简单的 input 框以及一些 radio 场景
4. 随机 mock 数据能力有限，在自定义规则集中生成
5. 不支持页面上表单与事件连续操作，比如派发表单填充后的点击行为

既然无侵入式方案能力有限，那么做些侵入式改造是不是会更加有用呢？比如，通过约定 url 传参或者业务代码内嵌入开关，来允许用户显式控制代码的执行逻辑，这样用户可以在打开页面时对表单做指定的赋值操作，对实际点击行为后触发的回调函数进行调用，这是一个大概的实现思路，其特点罗列如下：

1. 基于具体表单结构定制，通用性弱
2. 完美填充，支持全部表单控件
3. 不支持页面上表单与事件连续操作
4. 填充数据变更时需重新打包，成本高昂

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-3.png)

由于辅助工具和侵入式改造都或多或少有些缺陷，熟悉自动化测试的同学肯定会说，这些要做的事情，自动化测试方案不是早就覆盖了吗？是的，自动化测试方案是一个完美的解决方案，基于 puppeteer 或者 e2e 框架，不仅方案通用性强，填充也很准确，但是从开发者以及使用者的便利性角度来看，基于这类方案用户在上手使用时存在成本，研发要实现对应功能成本也相对较高。还记得初衷么，我们是希望有一个可以解决表单场景的工具，我们既希望他能解决一些复杂场景的问题，同时也希望他简单易用成本低。

回顾一下，我们调研过的几个实现思路，能不能把无侵入式改造与高识别率结合？即“取其精华，取其糟粕”。

## 需求拆解：我们究竟需要一个怎样的工具

做完现有技术调研后，我们来将需求做拆解，从远期来看，我们当然希望有一个不侵入用户代码，却可辅助用户自动化识别页面内存在表单、支持用户自定义 mock 规则生成表单数据进行填充的工具，来帮助我们在各类表单场景中提效。

具体来看，我们将需求细化，希望覆盖这么几个场景：

1. **接入零成本：**开发者不用对当前业务代码做任何改造，零代码侵入便可使用
2. **表单准确填充：**当下很多方案基于 DOM 解析与处理进行实现，通过这类方案进行表单填充，会因为组件库自身实现做了事件拦截或者托管，而导致表单填充很多情况无法生效的情况，而用户在意的大多数字段却无法触发
3. **表单准确识别：**准确获取与开发者完全一致的表单结构，防止 DOM 解析不准确的情况，大多数工具只能解析简单的 input、radio 等场景
4. **填充内容自定义：**支持 mockjs 类语法对填充数据进行自定义构造
5. **支持事件派发：**在登陆场景下，一般除了填充表单外，还可以直接替用户点击「确定」进行登录操作，工具支持增加事件派发，将表单填充和点击等事件一体化流程处理

拆解了需求，就可以规划一步步来实现，将产品需求做成一期、二期不断迭代的交付节奏，我们在这一块遵循和正常产品研发相同的节奏。第一步，当然是识别表单结构，因为只有准确识别到表单，后续的数据构造、表单填充、事件派发才有意义。

## 技术方案：如何准确识别表单

怎么识别才准确呢？侵入式的方式肯定是最准确的，但我不能每个组件都包一个 wrapper 吧，如果一个项目有100处表单的调用，那我就需要做100次改造，而且从前面的调研来看，我们还是希望从无侵入方案入手，因此，如何提高无侵入识别方案的准确性，成了一个需要攻克的难题。这个时候，让我们先来看看一个面试常被问到的点，从 React Fiber 说起。

我们都知道，Virtual DOM 是对真实 DOM 的模拟，也是一棵树，通过 Diffing 算法和老树对比，得到差值，再同步给视图要修改哪些部分。Fiber 是对 React 核心算法的重构，Fiber 对象是一个用于保存「组件状态」、「组件对应的 DOM 的信息」、以及「工作任务 (work)」的数据结构，Fiber node 是 Fiber 对象的实例。

先不看 React Fiber 树的实现方式，如果我们自己来实现一遍，大抵会想到两种思路：数组或者链表。数组的组织方式可能更符合我们的直觉，但是想一想在这个树如果我们要查找遍历、调整结构（分割、替换节点）或者随时重建新树，链表的方式似乎更加灵活，事实上，React 也是这么做的。

### Fiber 树的组织与遍历

我们先整体来看一下遍历过程。Fiber 树的遍历需要一个指针指向当前遍历到的节点，workInProgress 就是这个指针，进一步是 performUnitOfWork 的 next 指针，遍历在指针为 null 的时候结束。

next 先从 beginWork 获取，如果有则直接将当前遍历的指针 workInProgress 指向 next；如果没有，就到 completeUnitOfWork 中进一步处理。这里 beginWork 是“递”，即不停向下找到当前分支最深叶子节点的过程；completeUnitOfWork 是“归”，即结束这个分支，向右或向上的过程。

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-4.png)

*关于 performUnitOfWork 的更完整代码详见 [https://github.com/facebook/react/blob/c1d414d75851aee7f25f69c1b6fda6a14198ba24/packages/react-reconciler/src/ReactFiberWorkLoop.new.js#L2051-L2077](https://github.com/facebook/react/blob/c1d414d75851aee7f25f69c1b6fda6a14198ba24/packages/react-reconciler/src/ReactFiberWorkLoop.new.js#L2051-L2077)*

在递归过程中，beginWork 过程比较简单，大体上是在深度优先搜索中，对遍历到的节点进行 component 更新处理，然后返回第一个字节点，这里就不介绍，我们看看 performUnitOfWork 的具体逻辑。

在“归”的过程中，我们需要避免遍历造成死循环，即若我们向下遍历时遇到的节点，在向上过程中出现时，我们不应该让其再次进入 beginWork。

completeUnitOfWork 内部又创建了一层循环，搭配一个向上的新指针 completeWork，然后循环该指针节点，如果有兄弟节点就更新当前遍历到的节点指针，返回交还给外层循环；没有就向上到父节点继续循环，直到新指针为空（即已经到达根节点）；最后再处理标记最顶层的根节点处理状态。

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-5.png)

*关于 completeUnitOfWork 的更完整代码详见 [https://github.com/facebook/react/blob/c1d414d75851aee7f25f69c1b6fda6a14198ba24/packages/react-reconciler/src/ReactFiberWorkLoop.new.js#L2173-L2271](https://github.com/facebook/react/blob/c1d414d75851aee7f25f69c1b6fda6a14198ba24/packages/react-reconciler/src/ReactFiberWorkLoop.new.js#L2173-L2271)*

整个遍历流程示意图可以参考[《如何理解 React Fiber 架构？ - 几木的回答》](https://www.zhihu.com/question/49496872/answer/2517859568)中的贴图

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-6.png)

### **Fiber 树的构建与 Diffing**

> Fiber 树是边创建边遍历的，每个节点都经历了「创建、Diffing、收集副作用（要改哪些节点）」的过程。其中，创建、Diffing要自上而下，因为有父才有子；收集副作用要自下而上最终收集到根节点。—— [https://www.zhihu.com/question/49496872/answer/2517859568](https://www.zhihu.com/question/49496872/answer/2517859568)
>

在 React 中，同时最多会存在两颗树，一个是当前被渲染出来的 Fiber 树，称为 current，另一个是正在构建的 Fiber 树，称为 workInProgress，上文中提到的遍历均在后者身上进行。

找到两棵任意的树之间的最小的差异是一个复杂度为 O(n3) 的问题，React Diff 算法通过一些假设，最终达到了接近 O(n) 的复杂度。

这里提到的假设主要包含以下几点：

1. 假设一：不同类型的两个元素将产生不同的树，遇此情况时 React 会拆卸原有节点并且建立新的节点（触发重建流程）。
2. 假设二：默认情况下，在 DOM 节点的子节点上递归时，React 只会同时遍历两个子节点列表，并在存在差异时生成一个更新操作。
3. 假设三：用户给每个子节点提供一个 key，标记它们“是同一个”，在有 key 的情况下能保证二者都复用仅做移动，但无 key 就会造成两个不必要的卸载重建。

### 副作用与收集过程

Fiber 树的构建以及 Diffing 都是同时进行的，不是说构建完 Fiber 树之后再开始 Diffing 寻找差距。同样的，两棵树 Diffing 的过程中，就已经决定了哪些旧节点需要复用、删除、移动，哪些新节点需要创建，这些操作会以 Effect 的形式挂到节点上，他们随着 Diffing 过程同步完成收集。

由于需要保证所有后代节点的副作用信息，副作用的收集有两个约定：

1. 副作用是向上收集的，每次在 completeUnitOfWork 中循环经过一个节点时，会同时合并后代节点的 effectList 以及自己的 effectList；
2. 副作用同样采用链表的方式存储，并通过 fisrtEffect —> nextEffect —> lastEffect 的关系串联起来，但此链表与 Fiber 树的链表结构没有关系；

关于副作用以及 Host 实例更新的更多细节，本文不再深入，此时，让我们重新回到最初的目标，即识别表单上来。

### 利用 Fiber 识别表单

关于 React Fiber 相关的知识补充，我们就讲到这里。接下来，我们看看如果利用 Fiber 来识别表单，这主要分为三步：

1. 从 DOM 中找到目标 form 元素
2. 获取有效的 Fiber 实例
3. 读取目标属性值，解析表单结构

下方代码解释了我们如果从指定 form 元素中提取 Fiber 实例的过程。

```jsx
/**
 * 获取 Fiber 实例
 * @param dom
 * @param traverseUp
 */
function getFiberInstance(dom: HTMLElement, traverseUp = 0) {
  if (!dom) {
    return null
  }

  const key = Object.keys(dom).find((key) => {
    return (
      key.startsWith("__reactFiber$") || // react 17+
      key.startsWith("__reactInternalInstance$")
    ) // react <17
  })
  const domFiber = dom[key]
  if (domFiber == null) return null

  // react <16
  if (domFiber._currentElement) {
    let compFiber = domFiber._currentElement._owner
    for (let i = 0; i < traverseUp; i++) {
      compFiber = compFiber._currentElement._owner
    }
    return compFiber._instance
  }

  // react 16+
  const getCompFiber = (fiber) => {
    let parentFiber = fiber.return
    while (typeof parentFiber.type == "string") {
      parentFiber = parentFiber.return
    }

    return parentFiber
  }
  let compFiber = getCompFiber(domFiber)
  for (let i = 0; i < traverseUp; i++) {
    compFiber = getCompFiber(compFiber)
  }

  return compFiber
}
```

当我们拿到 Fiber 实例后，那么 UI 库的部分属性就可以通过 Fiber 实例暴露出来，比如 setFieldsValue 等，此时，我们即可以轻松的拿到表单本身的结构，此部分暂略。

## 工具完善：构造数据与表单填充

我们再来回顾一下，对于表单来说，我们都需要构造些什么数据来作为填充数据：

1. 固定取值：填入，每次填入相同值即可，无需特殊处理
2. 规则取值：每次填入的字段都需要取一个符合相同规则但取值不同的数值
3. 指定集合：针对单选、多选等场景，需要从指定选项中随机选取一个填入
4. 时间取值：在有效的时间范围内随机生成一个时间串
5. 布尔取值：checkbox、radio 等组件实际取值为 true/false 二选一
6. ……

让人开心的是，除了基于已知选项集合的数据和固定值外，其他类型数据都可以通过类似 mock.js 的规则来描述生成规则，而固定值和已知集合，我们暂且先让用户自己手动填写就好了。

需要注意的是，除了表单填充外，我们最开始还提到希望在表单完成填充后能够辅助用户对按钮进行点击操作，即事件派发能力，所以在表单填充上，我们至少要解决这两个问题：

1. 多步操作：表单存在字段之间的联动，无法一次完成赋值
2. 填充与事件组合：表单填充完下一步可能就是点击事件

关于这一部分，更多是在产品功能完善上的思考，而非技术调研上的难点，下面贴一张流程图来解释工具的工作流程：

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-7.png)

## 工程开发：功能集成与插件开发

在完成了需求收集、技术调研以及分步骤拆解实现后，貌似大部分难题我们都获得了答案，接下来要做的便是另一方面，在一个单独的工具中将这些功能集成，当下最合适的方式应该是通过浏览器插件来实现它，插件形式上小巧，但借助 chrome API 以及共享 DOM，我们又能拥有强大的能力。

![Untitled](/assets/in-post/2023-11-30-Technical-Attempt-of-Non-intrusive-Automated-Forms-with-React-Fiber-and-Chrome-Plugins-8.png)

### 现代化的插件开发体验

开发过浏览器插件的同学，想必都感受过 chrome 开发文档与当下现代开发方式格格不入的开发体验，手写 JavaScript、HTML 以及 manifest 声明文件，貌似开发流程还停留在刀耕火种的时代，作为一名开发者，我不仅希望我的产品体验良好，也希望开发流程更加现代化，具体来说，对于插件开发，开发工作流至少得满足如下几个方面吧：

1. 代码构建打包
2. TypeScript + React 支持
3. 插件声明 manifest.json 自动生成
4. 跨 script 持久化存储
5. 不同 script 间 (content script / background / popup) 通信

幸运的是，我们也不用完全从头改造插件的开发工作流，当下已经有开源框架在做相关的事情了，我们可以直接用上，比如 [plasmo](https://www.plasmo.com/)，他使得我们可以像开发 React 项目那样开发一个 chrome 插件。

当然，我们确实需要额外关注几点，考虑到工具开发过程中遇到的几个难点，我这里着重强调下插件通信以及插件安全。

### 插件通信方案简介

通信是这个工具绕不开的一个功能点。举几个例子，比如 popup UI 和 content script 之间需要通信，以控制 content UI 的展示与否；比如插件脚本与 MAIN 的通信，以控制在页面内执行特定的脚本以收集一些信息；比如 content script 与 background script 之间的通信，以控制插件在后台需要做的一些计算处理逻辑等等。

为了实现这些功能，需要选择合适的通信方案。好在大多数 Web 通信方案都可以直接用在插件上，此外，插件还可以额外调用一些 chrome API 来触发特定的通信事件，简单来说，存在这么几种方案：

1. 通用的通信机制，通过 postMessage 广播消息
2. 非广播传递，MessageChannel 传递消息
3. 通过 chrome API 进行消息通信
   1. chrome.devtools. inspectedWindow.eval
   2. chrome.tabs.sendMessage
   3. chrome.tabs.connect
   4. chrome.extension.getBackgroundPage
   5. ……

其中，关于跨线程通信相关的技术方案，我在《Service Worker 实践指南》一文中有详细介绍，感兴趣的同学可以查阅 [https://hijiangtao.github.io/2021/04/13/Service-Worker-Practical-Notes/](https://hijiangtao.github.io/2021/04/13/Service-Worker-Practical-Notes/)

### 插件安全问题汇总

由于浏览器对插件安全的设计，插件虽然可以通过 HTML/JavaScript/CSS 来编码开发，但其在运行上还存在一些安全限制，从我的开发过程来看，具体有这么三个方面值得注意：

1. 插件权限：chrome 插件在运行中涉及到的权限调用需要在 manifest permissions 中声明
2.  script 对 chrome API 权限：content scripts 中只允许如下几类 chrome.***.api 调用
    1. chrome.extension(getURL , inIncognitoContext , lastError , onRequest , sendRequest)
    2. chrome.i18n
    3. chrome.runtime(connect , getManifest , getURL , id , onConnect , onMessage , sendMessage)
    4. chrome.storage
3. 共享 DOM 权限：content scripts UI 部分不支持针对 DOM 的 Expando 属性的共享

### 工具功能集成

解决完插件开发的问题后，我们接下来需要做的便是，作为一个产品经理，去思考我们的产品在面世之前需要完成哪些功能的集成，比如：

1. 支持表单自定义 mock 规则生成填充数据
2. 不同规则适配不同页面地址
3. 配置数据的导入与导出
4. 表单识别后的规则提取与拆分
5. 支持自定义事件组合
6. ……

## 总结

表单类形态在开发场景中非常常见，如果研发需求的功能测试依赖一个复杂表单的填写而得以继续，那么频繁的表单填写在研发自测和 QA 测试中就会占用过多碎片化的时间，此类需要频繁执行（以生成测试数据或推进执行流程）但规则可循的场景如果可以被工具替代，那么将可以极大的提升产研研发效率。

从远期目标来看，我们需要有一个不侵入用户代码，但可辅助用户自动化识别页面内存在表单，并支持用户自定义 mock 规则生成表单数据进行填充的工具，涵盖各类表单场景。

相比现有社区的方案中，有几个明显的优势/改善点，使得该类工具具有广泛的应用场景：

1. 不依赖代码侵入，对开发人员无接入成本；
2. 识别准确率高，理论情况下可以达到100%，不受前端框架以及 UI 开源库的选型影响；
3. 数据构造灵活，可以完全自定义规则，生成中英文、数字、日期等各类数据，做到随机+灵活；
4. 支持事件派发，支持多步骤表单填充，拥有组合能力；
5. 使用者无需额外的软件安装，通过浏览器插件的方式使用，简单易用，成本低；

但从当下做起，通过技术调研，我们发现当下社区中并不存在一个低成本、无侵入且高准确性的工具，于是借助 React Fiber 结构以及浏览器插件的能力，我们先期实现了一个无侵入式、高准确性的表单识别和填充工具，更多功能会在后续迭代中不断完善。

## 参考

1. [https://xyy94813.gitbook.io/x-note/fe/react/react-diff-algorithm](https://xyy94813.gitbook.io/x-note/fe/react/react-diff-algorithm)
2. [https://www.zhihu.com/question/49496872/answer/2517859568](https://www.zhihu.com/question/49496872/answer/2517859568)