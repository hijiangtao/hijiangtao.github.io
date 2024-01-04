---
title: 基于一次应用卡死问题所做的前端性能评估与优化尝试
layout: post
thread: 294
date: 2024-01-03
author: Joe Jiang
categories: Document
tags: [electron, 调试, debug, React, 卡顿问题, 性能评估, 前端优化]
excerpt: 在上个月，由于客户反馈客户端卡死现象但我们远程却难以复现此现象，于是我们组织了一次现场上门故障排查，并希望基于此次观察与优化，为客户端开发提供一些整体的优化升级。当然，在尝试过程中，也发现了不少适用于通用前端项目开发的一些故障排查与性能评估的手段，于是总结此文，希望可以对读者有所帮助。
toc: true
header:
  image: ../assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-Teaser.png
  caption: "©️hijiangtao"
---

## 问题背景

在上个月，由于客户反馈客户端卡死现象但我们远程却难以复现此现象，于是我们组织了一次现场上门故障排查，并希望基于此次观察与优化，为客户端开发提供一些整体的优化升级。当然，在尝试过程中，也发现了不少适用于通用前端项目开发的一些故障排查与性能评估的手段，于是总结此文，希望可以对读者有所帮助。

需要注意，在本文中所指的客户端均指通过 electron 开发出来的客户端应用，所以本质上还是属于前端应用开发范畴，关于 electron 框架的介绍可以参考 [https://www.electronjs.org/](https://www.electronjs.org/)

## 现象复现

在客户那边，反馈过来的现象表现为“系统 CPU 资源未被占满，但客户端在操作一段时间后便卡死无法响应”。起初，我们根据用户的描述尝试在本地复现，但却没有收获；此外，由于客户的网络限制，也不方便频繁的远程连接以方便我们查看现场现象。

考虑到可能是机器部分配置较差（比如显卡）或者网络、机器自身运行软件过多等原因，而我们的开发机器由于要支持本地编译与调试，一般都是顶配机器，于是我们尝试让本机变慢，以模拟复现其现象，简单来看，存在如下几个思路：

1. 卡死/卡顿复现：最好在虚拟机中操作，虚拟机本身分配资源相对主机较少，再加上 chrome devtools 配置增加延时 throttle 时长，比如500ms；电脑中再开启几个占用 CPU 性能的软件，比如 vscode，firefox 等等，可以一定程度上模拟卡顿现象，不一定稳定复现卡死现象；
2. 操作卡顿复现：通过频繁的交互操作，制造同时多个请求并发发出的现象，加上 performance 录制，可以一定程度加重渲染进程的负担，以模拟操作卡顿现象；

## 定位问题

来到客户现场，作为首要尝试，当然是通过 `top` 、`netstat` 或者 `cat /proc/cpuinfo` 等命令来查看系统的 CPU、内存与网络的运行状态，但不出所料，这些信息在当前看来并没有太大异常。

由于从系统本身的一些状态上没能找到突破口，我们将目光转向客户端本身，希望在更小的范围内定位问题所在。通过 devtools 查看 netowork、performance 以及 DOM 渲染状态，我们只能发现貌似有些响应耗时过长的接口调用以及较长时长的 long task 任务，这当然需要我们进一步排查。

说到调试排查，首推的当然是 console.log 大法，为了让 log 打印复用，一个简单的技巧是写一个 HOC，以节省在每个地方都写一遍 debug log 的代码：

```typescript
export const debugRender = <T=any>(BaseComponent: FC<T>) => (props:any) => {
  console.log(`Rendering ${BaseComponent.name} at ${performance.now()}`);
  return <BaseComponent {...props} />;
}
```

通过添加一些基于经验的断点信息打印，我们发现一些 Modal/Drawer 的显示/隐藏会较为明显的加重页面卡顿甚至到卡死现象上，通过排查代码实现以及查看对应 UI 库的 API 实现，会发现其中 Modal/Drawer 等组件上在隐藏时触发了其对应 DOM 节点的卸载，而在显示时又会重新渲染与插入，由于这些任务都需要在浏览器的渲染进程执行，而当 DOM 节点过多时频繁的节点装载与卸载便会对页面渲染效率产生影响。

于是，第一步便是定位到主要的几个组件，避免其在隐藏时执行 DOM 卸载（保留节点），通过这一步改变，我们直接消除了卡死现象。

## 部分优化尝试

为了更好的模拟卡顿现象，我们可以通过 chrome devtools 中 performance tab 中的 CPU throttling 配置来模拟卡顿：

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-0.png)

