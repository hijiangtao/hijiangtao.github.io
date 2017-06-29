---
title: React 与 Vue 的实践总结
layout: post
thread: 176
date: 2017-06-19
author: Joe Jiang
categories: documents
tags: [Vue, React, 框架]
excerpt: 最近花了比较大段的时间用于了解和实践主流三大框架其中的两个 - Vue 和 React, 总结一下自己在使用中感受到的两者在提升开发效率上的一些异同之处。
---

最近花了比较大段的时间用于了解和实践主流三大框架其中的两个： Vue 和 React，总结一下自己在使用中感受到的两者在提升开发效率上的一些异同之处。

文章不算一个合格的总结对比文章，因为虽然是对 React 和 Vue 两者的叙述，但是并未详尽的列举两者相同和不同的每一个地方。因为我是先学习的 Vue 然后才学的 React，所以我会在 React 上多介绍总结一些，然后夹杂对 Vue 的一些感受（虽然有独立的篇章对 Vue 进行总结）。

## React

从官方介绍中可以知道 React 的目的是让开发者可以快速的构建 JavaScript 大型网络应用，作为一个 JavaScript 库，他的优点之一是允许你在编程的同时也可以思考你的应用架构。React 具有如下几个特点。

### JSX

React 不是一个渐进式的框架，这意味着开发者在上手之前需要了解它的几个关键概念，其中最具特色的一个方面就是 **JSX**， JavaScript 的一种语法扩展。用简单的话来说，它允许我们用类 HTML 的语法来声明 React 中的元素，并在实际执行前能够通过 JSX 转换工具转换成纯 JavaScript 代码。比如下面这个语句用 JSX 语法声明了一个标题元素：

```
const element = <h1>Hello, world!</h1>;
```

在 JSX 中，我们可以任意的使用 JavaScript 表达式，因为 JSX 完全就是在 JavaScript 内部实现的，但是需要注意的是我们需要用花括号将 JSX 中的表达式包裹起来，例如下面的图片标签中使用到的变量：

```
const element = <img src={user.avatarUrl} />;
```

`this` 也是 React JSX 中你需要谨慎对待的一点。对于回调函数来说，方法默认是不会[绑定](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_objects/Function/bind) `this` 的。如果你忘记绑定 `this.handleClick` 并把它传入 `onClick`, 当你调用这个函数的时候 `this` 的值会是 `undefined`。

所以在 react app 中有必要使用 `this.handleClick = this.handleClick.bind(this);` 对事件处理回调函数进行 this 的手动绑定。这样，在 JSX 定义组件时才可以之间直接将灰调函数赋给相应的事件处理属性。

