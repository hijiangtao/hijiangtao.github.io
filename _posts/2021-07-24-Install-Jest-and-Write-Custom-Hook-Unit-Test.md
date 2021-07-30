---
title: Jest 安装配置与自定义 React Hook 单元测试教程
layout: post
thread: 267
date: 2021-07-30
author: Joe Jiang
categories: Document
tags: [2021, React, Jest, 单元测试, Hook, TypeScript]
excerpt: 什么是 npx？npx 都有哪些使用场景？
---

**前言**

关于单元测试与 FIRST 原则的介绍，我在另一篇基于 Jasmine 和 Karma 的单元测试基础教程中已经有过描述，本文便不再重复，感兴趣的同学可以移步[《基于 Jasmine 和 Karma 的单元测试基础教程》](/2020/07/06/Basic-Unit-Test-Tutorial/)查看详情。

本文基于 Jest 框架的集成配置以及如何编写 React 单元测试进行介绍，本文不关注 UI 层的测试实现，且不关注常规的 util 方法类测试实现，只围绕如何就 React 特性 Hook 进行单元测试用例编写展开，主要分为两个部分：

1. Jest 安装配置与解释
2. 模拟函数介绍与 Hook 单元测试实现

以下为正文。

## 一、Jest 安装配置与解释

简单介绍下配置背景，本文期望的是需要让一个使用 TypeScript 开发的 React 项目可以运行 TypeScript 编写的 Jest 单元测试用例。具体实现步骤比较简单，可以分为以下三步。

### 1.1 安装依赖

第一步，安装依赖

```jsx
npm i jest @types/jest ts-jest typescript -D
```

稍微解释一下：

- 安装 `jest` 测试框架 (`jest`)
- 安装 `jest` 类型包(`@types/jest`)
- 安装 jest 支持的 TypeScript 预处理器(`ts-jest`)
- 安装 ts-jest 的依赖 TypeScript 编译器 (`typescript`).
- 将如上依赖均安装为 dev-dependency

### 1.2 Jest 配置文件

第二步，配置 jest.config.js

```jsx
module.exports = {
  "roots": [
    "<rootDir>/src"
  ],
  "testMatch": [
    "**/__tests__/**/*.+(ts|tsx|js)",
    "**/?(*.)+(spec|test).+(ts|tsx|js)"
  ],
  "transform": {
    "^.+\\.(ts|tsx)$": "ts-jest"
  },
}
```

解释一下：

- 在 `roots` 选项中指定测试文件位置；
- 通过 `testMatch` 配置匹配全局要处理的文件类型；
- 通过 `transform` 配置告诉 `jest` 使用 `ts-jest` 来处理以 ts/tsx 结尾的文件；

### 1.3 添加启动脚本

第三步，比较简单，在你的 package.json 文件中添加一个 npm scripts：

```jsx
{
  "test": "jest"
}
```

如果不是从新项目开始直接集成 Jest，在配置过程中可能会遇到问题，我将自己遇到的一些问题罗列如下，供参考：

1. `Invalid Hook Call Warning` - react dom 版本不匹配
2. `Hooks can only be called inside of the body of a function component` - 这是因为你的 React 渲染环境需要修改，将 Jest 的配置中 "testEnvironment" 设置为 "jsdom" 即可
3. 无法识别 import/export 等模块引入关键字 - Jest 默认为 CommonJS 标准，不支持 ES Modules 标准，需要为指定文件范围设定 "extensionsToTreatAsEsm" 配置，Jest 才会进行处理

## 二、模拟函数介绍与 Hooks 单元测试实现

坚持原则

- 仅测试代码库内自身逻辑，对于三方依赖进行 mock
- 一次只测一个逻辑
- 单元测试应该覆盖自定义 component、service 与 hook

### 2.1 模拟函数与 API 介绍

模拟函数允许你测试代码之间的连接——实现方式包括：擦除函数的实际实现、捕获对函数的调用 ( 以及在这些调用中传递的参数) 、在使用 `new` 实例化时捕获构造函数的实例、允许测试时配置返回值。以下介绍创建模拟函数的方式。

#### jest.mock

通过 `jest.mock` ，直接指定工厂函数入参，便可以完成对特定三方依赖的模拟

