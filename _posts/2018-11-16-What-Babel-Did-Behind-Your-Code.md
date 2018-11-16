---
title: JavaScript 基础：Babel 转译 class 过程窥探
layout: post
thread: 204
date: 2018-11-16
author: Joe Jiang
categories: Document
tags: [前端, JavaScript, 2018, Babel, class]
excerpt: 本篇文章将介绍 Babel 在转译你的 class 写法时实际都做了哪些工作。
---

## 零、前言

虽然在 JavaScript 中对象无处不在，但这门语言并不使用经典的基于类的继承方式，而是依赖原型，至少在 ES6 之前是这样的。当时，假设我们要定义一个可以设置 id 与坐标的类，我们会这样写：

```javascript
// Shape 类
function Shape(id, x, y) {
    this.id = id;
    this.setLocation(x, y);
}

// 设置坐标的原型方法
Shape.prototype.setLocation = function(x, y) {
    this.x = x;
    this.y = y;
};
```

上面是类定义，下面是用于设置坐标的原型方法。从 ECMAScript 2015 开始，语法糖 `class` 被引入，开发者可以通过 `class` 关键字来定义类。我们可以直接定义类、在类中写静态方法或继承类等。上例便可改写为：

```javascript
class Shape {
    constructor(id, x, y) { // 构造函数语法糖
        this.id = id;
        this.setLocation(x, y);
    }
    
    setLocation(x, y) { // 原型方法
        this.x = x;
        this.y = y;
    }
}
```

一个更符合“传统语言”的写法。语法糖写法的优势在于当类中充满各类静态方法与继承关系时，class 这种对象模版写法的简洁性会更加突出，且不易出错。但不可否认时至今日，我们还需要为某些用户兼容我们的 ES6+ 代码，class 就是 TodoList 上的一项：

![](/assets/in-post/2018-11-16-What-Babel-Did-Behind-Your-Code-1.png)

作为当下最流行的 JavaScript 编译器，Babel 替我们转译 ECMAScript 语法，而我们不用再担心如何进行向后兼容。

本地安装 Babel 或者利用 Babel CLI 工具，看看我们的 Shape 类会有哪些变化。可惜的是，你会发现代码体积由现在的219字节激增到2.1KB，即便算上代码压缩（未混淆）代码也有1.1KB。转译后输出的代码长这样：

```javascript
"use strict";var _createClass=function(){function a(a,b){for(var c,d=0;d<b.length;d++)c=b[d],c.enumerable=c.enumerable||!1,c.configurable=!0,"value"in c&&(c.writable=!0),Object.defineProperty(a,c.key,c)}return function(b,c,d){return c&&a(b.prototype,c),d&&a(b,d),b}}();function _classCallCheck(a,b){if(!(a instanceof b))throw new TypeError("Cannot call a class as a function")}var Shape=function(){function a(b,c,d){_classCallCheck(this,a),this.id=b,this.setLocation(c,d)}return _createClass(a,[{key:"setLocation",value:function c(a,b){this.x=a,this.y=b}}]),a}();
```

Babel 仅仅是把我们定义的 Shape 还原成一个 ES5 函数与对应的原型方法么？

## 一、揭秘

好像没那么简单，为了摸清实际转译流程，我们先将上述类定义代码简化为一个只有14字节的空类：

```javascript
class Shape {}
```

首先，当访问器走到类声明阶段，需要补充严格模式：

```javascript
"use strict";

class Shape {}
```

而进入变量声明与标识符阶段时则需补充 let 关键字并转为 var:

```javascript
"use strict";

var Shape = class Shape {};
```

到这个时候代码的变化都不太大。接下来是进入函数表达式阶段，多出来几行函数：

```javascript
"use strict";

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Shape = function Shape() {
  _classCallCheck(this, Shape);
};
```

该阶段不仅替换了 class，还在类中调用了叫做 `_classCallCheck` 的方法。这是什么呢？

