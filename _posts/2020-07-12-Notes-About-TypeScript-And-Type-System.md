---
title: 与 TypeScript 相关的一些记录
layout: post
thread: 252
date: 2020-07-12
author: Joe Jiang
categories: Document
tags: [2020, 前端, TypeScript, 类型系统, typing]
excerpt: 与 TypeScript 相关的一些记录。
---

> A type system specifies the type rules of a programming language independently of particular typechecking algorithms. This is analogous to describing the syntax of a programming language by a formal grammar, independently of particular parsing algorithms. —— Type Systems

本文记录两件事，一个是关于 typing 的一些名词释义，另一个便是结合 TypeScript 给出一些示例用于解释这门语言的能力。

## 1. 关于 typing 的一些名词释义

说到 typing 分类，常见的维度分为以下几种：

- Static (expressions have types) vs. dynamic (values have types) - 静态类型和动态类型，区分的关键点为编译期或运行期确定类型：静态类型在编译期确定，动态类型在运行期确定。
- Strong (values cannot be coerced to other types without a cast) vs. weak (the runtime performs a variety of coercions for convenience) - 强类型和弱类型，区分的关键点为运行时是否自动转换到与实际类型不符的类型：强类型要求手工类型转换，弱类型自动转换。
- Latent (no type declarations) vs. manifest (type declarations) - 隐式类型和显式类型，区分的关键点为是否要在源码中声明类型：隐式类型不需要，显式类型需要。
- Nominal (subtyping relations are declared explicitly) vs. structural (subtyping relations are inferred from the operations available on types) - 标明类型和结构类型，区分的关键点为类型判定是根据标称还是根据内容：标明类型根据标称，结构类型根据内容。

而以上说到的最后一个分类也被用于引出 TypeScript 所采用的类型系统——结构类型系统。

- 结构类型系统 / Structure Type System，可以简单理解成“任两个以相同结构所描述的值的类型都是等价的”。
- 标明类型系统 / Nominal Type System，则可以简单理解成“没有两个独特的语法构成的类型表达式表示同一类型，（即类型若要相等，就必须具有相同的“名字”）”。

其他还有一些名词：

- 鸭子类型 / Duck Typing - 在程序设计中是动态类型的一种风格。在这种风格中，一个对象有效的语义，不是由继承自特定的类或实现特定的接口，而是由"当前方法和属性的集合"决定。在与结构类型系统的对比上，鸭子类型和结构类型相似但与之不同。结构类型由类型的结构决定类型的兼容性和等价性，而鸭子类型只由结构中在运行时所访问的部分决定类型的兼容性。
- 泛型 / Generic - 泛型程序设计（generic programming）是程序设计语言的一种风格或范式。泛型允许程序员在强类型程序设计语言中编写代码时使用一些以后才指定的类型，在实例化时作为参数指明这些类型。

关于类型系统有一本“小书”，也就几十页，但个人看起来还相当吃力，感兴趣可以移步

> Cardelli, Luca. "[Type systems](http://lucacardelli.name/papers/typesystems.pdf)." ACM Computing Surveys 28.1 (1996): 263-264.

## 2. 关于 TypeScript 系统性入门的一些标注

### 2.1 **TypeScript 采用结构类型系统（Structure Type System）**

TypeScript 和 C# 有着颇深的渊源，他们都是在微软大神 Anders Hejlsberg 的领导之下产生的编程语言，两者在诸多设计细节方面十分相似。然而，一个非常重要的不同之处在于，C# 采用的是 Nominal Type System（标明类型系统），TypeScript 考虑到 JavaScript 本身的灵活特性，采用的是 Structural Type System。

关于标明类型系统和结构类型系统的区别，可以看这个例子。这里是一段 C# 代码：

```csharp
// 示例 from https://zhuanlan.zhihu.com/p/64446259

public class Foo  
{
    public string Name { get; set; }
    public int Id { get; set;}
}

public class Bar  
{
    public string Name { get; set; }
    public int Id { get; set; }
}

Foo foo = new Foo(); // Okay.
Bar bar = new Foo(); // Error!!!
```

