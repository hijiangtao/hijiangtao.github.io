---
title: RxJS tslint 规则与推荐配置
layout: post
thread: 257
date: 2020-08-05
author: Joe Jiang
categories: Document
tags: [2020, RxJS, tslint]
excerpt: RxJS tslint 规则与推荐配置
---

本文推荐一些和 RxJS 使用相关的规则，并做分级配置。其中，Force 表示强制，Recommend 表示推荐，Optional 表示可选。

## Force: no-unused-variable

在代码中禁止未使用的 import 引入、变量、函数以及私有类成员等。

```jsx
"no-unused-variable": [true, {"ignore-pattern": "^_"}]
```

tslint 规则描述 [https://palantir.github.io/tslint/rules/no-unused-variable/](https://palantir.github.io/tslint/rules/no-unused-variable/)

## Force: Avoid takeUntil Leaks

防止由于不规范的 `takeUntil` 使用导致的 subscriptions 隐患。

```jsx
"rxjs-no-unsafe-takeuntil": true,
```

场景解释 [https://ncjamieson.com/avoiding-takeuntil-leaks/](https://ncjamieson.com/avoiding-takeuntil-leaks/)

## Recommend: Finnish Notation

强制开启 functions, methods, parameters, properties 与 variables 五项的命名规范。

```jsx
"rxjs-finnish": {
    "options": [
        {
            "functions": true,
            "methods": true,
            "parameters": true,
            "properties": true,
            "variables": true
        }
    ],
    "severity": "error"
},
```

场景解释 [https://medium.com/@benlesh/observables-and-finnish-notation-df8356ed1c9b](https://medium.com/@benlesh/observables-and-finnish-notation-df8356ed1c9b)

## Recommend: Async Subscribe

不允许将 async 方法传入 subscribe。

```jsx
"rxjs-no-async-subscribe": true,
```

## Recommend: No ignored notifier/observable/subscribe

一些禁止忽略的规则，比如不允许忽视函数返回的 Observable，不允许不指定入参的调用 subscribe，禁止不是由 `repeatWhen` 与 `retryWhen` notifier 组成的 Observable 等。

```jsx
"rxjs-no-ignored-notifier": true,
"rxjs-no-ignored-observable": true,
"rxjs-no-ignored-subscribe": true,
```

## Recommend: No redundant

禁止在已处于 complete 或者 error 状态的 Observable 中传递无效的通知。

```jsx
// 配置
"rxjs-no-redundant-notify": true,

// 问题用法
new Observable<number>(observer => {
    observer.complete();
    observer.next(42);
             ~~~~                               [no-redundant-notify]
}),
```

## Recommend: No subclass

不允许将 RxJS class 子类化。

```jsx
// 配置
"rxjs-no-subclass": true,

// 问题用法
class GenericObservable<T> extends Observable<T> {}
                                   ~~~~~~~~~~~~~                [no-subclass]
```

## Recommend: (un)subscribe

不允许在 Subject 实例上调用 unsubscribe 方法；不允许在 subscribe 方法中嵌套调用 subscribe。

```jsx
"rxjs-no-subject-unsubscribe": true,
"rxjs-no-nested-subscribe": true,
```

场景解释 [https://stackoverflow.com/questions/45096970/how-to-prevent-asyncsubject-from-completing-when-the-last-observer-unsubscribes/45112125#45112125](https://stackoverflow.com/questions/45096970/how-to-prevent-asyncsubject-from-completing-when-the-last-observer-unsubscribes/45112125#45112125)

## Recommend: Unbound methods

禁止在代码中出现对未绑定的方法调用。

```jsx
// 配置
"rxjs-no-unbound-methods": true,

// 问题用法
const ob = of(1).pipe(
            map(this.map),
                ~~~~~~~~                                                    [no-unbound-methods]
)
```

## Recommend: No create

不允许调用 Observable.create，用 new Observable 替代。

```jsx
"rxjs-no-create": true,
```

## Optional: Rules with NgRx

```jsx
"rxjs-no-unsafe-first": true,
"rxjs-no-unsafe-switchmap": true,
"rxjs-no-unsafe-catch": true,
```

## Optional: Switching to lettable operators

当使用 Lettable Operator 时，可以通过一些规则禁用其他的引入方法。

```jsx
"rxjs-no-add": { "severity": "error" },
"rxjs-no-patched": { "severity": "error" },
"rxjs-no-operator": { "severity": "error" },
```

场景解释 [https://ncjamieson.com/understanding-lettable-operators/](https://ncjamieson.com/understanding-lettable-operators/)

## Optional: rxjs-ban-operators

```jsx
// 禁止使用指定的 operator 或者 observable
"rxjs-ban-operators": {
  "options": [{
    "concat": "Use the concat factory function",
  }],
  "severity": "error"
}
```

详细规则可见 [https://github.com/cartant/rxjs-tslint-rules](https://github.com/cartant/rxjs-tslint-rules)
