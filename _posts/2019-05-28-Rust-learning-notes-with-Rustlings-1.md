---
title: Rust学习笔记 - 变量、数据类型与控制流
layout: post
thread: 219
date: 2019-05-28
author: Joe Jiang
categories: Document
tags: [2019, Rust, WebAssembly]
excerpt: Rust 学习笔记，变量、数据类型与控制流。
---

## 0. 变量

在 Rust 中，变量默认都是不可变的，采用关键字 `let` 声明，若需要使变量可变需使用 `mut`，但需要注意即便如此也不能改变变量的类型：

```rust
fn main() {
    // 若只使用 let x = 5; 则会报错
    let mut x = 5;
    println!("The value of x is: {}", x);
    x = 6;
    println!("The value of x is: {}", x);
}
```

而常量则是一直不可变的，比如声明一个名为 `MAX_POINTS` 的常量：

```rust
const MAX_POINTS: u32 = 100_000;
```

通过 Shadowing 可以复用变量名，但依旧保持变量的不可变性，例如：

```rust
fn main() {
    let x = 5;

    let x = x + 1;

    let x = x * 2;

    println!("The value of x is: {}", x); 
}
```

## 1. 数据类型

Rust 是静态类型语言，即编译时就必须知道所有变量的类型。当多种类型均有可能时，必须增加类型注解：

```rust
let guess: u32 = "42".parse().expect("Not a number!");
```

变量包含**标量类型与复合类型**，其中 Rust 有四种基本的标量类型（代表一个单独的值）：整型、浮点型、布尔类型和字符类型。

整型类别有这几种：

| 长度  | 有符号 | 无符号 |
|---------|---------|----------|
| 8-bit   | `i8`    | `u8`     |
| 16-bit  | `i16`   | `u16`    |
| 32-bit  | `i32`   | `u32`    |
| 64-bit  | `i64`   | `u64`    |
| 128-bit | `i128`  | `u128`   |
| arch    | `isize` | `usize`  |

浮点数采用 IEEE-754 标准表示。`f32` 是单精度浮点数，`f64` 是双精度浮点数。

```rust
fn main() {
    let x = 2.0; // f64

    let y: f32 = 3.0; // f32
}
```

布尔类型也存在两种声明方式：

```rust
fn main() {
    let t = true;

    let f: bool = false; // 显式指定类型注解
}
```

需要注意，Rust 的字符类型由单引号指定，而字符串使用双引号。`char` 代表一个 Unicode 标量：

```rust
let c = 'z';
```

复合类型包含元组和数组：

```rust
fn main() {
    // 类型注解可选
    let tup: (i32, f64, u8) = (500, 6.4, 1);

    // 解构
    let (x, y, z) = tup;

    // 除了使用模式匹配解构外，也可以使用点号（.）后跟值的索引来直接访问它们
    // 元组的第一个索引值是 0
    let one = tup.2; 

    println!("The value of y is: {}", y);
}
```

与元组不同，数组中的每个元素的类型必须相同，且定长，一旦声明长度不可改变，如需变长则使用 vector：

```rust
fn main() {
    let a = [1, 2, 3, 4, 5];

    let first = a[0];
    let second = a[1];
}
```

数组的类型比较有趣；它看起来像 [type; number]，例如：

```rust
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

## 2. 控制流

Rust 有三种循环：loop、while 和 for

```rust
let mut number = 3;

let result = loop {
    number += 1;

    if number == 10 {
        break number * 2;
    }
};

while number != 0 {
    println!("{}!", number);

    number = number - 1;
}

let a = [10, 20, 30, 40, 50];
let mut index = 0;

while index < 5 {
    println!("the value is: {}", a[index]);

    index = index + 1;
}
```

Rust 在 if 表达式中总是期望一个 bool 值，而不会替你去转换：

```rust
fn main() {
    let number = 3;

    if number != 0 {
        println!("number was something other than zero");
    }
}
```