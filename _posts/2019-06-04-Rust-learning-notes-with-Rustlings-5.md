---
title: Rust学习笔记 - 错误处理
layout: post
thread: 224
date: 2019-06-04
author: Joe Jiang
categories: Document
tags: [2019, Rust, WebAssembly, 笔记]
excerpt: Rust 学习笔记，错误处理。
---

Rust 将错误组合成两个主要类别：可恢复错误（recoverable）和不可恢复错误（unrecoverable）。可恢复错误比如未找到文件。不可恢复错误比如尝试访问超过数组结尾的位置。

当不使用 `--release` 参数运行 `cargo build` 或 `cargo run` 时 Rust 的 debug 标识会默认启用。

`panic!` 用于不可恢复的错误，`Result` 用于可恢复的错误。

使用 Result 处理错误的一个基本示例如下：

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => {
            panic!("There was a problem opening the file: {:?}", error)
        },
    };
}
```

而为了匹配不同的错误，一个更详细的示例如下所示：

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("Tried to create file but there was a problem: {:?}", e),
            },
            other_error => panic!("There was a problem opening the file: {:?}", other_error),
        },
    };
}
```

如上示例的另一种写法（可以消除大量处理错误时嵌套的 `match` 表达式）如下：

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt").map_err(|error| {
        if error.kind() == ErrorKind::NotFound {
            File::create("hello.txt").unwrap_or_else(|error| {
                panic!("Tried to create file but there was a problem: {:?}", error);
            })
        } else {
            panic!("There was a problem opening the file: {:?}", error);
        }
    });
}
```

失败时 `panic` 还有两种简写 `unwrap` 以及 `expect`。如果 `Result` 值是成员 `Ok`，`unwrap` 会返回 `Ok` 中的值，否则 `unwrap` 会调用 `panic!`；`expect` 用来调用 `panic!` 的错误信息将会作为参数传递给 `expect`。

而传播错误的一个示例如下：

```rust
use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
```

若是用 `?` 简写，示例可以改为：

```rust
use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```

但需要注意 `?` 只能被用于返回 `Result` 的函数。