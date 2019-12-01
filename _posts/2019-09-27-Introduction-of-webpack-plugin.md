---
title: 让我们来写个 webpack 插件
layout: keynote
thread: 234
date: 2019-11-30
author: Joe Jiang
categories: Presentation
tags: [2019, webpack, plugin, 插件, 前端]
excerpt: 对 webpack plugin 的简要介绍。
iframe: https://hijiangtao.github.io/slides/s-Fliggy/Introduction-of-webpack-plugin.html#/

---

> [扫码或点击链接查看完整 Slides](https://hijiangtao.github.io/slides/s-Fliggy/Introduction-of-webpack-plugin.html#/)

[![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-qrcode.png)](https://hijiangtao.github.io/slides/s-Fliggy/Introduction-of-webpack-plugin.html#/)

时至今日，webpack 已成为前端打包工具链中不可或缺的一环，如若只是配置使用，那么了解到如下几类即可满足大部分需求：

* Entry：入口，Webpack 执行构建的第一步将从 Entry 开始，可抽象成输入。
* Module：模块，在 Webpack 里一切皆模块，一个模块对应着一个文件。Webpack 会从配置的 Entry 开始递归找出所有依赖的模块。
* Chunk：代码块，一个 Chunk 由多个模块组合而成，用于代码合并与分割。
* Loader：模块转换器，用于把模块原内容按照需求转换成新内容。
* Plugin：扩展插件，在 Webpack 构建流程中的特定时机注入扩展逻辑来改变构建结果或做你想要的事情。
* Output：输出结果，在 Webpack 经过一系列处理并得出最终想要的代码后输出结果。

整体来说，webpack 可以看作是基于事件流的编程实现，其核心概念便是插件机制了，webpack 自身便是利用这套机制构建出来的，你可以将其看成一个插件集合。Tappable 是实现 webpack 插件机制一个很基础的类，但本文不做过多解释，详情可以移步 <https://github.com/webpack/tapable> 阅读源码。我们简单介绍下 webpack 插件以及如何上手。

*注1：最准确的描述可以直接移步 webpack 官方文档（中文文档移步印记中文），由于 webpack 文档在描述时遵循最小可用原则，故很多细节其实是需要实践和进一步阅读源码才可以理解的，本文的目的即是想通过一件事将一些零散的内容串在一起，用于学习记录。*

*注2: 本文在编写时参考的 API 为 webpack 4.x 版本*

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-1.png)

如下是我们正常使用 webpack 插件所需要编写的代码，分成两步：

* 通过一个命令例如 `npm install --save-dev build-time-analysis-webpack-plugin` 将插件加入依赖；
* 在 `webpack.config.js` 文件头部引入插件，在配置 `plugins` 字段中添加一个插件实例；

而插件的用处，对开发者来说就是可以接触到 webpack 构建流程中的各个阶段并劫持做一些代码处理，对使用者来说则是我们可以通过各类插件实现诸如自动生成 HTML 模版 (`html-webpack-plugin`)、自动压缩图片 (`imagemin-webpack-plugin`) 等功能。

> 插件向第三方开发者提供了 webpack 引擎中完整的能力。使用阶段式的构建回调，开发者可以引入它们自己的行为到 webpack 构建流程中。 —— webpack 中文文档

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-2.png)

说完了插件可以干什么，那想开发一个插件，我们首先需要知道一个 webpack 插件由什么构成。一个插件应该包含：

* 一个 JavaScript 函数或 JavaScript 类，用于承接这个插件模块的所有逻辑；
* 在它原型上定义的 `apply` 方法，会在安装插件时被调用，并被 webpack compiler 调用一次；
* 指定一个触及到 webpack 本身的事件钩子，即下文会提及的 hooks，用于特定时机处理额外的逻辑；
* 对 webpack 实例内部做一些操作处理；
* 在功能流程完成后可以调用 webpack 提供的回调函数；

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-3.png)

基于已知的逻辑，我们可以看看 webpack 官方提供的一个 Hello World 例子，它的作用是在 webpack 编译完成时向命令行输入一段字符串 `Hello World!`，代码的上部分是插件实现，下部分是配置应用方式。

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-4.png)

我们基于上面的例子，将其中一些关键的概念解释一下。首先是 compiler。这个对象包含了 webpack 环境所有的的配置信息，包含 options，loaders，plugins 这些信息，这个对象在 webpack 启动时候被实例化，它是全局唯一的，可以简单地把它理解为 webpack 实例。

