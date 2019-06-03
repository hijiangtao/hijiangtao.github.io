---
title: Rust学习笔记 - 测试与字符串
layout: post
thread: 221
date: 2019-05-30
author: Joe Jiang
categories: Document
tags: [2019, Rust, WebAssembly, 笔记]
excerpt: Rust 学习笔记，关于测试与字符串操作的内容。
---

## 0. 测试

在 Rust 中，需要需要使用 `#[test]` 属性标明哪些函数是测试，以下为一个成功测试和失败测试：

```rust
# fn main() {}
#[cfg(test)]
mod tests {
    #[test]
    fn exploration() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    fn another() {
        panic!("Make this test fail");
    }
}
```

`assert_eq!` 和 `assert_ne!` 两个宏分别比较两个值是相等还是不相等。其他的一些宏还包括 `should_panic` 等。一个使用 `Result<T, E>` 编写测试的示例如下：

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() -> Result<(), String> {
        if 2 + 2 == 4 {
            Ok(())
        } else {
            Err(String::from("two plus two does not equal four"))
        }
    }
}
```

## 1. 字符串

Rust 的核心语言中只有一种字符串类型： `str`。`String` 类型由标准库提供，是可增长的、可变的、有所有权的、UTF-8 编码的字符串类型。

### 新建字符串

```rust
// 第一种方法
let data = "initial contents";
let s = data.to_string();

// 第二种方法
let s = String::from("initial contents");
```

### 更新字符串

利用 + 的示例如下：

```rust
let mut s = String::from("foo");
s.push_str("bar");
s.push('l');

let s2 = String::from("world!");

let s3 = s + &s2; // 注意 s 被移动了，不能继续使用，且 + 不能将两个 String 相加
```

利用 `format!` 的示例（不会获取任何参数的所有权）如下：

```rust
let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");

let s = format!("{}-{}-{}", s1, s2, s3);
```

### 索引字符串

Rust 字符串不支持索引，可以通过 `[]` 和一个 `range` 来创建含特定字节的字符串 slice：

```rust
let hello = "Здравствуйте";

let s = &hello[0..4];
```

### 遍历字符串

操作单独 Unicode 标量的示例如下：

```rust
for c in "नमस्ते".chars() {
    println!("{}", c);
}
```

chars 换成 bytes 则可以返回每一个原始字节：

```rust
for c in "नमस्ते".chars() {
    println!("{}", c);
}
```

### 关于 `str / String / &str / &String`

首先看一下 str 和 String 间的区别：String 是一个可变的、堆上分配的 UTF-8 的字节缓冲区。而 str 是一个不可变的固定长度的字符串，如果是从 String 解引用而来的，则指向堆上，如果是字面值，则指向静态内存。

&String 是 borrowed String，一个指针类型，可以传递而不放弃所有权。事实上，一个 &String 可以当做是 &str。例如，`foo()` 可以使用 string slice 或者 borrowed String 类型。

```rust
fn main() {
    let s = String::from("Hello, Rust!");
    foo(&s);
}
fn foo(s: &str) {
    println!("{}", s);
}
```

String、&String、&str 三者之间的转换示例如下：

```rust
// &str => String
let a = "Test";
let b = a.to_string();
let b = String::from("Test");
let b = a.to_owned();

// String => &str
let e = &String::from("Hello Rust");
// 或使用as_str()
let e_tmp = String::from("Hello Rust");
let e = e_tmp.as_str();
// 不能直接用 String::from("Hello Rust").as_str();

// String + &str => String
let mut strs = "Hello".to_string();
strs.push_str(" Rust");
println!("{}", strs);
```

只想要一个字符串的只读视图、或者 `&str` 作为入参，那就首选 `&str`；如果想拥有所有权、修改字符串那就用 `String`。