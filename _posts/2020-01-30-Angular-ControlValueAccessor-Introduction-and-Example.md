---
title: Angular ControlValueAccessor - 自定义表单控件介绍与实战
layout: post
thread: 241
date: 2020-01-30
author: Joe Jiang
categories: Document
tags: [Angular, 表单, form, 前端, 自定义控件, 原生, 实战]
excerpt: 本文是学习 Angular ControlValueAccessor 过程中的笔记摘要，全文结构如下……
---

本文是学习 Angular ControlValueAccessor 过程中的笔记摘要，全文结构如下：

1. 表单与控件介绍 - 通过日常在 Angular 中使用表单以及自定义控件的场景引出 ControlValueAccessor
2. ControlValueAccessor API 介绍 - 介绍 ControlValueAccessor API 的细节
3. 自定义表单控件实现 - 通过一个计数器例子实战来叙述如何利用 ControlValueAccessor 自定义你的表单控件
    1. 初始化计数器控件
    2. 完善 ControlValueAccessor 接口
    3. 注册 NG_VALUE_ACCESSOR 提供者
    4. 在响应式表单中使用

本文假设你已经了解了基本的 Angular 语法与表单用法，其中所使用的完整代码可以在 GIST 上找到 [https://gist.github.com/hijiangtao/1be6feba90294863a403316b3b9dc31e](https://gist.github.com/hijiangtao/1be6feba90294863a403316b3b9dc31e)，以下开始正文。

![](/assets/in-post/2020-01-30-Angular-ControlValueAccessor-Introduction-and-Example-Teaser.png )

## 1. 表单与控件介绍

不仅仅是在 Angular 中，大部分 Web 应用中（尤其是中后台系统）用表单来处理用户输入都是非常基础的功能。在 Angular 中，一个极其简单的表单应用如下所示：

    import { Component } from '@angular/core';
    import { FormControl } from '@angular/forms';
     
    @Component({
      selector: 'app-reactive-favorite-color',
      template: `
        Favorite Color: <input type="text" [formControl]="favoriteColorControl">
      `
    })
    export class FavoriteColorComponent {
      favoriteColorControl = new FormControl('');
    }

以上例子中，我们在控件类中定义了一个 `FormControl` 属性，然后在模版中通过 `[formControl]` 将 UI (DOM) 与数据进行双向绑定。

但写代码时为了以后场景复用，难免要自定义控件，当控件中涉及到用户输入交互时，可能就要与表单打交道。在 Angular 中，不管你使用模板驱动表单还是响应式表单，总是会创建`FormControl`。如果你使用响应式表单，你需要显式创建 `FormControl` 对象，并使用 `formControl` 或 `formControlName` 指令来绑定原生控件；如果你使用模板驱动表单，`FormControl` 对象会被 `NgModel` 指令隐式创建。

这时，一个直观但不优雅的做法是在调用自定义控件时通过 `@Input` 传入一个表单数据 ，而控件内部写相应的逻辑对 Angular 表单进行操作。具体调用可能长成这样：

    <form [formGroup]="anyForm">                                
      <some-component [form]="anyForm"></some-component>      
      <another-component [form]="anyForm"></another-component>
    </form>

但是为了让控件拥有 Angular 表单般的使用体验，我希望 API 设计成这样，直接通过 `formControlName` 来绑定数据：

    <form [formGroup]="anyForm">
      <some-component formControlName="cool" /></some-component>
      <another-component type="text" formControlName="coool"></another-component> 
    </form>

## 2. ControlValueAccessor API 介绍

在 Angular 中，类似的自定义表单其实是有相应接口实现的，这里就用到我们今天要谈的主角——ControlValueAccessor，其官方定义是

> Implement this interface to create a custom form control directive that integrates with Angular forms.

简单来说，这个对象桥接原生表单控件和 `formControl` 指令，并同步两者的值。

任何一个控件或指令都可以通过实现 `ControlValueAccessor` 接口并注册为 `NG_VALUE_ACCESSOR`，从而转变成 `ControlValueAccessor` 类型的对象。在介绍其他内容之前，我们来看看 `ControlValueAccessor` 的数据结构：

    interface ControlValueAccessor {
      writeValue(obj: any): void
      registerOnChange(fn: any): void
      registerOnTouched(fn: any): void
      setDisabledState(isDisabled: boolean)?: void
    }

这个接口定义有四个方法，为了描述准确，我们将 Angular 表单和原生表单分别用 Angular form 和 Native form 区分开：

- writeValue：任何 `FormControl` 显式调用 API 的**值**操作都将调用自定义表单控件的 `writeValue()` 方法，并将新值作为参数传入。其作用是设置原生表单控件的值。**数据流向则是从 Angular form ➡️ Native form。**
- registerOnChange：注册 `onChange` 事件，在初始化时被调用，参数为事件触发函数。这个事件触发函数有什么用呢？我们首先要在 `registerOnChange` 中将该事件触发函数保存起来，等到合适的时候（比如控件收到用户输入，需要作出响应时）调用该函数以触发事件。这里的概念比较绕，你可以将这个函数理解成“当控件内表单数据存在变化、需要通知控件的调用方所用到的一个 API”，即将控件内信息同步出去。这个事件函数的参数是 Angular form 所要接收的值。**数据流向从 Native form ➡️ Angular form。**
- registerOnTouched：注册 `onTouched` 事件，即用户和控件交互时触发的回调函数。该函数用于通知表单控件已经处于 touched 状态，以更新绑定的 `FormContorl` 的内部状态。**数据流向从 Native form ➡️ Angular form。**
- setDisabledState：当表单状态变为 `DISABLED` 或从 `DISABLED` 变更时，表单 API 会调用 `setDisabledState()` 方法，以启用或禁用对应的 DOM 元素。**数据流向则是从 Angular form ➡️ Native form。**

关于其中的交互关系我们可以参照下面这张图：

![](/assets/in-post/2020-01-30-Angular-ControlValueAccessor-Introduction-and-Example-1.jpeg )

## 3. 自定义表单控件实现

介绍完概念后，我们通过一个例子来看看如何自定义表单控件。我们分以下几个步骤

### 3.1 初始化自定义控件

一个基本的 counter 控件应该包含 ts 脚本和 html 文件：

- `counter.component.html`

```html
<div>
    <p>当前值: {{ count }}</p>
    <button (click)="increment()"> + </button>
    <button (click)="decrement()"> - </button>
</div>
```

- `counter.component.ts`

```javascript
import { Component, Input } from '@angular/core';
    
@Component({
    selector: 'app-counter',
    templateUrl: './counter.component.html',
    styleUrls: ['./counter.component.css'],
})
export class Counter {
    @Input() count: number = 0;

    ngOnInit() {}

    increment() {
        this.count++;
    }

    decrement() {
        this.count--;
    }
}
```

### 3.2 完善 ControlValueAccessor 接口

根据 ControlValueAccessor 定义的 API 接口，当合法值输入控件时，我们需要更新控件内的 count 值，所以我们这样完善 writeValue 方法：

    writeValue(value: any) {
        if (value) {
            this.count = value;
        }
    }

然后我们注册两个事件，涉及到 registerOnChange 方法和 registerOnTouched 方法：

    propagateOnChange: (value: any) => void = (_: any) => {};
    propagateOnTouched: (value: any) => void = (_: any) => {};
    
    registerOnChange(fn: any) {
        this.propagateOnChange = fn;
    }
    
    registerOnTouched(fn: any) {
        this.propagateOnTouched = fn;
    }

由于控件内 count 改变时我们需要调用事件触发函数将数据传递给 Angular form，于是针对控件内部的 count 我们做一些改造：

    _count: number = 0;
    
    get count() {
        return this._count;
    }
    
    set count(value: number) {
        this._count = value;
        this.propagateOnChange(this._count);
    }

好了，其余内容不变。

### 3.3 注册 NG_VALUE_ACCESSOR 提供者

对于我们开发的自定义控件来说，实现 ControlValueAccessor 接口只完成了一半工作，我们还需要执行注册操作。`NG_VALUE_ACCESSOR` 提供者用来指定实现了 `ControlValueAccessor` 接口的类，并且被 Angular 用来和 `formControl` 同步，通常是使用控件类或指令来注册。所有表单指令都是使用`NG_VALUE_ACCESSOR` 标识来注入控件值访问器，然后选择合适的访问器。具体分以下几个步骤：

步骤1：创建 EXE_COUNTER_VALUE_ACCESSOR

    export const EXE_COUNTER_VALUE_ACCESSOR: any = {
        provide: NG_VALUE_ACCESSOR,
        useExisting: forwardRef(() => Counter),
        multi: true
    };

步骤2：配置控件 providers 信息

    @Component({
      ...
      providers: [EXE_COUNTER_VALUE_ACCESSOR],
      ...
    })
    export class Counter implements ControlValueAccessor {
      ...
    }

这部分我们不做深入探讨，关于 NG_VALUE_ACCESSOR 及相关概念的深入，我将部分内容附在文末的参考列表中了。

### 3.4 在响应式表单中使用

至此，我们的控件就写完了。由于 Angular 存在响应式表单和模版驱动表单两种，以下以响应式表单为例，我们实际调用它看看效果。首先是导入控件并注册 `[ReactiveFormsModule](https://angular.cn/api/forms/ReactiveFormsModule)`:

    import { NgModule } from '@angular/core';
    import { ReactiveFormsModule } from '@angular/forms';
    // 替换为你自己的 counter 控件地址
    import { Counter } from './components/counter/counter.component';
    
    @NgModule({
      declarations: [
        ...
        Counter,
      ],
      imports: [
        ...
        ReactiveFormsModule,
      ],
    })
    export class AppModule { }

然后我们完善调用自定义控件的代码，假设我们是在一个叫 hello 的 component 中调用它，那么代码分以下两步，首先是 HTML：

```html
<ng-container>
    <p>counter 控件测试</p>
    <form [formGroup]="helloForm">
        <app-counter formControlName="counter"></app-counter>
    </form>
</ng-container>
```

其次，我们完善 ts 代码：

    import { Component, OnInit, Input } from '@angular/core';
    import { FormGroup, FormBuilder } from '@angular/forms';
    
    @Component({
      selector: 'app-hello-page',
      templateUrl: './hello.component.html',
      styleUrls: ['./hello.component.css'],
    })
    export class HelloPageComponent implements OnInit {
        helloForm: FormGroup;
    
        constructor(private fb: FormBuilder) { }
        
        ngOnInit() {
            this.helloForm = this.fb.group({
                counter: 5 // 设置初始值
            });
        }
    }

以上便是 Angular ControlValueAccessor 在表单控件中从定义到使用的全部过程，以下附上计数器的完整 TypeScript 代码，其余完整代码见 GIST [https://gist.github.com/hijiangtao/1be6feba90294863a403316b3b9dc31e](https://gist.github.com/hijiangtao/1be6feba90294863a403316b3b9dc31e)

参考

1. Angualr API [https://angular.io/api/forms/ControlValueAccessor](https://angular.io/api/forms/ControlValueAccessor)
2. Never again be confused when implementing ControlValueAccessor in Angular forms [https://indepth.dev/never-again-be-confused-when-implementing-controlvalueaccessor-in-angular-forms/](https://indepth.dev/never-again-be-confused-when-implementing-controlvalueaccessor-in-angular-forms/)
3. [译] 别再对 Angular 表单的 ControlValueAccessor 感到迷惑 [https://github.com/AngularID-CN/AngularID-CN/blob/master/articles/angular-32.[翻译]-别再对-Angular-Form-的-ControlValueAccessor-感到迷惑.md](https://github.com/AngularID-CN/AngularID-CN/blob/master/articles/angular-32.%5B%E7%BF%BB%E8%AF%91%5D-%E5%88%AB%E5%86%8D%E5%AF%B9-Angular-Form-%E7%9A%84-ControlValueAccessor-%E6%84%9F%E5%88%B0%E8%BF%B7%E6%83%91.md)
4. What is forwardRef in Angular and why we need it [https://blog.angularindepth.com/what-is-forwardref-in-angular-and-why-we-need-it-6ecefb417d48](https://blog.angularindepth.com/what-is-forwardref-in-angular-and-why-we-need-it-6ecefb417d48)
5. What does forwardRef do in angular? [https://stackoverflow.com/questions/50894571/what-does-do-forwardref-in-angular](https://stackoverflow.com/questions/50894571/what-does-do-forwardref-in-angular)
6. [https://segmentfault.com/a/1190000009070500](https://segmentfault.com/a/1190000009070500#item-9)
7. [https://blog.csdn.net/oschina_41790905/article/details/101716227](https://blog.csdn.net/oschina_41790905/article/details/101716227)
8. [https://angular.io/guide/reactive-forms](https://angular.io/guide/reactive-forms)

附 counter.component.ts 代码

    import { Component, Input, forwardRef } from '@angular/core';
    import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
    
    export const EXE_COUNTER_VALUE_ACCESSOR: any = {
        provide: NG_VALUE_ACCESSOR,
        useExisting: forwardRef(() => Counter),
        multi: true
    };
    
    @Component({
      selector: 'app-counter',
      templateUrl: './counter.component.html',
      styleUrls: ['./counter.component.css'],
      providers: [EXE_COUNTER_VALUE_ACCESSOR]
    })
    export class Counter implements ControlValueAccessor {
        _count: number = 0;
    
        get count() {
            return this._count;
        }
    
        set count(value: number) {
            this._count = value;
            this.propagateOnChange(this._count);
        }
    
        propagateOnChange: (value: any) => void = (_: any) => {};
        propagateOnTouched: (value: any) => void = (_: any) => {};
    
        ngOnInit() {}
    
        writeValue(value: any) {
            if (value) {
                this.count = value;
            }
        }
    
        registerOnChange(fn: any) {
            this.propagateOnChange = fn;
        }
    
        registerOnTouched(fn: any) {
            this.propagateOnTouched = fn;
        }
    
        increment() {
            this.count++;
        }
    
        decrement() {
            this.count--;
        }
    }
