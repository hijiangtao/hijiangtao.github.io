---
title: 赶上 ECMAScript 潮流：用现代 JavaScript 编程
layout: post
thread: 205
date: 2018-11-24
author: Joe Jiang
categories: Document
tags: [前端, JavaScript, 2018, ECMAScript, ES2018]
excerpt: 距年中 ECMAScript2018 发布也有几个月了，站在2018年末时间点上，如何赶上 ECMAScript 的潮流呢？
---

前言：得益于 TC39 从2015年开始对 ECMAScript 标准才去的年更节奏，JavaScript 开发者终生学习的「梦想」得以实现。口口相传的 ES6 已经发布三年有余，而距年中 ECMAScript2018 发布也有几个月了，站在2018年末时间点上，如何赶上 ECMAScript 的潮流呢？

本文将会介绍一些 [ECMAScript2018](http://www.ecma-international.org/ecma-262/9.0/index.html#Title) 标准新特性与尚在襁褓中的一些[有趣提案](https://github.com/tc39/proposals)，汇总共十个方面。

> 为了便于读者阅读理解，请注意本文中提到的「ECMAScript2018」等价于「ES9」，「Stage 1/2/3/4」等概念可参考 [TC39 定义](https://tc39.github.io/process-document/)。本文在兼容性评估上选用了「Chrome/Edge/Opera/Safari/Firefox」五类主流浏览器与「Node」运行时进行评判，完整的评估可查阅 [Can I use](https://caniuse.com/)。

## ECMAScript 新特性与标准提案

### 1. ES 模块

第一个要介绍的 ES 模块，由于历史上 JavaScript 没有提供模块系统，在远古时期我们常用多个 script 标签将代码进行人工隔离。但得益于浏览器和 Node.js 对于 ES 标准的讨论统一，现在我们可以在浏览器中直接书写 ES 模块语法。比如我们新建一个 `lib.mjs` 文件在其中导出一个函数，那么在 `main.mjs` 中我便可以直接导入使用它。

```javascript
// lib.mjs
export const repeat = (string) => `${string} ${string}`;

// main.mjs
import {repeat} from './lib.mjs';
repeat('#io18');
```

而在浏览器中我们可以用 `type="module"` 引入 ES 模块，我们还可以引入一个 JavaScript 文件用于兼容不支持 ES 模块写法的浏览器。加上 `rel="modulepreload"` 我们可以告诉浏览器预加载一些公共库与代码。

```javascript
// 浏览器
<script type="module" src="/mypath_to_js_module.mjs"></script>
<script nomodule src="fallback.js"></script>

// preload
<link rel="modulepreload" href="lib.mjs" >
```

上述的写法中都用到了 mjs 后缀，然而在浏览器中引用 ES 模块这种做法并不是强制的，但在 Node 实验性新特性中 mjs 是必须的。

```javascript
node --experimental-modules main.mjs
```

兼容性如下

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-all.png )

### 2. 数字分隔符

给到你一串很长的数字，如何快速辨别其数值？

```
1000000000000
1019436871.42
```

我们换个写法，是不是就明确了不少：

```
1_000_000_000_000
1_019_436_871.42
```

对于非十进制数值，ES 允许我们同样用下划线进行区分

```
// 十六进制
0b01001001_00101111_01001111
0x23_69_6F_31_38
```

然而不幸的是这仍是一个处于 Stage 2 阶段的[提案](https://github.com/tc39/proposal-numeric-separator)，但幸好我们有 Babel。兼容性如下：

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-none.png )

### 3. BigInt

在 JavaScript 中安全整数范围是多少，`console.log` 一下。在此之前，我们若要操作超出安全整数范围的数值，结果正确性将不被得到保证，同样的问题也曾发生在 Node 上，曾有一个 issue 直指由于 Node 会偶发性给多个文件/文件夹赋值相同 inode 数。

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-node-issue.png )

对于超出了 Number 能够表示的安全整数范围的整数操作，我们现在可以使用 BigInt 了。虽然有很多 polyfill 支持，但现在我们得到官方支持了。

```javascript
console.log(Number.MIN_SAFE_INTEGER); // 9007199254740991
console.log(Number.MAX_SAFE_INTEGER); // -9007199254740991

// BigInt 可以直接使用，也可以在整数值后面加上n用以表示属于 BigInt 类型
BigInt(Number.MAX_SAFE_INTEGER) + 2n;
// → 9007199254740993n 正确

1234567890123456789 * 123;
// → 151851850485185200000 错误结果

1234567890123456789n * 123n;
// → 151851850485185185047n 正确

42n === BigInt(42);

typeof 123n; // 'bigint'

BigInt(1.5);
// → RangeError

BigInt('1.5');
// → SyntaxError
```

