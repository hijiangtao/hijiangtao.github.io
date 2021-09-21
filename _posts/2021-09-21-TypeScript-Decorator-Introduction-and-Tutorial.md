---
title: TypeScript 装饰器介绍与示例教程
layout: post
thread: 269
date: 2021-09-21
author: Joe Jiang
categories: Document
tags: [2021, TypeScript, Decorator, 装饰器, metadata, 元数据, Angular, 依赖注入]
excerpt: 如果你使用过 Angular，那么在日常的开发过程中，你已经大量使用过由 Angular 官方提供的各类由装饰器封装的特性了，比如 @Component 以及 @ViewChild 等等。即便不了解其实现原理，这也不影响我们熟练的通过它来实现各种需求。但如果我们深入了解隐藏在其背后的装饰器，便能将这个黑盒变成我们的代码能力，利用它来实现很多复用逻辑的代码抽象，给我们提供一个有别于组件抽象的方式，来使我们的项目更健壮、代码更简洁。
header:
  image: ../assets/in-post/2021-09-21-TypeScript-Decorator-Introduction-and-Tutorial-Teaser.png
  caption: "©️hijiangtao"
---

## **前言**

如果你使用过 Angular，那么在日常的开发过程中，你已经大量使用过由 Angular 官方提供的各类由装饰器封装的特性了，比如 @Component 以及 @ViewChild 等等。即便不了解其实现原理，这也不影响我们熟练的通过它来实现各种需求。

但如果我们深入了解隐藏在其背后的装饰器，便能将这个黑盒变成我们的代码能力，利用它来实现很多复用逻辑的代码抽象，给我们提供一个有别于组件抽象的方式，来使我们的项目更健壮、代码更简洁。

如果你没使用过 Angular 也没有关系，本文尽可能去除对 Angular 的强绑定，并在第一部分增加了一些关于 Angular 的必要介绍，帮助你更好的理解本文。

*注：关于本文第二部分的示例教程所有代码可以通过 GitHub <https://github.com/hijiangtao/custom-decorator-project> 下载。*

*注：本文中装饰器等同于 Decorator；元数据等同于 metadata。*

本文主要分三部分，分别是和装饰器有关的先修概念、装饰器在 Angular 中的应用举例与定义、自定义装饰器示例教程。详细目录如下：

1. 前言
2. 先修概念
    1. Property Descriptor
    2. 依赖注入
    3. Angular 框架
    4. Metadata Reflection
3. 装饰器在 Angular 中的应用举例与定义
    1. 通过 @NgModule 了解类装饰器
    2. 通过 @Input 了解属性装饰器
    3. 装饰器定义与类型介绍
4. 自定义装饰器示例教程
    1. 新建项目与引入依赖
    2. 定义需要调用的弹窗组件
    3. 完善弹窗组件交互
    4. 新建 Confirmable 装饰器并注入必要的服务
    5. 补全装饰器中所需的二次确认逻辑
5. 参考

以下开始正文。

## 一、先修概念

在进入装饰器的正式介绍前，我们需要先了解几个概念，这能帮助我们更好的理解后文对装饰器的介绍逻辑。如果你已经熟悉，可以直接移步第二部分。

### 1.1 Property Descriptor

一个JavaScript 对象里面可能有一堆属性，属性都有一个名字，还有对应的值，除了这些其实还隐含了一些东西，这就是 Property Descriptor。

这里，我们先介绍一个 Web API —— `Object.defineProperty()`。

> Object.defineProperty() 方法会直接在一个对象上定义一个新属性，或者修改一个对象的现有属性，并返回此对象。—— MDN

该方法允许精确地添加或修改对象的属性。通过赋值操作添加的普通属性是可枚举的，在枚举对象属性时会被枚举到（ `for...in` 或 `Object.keys` 方法），可以改变这些属性的值，也可以删除这些属性。

假设我们不允许通过赋值运算符来修改一个对象的属性，我们便可以这么写来达到目的：

```tsx
const object1 = {};

Object.defineProperty(object1, 'property1', {
  value: 42,
  writable: false
});

object1.property1 = 77;
// throws an error in strict mode

console.log(object1.property1);
// expected output: 42
```