除此外， JSX 还能帮助我们防注入攻击、通过首字母大小写区分 DOM 标签以及自定义组件的渲染。虽然 React 不强制开发者使用 JSX 去编写代码，但是这是推荐的用法。在 Facebook 看来，**JSX 这样一种语法扩展使得我们可以以更加清晰的一种方式去定义组件的结构**。更多有关 JSX 的介绍可以查看 React [文档](https://facebook.github.io/react/docs/introducing-jsx.html)。

### 组件，State 和 Props

React 中的组件定义有两种方式。如下所示第一种是普通的函数定义，通过 JSX 语法我们可以直接返回这样格式的元素，同样的如果使用 ES6 的 class 关键字，我们也可以定义同样功能的组件，但需要注意的是相应的元素需要在类的 render 方法中被返回，即 render 方法是必须的：

```
// 函数定义
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

// 类定义组件
class Welcome extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}
```

组件之间可以组合和引用，用于抽象出更复杂层次的组件结构。同时，我们可以看到在定义组件的时候都通过 `this.props` 从父组件向组件的具体实现中传递了参数。 `props` 作为传入属性，通过调用组件本身去更新页面中的元素内容。但需要注意的一点是 `props` 具有只读性，即我们不能直接改变它自身的 `props`。但是，应用的界面是随时间动态变化的，所以另一个概念 `state` 被提出用于实现用户操作、网络响应或者其他状态变化。

在一个构造的组件类中，用 `this.state` 去初始化组件状态，用 `this.setState()` 来更新组件局部状态，例如：

```
class Test extends React.Component {
  constructor(props) {
    super(props);
    this.state = {...};
  }

  tick() {
    this.setState({...});
  }

  render() {
    return (
      ...
    );
  }
}
```

需要注意的是，`state` 不能被直接更新，即类似 `this.state.test = 2;` 的操作不会重新渲染组件，当需要更新状态时请使用 `this.setState` 方法。另一点是由于 React 可能将 多个 `setState` 方法合并成一个用于调用，所以状态的更新可能是异步更新的，因此我们不应该依靠 `this.props` 和 `this.state` 来更新计算下一个状态。最后一个需要注意的地方为 `setState` 方法的浅合并实现，所以当我们利用 `setState` 去更新状态时，未提及的状态属性会保持原样不被改变，这意味着当组件有100个状态属性时，如果我们只给 `setState` 传递一个属性，那么只有这一个属性会被更新，而其余99个状态属性不变。

### 状态提升

在 React 中，父组件或子组件都不能知道某个组件是有状态还是无状态，其中定义的属性（数据）只能影响组件树下方的组件，这个被称为自顶向下流动的数据流。但我们知道，有些情况下，我们会遇到几个组件需要共用状态数据的情况，那么如何解决这种情况呢？

React利用 状态提升来解决这个问题。假设我们有两个组件，A 是 B 的父组件，B 为一个输入框，其中输入的数据需要向上传递在父组件的其他部分保持同步。我们知道 A 可以通过 props 向 B 传递状态（state），那么接下来介绍 B 如何将改动的数据回传。

```
// A
class A extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
    this.state = {temperature: ''};
  }

  handleChange(temperature) {
    this.setState({temperature});
  }

  render() {
    const scale = this.state.scale;
    const temperature = this.state.temperature;

    return (
      <div>
        <TemperatureInput
          temperature={temperature}
          onBChange={this.handleChange} />
      </div>
    );
  }
}

// B
class B extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    this.props.onBChange(e.target.value);
  }

  render() {
    const temperature = this.props.temperature;
    return (
      <fieldset>
        <input value={temperature}
               onChange={this.handleChange} />
      </fieldset>
    );
  }
}
```

从上述代码可以知道，我们将父组件的 state 更新操作以 props 属性的形式传递给了子组件，而在子组件中若 input 发生了变化，其会调用相应的事件函数更新 state 并“提升”更新到父组件，这里在子组件中更新 state 用到的是从父组件传递过来的包含 `setState` 的一个方法。

> 状态提升比双向绑定方式要写更多的“模版代码”，但带来的好处是，你也可以更快地寻找和定位bug的工作。因为哪个组件保有状态数据，也只有它自己能够操作这些数据，发生bug的范围就被大大地减小了。此外，你也可以使用自定义逻辑来拒绝或者更改用户的输入。- [React 文档中文翻译](https://discountry.github.io/react/docs/lifting-state-up.html)

### 组合与继承

组合的主要设计思想是通过一些指定属性将子元素等相关元素直接传递，以实现不同组件的实现/组合。比如，可以通过 children 属性将上层 JSX 标签内的任何内容传递到该便签的实际实现中；自定义属性例如 left 和 right 用于分隔组件的多个入口。一个简单的例子如下所示：

```
// 子组件，注意 props.children
function FancyBorder(props) {
  return (
    <div className={'FancyBorder FancyBorder-' + props.color}>
      {props.children}
    </div>
  );
}

// 父组件，FancyBorder 中的所有内容通过 children 属性传入
function WelcomeDialog() {
  return (
    <FancyBorder color="blue">
      <h1 className="Dialog-title">
        Welcome
      </h1>
    </FancyBorder>
  );
}
```

而相比之下说到继承， React 表示还未发现任何需要推荐你使用继承的情况。

## Vue

Vue 官网如此介绍自己：

> 渐进式 JavaScript 框架

相比之下， Vue 更适合零基础入门。因为只要我们通过 `script` 标签引入任一版本的 Vue.js 源码文件，即可以通过类似下面的操作去实现 MVVM 的双向绑定。

```
// html 文件
<div id="app">
  {{ message }}
</div>

// js 文件
var app = new Vue({
  el: '#app',
  data: {
    message: 'Hello Vue!'
  }
})
```

相比之下，只要我们了解 JavaScript 的基本语法，上面的代码我们就可以轻易的看懂，而不像 React 的语法那样在具体实现前我们需要提前去了解到其中涉及的一些关键概念。

以上这段代码已经实现了数据 `message` 与 DOM的绑定，所有元素都是响应式的，即若 `message` 改变，那么相应 DOM 中的内容也会随之更新。Vue 也具有 一些鲜明的特点。

### 条件与循环

在 Vue 中，对于条件控制一个元素的显示以及循环渲染一个项目列表，我们都是在 HTML 代码中通过相应的指令去实现的（条件指令为 `v-if`，循环指令为 `v-for`），例如：

```
// HTML 文件
<div id="app-4">
  <ol>
    <li v-for="todo in todos">
      {{ todo.text }}
    </li>
  </ol>
</div>

// js 文件
var app4 = new Vue({
  el: '#app-4',
  data: {
    todos: [
      { text: '学习 JavaScript' },
      { text: '学习 Vue' },
      { text: '整个牛项目' }
    ]
  }
})
```

而相应的内容在 React 中实现我们需要利用类似 map 的操作去实现元素的批量定义，然后通过 JSX 语法指定插入对应位置。

### 处理用户输入

Vue 中利用 `v-on` 指令来绑定事件监听器，以此允许用户和我们的应用进行互动，其中绑定的方法在 Vue 实例的 methods 属性中指定。`v-model` 指令是一个实现表单输入和应用状态之间的双向绑定。以下为给 button 按钮绑定一个点击事件的代码片段：

```
// HTML 文件
<div id="app-5">
  <p>{{ message }}</p>
  <button v-on:click="reverseMessage">逆转消息</button>
</div>

// js 文件
var app5 = new Vue({
  el: '#app-5',
  data: {
    message: 'Hello Vue.js!'
  },
  methods: {
    reverseMessage: function () {
      this.message = this.message.split('').reverse().join('')
    }
  }
})
```

### 组件

Vue 中也支持组件的使用。一个组件实质上是一个拥有预定义选项的一个 Vue 实例。Vue 也是通过 props 接口实现父单元向子单元的单向数据传递，对于元素的 HTML 模板则是通过 template 指定。

在组件中，Vue 允许我们为组件的 props 指定严正规格。即若传入的 propA 属性需要指定为数字，那么我们可以按照如下语法指定：

```
Vue.component('example', {
  props: {
    propA: Number
  }
})
```

对于一个 prop 如果我要实现双向绑定，在 React 中我们使用的是状态提升，而 Vue(2.3.0+) 中是通过 .sync 修饰符来实现，使用方法如下所示
：

```
// .sync 只是一个编译时的语法糖
<comp :foo.sync="bar"></comp>

// 子组件更新 foo 需要如下显式的触发一个更新事件
this.$emit('update:foo', newValue)
```

对于非父子组件之间的通信：

> 在简单的场景下，可以使用一个空的 Vue 实例作为中央事件总线；在复杂的情况下，我们应该考虑使用专门的[状态管理模式](https://cn.vuejs.org/v2/guide/state-management.html) (store)。 - Vuejs.org


## 感受

React 通过 props 和 state 将状态管理给明确了出来，相应的在 Vue 中，props 和 store 用来实现类似的功能；Vue 中的 .sync 用于实现 prop 双向绑定，而 React 利用状态提升来解决组件间的共用状态数据的情况。与此同时，在计算属性、样式绑定、事件处理器、组件等方面，Vue 均以一种和 HTML/JavaScript 搭配的方式去定义实现，而另一方面 React 较早的引入很多思想来规范实践，因此为了更方便的使用 React， 开发者在使用的时候往往需要提前了解好 state/props/component/状态提升 等概念。另一方面， JSX 虽然是为了更灵活的定义组件而实现的语法扩展，但是在个人看来，这样的定义还是需要一定的适应时间，毕竟 XML 结合 JavaScript 的结构看上去还是有点奇怪。

我最开始在实践中使用的是 Vue，当初还不需要了解很多类似状态管理或者组件开发的概念，所以结合原生 JavaScript 我也可以快速的开发出一个 MVVM 双向绑定的页面，而后随着需求越来越复杂，我也可以渐进的去了解更多的 Vue 生态的相关知识。但是如果换做 React 可能最开始学习成本会相比之下高出很多。同样的，相同的功能在 Vue 中实现所需要的代码会比 React 少不少。

由于个人原因，最近开始学习 React，可能是因为对于 Vue + Vuex + Vue-router 这一套系统稍有了解了，所以 React 看起来很容易理解其中的一些设计思想，相应的生态里 React 也具有 React + Redux + React router。简短的将 React 快速入门的文档看了一遍下来，发现其中很多思想还是值得提前去了解好的，虽然刚开始需要一段时间学习、但是随之而来在开发上给自己带来的收益会远远超出自己开始的付出，相比 Vue 的渐进式开发，React 能“强迫”自己尽早的写出结构更完美的代码。

## 总结

ECMAScript 标准以及实现是前端工程师需要去详细透彻了解的内容，框架只是提升我们工作效率的一个手段。当然，闲暇之余，React/Vue/Angular 的设计思想还是值得我们去研究的，这对我们写出更好的代码以及设计更好的应用架构都很有很大的帮助。

最近，用 Vue + Vuex + Vue-router + PWA + HTML5 localStorage 开发了一个简单的笔记应用，代码可以在 [Github](https://github.com/hijiangtao/octo-note) 查看，在线演示见 [demo](https://hijiangtao.github.io/octo-note/)。

与此同时，由于学习 React，跟着入门教程也开发了一版 tic-tac-toe 游戏，代码见 [Github](https://github.com/hijiangtao/tic-tac-toe)，在线演示见 [demo](https://hijiangtao.github.io/tic-tac-toe/)。

文章写的不尽完善，相关的要点待想到时再添加上来。

## 参考

* <https://facebook.github.io/react/>
* <https://vuejs.org/>