---
title: Diff ECMAScript 2019
layout: post
thread: 227
date: 2019-07-05
author: Joe Jiang
categories: Document
tags: [2019, ECMAScript, JavaScript, 语言特性]
excerpt: ECMAScript® 2019 已定稿，通过 ECMA 可以查看到 ECMAScript 第十版语言标准的所有内容。由于该语言于几年前开始的年更节奏，每年的变化并不如当初 ES5 到 ES6 的改动大，于是想知道标准有哪些改动，看看在今年发布期内完结的提案倒是更有帮助些。
---

ECMAScript® 2019 已定稿，通过 ECMA [链接](https://www.ecma-international.org/ecma-262/10.0/index.html)可以查看到 ECMAScript 第十版语言标准的所有内容。

由于该语言于几年前开始的年更节奏，每年的变化并不如当初 ES5 到 ES6 的改动大，于是想知道标准有哪些改动，看看在今年发布期内完结的[提案](https://github.com/tc39/proposals/blob/master/finished-proposals.md)倒是更有帮助些。

| 提案                                                                 | 作者                                                 | 主席                                             | TC39 会议纪要                          | 预期发布年份 |
| ------------------------------------------------------------------------ | ------------------------------------------------------ | ------------------------------------------------------- | ------------------------------------------- | ------------------------- |
| [Optional `catch` binding][optional-catch]                               | Michael Ficarra                                        | Michael Ficarra                                         | [May 2018][optional-catch-notes]            | 2019                      |
| [JSON superset][json-superset]                                           | Richard Gibson                                         | Mark Miller<br />Mathias Bynens                         | [May 2018][json-superset-notes]             | 2019                      |
| [`Symbol.prototype.description`][symbol-description]                     | Michael Ficarra                                        | Michael Ficarra                                         | [November 2018][symbol-description-notes]   | 2019                      |
| [`Function.prototype.toString` revision][function-to-string]             | Michael Ficarra                                        | Michael Ficarra                                         | [November 2018][function-to-string-notes]   | 2019                      |
| [`Object.fromEntries`][object-from-entries]                              | Darien Maillet Valentine                               | Jordan Harband<br />Kevin Gibbons                       | [January 2019][object-from-entries-notes]   | 2019                      |
| [Well-formed `JSON.stringify`][well-formed-stringify]                    | Richard Gibson                                         | Mathias Bynens                                          | [January 2019][well-formed-stringify-notes] | 2019                      |
| [`String.prototype.{trimStart,trimEnd}`][trims]                          | Sebastian Markbåge                                     | Sebastian Markbåge<br />Mathias Bynens                  | [January 2019][trims-notes]                 | 2019                      |
| [`Array.prototype.{flat,flatMap}`][flat]                                 | Brian Terlson<br />Michael Ficarra<br />Mathias Bynens | Brian Terlson<br />Michael Ficarra                      | [January 2019][flat-notes]                  | 2019                      |

接下来我们一一细读。其中，部分新特性我在[赶上 ECMAScript 潮流：用现代 JavaScript 编程](/2018/11/24/Write-JavaScript-in-2018/)一文中已给出详例解释，故此处针对剩余六个提案/特性进行介绍。

## 1. JSON superset

什么是 JSON 超集？还记得 `⊂` 这个符号的可以这样解释该提案 `JSON ⊂ ECMAScript`，简而言之就是让 ECMAScript 兼容所有 JSON 支持的文本。ECMAScript 曾在标准 [JSON.parse](https://tc39.github.io/ecma262/#sec-json.parse) 部分阐明 JSON 确为其一个子集，但由于 JSON 内容可以正常包含 `U+2028` 行分隔符与 `U+2029` 段落分隔符而 ECMAScript 却不行。

该草案旨在解决这一问题。在这之前，如果你使用 `JSON.parse()` 执行带如上特殊字符的字符串时，只会收到 `SyntaxError` 的错误提示。该草案同样是向后兼容的，其对用户唯一的影响是保持原样，即在暂不支持特殊字符解析的运行环境中保持 `SyntaxError` 的报错。

## 2. `Symbol.prototype.description`

ECMAScript 在该[提案](https://tc39.es/proposal-Symbol-description/)中规定，`Symbol.prototype.description ` 是一个访问器属性，你可以通过它获取 Symbol 对象的字符串表述，而在此之前，你必须通过调用 `Symbol.prototype.toString` 方法达到同样的目的。我们来看几个例子熟悉一下：

```js
const testSymbol = Symbol('Test')
testSymbol.description // 'Test'

Symbol("foo") + "bar";      
// TypeError: Can't convert symbol to string

Symbol("foo").toString() + "bar"
// "Symbol(foo)bar"
```

## 3. `Function.prototype.toString`

这是一个校订提案，内容很长详见 <https://tc39.es/Function-prototype-toString-revision/>，但解释起来相对容易。我们知道，调用 `Function` 原型链上的 `toString()` 方法可以返回函数的源码字符串，但是在转换过程中，空格、代码注释等内容会被去除。

在校订中，这些内容得以正常解析保留，使得调用 `toString()` 方法获得的结果与函数的实际定义更加接近，来看个例子加深印象：

```js
function /* this is bar */ bar () {
  // Hello
  return 'Hello, bar!';
}

bar.toString()
// → "function /* this is bar */ bar () {
// →   // Hello
// →   return 'Hello, bar!';
// → }"
```

## 4. `Object.fromEntries`

在 JavaScript 操作中，数据在各种数据结构之间的转换都是很容易的，比如 Map 到数组、Map 到 Set、对象到 Map 等等：

```js
const map = new Map().set('foo', true).set('bar', false);
const arr = Array.from(map);
const set = new Set(map.values());

const obj = { foo: true, bar: false };
const newMap = new Map(Object.entries(obj));
```

其中，`Object.entries()` 方法返回一个给定对象自身可枚举属性的键值对数组，例如：

```js
const obj = { foo: 'bar', baz: 42 };
console.log(Object.entries(obj)); // [ ['foo', 'bar'], ['baz', 42] ]
```

但是如果我们需要将一个键值对列表转换为对象，相对还是很麻烦的：

```js
const map = new Map().set('foo', true).set('bar', false);

const obj = Array.from(map).reduce((acc, [ key, val ]) => {
  return Object.assign(acc, { 
    [key]: val 
  });
}, {});
```

该提案的目的在于为对象添加一个新的静态方法 `Object.fromEntries`，用于将符合键值对的列表（例如 Map、数组等）转换为一个对象。如此一来，以上转换我们只需要一行代码即可搞定：

```js
Object.fromEntries(map);
```

## 5. `JSON.stringify`

当你使用 `JSON.stringify` 处理一些无法用 UTF-8 编码表示的字符时（U+D800 至 U+DFFF），曾经返回的结果会是一个乱码 Unicode 字符，即“�”。该提案提出，用 JSON 转义序列来安全的表示这些特殊字符。

正常字符的表示不变：

```js
JSON.stringify('𝌆')
// → '"𝌆"'
JSON.stringify('\uD834\uDF06')
// → '"𝌆"'
```

而无法用 UTF-8 编码表示的字符会被序列化为转移序列：

```js
JSON.stringify('\uDF06\uD834')
// → '"\\udf06\\ud834"'
JSON.stringify('\uDEAD')
// → '"\\udead"'
```

## 6. `Array.prototype.{flat,flatMap}`

这个提案提出了两个方法，其中：

* `Array.prototype.flat` 返回一个新数组，其中所有子数组元素会以指定的深度递归的连接到一起；
* `Array.prototype.flatMap` 方法首先会调用提供的函数执行一次 map() 方法，然后再通过类似 flat 方法「打平」数组。它等价于执行完 `map()` 后再执行一次 `flat()` 方法，但当你执行 `map()` 时返回的结果如果是个数组时，这个方法会显得额外有用与简便；

来看几个例子解释一下，首先 `flat()` 方法支持不同深度的「打平」，其中 “Infinity” 可以将所有深度打平成一级：

```js
['Dog', ['Sheep', ['Wolf']]].flat()
//[ 'Dog', 'Sheep', [ 'Wolf' ] ]

['Dog', ['Sheep', ['Wolf']]].flat(2)
//[ 'Dog', 'Sheep', 'Wolf' ]

['Dog', ['Sheep', ['Wolf']]].flat(Infinity)
//[ 'Dog', 'Sheep', 'Wolf' ]
```

用另一个例子来解释 `flatMap()` 方法的便利之处：

```js
['My dog', 'is awesome'].map(words => words.split(' '))
//[ [ 'My', 'dog' ], [ 'is', 'awesome' ] ]

['My dog', 'is awesome'].flatMap(words => words.split(' '))
//[ 'My', 'dog', 'is', 'awesome' ]
```

## 参考

* <https://github.com/tc39/proposals>
* <https://tc39.es/ecma262/>

[optional-catch]: https://github.com/tc39/proposal-optional-catch-binding
[optional-catch-notes]: https://github.com/tc39/tc39-notes/blob/master/meetings/2018-05/may-22.md#conclusionresolution-7
[json-superset]: https://github.com/tc39/proposal-json-superset
[json-superset-notes]: https://github.com/tc39/tc39-notes/blob/master/meetings/2018-05/may-22.md#conclusionresolution-8
[symbol-description]: https://github.com/tc39/proposal-Symbol-description
[symbol-description-notes]: https://github.com/rwaldron/tc39-notes/blob/master/meetings/2018-11/nov-27.md#conclusionresolution-12
[function-to-string]: https://github.com/tc39/Function-prototype-toString-revision
[function-to-string-notes]: https://github.com/rwaldron/tc39-notes/blob/master/meetings/2018-11/nov-27.md#conclusionresolution-13
[object-from-entries]: https://github.com/tc39/proposal-object-from-entries
[object-from-entries-notes]: https://github.com/tc39/tc39-notes/blob/master/meetings/2019-01/jan-29.md#objectfromentries-for-stage-4
[well-formed-stringify]: https://github.com/tc39/proposal-well-formed-stringify
[well-formed-stringify-notes]: https://github.com/tc39/tc39-notes/blob/master/meetings/2019-01/jan-29.md#well-formed-jsonstringify-for-stage-4
[trims]: https://github.com/tc39/proposal-string-left-right-trim
[trims-notes]: https://github.com/tc39/tc39-notes/blob/master/meetings/2019-01/jan-29,md#stringprototypetrimstarttrimend-for-stage-4
[flat]: https://github.com/tc39/proposal-flatMap
[flat-notes]: https://github.com/tc39/tc39-notes/blob/master/meetings/2019-01/jan-29.md#arrayprototypeflatflatmap-for-stage-4