兼容性如下：

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-all.png )

### 4. Async Iterator/Generator

我们可能习惯了这样操作一段数据读取：

```javascript
const print = (readable) => {
    readable.setEncoding('utf8');
    let data = '';
    readable.on('data', (chunk) => {
        data += chunk;
    });
    readable.on('end', () => {
        console.log(data);
    })
}

const fs = require('fs');
print(fs.createReadStream('./file.txt'));
```

但好消息是 await 支持 for-each-of 了，于是我们可以这样写了：

```javascript
async function print(readable) {
    readable.setEncoding('utf8');
    let data = '';
    for await (const chunk of readable) {
        data += chunk;
    }
    
    console.log(data);
}

const fs = require('fs');
print(fs.createReadStream('./file.txt'));
```

兼容性

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-one-lose.png )

### 5. 正则匹配与字符串操作方式

现在我们来看看 dotAll 模式。字符串模版我们都用过，比如要匹配出下面的 Hello world 我们该怎么做？

```javascript
const input = `
Hi, Fliggy. Hello 
world.
`;

/Hello.world/u.test(input); // false
```

我们可能会想到`.`可以表示任意字符，但在这里不行，因为匹配不上换行符。于是我们可以这样做：

```javascript
/Hello[\s\S]world/u.test(input); // 所有空格和所有非空格匹配
/Hello[^]world/u.test(input); // 所有非空匹配
```

现在 ES 支持 dotAll 模式，于是我们可以这样写：

```javascript
/Hello.world/su.test(input); // true
```

接下来要介绍的是 Name Capture，他的作用在于将从前我们需要通过下标获取的正则匹配结果通过显式命名方法进行匹配，例如原来我们这样匹配日期：

```javascript
const pattern = /(\d{4})-(\d{2})-(\d{2})/u;
const result = pattern.exec('2017-07-10');
// result[0] === '2017-07-10'
// result[1] === '2017'
// result[2] === '07'
// result[3] === '10'
```

现在我们可以这样写：

```javascript
const pattern = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/u;
const result = pattern.exec('2017-07-10');
// result.groups.year === '2017'
// result.groups.month === '07'
// result.groups.day === '10'
```

对于异常复杂的正则表达式，新特性写法的优势得以体现。

第三个特性来自 Unicode 字符匹配。现在 ES 提供两种简便的匹配方式，`\p{…}` 用于匹配非二进制 Unicode 字符，而 `\P{…}` 则取其相反。

```javascript
/\p{Number}/u.test('①');      // true
/\p{Alphabetic}/u.test('雪');  // true

/\P{Number}/u.test('①');      // false
/\P{Alphabetic}/u.test('雪');  // false

/^\p{Math}+$/u.test('∛∞∉');                            // true
/^\p{Script_Extensions=Hiragana}+$/u.test('ひらがな');  // true
```

以上所述几个方法的兼容性相同，当下 Edge 与 Firefox 还未支持。

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-two-lose.png )

第四个特性是字符串全匹配。通过 String matchall 特性，我们原来通过 while 循环匹配所有符合正则的写法可以直接通过 `.matchAll` 一次性搞定：

```javascript
const string = 'Magic hex numbers: DEADBEEF CAFE 8BADF00D';
const regex = /\b\p{ASCII_Hex_Digit}+\b/gu;
let match;

// 旧方式
while (match = regex.exec(string)) {
    console.log(match);
}

// 新方式
for (const match of string.matchAll(regex)) {
    console.log(match);
}
```

新特性仍然处于 Stage 3，所以支持度比较感人，但社区已经有很多 polyfill 支持这种写法。

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-none.png )

### 6. catch binding

正则总是让人难以理解，来说一个简单些的新特性—— `try/catch`。现在我们可以选择性的决定 catch 是否带上入参了。

```javascript
try {} catch (e) {} // 以前
try {} catch {} // 现在
```

兼容性

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-one-lose.png )


### 7. trim

假设给你一串字符串，如果让你单独删除 hello 前部的空格或者尾部的空格，你会怎么做？

```javascript
const string = '      hello        ';
```

以前的话，你大概率得用正则来实现，而现在 `trimStart` 和 `trimEnd` 两个方法便可以完成操作。

```javascript
string.trim(); // 'hello';
string.trimStart(); // 'hello        ';
string.trimEnd(); // '      hello';
```

兼容性

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-one-lose.png )

### 8. Promise.prototype.finally

Promise 我们都写过，假设我们 fetch 一段数据，在结果回来之前我们需要加载 loading 动画，而结果回来后不管正确还是错误我们都需要去除这段动画。在原来，我们需要将相同的逻辑写在好几个地方（观察 `isLoading = false;` 写法）：