这个函数的作用在于确保构造方法永远不会作为函数被调用，它会评估函数的上下文是否为 Shape 对象的实例，以此确定是否需要抛出异常。接下来，则轮到 [babel-plugin-minify-simplify](https://www.npmjs.com/package/babel-plugin-minify-simplify) 上场，这个插件做的事情在于通过简化语句为表达式、并使表达式尽可能统一来精简代码。运行后的输出是这样的：

```javascript
"use strict";

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) throw new TypeError("Cannot call a class as a function"); }

var Shape = function Shape() {
  _classCallCheck(this, Shape);
};
```

可以看到 if 语句中由于只有一行代码，于是花括号被去掉。接下来上场的便是内置的 [Block Hoist](https://github.com/babel/babel/blob/eac4c5bc17133c2857f2c94c1a6a8643e3b547a7/packages/babel-core/src/transformation/block-hoist-plugin.js)，该插件通过遍历参数排序然后替换，Babel 输出结果为：

```javascript
"use strict";

function _classCallCheck(a, b) { if (!(a instanceof b)) throw new TypeError("Cannot call a class as a function"); }

var Shape = function a() {
  _classCallCheck(this, a);
};
```

最后一步，minify 一下，代码体积由最初的14字节增为338字节：

```javascript
"use strict";function _classCallCheck(a,b){if(!(a instanceof b))throw new TypeError("Cannot call a class as a function")}var Shape=function a(){_classCallCheck(this,a)};
```

## 二、再说一些

这是一个什么都没干的类声明，但现实中任何类都会有自己的方法，而此时 Babel 必定会引入更多的插件来帮助它完成代码的转译工作。直接在刚刚的空类中定义一个方法吧。

```javascript
class Shape {
  render() {
  	console.log("Hi");
  }
}
```

我们用 Babel 转译一下，会发现代码中包含如下这段：

```javascript
var _createClass = function () { function a(a, b) { for (var c, d = 0; d < b.length; d++) c = b[d], c.enumerable = c.enumerable || !1, c.configurable = !0, "value" in c && (c.writable = !0), Object.defineProperty(a, c.key, c); } return function (b, c, d) { return c && a(b.prototype, c), d && a(b, d), b; }; }();
```

类似前面我们遇到的 `_classCallCheck`，这里又多出一个 `_createClass`，这是做什么的呢？我们稍微把代码状态往前挪一挪，来到 [babel-plugin-minify-builtins](https://www.npmjs.com/package/babel-plugin-minify-builtins) 处理阶段（该插件的作用在于缩减内置对象代码体积，但我们主要关注点在于这个阶段的 `_createClass` 函数是基本可读的），此时 `_classCallCheck` 长成这样：

```javascript
var _createClass = function() {
  function defineProperties(target, props) {
    for (var i = 0; i < props.length; i++) {
      var descriptor = props[i];
      descriptor.enumerable = descriptor.enumerable || false;
      descriptor.configurable = true;
      if ("value" in descriptor) descriptor.writable = true;
      Object.defineProperty(target, descriptor.key, descriptor);
    }
  }
  return function(Constructor, protoProps, staticProps) {
    if (protoProps) defineProperties(Constructor.prototype, protoProps);
    if (staticProps) defineProperties(Constructor, staticProps);
    return Constructor;
  };
} ();
```

可以看出 `_createClass` 用于处理创建对象属性，函数支持传入构造函数与需定义的键值对属性数组。函数判断传入的参数（普通方法/静态方法）是否为空对应到不同的处理流程上。而 `defineProperties` 方法做的事情便是遍历传入的属性数组，然后分别调用 `Object.defineProperty` 以更新构造函数。而在 Shape 中，由于我们定义的不是静态方法，我们便这样调用：

```javascript
_createClass(Shape, [{
    key: "render",
    value: function render() {
      console.log("Hi");
    }
  }]);
```

T.J. Crowder 在 [How does Babel.js create compile a class declaration into ES2015?](https://stackoverflow.com/questions/35774928/how-does-babel-js-create-compile-a-class-declaration-into-es2015) 中谈到 Babel 是如何将 class 转化为 ES5 兼容代码时谈到了几点，大意为：

* `constructor` 会成为构造方法数；
* 所有非构造方法、非静态方法会成为原型方法；
* 静态方法会被赋值到构造函数的属性上，其他属性保持不变；
* 派生构造函数上的原型属性是通过 `Object.create(Base.prototype)` 构造的对象，而不是 `new Base()`；
* `constructor` 调用构造器基类是第一步操作；
* ES5 中对应 `super` 方法的写法是 `Base.prototype.baseMethod.call(this);`，这种操作不仅繁琐而且容易出错；

这些概述大致总结了类定义在两个 ES 版本中的一些差异，其他很多方面比如 `extends` ——继承关键字，它的使用则会使 Babel 在转译结果加上 `_inherits` 与 `_possibleConstructorReturn` 两个函数。篇幅所限，此处不再展开详述。

## 三、最后

语法糖 `class` 给我们带来了很多写法上的便利，但可能会使我们在代码体积上的优化努力“付诸东流”。

另一方面，如果你是一名 React 应用开发者，你是否已经在想将代码中的所有 class 写法换为 function 呢？那样做的话，代码体积无疑会减少很多，但你一定也知道 PureComponent 相比 Component 的好处。所以虽然 function 给你的代码体积减负了，但他在哪里又给你无形增加负担了呢？

因此，真的不推荐开发者用 `class` 这种写法么，你觉得呢？

## 四、更多阅读

* [Babel is a compiler for writing next generation JavaScript](https://babeljs.io/)
* [How does Babel.js create compile a class declaration into ES2015?](https://stackoverflow.com/questions/35774928/how-does-babel-js-create-compile-a-class-declaration-into-es2015)
* [How JavaScript works: The internals of classes and inheritance + transpiling in Babel and TypeScript](https://blog.sessionstack.com/how-javascript-works-the-internals-of-classes-and-inheritance-transpiling-in-babel-and-113612cdc220)