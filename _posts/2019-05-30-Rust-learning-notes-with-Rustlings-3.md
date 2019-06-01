---
title: Rust学习笔记 - 测试与字符串操作
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

Rust 字符串不支持索引。