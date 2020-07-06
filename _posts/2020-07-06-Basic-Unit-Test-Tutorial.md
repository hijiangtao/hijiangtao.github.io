---
title: 基于 Jasmine 和 Karma 的单元测试基础教程
layout: post
thread: 251
date: 2020-07-06
author: Joe Jiang
categories: Document
tags: [2020, 前端, 单元测试, Jasmine, Karma, Angular, 质量]
excerpt: 单元测试框架方方面面，本文除了列出一些单元测试的基础概念外，还会基于 Jasmine 和 Karma 对单元测试的一些实际用例进行介绍。
---

> 在计算机编程中，单元测试（英语：Unit Testing）又称为模块测试，是针对程序模块（软件设计的最小单位）来进行正确性检验的测试工作。程序单元是应用的最小可测试部件。在过程化编程中，一个单元就是单个程序、函数、过程等；对于面向对象编程，最小单元就是方法，包括基类（超类）、抽象类、或者派生类（子类）中的方法。

以上是维基百科对单元测试的一段定义。单元测试对我们的嗲吗质量保障有至关重要的作用，但换到国内，其实大部分企业在应用（前端）开发时并不会太在意单元测试，感觉在大家心里，业务的快速迭代会比测试覆盖更加重要，但其实为一个应用覆盖单元测试是非常简单的一件事情。

## 单元测试简介与 FIRST 原则

TDD (Test Driven Development) 测试驱动开发，是敏捷开发中提出的最佳实践之一。测试驱动开发，对软件质量起到了规范性的控制。未写实现，先写测试，一度成为 Java 领域研发的圣经。随着 Javascript 兴起，功能越来越多，代码量越来越大，开发人员素质相差悬殊，真的有必要建立对代码的规范性控制。

而 Jasmine 提出的是 BDD (Behavior Driven Development) 行为驱动开发。即通过用自然语言书写非程序员可读的测试用例扩展了测试驱动开发方法, 行为驱动开发人员使用混合了领域中统一的语言的母语语言来描述他们的代码的目的。

当我们在写单元测试时，需要遵循 FIRST 原则：

1. 执行快速 (Fast)：单元测试执行一定要快，这样研发同学可以在项目周期的任意时间点，可以方便地执行单元测试，即便是有几千个单元测试也不影响。这些单元测试最好在几秒内运行完并返回期望的结果。
2. 隔离 (Isolated)：每一个测试用例运行时、准备环境变量时或测试前环境搭建过程中，都是隔离的。过程中，不能有相互依赖，这样最终的测试结果可以不受其它因素的影响。
3. 可重复 (Repeatable) 执行：单元测试可以在不做任何修改情况下，在任何环境下执行。如果单元测试不依赖网络或数据库，单元测试失败原因的排查中，就不用考虑这方面的原因，毕竟单元测试依赖的只是被测试类或方法中的代码。这个原则，可以方便地让自己的单元测试逻辑保持良好的价值。
4. 代码测试中自校验 (Self-validating)：写了单元测试后，咱们不能再依赖肉眼观察，看被测代码的结果是否正确。测试代码自身会明白无误地告诉咱哪条测试用例失败了。
5. 即时 (Timely)：按 TDD 的理念，应该在相应的业务代码之前定单元测试。这一点上，大家可以自己掌握是否采用 TDD 的开发理念。不过，这个的理念是，即时地写单元代码，即便是很小的代码也是这样。

## Jasmine + Karma 接入流程概览

以下基于 Jasmine 来说说如何在一个应用中引入单元测试，不同框架在流程上大同小异，你可以查看对应单元测试框架的文档了解更多。

要在一个项目中跑通单元测试流程一般需要两件事情，即单元测试框架以及自动化执行流程。以 Angular 内置的测试能力为例，Jasmine 做单元测试，Karma 自动化完成单元测试：

* Jasmine 是一个用于测试 JavaScript 代码的行为驱动开发框架。它不依赖于任何其他 JavaScript 框架，且不依赖 DOM。
* Karma 是一个基于 Node.js 的 JavaScript 测试执行过程管理工具 (Test Runner)。该工具可用于测试所有主流 Web 浏览器，也可集成到CI (Continuous integration) 工具，也可和其他代码编辑器一起使用。