在 Windows 高配版机器上，我们先将 CPU 降低配置 4x 情况，然后录制一段操作，从下图中可以看出有明显的任务执行耗时过长 & CPU 占用过高的现象：

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-1.png)


以耗时最长的任务中占用时间最长的活动为例，我们搜索一下该关键词可以查到一个讨论 [https://stackoverflow.com/questions/39916356/reacterrorutils-invokeguardedcallback-in-react-fires-event-repeatedly-in-ie-brow](https://stackoverflow.com/questions/39916356/reacterrorutils-invokeguardedcallback-in-react-fires-event-repeatedly-in-ie-brow)，简单来说，我们可以尝试优化点击事件不进行冒泡来减少事件的触发，例如：

```
event.stopPropagation();
```

通过优化该事件，我们可以一定程度上对事件在 DOM 上的传递 & 调用进行优化，但说到交互事件模型，我们在实际优化尝试时，也需要对 Web API 有些了解，以防用错 Web API 而南辕北辙，比如一个常见的面试题就是对比 Event 上暴露的两个 API `stoppropagation` 与 `stopimmediatepropagation` 的用途区别，可别用错了。关于此细节可以参考回答 [https://stackoverflow.com/questions/5299740/stoppropagation-vs-stopimmediatepropagation](https://stackoverflow.com/questions/5299740/stoppropagation-vs-stopimmediatepropagation)

但假如我们需要针对不同事件切换不同的 API 该怎么办呢，这里可以简单写个函数封装一下，再加个类型守卫来实现，比如如下的伪代码通过传入一个点击回调事件，而后在实际事件触发时通过判断 Event 类型从而调用不同 API 以达到优化效果：

```typescript
const isMouseEvent = (event: Event | MouseEvent): event is MouseEvent => 'stopImmediatePropagation' in event

export const stopPropagationWrapper = (handleClick: Func) => (event: Event | MouseEvent) => {
  if (isMouseEvent(event)) {
    event.stopImmediatePropagation();
  } else {
    event.stopPropagation();
  }

  handleClick(event);
};

```

我们继续针对卡顿问题的调用情况进行梳理。从录制的执行队列中选取较长的一个 long task 进行分析，可以看到在模拟卡顿时排名靠前四的调用任务分别如下：

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-2.png)


其中 fsync 函数调用时间占第一，而拆分 fsync 的活动调用可以看到主要调用了 fsyncSync：

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-3.png)


此处未对 fsync 进一步分析以确定优化策略，但对于 fsync 的作用可以参考如下一段描述：

> fsync 函数只对由文件描述符 filedes 指定的单一文件起作用，并且等待写磁盘操作结束，然后返回。fsync 可用于数据库这样的应用程序，这种应用程序需要确保将修改过的块立即写到磁盘上。
>

这说明应用中有可能有数据库读写操作，也可能有文件读写操作，所以如果要进一步优化的话可以从这个方面展开，囿于时间限制，我们继续探索可行的快捷优化方案。

在最初解决卡死问题时，我们看到了过多的 DOM 卸载/挂载现象，但回到前端框架本身，我们也可以用一些常规的手段来减少组件不必要的 rerender，这些方案通常通过仔细阅读 React 文档便可以略知一二，比如在必要的地方增加 memo 以减少不必要的渲染执行，一个示例代码如下：

```jsx
import {
  FC,
  memo,
} from 'react';

const Detail: FC = ({}) => {
  return (
    <div>Detail</div>
  );
}

export default memo(Detail);
```

此外，还有什么写法可能会影响 Web 应用的性能呢？闭包。

