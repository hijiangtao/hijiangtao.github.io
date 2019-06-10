---
title: Rust学习笔记 - 模块系统
layout: post
thread: 222
date: 2019-05-30
author: Joe Jiang
categories: Document
tags: [2019, Rust, WebAssembly, 笔记]
excerpt: Rust 学习笔记，模块系统。
---

模块是 Rust 中的 私有性边界，如果你希望函数或结构体是私有的，将其放入模块。私有性规则有如下：

* 所有项（函数、方法、结构体、枚举、模块和常量）默认是私有的。
* 可以使用 `pub` 关键字使项变为公有。
* 不允许使用定义于当前模块的子模块中的私有代码。
* 允许使用任何定义于父模块或当前模块中的代码。

使用 `pub` 关键字使项变为公有，一个示例如下：

```rust
mod sound {
    pub mod instrument {
        pub fn clarinet() {
            // 函数体
        }
    }
}

fn main() {
    // 绝对路径
    crate::sound::instrument::clarinet();

    // 相对路径
    sound::instrument::clarinet();
}
```

使用 `super` 开头来构建相对路径，类似文件系统中以 `..` 开头的作用，一个示例如下：

```rust
mod instrument {
    fn clarinet() {
        super::breathe_in();
    }
}

fn breathe_in() {
    // 函数体
}
```

对结构和枚举使用 `pub` 的一个示例如下：

```rust
mod plant {
    pub struct Vegetable {
        pub name: String,
        id: i32,
    }

    impl Vegetable {
        pub fn new(name: &str) -> Vegetable {
            Vegetable {
                name: String::from(name),
                id: 1,
            }
        }
    }
}

fn main() {
    let mut v = plant::Vegetable::new("squash");

    v.name = String::from("butternut squash");
    println!("{} are delicious", v.name);

    // 如果将如下行取消注释代码将无法编译:
    // println!("The ID is {}", v.id);
}
```

使用 `use` 关键字将名称引入作用域的一个示例如下，优势是更加简洁、避免重复：

```rust
mod sound {
    pub mod instrument {
        pub fn clarinet() {
            // 函数体
        }
    }
}

use crate::sound::instrument; // 绝对路径
// use self::sound::instrument; // 相对路径

fn main() {
    instrument::clarinet();
    instrument::clarinet();
    instrument::clarinet();
}
```

通过 `as` 关键字重命名引入作用域的类型的一个示例如下：

```rust
use std::fmt::Result;
use std::io::Result as IoResult;

fn function1() -> Result {}
fn function2() -> IoResult<()> {}
```

通过 `pub use` 重导出名称的一个示例如下：

```rust
mod sound {
    pub mod instrument {
        pub fn clarinet() {
            // 函数体
        }
    }
}

mod performance_group {
    pub use crate::sound::instrument;

    pub fn clarinet_trio() {
        instrument::clarinet();
        instrument::clarinet();
        instrument::clarinet();
    }
}

fn main() {
    performance_group::clarinet_trio();
    performance_group::instrument::clarinet();
}
```

可以利用嵌套路径来消除重复的 `use` 书写：

```rust
use std::cmp::Ordering;
use std::io;
// to
use std::{cmp::Ordering, io};
```

也可以通过 `glob` 运算符将所有的公有定义引入作用域，例如如下示例引入了 `std::collections` 中定义的所有公有项：

```rust
use std::collections::*;
```