首先通过 npm 将相关依赖装上：

```
npm install --save-dev karma
npm install --save-dev Jasime-core 
npm install --save-dev karma-Jasmine

// 如果你需要生成代码覆盖率，再把这个也装上
npm install --save-dev karma-coverage
```

在安装完两个工具环境之后，在编写单元测试之前，一般需要为测试执行管理工具做一些配置。比如 Karma 需要你在项目根目录下定义一个 `karma.conf.js` 文件，用于指明 karma 运行时的一些配置。比如当你需要，在 Karma 配置文件 `karma.conf.js` 中，浏览器的紧下方，添加自定义的启动器，名叫 ChromeNoSandbox:

```javascript
browsers: ['Chrome'],
customLaunchers: {
  ChromeHeadlessCI: {
    base: 'ChromeHeadless',
    flags: ['--no-sandbox']
  }
},
```

为了允许 Karma 找到你的测试文件，你还应该添加类似这样的配置：

```
files: ['./src/*.spec.js'],
exclude: ['karma.conf.js'],
```

具体配置可以查看 Karma 文档。配置完成后，你可以写一个最简单的单元测试试试：

```javascript
describe("A suite is just a function", function() {
  var a;

  it("and so is a spec", function() {
    a = true;

    expect(a).toBe(true);
  });
});
```

然后在命令行输入：

```shell
karma start karma.conf.js
```

如果需要做 CI 集成，则需要依据具体集成环境做相应配置。以 Circle CI 为例，首先你需要在项目根目录下创建 `.circleci` 的目录，然后在新建目录下，创建一个名为 config.yml 的文件，内容如下（这里假设你的 `npm run test` 已经是调用单元测试执行的命令了）：

```
version: 2
jobs:
  build:
    working_directory: ~/my-project
    docker:
      - image: circleci/node:10-browsers
    steps:
      - checkout
      - restore_cache:
          key: my-project-{{ .Branch }}-{{ checksum "package-lock.json" }}
      - run: npm install
      - save_cache:
          key: my-project-{{ .Branch }}-{{ checksum "package-lock.json" }}
          paths:
            - "node_modules"
      - run: npm run test
```

