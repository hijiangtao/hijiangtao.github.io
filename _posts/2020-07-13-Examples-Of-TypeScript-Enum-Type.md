---
title: TypeScript 枚举类型用法示例
layout: post
thread: 253
date: 2020-07-13
author: Joe Jiang
categories: Document
tags: [2020, 前端, TypeScript, Enum, 枚举, 示例]
excerpt: 与 TypeScript 相关的一些记录。
---

使用枚举类型可以允许我们定义一些带名字的常量，也可以清晰地表达意图或创建一组有区别的用例。在 TypeScript 中，支持数字的和基于字符串的枚举。

因为对同学的错误指导，于是仔细把 TypeScript Handbook Enum 一节过了一遍，罗列了以下十一个示例，希望能通过这些场景更好地解释如何使用 TypeScript Enum 类型。

*注：以下代码通过 TypeScript 版本 3.9.2 演绎，文中提及的 Enum 在大部分时候等价于中文“枚举”一词。*

### 1. 数字枚举示例

```tsx
enum NumberEnum {
    Fisrt = 0,
    Second = 1,
}
```

### 2. 字符串枚举示例

```tsx
enum StringEnum {
    Up = "UP",
    Down = "DOWN",
    Left = "LEFT",
    Right = "RIGHT",
}
```

### 3. 不带初始化值的数字枚举

若定义的成员不带初始化值，则会自动加1增长，还是上面那个例子，我们加点东西：

```tsx
enum NumberEnum {
    Fisrt = 0,
    Second = 1,
    Third,
    Fourth
}

// (enum member) NumberEnum.Fisrt = 0
NumberEnum.Fisrt

// (enum member) NumberEnum.Third = 2
NumberEnum.Third
```

### 4. 数字枚举在不指定初始化值时默认从0取值

如果不指定初始化值，那么取值会从0开始计算，比如：

```tsx
enum E { X }

console.log(E.X); // 0
```

### 5. 不能随意摆放不带初始化值的枚举

针对不带初始化器的枚举定义时，位置也是有要求的。根据 TypeScrtip Handbook，不带初始化器的枚举或者被放在第一的位置，或者被放在使用了数字常量或其它常量初始化了的枚举后面。意即下面这种情况是会出问题的：

```tsx
const getSomeValue = () => 0;

enum E {
    A = getSomeValue(),
    // Enum member must have initializer.ts(1061)
    B,
}
```

### 6. 枚举成员的值除了是常量，还可以是计算出来的结果

每个枚举成员都带有一个值，上面说过的都是常量，但是这个值也可以是计算出来的，即 computed value，来看一个带有计算结果的例子：

```tsx
enum EnumWithBothTwoMembers {
    // constant members
    None,
    Read    = 1 << 1,
    Write   = 1 << 2,
    ReadWrite  = Read | Write,
    
    // computed member
    G = "123".length
}

const EnumGValue = EnumWithBothTwoMembers.G; // 3
```

### 7. 数字枚举可以反向映射，字符串枚举不行

除了创建一个以属性名做为对象成员的对象之外，数字枚举成员还具有了反向映射，从枚举值到枚举名字。 例如下面的例子中：

```tsx
enum NumberTypeEnum {
    A
}

const nameOfA = NumberTypeEnum[NumberTypeEnum.A]; // "A"
```

但是字符串枚举不行：

```tsx
enum StringTypeEnum {
    TestName = 'TestValue'
}

// Element implicitly has an 'any' type because expression of type 'StringTypeEnum.TestName' can't be used to index type 'typeof StringTypeEnum'.
const stringEnumName = StringTypeEnum[StringTypeEnum.TestName];
```

### 8. 枚举前面加个 const 可以减少开销

再来看另一个例子，在枚举关键字前面加上 const 会发生什么？这就是常量枚举。

常量枚举不同于常规的枚举，它们在编译阶段会被删除，且只能使用常量枚举表达式。常量枚举成员在使用的地方会被内联进来。来看下面一个例子：

```tsx
const enum Directions {
    Up,
    Down,
    Left,
    Right
}

let directions = [Directions.Up, Directions.Down, Directions.Left, Directions.Right];

// generated code
var directions = [0 /* Up */, 1 /* Down */, 2 /* Left */, 3 /* Right */];
```

这样使用，可以满足一些需要额外考虑生成代码开销以及对枚举值间接引用存在成本的场景。

### 9. 外部枚举 declare

再来看一个 declare 的例子，比如说当我们在写一些单元测试时，有些对象我们并不想完整构造（因为太麻烦了），而我们又想声明一个已有 shape 的枚举类型，那么 declare 就派上了用场：

```tsx
declare enum Enum {
    A = 1,
    B, // computed value
    C = 2
}
```

### 10. 枚举 key 不能是计算属性

computed value 可以作为枚举值，但不能当作枚举类型的 key：

```tsx
enum OneMapEnum {
    Dog = 'Dog',
    Cat = 'Cat'
};

enum EnumUseEnumValueAsKey {
    // Computed property names are not allowed in enums.ts(1164)
    [OneMapEnum.Dog] = OneMapEnum.Dog
}
```

### 11. 只有数字枚举类型可以用计算值

如下我们定义两个常量，一个是字符串，一个是数字，但只有在数字枚举类型中我们可以使用计算值，联合枚举以及字符串枚举均不可使用计算值，即我们定义的 const 变量。

```tsx
const StringConst = '0';
const NumberConst = 0;

enum UseStringConstAsValue {
    // Only numeric enums can have computed members, but this expression has type '"0"'. If you do not need exhaustiveness checks, consider using an object literal instead.ts(18033)
    StringTest = StringConst,
}
enum UseNumberConstAsValue {
    NumberTest = NumberConst,
}
```
