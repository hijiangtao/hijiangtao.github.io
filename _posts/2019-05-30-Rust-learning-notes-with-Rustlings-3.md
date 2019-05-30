---
title: Rust学习笔记 - 测试
layout: post
thread: 221
date: 2019-05-30
author: Joe Jiang
categories: Document
tags: [2019, Rust, WebAssembly, 笔记]
excerpt: Rust 学习笔记，关于测试。
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