提交包含这个改动的代码到 GitHub 或者其他地方。另一方面，当你在 [Circle CI](https://circleci.com/docs/2.0/first-steps/) 注册并添加这个项目后，你的项目便开始构建了，日后每一次推送也都会重新触发构建执行流程（这里面包含你的测试命令）。

前面提到有覆盖率报告，代码覆盖率报告会向你展示代码库中有哪些可能未使用单元测试正常测试过的代码。增加代码覆盖率，我们继续修改配置：

```javascript
coverageIstanbulReporter: {
    reports: [ 'html', 'lcovonly' ],
    fixWebpackSourcePaths: true,
    thresholds: {
        statements: 80,
        lines: 80,
        branches: 80,
        functions: 80
    }
},
reporters: ['progress', 'coverage', 'kjhtml'],
```

这里的 thresholds 属性会让此工具在项目中运行单元测试时强制保证至少达到 80% 的测试覆盖率。

## 单元测试基本概念与用法

### 0. 断言

判断一个函数或对象的一个方法所产生的结果是否符合你期望的那个结果。

### 1. describe

describe 是 Jasmine 的全局函数，作为一个 Test Suite 的开始，它通常有 2 个参数：字符串和方法。字符串作为特定 Suite 的名字和标题。方法是包含实现 Suite 的代码。

```javascript
describe("This is an exmaple suite", function() {
  it("contains spec with an expectation", function() {
    expect(true).toBe(true);
    expect(false).toBe(false);
    expect(false).not.toBe(true);
  });
});
```

### 2. Specs

Specs 通过调用 it 的全局函数来定义。和 describe 类似，it 也是有 2 个参数，字符串和方法。每个 Spec 包含一个或多个 expectations 来测试需要测试代码。

Jasmine 中的每个 expectation 是一个断言，可以是 true 或者 false。当每个 Spec 中的所有 expectations 都是 true，则通过测试。有任何一个 expectation 是 false，则未通过测试。而方法的内容就是测试主体。

JavaScript 的作用域的规则适用，所以在 describe 定义的变量对 Suite 中的任何 it 代码块都是可见的。

```javascript
describe("Test suite is a function.", function() {
  let gVar;

  it("Spec is a function.", function() {
    gVar = true;
    expect(gVar).toBe(true);
  });

  it("Another spec is a function.", function() {
    gVar = false;
    expect(gVar).toBe(false);
  });
 
});
```

### 3. Expectations

Expectations 是由方法 expect 来定义，一个值代表实际值。另外的匹配的方法，代表期望值。

```javascript
describe("This is an exmaple suite", function() {
  it("contains spec with an expectation", function() {
    var num = 10;
    expect(num).toEqual(10);
  });
});
```

Jasmine 有很多的 Matchers 集合。比如：

```
toBe()
toNotBe()
toBeDefined()
toBeUndefined()
toBeNull()
toBeTruthy()
toBeFalsy()
toBeLessThan()
toBeGreaterThan()
toEqual()
toNotEqual()
toContain()
toBeCloseTo()
toHaveBeenCalled()
toHaveBeenCalledWith()
toMatch()
toNotMatch()
toThrow()
```

### 4. Setup and Teardown

为了使某个测试用例干净的重复 setup 和 teardown 代码， Jasmine 提供了全局的 beforeEach 和 afterEach 方法。正像其名字一样，beforeEach 方法在 describe 中的每个 Spec 执行之前运行，afterEach 在每个 Spec 调用后运行。

这里的在同一 Spec 集合中的例子有些不同。测试中的变量被定义为全局的 describe 代码块中，用来初始化的代码被挪到 beforeEach 方法中。afterEach 方法在继续前重置这些变量。

```javascript
describe("An example of setup and teardown)", function() {
  var gVar;
 
  beforeEach(function() {
    gVar = 3.6;
    gVar += 1;
  });
 
  afterEach(function() {
    gVar = 0;
  });
 
  it("after setup, gVar has new value.", function() {
    expect(gVar).toEqual(4.6);
  });
 
  it("A spec contains 2 expectations.", function() {
    gVar = 0;
    expect(gVar).toEqual(0);
    expect(true).toEqual(true);
  });
});
```

## 各类测试场景

### 0. SpyOn

当没有函数需要监听时，也可以创建一个 spy 对象来方便测试。比如如下代码便通过 spyOn 监听了 nextSeason 方法并在方法被调用时通过返回一个预设值替代实际调用。

```javascript
describe('spyOn() Demo. Season', function() {
    it('should be Autumn', function() {
        var s = new Season();
        spyOn(s, 'nextSeason').and.returnValue('Autumn');
        s.getNextSeason();
        expect(s.nextSeason()).toEqual('Autumn');
    });
});
```

### 1. 异步操作

Jasmine 支持测试需要执行异步操作的 specs，调用beforeEach, it, 和 afterEach 的时候，可以带一个可选的参数 `done`，当 spec 执行完成之后需要调用 done 来告诉 Jasmine 异步操作已经完成。默认 Jasmine 的超时时间是5s，可以通过全局的 `jasmine.DEFAULT_TIMEOUT_INTERVAL` 设置。

```javascript
describe("Jasmine 异步测试演示", function() {
    let value;

    beforeEach(function(done) {
        setTimeout(function() {
            value = 0;
            done();
        }, 1);
    });

    it("should support async execution of test preparation and expectations", function(done) {
        value++;
        expect(value).toBeGreaterThan(0);
        done();
    });
});
```

### 2. Angular 组件

以下针对 Angular 项目中常出现的一些代码场景进行介绍，看看针对这些内容我们要如何完善单元测试。假设我们的组件 demo.ts 长成这样：

```javascript
@Component({
  selector: 'lightswitch-comp',
  template: `
    <button (click)="clicked()">Click me!</button>
    <span>{{message}}</span>`
})
export class LightswitchComponent {
  isOn = false;
  clicked() { this.isOn = !this.isOn; }
  get message() { return `The light is ${this.isOn ? 'On' : 'Off'}`; }
}
```

那么单元测试这样写，便可以覆盖到我们的 `.click()` 事件：

```javascript
describe('Demo', () => {
  it('#clicked() should set #message to "is on"', () => {
    const comp = new LightswitchComponent();
    expect(comp.message).toMatch(/is off/i, 'off at first');
    comp.clicked();
    expect(comp.message).toMatch(/is on/i, 'on after clicked');
  });
});
```

### 3. Angular Service

以一个有依赖的 service 为例，我们对如下代码进行单元测试覆盖：

```javascript
@Injectable()
export class MasterService {
  constructor(private valueService: ValueService) { }
  getValue() { return this.valueService.getValue(); }
}
```

为了正常构建这个服务，我们应该在第一个测试使用 new 创建了 ValueService，然后把它传给了 MasterService 的构造函数。

```javascript
describe('MasterService without Angular testing support', () => {
  let masterService: MasterService;

  it('#getValue should return real value from the real service', () => {
    masterService = new MasterService(new ValueService());
    expect(masterService.getValue()).toBe('real value');
  });
});
```

### 4. Angular Pipe

管道很容易测试，无需 Angular 测试工具。

管道类有一个方法，transform，用来转换输入值到输出值。 transform 的实现很少与 DOM 交互。 除了 @Pipe 元数据和一个接口外，大部分管道不依赖 Angular。

假设 TitleCasePipe 将每个单词的第一个字母变成大写。 下面是使用正则表达式实现的简单代码：

```javascript
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({name: 'titlecase', pure: true})
export class TitleCasePipe implements PipeTransform {
  transform(input: string): string {
    return input.length === 0 ? '' :
      input.replace(/\w\S*/g, (txt => txt[0].toUpperCase() + txt.substr(1).toLowerCase() ));
  }
}
```

而用 Jasmine 测试你只需构造一个 Pipe 实例然后调用 transform 验证即可：

```javascript
describe('TitleCasePipe', () => {
  let pipe = new TitleCasePipe();

  it('transforms "abc" to "Abc"', () => {
    expect(pipe.transform('abc')).toBe('Abc');
  });
});
```

### 5. RxJs

RxJS 中的调度器 (Schedulers) 是用来控制事件发出的顺序和速度的(发送给观察者的)。它还可以控制订阅 (Subscriptions) 的顺序。以下是一段简单的示例代码：

```javascript
import { TestScheduler } from 'rxjs/testing';

const testScheduler = new TestScheduler((actual, expected) => {
  // 假设两个内容相等
  expect(actual).toEqual(expected);
});

// 同步运行的代码
it('generate the stream correctly', () => {
  testScheduler.run(helpers => {
    const { cold, expectObservable, expectSubscriptions } = helpers;
    const e1 =  cold('-a--b--c---|');
    const subs =     '^----------!';
    const expected = '-a-----c---|';

    expectObservable(e1.pipe(throttleTime(3, testScheduler))).toBe(expected);
    expectSubscriptions(e1.subscriptions).toBe(subs);
  });
});
```

如果你要测试 error 是否符合预期，可以针对上述的 testScheduler 调用进行改造（以下代码）：

```javascript
it('Error Handler Logic', () => {
  const status403 = { status: 403 };

  testScheduler.run(({ expectObservable }) => {
      // 假设 securedErrorHandler 是我们要测试的错误处理程序
      const result$ = securedErrorHandler(e => e);

      expectObservable(result$).toBe('#', null, status403);
  });
})
```

需要注意的是，要测试需要在 `toBe` 第一个参数指明为 '#'，第二个参数指明正常返回的预期结果，而后在第三个参数填入符合预期的 error message。

## 参考

* [Unit Testing](https://en.wikipedia.org/wiki/Unit_testing)
* [Testing RxJS Code with Marble Diagrams](https://rxjs-dev.firebaseapp.com/guide/testing/marble-testing)
* [Jasmine](https://jasmine.github.io/)
* [Karma](https://karma-runner.github.io/latest/index.html)
* [JavaScript 单元测试框架：Jasmine 初探](https://www.ibm.com/developerworks/cn/web/1404_changwz_jasmine/index.html)
* [Angular Testing](https://angular.io/guide/testing)
