---
title: \[译\] JavaScript 打怪升级：你还可以这样用 Class 来重构项目代码
layout: post
thread: 199
date: 2018-07-21
author: Joe Jiang
categories: Documents
tags: [JavaScript, 重构, Class, 前端]
excerpt: 起手一个项目时，我们都是想着“多快好省”地以完成业务功能为主，而在推进的过程中随着项目越滚越大，为了提高代码的可维护性，我们不得不择机对代码进行重构……
---

*前言：起手一个项目时，我们都是想着“多快好省”地以完成业务功能为主，而在推进的过程中随着项目越滚越大，为了提高代码的可维护性，我们不得不择机对代码进行重构，否则就只剩下一条路可走了——跑路。而在重构过程中，我们大多会建立一个 `utils` 文件（夹）来存放我们的通用方法，那么在不同场景下，我们是否考虑过会有更好的重构思路呢？本文作者结合 class 介绍了一个轻巧的代码清理思路。你还可以在专栏[初级前端工程师](https://zhuanlan.zhihu.com/p/40276962)查看此文。*

![](/assets/in-post/2018-07-21-javascript-code-cleanup-how-you-can-refactor-to-use-classes-2.jpeg )

在较小的 React 项目中，将所有的函数方法保留在组件自身中效果很好。在中型项目里，你可能就开始希望这些函数方法来自组件之外，并将它们都放进一个类似“工具箱”的地方。本文将向你展示如何利用一个 Class 来组织自己的代码（而不是导出单个函数或者变量）。

注：我用 react 开发，而接下来要讨论的例子也是用它编写的。

## 一、典型的重构方式

在一个典型的重构过程中，你通常会把函数方法从组件中拿出来，并将它放入另一个“工具箱”中。

例如，从如下代码

```javascript
const MyComponent = () => {
  const someFunction = () => 'Hey, I am text'
  return (
    <div>
      {someFunction()}
    </div>
  )
}
```

转移到

```javascript
import { someFunction } from 'functionHelper.js'
const MyComponent = () => {
  return (
    <div>
      {someFunction()}
    </div>
  )
}
```

以及

```javascript
export const someFunction = () => 'Hey, I am text'
```

这个例子实在有点笨拙，但来看看我们都干了些什么：

1. 取出具体的函数代码并将它们放入一个单独的文件；
2. 在需要引用的文件中 import 它们并按照正常方式调用；

但当事情变得复杂起来，你就需要给那些函数传递一堆东西——对象，操纵状态的函数等等。如我今天遇到的一个问题：我想从一个组件中提取三个方法，且它们拥有相同的入参（一个 `resource` 对象和一个函数用于更新 `resource`）。一定会有更好的处理方法的……

## 二、利用 Class 来实现重构

我为这篇文章写了个 demo，代码放在 [GitHub](https://github.com/AmberWilkie/class-demo)。首次 commit 展示了主组件（`App.js`）中的所有功能，而后续 commit 则使用 class 对代码进行了重构。

![](/assets/in-post/2018-07-21-javascript-code-cleanup-how-you-can-refactor-to-use-classes-1.png )

你可以下载到本地并在上面做任何修改，但记住一定要先 `yarn install` 下。

我们从“获取”包含一些特定属性对象（模仿我们可能通过 API 来执行此操作的方式）的组件开始，比如：迭代（对象数量）、尺寸（高度与宽度）、文字与颜色。之后我们可以通过多种方式来操作视图——更改颜色，更新文本等等。每次变更，我们都计划显示一条消息（来明确状态）。

举个例子，这是我们改变长宽的方法：

```javascript
changeSide = side => {
  const obj = {...this.state.obj, side}
  this.fetchObject(obj);
  this.setState({ message: `You changed the sides to ${side} pixels!` });
}
```

我们可能还有许多其他方法也执行类似的操作——又或者是完全不同的方法。我们这时便开始考虑将这些代码提取到一个“工具箱”中。然后我们需要新建一个不同的方法来调用 `setState` 操作，我们也不得不传递 `this.fetchObject`，即带状态的对象，以及作为方法入参的 `side` 等。如果类似的方法我们有好几个，那么真的需要传递很多参数。这样一想这个提取过程实际上对我们来说并没有太大的帮助（或者说不具备很好的可读性）。

相反，我们可以利用一个类，使用构造方法来完成这些：

```javascript
export default class ObjectManipulator {
  constructor( { object, fetchObject, markResettable, updateMessage, updateStateValue } ) {
    this.fetchObject = fetchObject;
    this.markResettable = markResettable;
    this.updateMessage = updateMessage;
    this.updateStateValue = updateStateValue;
  }

  changeSide = ( object, side ) => {
    const newObject = { ...object, side };
    this.fetchObject(newObject);
    this.updateMessage(`You changed the sides to ${side} pixels!`);
    this.markResettable();
    this.updateStateValue('side', side);
  };
};
```

这允许我们创建一个对象，而后在我们的组件中对这个对象的内部方法进行调用：

```javascript
const manipulator = new ObjectManipulator({
  object,
  fetchObject: this.fetchObject,
  markResettable: this.markResettable,
  updateMessage: this.updateMessage,
  updateStateValue: this.updateStateValue,
});
```

以上代码创建了一个对象 `manipulator` —— `ObjectManipulator` 类的一个实例。当我们调用 `manipulator.changeSide(object, '800')` 时它会运行我们之前定义的 `changeSide` 方法。我们没有必要再向其中传递诸如 `updateMessage` 之类的方法——因为我们已经在新建实例时，在构造函数中对他们进行了定义。

你可以想象，如果我们有很多诸如此类的方法需要处理，这将变得非常有用。就拿我的遭遇来说，我需要在获取到所有内容后调用 `.then(res => myFunction(res))`。在类中定义 `myFunction` 而不是给每个函数都传递一遍，这大大减少了我的代码量。

## 三、保持一切井然有序

若你需要保持所有内容都井然有序，那这种组织方法将非常有用。举个例子，我有一个数组，其中存有不同的颜色，我通过遍历它生成你在示例中看到的那些颜色按钮。通过将此常量移动到 `ObjectManipulator` 中，我可以确保它不会与我应用程序其余部分中的任何 `colors` 产生冲突：

```javascript
export default class ObjectManipulator {
  [...]

  colors = ['blue', 'red', 'orange', 'aquamarine', 'green', 'gray', 'magenta'];
};
```

我可以使用 `manipulator.colors` 为这个页面抓取正确的颜色，而用另一个全局常量 colors 来处理些其他事情。

**参考**：[Good old Mozilla Class docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes)。本文首图来自 [Unsplash](https://unsplash.com/search/photos/cleaning)，作者 [Jennifer Burk](https://unsplash.com/photos/wP9yLk_VKI8)。

意译自 [JavaScript code cleanup: how you can refactor to use Classes](https://medium.freecodecamp.org/javascript-code-cleanup-how-you-can-refactor-to-use-classes-3948118e4468)，作者 [Amber Wilkie](https://medium.freecodecamp.org/@heyamberwilkie)，译者 [hijiangtao](https://github.com/hijiangtao)。