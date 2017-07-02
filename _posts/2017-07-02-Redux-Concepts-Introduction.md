---
title: 知识点整理 - Redux 介绍与基础
layout: post
thread: 177
date: 2017-07-02
author: Joe Jiang
categories: documents
tags: [React, Redux, 框架]
excerpt: 此处以 Redux 为例，总结如何利用其设计思想以及实践经验，来使得应用的 state 管理变得容易。
---

随着 JavaScript 单页应用开发日趋复杂，越来越多的 state （状态）需要在前端进行管理。

>  这些 state 可能包括服务器响应、缓存数据、本地生成尚未持久化到服务器的数据，也包括 UI 状态，如激活的路由，被选中的标签，是否显示加载动效或者分页器等等。

为了高效的管理 state 而不是简单的在全局上新建变量，开发者需要捋清 model/view 之间的关系，以降低前端开发的复杂性。此处以 Redux 为例，总结如何利用其设计思想以及实践经验，来使得应用的 state 管理变得容易。

## 核心概念

Redux 的核心概念第一点则是 **state** 的表示，你可以用一个对象来表示应用的 state (可以看成 model) 但不能直接修改他（没有 setter）。这一步定义的内容可以看成是用于控制页面效果、动画的一些开关状态。

```
{
    todo: [],
    name: 'me'
}
```

想要修改 state 中的数据只能通过发起 **action** 来实现（这样做的好处就是可以清晰的知道应用中到底发生了什么）， action 也是一个普通对象，用来描述将要发生什么。在 action 中我们需要存储发生事件的描述以及用于更新 state 的属性数据，比如：

```
{ type: 'ADD_TODO', text: 'Go to swimming pool' }
```

那么如何接收 action 并更新返回新的 state 呢？用 **reducer** 函数。它接收 state 和 action，在内部处理后并返回新的 state。考虑到应用的复杂性，我们可以分别编写 reducer 分别独立地操作 state tree 的不同部分。

## Redux 三大原则

* **单一数据源**：整个应用的 state 被储存在一棵 object tree 中，并且这个 object tree 只存在于唯一一个 store 中。
* **State 是只读的**：唯一改变 state 的方法就是触发 action，action 是一个用于描述已发生事件的普通对象。
* **使用纯函数来执行修改**：为了描述 action 如何改变 state tree ，你需要编写 reducers。

## 基础

### Action

我们约定，action 内必须使用一个字符串类型的 type 字段来表示将要执行的动作。多数情况下，type 会被定义成字符串常量。除了 type 字段外，对象结构完全由自己决定。但是需要注意的是应该尽量减少在 action 中传递的数据。

为了了解生成 action，还需要知道 action 创建函数，该函数只是简单的返回一个 action，这样做将使 action 创建函数更容易被移植和测试。例如：

```
function addTodo(text) {
  return {
    type: ADD_TODO,
    text
  }
}
```

当你把 action 创建函数结果传给 dispatch() 方法，即可发起一次 dispatch 过程，例如：

```
dispatch(addTodo(text))
```

在使用过程中可能用到的工具包括 `connect()`， `bindActionCreators()`

### Reducer

reducer 就是一个纯函数，接收旧的 state 和 action，返回新的 state。通过 reducer，我们不仅可以修改 state 还可以借机初始化 state。

针对 action 的处理我们需要注意：不要修改 state，且在 default 情况下返回旧的 state。

在使用过程中可能用到的工具包括 `combineReducers()`

### Store

在知道了如何用 reducer 来根据 action 更新 state 后，需要进一步了解的就是 store —— 将它们联系到一起的对象。store 具有以下职责：

* 维持应用的 state；
* 提供 `getState()` 方法获取 state；
* 提供 `dispatch(action)` 方法更新 state；
* 通过 `subscribe(listener)` 注册监听器;
* 通过 `subscribe(listener)` 返回的函数注销监听器。

### 数据流

Redux 应用中的数据的生命周期遵循四个步骤：

* 调用 `store.dispatch(action)`
* redux store 调用传入的 reducer 函数
* 根 reducer 应该把多个子 reducer 输出合并成一个单一的 state 树
* Redux store 保存了根 reducer 返回的完整 state 树

### 搭配 react

结合 react 开发其中比较重要的一点在于如何设计组件层次结构。结合 react 可以知道在组件层次方面，主要需要考虑两点：展示组件和容器组件，当然不好区分的组件可以划分为其他组件。