```jsx
import { jest } from '@jest/globals';

jest.mock('react-i18next', () => ({
  useTranslation: () => {
    return {
      t: (str: string) => str,
    };
  },
}));
```

而在模拟模块上，我们还有不少 API 可以调用，用来单独对模拟行为进行定制，以下介绍其中三组，每组有两种用法：

1. `mockFn.mockImplementation(fn)`
2. `mockFn.mockImplementationOnce(fn)`
3. `mockFn.mockReturnValue(value)`
4. `mockFn.mockReturnValueOnce(value)`
5. `mockFn.mockResolvedValue(value)`
6. `mockFn.mockResolvedValueOnce(value)`

#### 模拟函数部分 API 介绍

在 Jest 框架中用来进行模拟的方法有很多，主要用到的是`jest.fn()`和`jest.spyOn()`。`jest.fn`会生成一个模拟函数，这个函数可以用来代替源代码中被使用的第三方函数。

当你需要根据别的模块定义默认的模拟函数实现时，`mockImplementation`方法便可以派上用场；而如果需要每一次调用返回不同结果时，可以换用`mockImplementationOnce` 方法。

```jsx
const mockFn = jest.fn().mockImplementation(scalar => 42 + scalar);

const a = mockFn(0);
const b = mockFn(1);

a === 42; // true
b === 43; // true

mockFn.mock.calls[0][0] === 0; // true
mockFn.mock.calls[1][0] === 1; // true
```

模拟函数在测试期间还有一些其他的测试值注入代码方式，比如 `mockReturnValue` 可以用于定义在指定函数的每一次调用时返回预设值︰

```jsx
const myMock = jest.fn();
console.log(myMock());
// > undefined

myMock.mockReturnValueOnce(10).mockReturnValueOnce('x').mockReturnValue(true);

console.log(myMock(), myMock(), myMock(), myMock());
// > 10, 'x', true, true
```

此外，我们还可以通过模拟函数的 `mockResolvedValueOnce` 方法（在指定函数调用时只会返回一次预设值）来 mock axios API 的多次请求返回值，如下为一个基本的请求函数：

```jsx
// 请求本身
export const getData = () => {
    return axios.get('/api').then(res => res.data)
}
```

我们通过如下方式对如上函数进行测试：

```typescript
import { testDemo } from './index';
import axios from 'axios';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

test('测试 testDemo', async () => {
    mockedAxios.get.mockResolvedValueOnce({ data: 'hello' });
    mockedAxios.get.mockResolvedValueOnce({ data: 'world' });
    await testDemo('test').then(data => {
        expect(data).toBe('hello');
    });
    await testDemo('test2').then(data => {
        expect(data).toBe('world');
    });
});
```

除了以上同步的 mock 外，我们还可以定义一些异步的模拟操作，比如 `mockResolvedValue`：

```jsx
test('async test', async () => {
  const asyncMock = jest.fn().mockResolvedValue(43);

  await asyncMock(); // 43
});
```

### 2.2 如何测试自定义 React Hook

如何测试 hook？我们可以使用 `[@testing-library/react-hooks](https://github.com/testing-library/react-hooks-testing-library)` 来辅助实现。

`@testing-library/react-hooks` 允许你为 React 钩子创建一个简单的测试工具，用来处理在函数组件内去运行它们，并提供有各种有用的实用函数来更新输入输出。

利用该开源库，你不再需要关注如何构造、渲染以及与 react 组件交互的细节，你可以直接测试 hook 并断言结果。

以下主要介绍 `renderHook` 和 `act` 的使用方式。

#### 使用 renderHook API 测试 Hook

`renderHook`，顾名思义是一个直接用来“渲染” hook 的 API。它会在调用的时候渲染一个专门用来测试的 `TestComponent` 来使用我们的 hook。

`renderHook` 的函数签名是 `renderHook(callback, options?)`，第一个参数是一个回调函数，这个函数会在 `TestComponent`每次被重新渲染的时候被调用，因此我们可以在这个函数里面调用我们想要测试的 hook；它的第二个参数是一个可选 options，这个 options 可以带两个属性，一个是initialProps，它是 `TestComponent` 的初始 props 参数，并且会被传递给回调函数用来调用 hook，options 的另外一个属性是 wrapper，它用来指定 `TestComponent` 的父级组件（Wrapper Component），这个组件可以是一些 `ContextProvider`等用来为 `TestComponent` 的 hook 提供测试数据的东西。