为了在指定生命周期做自定义的一些逻辑处理，我们需要在 compiler 暴露的钩子上指明我们的 tap 配置，一般这由一个字符串命名和一个回调函数组成。一般来说，compile 过程中会触发如下几个钩子：

1. beforeRun
2. run
3. beforeCompile
4. compile
5. make
6. seal

假设我们想在 compiler.run() 之前处理逻辑，那么就要调用 beforeRun 钩子来处理： 

```
compiler.hooks.beforeRun.tap('testPlugin', (comp) => {
  // ...
});
```

而钩子 entryOption 表示在 webpack 选项中的 entry 配置项处理过之后，执行该插件，钩子 compilation 表示在编译创建之后，执行插件，更详细的 compiler 钩子列表可参见官方文档。

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-5.png)

说完 complier 我们再来看看 compilation。compilation 对象包含了当前的模块资源、编译生成资源、变化的文件等。当 webpack 以开发模式运行时，每当检测到一个文件变化，一次新的 compilation 将被创建。compilation 对象也提供了很多事件回调供插件做扩展。通过 compilation 也能读取到 compiler 对象。两者的区别在于，前者代表了整个 webpack 从启动到关闭的生命周期，而 compilation 只代表一次单独的编译。

同样的，compilation 也对应有不同的钩子给开发者调用，具体可参见官方文档。

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-6.png)

不论是 compiler 还是 compilation 阶段，从上述举例的几个事件钩子中都可以看出，貌似是存在不同的类型。所以最后，我们再来看看这一块。

> 根据插件所能触及到的 event hook(事件钩子)，对其进行分类。每个 event hook 都被预先定义为 synchronous hook(同步), asynchronous hook(异步), waterfall hook(瀑布), parallel hook(并行)，而在 webpack 内部会使用 call/callAsync 方法调用这些 hook。 —— webpack 中文文档

其中同步钩子有以下几种，你在查询文档的时候可以在钩子名称后面找到对应的类型：

* SyncHook(同步钩子) - SyncHook
* Bail Hooks(保释钩子) - SyncBailHook
* Waterfall Hooks(瀑布钩子) - SyncWaterfallHook

异步钩子如下：

* Async Series Hook(异步串行钩子) - AsyncSeriesHook
* Async waterfall(异步瀑布钩子) - AsyncWaterfallHook
* Async Series Bail - AsyncSeriesBailHook
* Async Parallel - AsyncParallelHook
* Async Series Bail - AsyncSeriesBailHook

如果你不进一步追究，那么按照如下所示的方式对不同钩子进行 tap 处理即可，其中 tap 方法用于同步处理，异步方式则可以调用 tapAsync 方法或 tapPromise 方法。

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-7.png)

至此，我们理解了一个 webpack 插件的构成。现在需求来了，在 npm 或者 GitHub 上我们可以很快找到各种 loader 耗时计算或者 webpack 各生命周期耗时计算的插件，如果只是想看看我们自己的业务代码构建耗时呢，如何实现这个需求呢。

由于篇幅所限，本文不再展开详述，我写了一个 webpack 插件 `build-time-analysis-webpack-plugin`，感兴趣的同学可以移步 [GitHub](https://github.com/hijiangtao/build-time-analysis-webpack-plugin) 查看。

更多开发 API 上的内容可移步参考文章/文档。

![](/assets/in-post/2019-11-29-Introduction-of-webpack-plugin-8.png)

## 参考

* <https://webpack.js.org/contribute/writing-a-plugin/>
* <https://webpack.docschina.org/api/compiler-hooks/>
* <https://webpack.docschina.org/api/compilation-hooks/>
* <https://webpack.js.org/api/compilation-object/>
* <https://stackoverflow.com/questions/47540440/can-i-get-the-dependency-tree-before-webpack-starts-to-build>
* <https://github.com/webpack/webpack.js.org/blob/master/src/content/contribute/writing-a-plugin.md>
* <https://github.com/stephencookdev/speed-measure-webpack-plugin>
* <https://webpack.js.org/api/#plugins>
* <https://webpack.docschina.org/>
* <https://segmentfault.com/a/1190000012840742>
* <https://hijiangtao.github.io/slides/s-Fliggy/Introduction-of-webpack-plugin.html#/>