我们检查了客户端代码仓库里的两个列表文件，发现其中组件包含过多闭包变量，大多数写法是在一些函数定义中直接从上层作用域引用了一些变量进行操作，而不是通过参数传入函数，这样的数据/函数在使用后无法及时释放内存空间，可能会对内存存在持续占用的现象，因此，这也是优化的方向之一。

## 后续可能的优化空间

在一些 long task 任务的分析中，我们还可以具体定位到代码来进行优化，这里再举一个例子。

通过录制卡死情况下的堆栈调用情况，可以发现有一个 2.7s 任务中包含很多活动，如 Minor GC、react event、fsync、ReactElement 等等，其中 mergeProps 函数调用耗时250+ms。

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-4.png)


针对这些函数调用，有些可能是 React 内部实现 API，有些可能是 UI 库 API，所以要想一一优化，也需要逐个分析，看是优化代码的调用与响应方式，还是合并组件 props 的传递与调用。

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-5.png)


此外，通过监控 layers 变化情况，也会发现一些 slow scroll rects，这在 chrome 中都会通过红色区域以标注出来，通过定位这些在滚动中可能会造成缓慢的区域并检查代码，也有提升应用性能的可能性，因此，也是优化方向之一。

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-6.png)

比如针对我们的场景，通过调整 layer 布局，可以看到虽然 layer 层级很多，但是主要的 slow scroll rects 区域还是集中在主内容区，即分页列表本身。

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-7.png)

## Electron 注意事项

本来，为了可以针对这些数据进行持续的分析，想从 performance 中将数据下载下来，以便之后有空时继续调试，但由于 Electron 的某些限制或者说是错误，我们目前无法保存 performance tab 下的性能数据到本地以便进行更深入的分析和查看。如果有涉及到 electron 开发的场景，需要注意下这个问题。问题现象详见 issue [https://github.com/electron/electron/issues/39818](https://github.com/electron/electron/issues/39818)

## 优化效果

为了提高客户端的性能和用户体验，我们进行了一系列的优化措施。首先，我们分析了卡死现象，包括客户端出现卡死时的 CPU 占用率/JS 堆栈/DOM 节点数情况、虚拟机运行状态等。然后，我们尝试了一些优化措施，如去除Modal/Drawer的 unmountOnExit 配置等。接下来，我们梳理了卡顿问题调用情况，分析了排名靠前的四个调用任务。为了减少组件不必要的rerender，我们在必要的地方增加了 memo。此外，我们还提到了组件中包含过多闭包的问题，以及右键菜单卡顿问题的排查。

由于客户端需求迭代过快，在前端技术上没有做较多的数据监控、性能评估等建设，这都对我们评估用户体验与定位问题产生了影响；此外，由于生产工具链的不完善，在生产环境进行定位与调试都给我们带来了比较大的挑战与时间消耗，这也会是我们持续要跟进与解决的一些开发链路的效率提升工作之一。

通过这些优化，我们希望能够解决客户端卡死问题并改善卡顿现象，并提高用户的使用体验。当然，从具体效果上来看，我们确实在如下两个方面进行了改善：

1. 交互性能上，问题页面在切换时，即便将 CPU 降低配置 4x 情况下也再无出现卡死现象，卡顿现象有减轻趋势；
2. 渲染效率上，从数据上看，频繁出现的 500ms-700ms long task 已减为当前观察范围内没有超过 300ms 的 long task，代码执行效率上有较大提升；

以下为优化后效果采样图：

![](/assets/in-post/2024-01-03-Debug-Notes-of-Electron-App-8.png)

## 简要总结

通过分析与优化尝试，我们解决了客户端卡死问题，并改善了卡顿现象，但其中暴露出一些编程规范与用法不够优雅的问题还需要在日常中持续完善，这也是这次优化未尽事宜，需要在未来不断排期以彻底解决。

当然，此中涉及到的一些调试与问题定位方法，也不仅局限于客户端的问题排查，而是通用 Web 应用性能评估时调试可以用到的手段，而更深入的研究则要开始涉猎到框架代码等内部函数调用的地方了，这也是本文未涉及部分，有待后续继续研究与定位。