---
title: Tree Shaking 简介
layout: keynote
thread: 265
date: 2021-06-25
author: Joe Jiang
categories: Presentation
tags: [2021, webpack, ESM, tree-shaking, SideEffects, 优化, 摇树]
excerpt: 本周分享会上，给团队同学分享了 Tree Shaking 的相关内容。哈哈是的，这已经不是一个新鲜事了……
iframe: https://hijiangtao.github.io/slides/s-YFD/Tree-Shaking.html
---

> [扫码或点击链接查看完整 Slides](https://hijiangtao.github.io/slides/s-YFD/Tree-Shaking.html)

[![](/assets/in-post/2021-06-25-Tree-Shaking-qrcode.png)](https://hijiangtao.github.io/slides/s-YFD/Tree-Shaking.html)

本周分享会上，给团队同学分享了 Tree Shaking 的相关内容。哈哈是的，这已经不是一个新鲜事了，最开始是想分享 esbuild 的，但最新杂事多，期间没有准备太多资料，所以让我偷一次懒吧。

以下为目录，主要包含概念介绍、模块化标准介绍、SideEffects、webpack 相关内容以及一些最佳实践。

1. WHAT DOES TREE-SHAKING ACTUALLY MEAN?
2. ES MODULES VS. COMMONJS
3. SCOPE AND SIDE EFFECTS
4. OPTIMIZING WEBPACK
5. WEBPACK VERSION 3 AND BELOW
6. AVOID PREMATURE TRANSPILING
7. TREE-SHAKING CHECKLIST

TREE SHAKING 是什么？Tree Shaking 通常用于描述移除 JavaScript 上下文中的未引用代码 (dead-code)。它依赖于 ES2015 模块系统中的静态结构特性，例如 import 和 export。

这个术语和概念兴起于 ES2015 模块打包工具 rollup。

模块化这个话题在 ES6 之前是不存在的，因此这也被诟病为早期 JavaScript 开发全局污染和依赖管理混乱问题的源头。

常见的模块化方案包含这几种：

* CommonJS
* AMD
* CMD
* UMD
* ES Modules

CommonJS 比 ES Modules 规范早了几年。它旨在解决 JavaScript 生态系统中缺乏对可重用模块的支持。CommonJS 有一个 require() 函数，它根据提供的路径获取外部模块，并在运行时将其添加到作用域中。

说到这里，就得说说运行时执行的特点，主要包含以下两点：

1. 无法在编译阶段确定产物
2. 你可以在代码中随意使用 require，比如全局、函数、if/else 条件语句中等等

从 CommonJS 规范中吸取教训，ES Modules 标准采用 import/export 关键字对模块进行处理，且不依赖运行时执行结果。

ES Modules 标准的特点

1. 只能作为模块顶层的语句出现
2. import 的模块名只能是字符串常量
3. import binding 是 immutable的

……