关于 Property Descriptor 的更多介绍可以参考文章 [https://medium.com/jspoint/a-quick-introduction-to-the-property-descriptor-of-the-javascript-objects-5093c37d079](https://medium.com/jspoint/a-quick-introduction-to-the-property-descriptor-of-the-javascript-objects-5093c37d079)

### 1.2 依赖注入

依赖注入一般指控制反转，是面向对象编程中的一种设计原则，可以用来减低计算机代码之间的耦合度。其中最常见的方式叫做依赖注入，还有一种方式叫依赖查找。通过控制反转，对象在被创建的时候，由一个调控系统内所有对象的外界实体将其所依赖的对象的引用传递给它。也可以说，依赖被注入到对象中。

依赖注入中的主要概念是依赖项，依赖项是指某个类执行其功能所需的服务或对象。依赖项注入（DI）是一种设计模式，在这种设计模式中，类会从外部源请求依赖项而不是创建它们。

依赖不一定是服务，它还可能是函数或值。通过依赖注入，我们可以很好的将调用方与服务方的代码进行解耦，而不必强行捆绑在一起进行书写。

### 1.3 Angular 框架

Angular 作为当下的三大框架之一，是一个应用设计框架与开发平台，用于创建高效、复杂、精致的单页面应用。

在 Angular 中通过定义组件、服务、模版，并注入必要的依赖，可以简单快速的搭建一个 Web 项目。

在 Angular 中，可以通过 Angular CLI 来简化诸如项目初始化、生成组件、构建项目等任务，通过一组 HTML + TypeScript + CSS 文件，我们可以轻松定义一个 Angular 组件。如下为一个最简单的 Angular 组件示例：

```tsx
// 组件定义
import { Component } from '@angular/core';

@Component({
  selector: 'hello-world',
  template: `
    <h2>Hello World</h2>
    <p>This is my first component!</p>
    `,
})
export class HelloWorldComponent {
  // The code in this class drives the component's behavior.
}

// index.html 中可以这么使用
<hello-world></hello-world>
```

### 1.4 Metadata Reflection

Reflect Metadata 是 ES7 的一个提案，它主要用来在声明的时候添加和读取 metadata。Reflect Metadata 的 API 可以用于类或者类的属性上，如：

```tsx
function metadata(
  metadataKey: any,
  metadataValue: any
): {
  (target: Function): void;
  (target: Object, propertyKey: string | symbol): void;
};
```

我们把 `Reflect.metadata` 当作装饰器使用，当修饰类时，在类上添加 metadata，当修饰类属性时，在类原型的属性上添加 metadata，如：

```tsx
@Reflect.metadata('inClass', 'A')
class Test {
  @Reflect.metadata('inMethod', 'B')
  public hello(): string {
    return 'hello world';
  }
}

console.log(Reflect.getMetadata('inClass', Test)); // 'A'
console.log(Reflect.getMetadata('inMethod', new Test(), 'hello')); // 'B'
```

在 Angular 的实现中，也利用了这个 API 来实现声明式组件的定义。由于 ECMAScript 还未覆盖此特性，Angular 采用 [reflect-metadata](https://www.npmjs.com/package/reflect-metadata) npm 包与 TypeScript 编译器达到同等目的。大多数 Angular 提供的装饰器核心都是将 metadata 添加到某个类上，而后这些 metadata 会被用在装饰器的工厂函数上。

关于提案的详细细节可以移步 [https://github.com/rbuckton/reflect-metadata](https://github.com/rbuckton/reflect-metadata) 查看。

## 二、装饰器在 Angular 中的应用举例与定义

接下来，本章结合装饰器在 Angular 中的应用进行举例和介绍，后半部分亦有对装饰器的定义。

为了便于理解，我们可以先通过 Angular CLI 命令 `ng new custom-decorator-project` 来新建一个项目，这个项目在后续的自定义装饰器实现中中也会被用到。

好了，我们从官方的 @NgModule 装饰器开始说起。

### 2.1 通过 @NgModule 了解类装饰器

打开 `app.module.ts` 我们首先可以看到 @NgModule，通过传入一个指定格式的 metadata 对象，我们可以将一个将类标记为 NgModule，以方便 Angular 在执行时进行处理，比如，我们可以通过指定 declarations 属性来指定属于该模块的一组组件、指令和管道。

这是 Angular 提供的一个标记 NgModule 的装饰器，同类的装饰器还有 @Component。在 TypeScript 中，这些都被分类为**类装饰器。**类装饰器可以拦截类的构造函数 constructor，这使得我们可以通过结合传入的 metadata，以此确定类在运行时是如何被处理、实例化以及使用的。

```tsx
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppComponent } from './app.component';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

### 2.2 通过 @Input 了解属性装饰器

我们再来看一个例子 @Input，当定义一个组件如何需要接受外部传入数据时，我们往往会用到 @Input 和 @Output，比如如下例子这样：

```tsx
import { Component, Input } from '@angular/core';

@Component({
  selector: 'example-component',
  template: '<div>Hello world!</div>'
})
export class ExampleComponent {
  @Input() exampleProperty: string;
}
```

@Input 是 Angular 提供的一个属性装饰器，可以用来定义组件内的输入属性。在实际应用中，我们主要用来实现父组件向子组件传递数据。

属性装饰器属于第二类装饰器，它的声明在一个属性声明之前（紧靠着属性声明）。属性装饰器表达式会在运行时当作函数被调用，传入下列2个参数：

1. 类的构造函数（静态成员）或者类的原型对象（实例成员）；
2. 成员的名字；

所以，通过属性装饰器，我们可以监听属性对象的变化，比如如下这个例子，通过定义一个 @Emoji 指令，实现了给属性赋值时默认在前后带上一个冰淇淋 emoji 表情：

```tsx
function Emoji() {
  return function(target: Object, key: string | symbol) {

    let val = target[key];

    const getter = () =>  {
        return val;
    };

    // 赋值时在字符串前后加上冰淇淋 emoji 表情
    const setter = (next) => {
        console.log('updating flavor...');
        val = `🍦 ${next} 🍦`;
    };

    Object.defineProperty(target, key, {
      get: getter,
      set: setter,
      enumerable: true,
      configurable: true,
    });
  };
}
```

而我们可以这么使用定义的 Emoji 装饰器：

```tsx
export class IceCreamComponent {
  @Emoji()
  flavor = 'vanilla';
}
```

### 2.3 装饰器定义与类型介绍

在 TypeScript 中，装饰器是一种特殊类型的声明，它能够被附加到类声明，方法， 访问符，属性或参数上。 装饰器使用 @expression 这种形式，expression 求值后必须为一个函数，它会在运行时被调用，被装饰的声明信息做为参数传入。

如果我们要定义一个应用到声明上的修饰器，我们就需要写一个装饰器工厂函数。装饰器工厂就是一个简单的函数，它返回一个表达式，以供装饰器在运行时调用。

我们可以通过下面的方式来定义一个装饰器工厂函数：

```tsx
function color(value: string) { // 这是一个装饰器工厂
    return function (target) { //  这是装饰器
        // ...
    }
}
```

按照装饰器被装饰的特性来分，一共可以分为五种类型：

1. **类装饰器 Class Decorator** - 类装饰器在类声明之前被声明（紧靠着类声明），类装饰器可以拦截类的构造函数 constructor，这使得我们可以通过结合传入的 metadata，以此确定类在运行时是如何被处理、实例化以及使用的。
2. **属性装饰器 Property Decorator** - 属性装饰器声明在一个属性声明之前（紧靠着属性声明），我们可以使用它来劫持属性的 getter 和 setter。
3. **方法装饰器 Method Decorator** - 方法装饰器声明在一个方法的声明之前（紧靠着方法声明）。它会被应用到方法的属性描述符上，可以用来监视，修改或者替换方法定义。
4. **参数装饰器 Parameter Decorator** - 参数装饰器声明在一个参数声明之前（紧靠着参数声明）。 参数装饰器应用于类构造函数或方法声明，但参数装饰器的返回值会被忽略。
5. **访问符装饰器 Accessor Decorator** - 访问器装饰器声明在一个访问器的声明之前（紧靠着访问器声明）。访问器装饰器应用于访问器的 属性描述符并且可以用来监视，修改或替换一个访问器的定义。访问器装饰器不能用在声明文件中（.d.ts），或者任何外部上下文（比如 declare 的类）里。

现在，当我们现在来回顾什么是装饰器，装饰器其实就是一个声明，而我们需要通过定义工厂函数来实现对类、属性、方法等等的装饰。关于 Angular 中对装饰器的更多使用场景，本文不再赘述，如果你希望了解更多，推荐移步文章 [TypeScript Decorators by Example](https://fireship.io/lessons/ts-decorators-by-example/) 查看，亦有[译文](https://zhuanlan.zhihu.com/p/65764702)。

## 三、自定义装饰器示例教程

让我们想象这样一个场景，我们在开发一个后台系统，用户可以浏览、修改和删除所有数据条目。但由于删除的敏感性，我们需要在用户每次执行操作前弹窗提示他一次，即一个**二次确认弹窗**。

除了通过封装一个弹窗组件，定义传入的接口请求等参数，我们还可以通过自定一个方法装饰器来达到这个目的，我们先来看看最终实现的调用方式以及效果。

```tsx
@Component({
  ...
})
export class AppComponent implements OnInit {
  constructor(public injector: Injector, private dialog: MatDialog) {}

  ngOnInit(): void {}

  @Confirmable()
  openDialog() {
    console.log('I am confirmed. Data is deleted!');
  }
}
```

在操作上，只有当用户点击了如下 UI 中的“确定”按钮，console 中才会打出确认数据被删除的日志。

![](/assets/in-post/2021-09-21-TypeScript-Decorator-Introduction-and-Tutorial-1.png )

*注：本示例教程所有代码可以通过 GitHub <https://github.com/hijiangtao/custom-decorator-project> 下载。*

### 3.1 新建项目与引入依赖

如果你已经按照前文新建了一个 Angular 项目，那么这个时候再引入 Material Design UI 库即可，我们需要使用它来调用生成一个弹框效果。

```tsx
// 新建项目
ng new custom-decorator-project

// 添加 Material Design
ng add @angular/material
```

### 3.2 定义需要调用的弹窗组件

首先，通过 Angular CLI 新建一个弹窗组件 ConfirmDialogComponent：

```bash
ng g component confirm-dialog
```

然后，我们稍微修改下 `app.module.ts` 引入必要的 Material Design 模块和新建的弹窗组件：

```tsx
import { ConfirmDialogComponent } from './confirm-dialog/confirm-dialog.component';

// ...

const THIRDPARTY_MODULES = [MatSliderModule, MatDialogModule];

@NgModule({
  declarations: [AppComponent, ConfirmDialogComponent],
  imports: [BrowserModule, BrowserAnimationsModule, ...THIRDPARTY_MODULES],
  providers: [
    { provide: MAT_DIALOG_DEFAULT_OPTIONS, useValue: { hasBackdrop: false } },
  ],
  bootstrap: [AppComponent],
})
export class AppModule {}
```

### 3.3 完善弹窗组件交互

首先修改 confirm-dialog 下的模版与 TypeScript 文件，模版中替换为如下内容：

```html
<h1 mat-dialog-title>{{ data.title }}</h1>
<div mat-dialog-content>
    删除后不可恢复，请慎重决定，确认要删除吗？
</div>

<mat-dialog-actions>
    <button mat-button mat-dialog-close>取消</button>
    <button mat-button [mat-dialog-close]="true" cdkFocusInitial>确认</button>
</mat-dialog-actions>
```

在 `confirm-dialog.component.ts` 中声明注入 DialogData 用于定义组件所需数据：

```tsx
export class ConfirmDialogComponent implements OnInit {
  constructor(@Inject(MAT_DIALOG_DATA) public data: DialogData) {}

  // ...
}
```

### 3.4 新建 Confirmable 装饰器并注入必要的服务

新建 confirmable.decorator.ts 文件用于存放我们自定义的装饰器代码，并添加如下代码：

```tsx
export const Confirmable = () => {
  return function confirmable(
    target: Object,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    return descriptor;
  };
};
```

这里我们先写一个 Confirmable 函数，稍微解释一下入参：

1. 其中 `target` 表示包含我们正在装饰的方法所在的类；
2. `propertyKey` 表示方法名称；
3. `descriptor` 包含方法实现。

在装饰器函数中，我们可以在方法执行之前/之后做一些事情，或者根据任意条件完全跳过执行。在我们的需求中，我们需要：

1. 在代码逻辑进入所装饰方法调用时先暂停，并调用弹窗组件供用户选择；
2. 通过判断弹窗组件中用户操作的结果，来决定是否执行所装饰的方法内容；

为了达到在装饰器内调用弹窗组件的目的，我们需要依赖 Angular 提供的 Injector 在装饰器中拿到类中的一些注入的服务比如 MatDialog。

由于属性装饰器只运行一次，且只能访问类原型但不能访问实例，因此我们需要在 `ngOnOnit` 方法中通过 `this.injector.get()` 来获取我们所需的服务，我们首先修改 `app.component.ts`：

```tsx
import { Injector, OnInit } from '@angular/core';
import { Component } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent implements OnInit {
  constructor(public injector: Injector, private dialog: MatDialog) {}

  ngOnInit(): void {}
}
```

然后我们来修改 Confirmable 装饰器函数：

```tsx
import { Injector } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';

interface IConfirmableDirective {
  injector: Injector;
  ngOnInit?: Function;
}

export const Confirmable = () => {
  return function confirmable(
    target: IConfirmableDirective,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    // 缓存方法引入
    const originalMethod = descriptor.value;

    let dialogService: MatDialog;

    // 获取注入的弹窗服务
    target.ngOnInit = function (this: IConfirmableDirective) {
      dialogService = this.injector.get(MatDialog);
    };

    return descriptor;
  };
};
```

### 3.5 补全装饰器中所需的二次确认逻辑

为了达到用户在点击按钮时，我们调用弹窗组件供用户选择并及时获取用户选择来决定是否执行原有逻辑的目的，我们接下来需要继续修改装饰器，并加入如下逻辑：

```tsx
// 重新所装饰的方法实现
descriptor.value = async function (...args: any[]) {
  const res = await dialogService
    .open(ConfirmDialogComponent, {
      data: {
        title: '删除测试服务',
      },
    })
    .afterClosed()
    .toPromise();

  // 确认弹窗用户选择结果
  if (res) {
    // 如果用户点击确认
    // 我们将原始参数传入原始方法并执行
    const result = originalMethod.apply(this, args);

    // 并返回执行结果
    return result;
  }
};
```

如上已在代码中加入注释，便不再解释各部分实现目的。最后一步，我们在根组件中加入点击按钮调用的方法实现以及装饰器调用，即大功告成。

```tsx
@Confirmable()
openDialog() {
  console.log('I am confirmed. Data is deleted!');
}
```

如上便实现了一个自定义的方法装饰器，当我们需要在增加二次弹窗确认的逻辑时，只需要把装饰器挂在对应的方法声明前即可。

当然，如上装饰器将一些变量写死在装饰器实现上了，这些都可以做成配置项，以使装饰器功能更加灵活。由于篇幅所限，本文不再展开。

*注：本示例教程所有代码可以通过 GitHub <https://github.com/hijiangtao/custom-decorator-project> 下载。*

祝大家在装饰器中玩的快乐。

## 参考

参考部分附上本文在书写过程中参考的文章，同时由于作者水平所限，也附上一些可进一步查看了解装饰器的技术博客，供参考。

- [https://www.typescriptlang.org/docs/handbook/decorators.html](https://www.typescriptlang.org/docs/handbook/decorators.html)
- [https://indepth.dev/posts/1163/implementing-custom-component-decorator-in-angular](https://indepth.dev/posts/1163/implementing-custom-component-decorator-in-angular)
- [https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty)
- [https://stackoverflow.com/questions/48888079/angular-4-custom-decorator-injecting-services](https://stackoverflow.com/questions/48888079/angular-4-custom-decorator-injecting-services)
- [https://stackoverflow.com/questions/48888079/angular-4-custom-decorator-injecting-services](https://stackoverflow.com/questions/48888079/angular-4-custom-decorator-injecting-services)
- [http://prideparrot.com/blog/archive/2018/7/extending_component_decorator_angular_6](http://prideparrot.com/blog/archive/2018/7/extending_component_decorator_angular_6)
- [https://fireship.io/lessons/ts-decorators-by-example/](https://fireship.io/lessons/ts-decorators-by-example/)
- [https://jkchao.github.io/typescript-book-chinese/#why](https://jkchao.github.io/typescript-book-chinese/#why)
- [https://angular.io/guide/ngmodules](https://angular.io/guide/ngmodules)
- [https://material.angular.io/guide/getting-started](https://material.angular.io/guide/getting-started)