`Foo`和`Bar`两个类的内部定义完全一致，但是当将`Foo`实例赋值给`Bar`类型的变量时编译器报错，说明两者的类型并不一致。标明类型系统比较的是类型本身，具备非常强的一致性要求。

TypeScript 则不太一样：

```tsx
// 示例 from https://zhuanlan.zhihu.com/p/64446259

class Foo {
  method(input: string): number { ... }
}

class Bar {
  method(input: string): number { ... }
}

const foo: Foo = new Foo(); // Okay.
const bar: Bar = new Foo(); // Okay.
```

### 2.2 **TypeScript 和 JavaScript 广泛应用鸭子类型相似，只检查类型定义的约束条件**

下面这个例子比较能够说明这一类型系统的灵活性：

```tsx
// 示例 from https://zhuanlan.zhihu.com/p/64446259

type Point = {
  x: number;
  y: number;
};

function plot(point: Point) {
  // ...
}

plot({ x: 10, y: 25 }); // Okay.
plot({ x: 8, y: 13, name: 'foo' }); // Extra fields Okay. Need enable `suppressExcessPropertyError`
```

### 2.3 **用 TypeScript 进行类型编程**

**一个典型便是泛型。**软件工程中，我们不仅要创建一致的定义良好的API，同时也要考虑可重用性。 组件不仅能够支持当前的数据类型，同时也能支持未来的数据类型，这在创建大型系统时为你提供了十分灵活的功能。

正常情况，我们会这样定义一个函数：

```tsx
function identity(arg: number): number {
    return arg;
}
```

若是 arg 改变类型，那么我们的函数可能又要改写成这样：

```tsx
function identity(arg: string): string {
    return arg;
}
```

因此，我们需要一种方法使返回值的类型与传入参数的类型是相同的。 类型变量，是一种特殊的变量，只用于表示类型而不是值，如上示例可以写成：

```tsx
function identity<T>(arg: T): T {
    return arg;
}
```

### 2.4 **TypeScript 提供一些工具类型来帮助常见的类型转换**

这里举例一个有意思的类型 NonNullable，这里粘同事写的一个例子来说明：

```tsx
function isNotNil<T>(x: T): x is NonNullable<T> {
  return x != null;
}

const type_guard_demo_1 = [1, 2, '', undefined, null].filter(isNotNil);
```

假设我们在这里不明确写上 isNotNil 的返回类型，那么 TypeScript 给你的推断结果或许就是，至少 TypeScript playground 上还是这样：

```tsx
const type_guard_demo_1: (string | number | null | undefined)[]
```

而对返回结果加上 NonNullable 声明，便可以得到你想要的结果：

```tsx
const type_guard_demo_1: (string | number)[]
```

`NonNullable<T>` 做的事情便是从类型T中剔除 null 和 undefined，然后构造一个类型。而得益于 TypeScript 本身就是用 TypeScript 开发的，你可以很容易看到 NonNullable 的实现：

```tsx
/**
 * Exclude null and undefined from T
 */
type NonNullable<T> = T extends null | undefined ? never : T;
```

在你觉得类型不够用的时候，你还可以通过**条件类型（Conditional Type）**来创造更多的自定义工具类型。

## 后记

以上，是对这两部分内容的一些笔记，这不适用于针对 TypeScript 的整体入门，相关内容应该会另起篇幅书写。

参考的资料与可以进一步阅读的资料包含在如下链接中：

1. [https://zhuanlan.zhihu.com/p/64446259](https://zhuanlan.zhihu.com/p/64446259)
2. [https://en.wikipedia.org/wiki/Generic_programming](https://en.wikipedia.org/wiki/Generic_programming)
3. [https://en.wikipedia.org/wiki/Nominal_type_system](https://en.wikipedia.org/wiki/Nominal_type_system)
4. [https://en.wikipedia.org/wiki/Structural_type_system](https://en.wikipedia.org/wiki/Structural_type_system)
5. [https://www.typescriptlang.org/docs/handbook/basic-types.html](https://www.typescriptlang.org/docs/handbook/basic-types.html)
6. [http://notebook.xyli.me/TAPL/type-system/](http://notebook.xyli.me/TAPL/type-system/)
7. [http://lucacardelli.name/papers/typesystems.pdf](http://lucacardelli.name/papers/typesystems.pdf)
