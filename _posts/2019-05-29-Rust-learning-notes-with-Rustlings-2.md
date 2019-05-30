---
title: Rust学习笔记 - 函数与所有权
layout: post
thread: 220
date: 2019-05-29
author: Joe Jiang
categories: Document
tags: [2019, Rust, WebAssembly, 笔记]
excerpt: Rust 学习笔记，关于函数、所有权以及 slice 用法等。
---

## 0. 函数

在函数签名中，必须声明每个参数的类型。

```rust
fn main() {
    another_function(5, 6);
}

fn another_function(x: i32, y: i32) {
    println!("The value of x is: {}", x);
    println!("The value of y is: {}", y);
}
```

函数定义也是语句，语句不返回值。具有返回值的函数需这样定义：

```rust
fn main() {
    let x = plus_one(5);

    println!("The value of x is: {}", x);
}

fn plus_one(x: i32) -> i32 {
    x + 1
}
```

在 Rust 中，函数的返回值等同于函数体最后一个表达式的值。

## 1. 所有权 / owner

### 1.1 所有权简介

所有权有以下几个规则：

* Rust 中的每一个值都有一个被称为其所有者的变量。
* 值有且只有一个所有者。
* 当所有者（变量）离开作用域，这个值将被丢弃。

以下示例展示了移动一个变量后，前一个变量无效的场景。注意，Rust 永远不会自动创建数据的“深拷贝”：

```rust
let s1 = String::from("hello");
let s2 = s1;

println!("{}, world!", s1); // error
```

如果我们确实需要深度复制 `String` 中堆上的数据，而不仅仅是栈上的数据，则需使用 `clone` 函数：

```rust
let s1 = String::from("hello");
let s2 = s1.clone();

println!("s1 = {}, s2 = {}", s1, s2);
```

如果一个类型拥有 `Copy` trait，一个旧的变量在将其赋值给其他变量后仍然可用。

* 所有整数类型，比如 `u32`。
* 布尔类型 `bool`。
* 所有浮点数类型，比如 `f64`。
* 字符类型，`char`。
* 元组，当且仅当其包含的类型也都是 `Copy` 时。比如，`(i32, i32)`

一个函数间转移返回权的例子如下：

```rust
fn main() {
    let s1 = gives_ownership();         // gives_ownership 将返回值
                                        // 移给 s1

    let s2 = String::from("hello");     // s2 进入作用域

    let s3 = takes_and_gives_back(s2);  // s2 被移动到
                                        // takes_and_gives_back 中, 
                                        // 它也将返回值移给 s3
} // 这里, s3 移出作用域并被丢弃。s2 也移出作用域，但已被移走，
  // 所以什么也不会发生。s1 移出作用域并被丢弃

fn gives_ownership() -> String {             // gives_ownership 将返回值移动给
                                             // 调用它的函数
 
    let some_string = String::from("hello"); // some_string 进入作用域.

    some_string                              // 返回 some_string 并移出给调用的函数
}

// takes_and_gives_back 将传入字符串并返回该值
fn takes_and_gives_back(a_string: String) -> String { // a_string 进入作用域

    a_string  // 返回 a_string 并移出给调用的函数
}
```

### 1.2 引用与借用

引用允许我们使用值但不获取其所有权，例如：

```rust
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);

    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize { // s 是对 String 的引用
    s.len()
}
```

获取引用作为函数参数被称为借用，而默认情况下不允许修改引用的值，若需修改必须创建一个可变引用。需要注意几点：

1. 在特定作用域中的特定数据有且只能有一个可变引用，以避免数据竞争。
2. 不能在拥有不可变引用的同时拥有可变引用。

一个可变引用的示例如下：

```rust
fn main() {
    let mut s = String::from("hello");

    change(&mut s);
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}
```

Rust 编译器会确保引用永远不会变成悬垂状态：

```rust
fn dangle() -> &String { // dangle 返回一个字符串的引用

    let s = String::from("hello"); // s 是一个新字符串

    &s // 返回字符串 s 的引用，解决办法是直接返回 String
} // 这里 s 离开作用域并被丢弃。其内存被释放。
```

总结来看：

* 在任意给定时间，要么只能有一个可变引用，要么只能有多个不可变引用。
* 引用必须总是有效。

### 1.3 Slice

```rust
let s = String::from("hello world");

// .. 是 range 语法，两边下标可省略
let hello = &s[0..5]; // 不包含结束下标
let world = &s[6..=10]; // 包含结束下标
```

字符串字面值就是 slice。