```javascript
let isLoading = true;

fetch(myRequest).then(function(response) {
    var contentType = response.headers.get("content-type");
    if(contentType && contentType.includes("application/json")) {
      return response.json();
    }
    throw new TypeError("Oops, we haven't got JSON!");
  })
  .then(function(json) {
    isLoading = false;
  })
  .catch(function(error) { 
    isLoading = false;
    console.log(error); 
  });
```

而现在 Promise 原型方法上补充的 finally 可以给我们减少冗余代码。

```javascript
let isLoading = true;

fetch(myRequest).then(function(response) {
    var contentType = response.headers.get("content-type");
    if(contentType && contentType.includes("application/json")) {
      return response.json();
    }
    throw new TypeError("Oops, we haven't got JSON!");
  })
  .then(function(json) { /* ... */ })
  .catch(function(error) { console.log(error); })
  .finally(function() { isLoading = false; });
```

兼容性

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-one-lose.png )

### 9. 对象解构

解构这个概念我们都不陌生，可能我们也一直在毫无感知的用着，但 ES2015 只给定了数组解构的标准，而直到2017年初针对对象的解构操作还处于 stage 3 阶段。

```javascript
const person = {
    firstName: 'Sebastian',
    lastName: 'Markbåge',
    country: 'USA',
    state: 'CA',
};
const { firstName, lastName, ...rest } = person;
console.log(firstName); // Sebastian
console.log(lastName); // Markbåge
console.log(rest); // { country: 'USA', state: 'CA' }

// Spread
const personCopy = { firstName, lastName, ...rest };
console.log(personCopy);
// { firstName: 'Sebastian', lastName: 'Markbåge', country: 'USA', state: 'CA' }
```

在许多情况下，对象解构能为我们提供了一个更优雅的 `Object.assign()` 替代方案，例如合并两个对象：

```javascript
const defaultSettings = { logWarnings: false, logErrors: false };
const userSettings = { logErrors: true };

// 老方式
const settings1 = Object.assign({}, defaultSettings, userSettings);

// 新方式
const settings2 = { ...defaultSettings, ...userSettings };

// 结果
// { logWarnings: false, logErrors: true }
```

兼容性

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-one-lose.png )

### 10. Class

最后我们来聊聊 JavaScript 中的 class。首先是字段定义，不再局限于（构造）函数中，我们可以这样定义属性 `instanceProperty` 和静态属性 `staticProperty`：

```javascript
class MyClass {
    instanceProperty = 0;
    static staticProperty = 0;
}
```

其次是私有变量的定义与使用。在历史的长河中，JavaScript 一直缺少像其他编程语言「正规军」所有的私有变量概念，开发者长期以来都通过闭包来实现相关功能。而现在，标准赋予了 ES 这门语言拥有私有变量定义的可能性。

在使用方法上，如果需要在 class 中定义仅在类中可访问的属性，我们需要以`＃`开头定义私有变量，就像下面这样：

```javascript
class MyClass {
    #foo; // 必须声明 
    constructor(foo) {
        this.#foo = foo;
    }
    incFoo() {
        this.#foo++;
    }
}
```

至今为止，主流浏览器和 Node 均未实现该特性。

![](/assets/in-post/2018-11-24-Write-JavaScript-in-2018-none.png )

> 私有变量的定义方式被很多开发者吐槽很「丑」，但「不幸」的是这份提案已经处于 stage 3，提案详情见 <https://github.com/tc39/proposal-class-fields>

## 后记

知乎上有个问题说的是「[为什么那么多公司仍然在使用JDK6？](https://www.zhihu.com/question/30137699)」，作者困惑于 JDK11 都已发布但很多公司还在用着老旧的 Java 版本的现状；而反观 JavaScript(ECMAScript) 生态，在 ECMAScript2018 远未定稿之时，很多开发者便得心应手的用上了新语法产出代码，很多写法可能仍处于 Stage 3。Java 和 JavaScript 不仅在关系上类似于雷锋于雷峰塔，就在对待语言标准上，两边的开发者态度也是截然相反。

ECMAScript 的征程是星辰大海，跟上 TA 的脚步。

## 参考

* [Build the future of the web with modern JavaScript](https://www.youtube.com/watch?v=mIWCLOftfRw)
* <https://github.com/tc39/proposal-numeric-separator>
* [BigInt：JavaScript 中的任意精度整数](https://zhuanlan.zhihu.com/p/36330307)
* <http://2ality.com/2016/10/asynchronous-iteration.html>
* <https://github.com/tc39/proposal-class-fields>
* <https://developers.google.com/web/updates/2017/06/object-rest-spread>