`renderHook` 的返回值是 `RenderHookResult` 对象，这个对象会有下面这些属性：

- result：`result` 是一个对象，它包含两个属性，一个是 `current`，它保存的是`renderHookcallback` 的返回值，另外一个属性是 `error`，它用来存储 hook 在 render 过程中出现的任何错误。
- rerender: `rerender` 函数是用来重新渲染 `TestComponent` 的，它可以接收一个 newProps 作为参数，这个参数会作为组件重新渲染时的 props 值，同样 `renderHook` 的 `callback` 函数也会使用这个新的 props 来重新调用。
- unmount: `unmount` 函数是用来卸载 `TestComponent` 的，它主要用来覆盖一些 `useEffect cleanup` 函数的场景。

下面我们来看一个例子。假设我们定义了一个自定义 `usePrevious` Hook 如下所示：

```jsx
import { useEffect, useRef } from 'react';

export function usePrevious<T>(value: T): T | undefined {
    const ref = useRef<T>();

    useEffect(() => {
        ref.current = value;
    }, [value]);

    return ref.current;
}
```

一个简单的单元测试用例可以写成这样：

```jsx
import { renderHook } from '@testing-library/react-hooks';
import { usePrevious } from '../index';

const setUp = () => renderHook(({ state }) => 
  usePrevious(state), { initialProps: { state: 0 } }
);

it('should return undefined on initial render', () => {
    const { result } = setUp();

    expect(result.current).toBeUndefined();
});

it('should always return previous state after each update', () => {
    const { result, rerender } = setUp();

    rerender({ state: 2 });
    expect(result.current).toBe(0);

    rerender({ state: 4 });
    expect(result.current).toBe(2);

    rerender({ state: 6 });
    expect(result.current).toBe(4);
});
```

#### 使用 act API 保证更新已应用于 DOM

从 React 文档中，我们可以知道 act 的作用：

> 在编写 UI 测试时，可以将渲染、用户事件或数据获取等任务视为与用户界面交互的“单元”。react-dom/test-utils 提供了一个名为 act() 的 helper，它确保在进行任何断言之前，与这些“单元”相关的所有更新都已处理并应用于 DOM —— [https://zh-hans.reactjs.org/docs/testing-recipes.html#act](https://zh-hans.reactjs.org/docs/testing-recipes.html#act)

在 React 中 act 可以通过如下方式调用：

```jsx
act(() => {
  // 渲染组件
});
// 进行断言
```

而在 `@testing-library/react-hooks` 中，它并没有额外的差异，是同一个函数。在组件状态更新时，组件需要被重新渲染，而这个重渲染是需要 React 调度的，因此是个异步的过程。通过使用 act 函数，我们可以将所有会更新到组件状态的操作封装在它的 callback 里面来保证 act 函数执行完之后我们定义的组件已经完成了重新渲染。

比如，如下我们定义一个自定义计数器 hook，返回值除了 count 本身，我们还提供增减两个操作方法： 

```jsx
import { useState, useCallback } from 'react'

function useCounter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => setCount(x => x + 1), [])
  const decrement = useCallback(() => setCount(x => x - 1), [])

  return {count, increment, decrease}
}
```

通过使用 act 函数，我们可以这样为这个组件完善单元测试：

```jsx
import { renderHook, act } from '@testing-library/react-hooks'
import useCounter from 'somewhere/useCounter'

describe('Test useCounter', () => {
  describe('increment', () => {
     it('increase counter by 1', () => {
      const { result } = renderHook(() => useCounter())

      act(() => {
        result.current.increment()
      })

      expect(result.current.count).toBe(1)
    })
  })

  describe('decrement', () => {
    it('decrease counter by 1', () => {
      const { result } = renderHook(() => useCounter())

      act(() => {
        result.current.decrement()
      })

      expect(result.current.count).toBe(-1)
    })
  })
})
```

最后附上部分参考：

- [Jest 文档](https://jestjs.io/)
- [React 测试技巧](https://zh-hans.reactjs.org/docs/testing-recipes.html)
- [@testing-library/react-hooks](https://react-hooks-testing-library.com/)
