---
title: Angular 状态管理方案调研
layout: post
thread: 247
date: 2020-05-08
author: Joe Jiang
categories: Document
tags: [Angular, Redux, ngrx, ngxs, State, 状态管理, 前端, JavaScript]
excerpt: 
---


## 1 / 状态管理

**RxJs + Service 组件内管理状态：** 在组件中可以声明一个属性，作为组件的内存存储。每次操作时调用服务（service）中的方法，然后手动更新状态。

```tsx
export class TodoComponent {
  todos : Todo[] = []; // 在组件中建立一个内存TodoList数组

  constructor(
    @Inject('todoService') private service,
  ) {}

  addTodo(){
    this.service
      .addTodo('test') // 通过服务新增数据到服务器数据库
      .then(todo => { // 更新todos的状态
        this.todos.push(todo); // 使用了可改变的数组操作方式
      });
  }
}
```

**RxJs + Service 组件只需访问，状态在服务中存储管理**：在服务中定义一个内存存储，然后在更新服务数据后手动更新内存存储，组件中只需要访问该属性即可。

```tsx
export class TodoService {
  private _todos: BehaviorSubject; 
  private dataStore: {  // 我们自己实现的内存数据存储
    todos: Todo[]
  };
  constructor() {
    this.dataStore = { todos: [] };
    this._todos = new BehaviorSubject([]);
  }
  get todos(){
    return this._todos.asObservable();
  }

  addTodo(desc:string){
    let todoToAdd = {};
    this.http
      .post(...)
      .map(res => res.json() as Todo) //通过服务新增数据到服务器数据库
      .subscribe(todo => {
        this.dataStore.todos = [...this.dataStore.todos, todo];
        //推送给订阅者新的内存存储数据
        this._todos.next(Object.assign({}, this.dataStore).todos);
      });
  }
}
```

**类 Redux 管理方案** - ngrx & ngxs

**其他未调研产品** - Akita  & mobX & Redux & Flux

## 2 / ngrx

ngrx/store的灵感来源于Redux，是一款集成RxJS的Angular状态管理库，由Angular的布道者Rob Wormald开发。它和Redux的核心思想相同，但使用RxJS实现观察者模式。它遵循Redux核心原则，但专门为Angular而设计。

![Angular%2042de371f584f465d91ae8d0d49f49bea/Untitled.png](/assets/in-post/2020-05-08-Angular-State-Management-Invest-Report-3.png)

### 基本原则/概念

- State（状态） 是指单一不可变数据
- Action（行为） 描述状态的变化
- Reducer（归约器/归约函数） 根据先前状态以及当前行为来计算出新的状态
- 状态用State的可观察对象，Action的观察者——Store来访问

1. **Actions** - Actions是信息的载体，它发送数据到reducer，然后reducer更新store。Actions是store能接受数据的唯一方式。在ngrx/store里，Action的[接口](https://link.zhihu.com/?target=https%3A//www.typescriptlang.org/docs/handbook/interfaces.html)是这样的：

    ```tsx
    export interface Action {
      type: string;
      payload?: any;
    }
    ```

2. **Reducers** - Reducers规定了行为对应的具体状态变化。它是纯函数，通过接收前一个状态和派发行为返回新对象作为下一个状态的方式来改变状态，新对象通常用Object.assign和扩展语法来实现。

    ```tsx
    export const todoReducer = (state = [], action) => {
      switch(action.type) {
        case 'ADD_TODO':
          return [...state, action.payload];
        default:
          return state;
      }
    }
    ```

3. **Store** - store中储存了应用中所有的不可变状态。ngrx/store中的store是RxJS状态的[可观察对象](https://link.zhihu.com/?target=https%3A//github.com/Reactive-Extensions/RxJS/blob/master/doc/api/core/observable.md)，以及行为的[观察者](https://link.zhihu.com/?target=https%3A//github.com/Reactive-Extensions/RxJS/blob/master/doc/api/core/observer.md)。我们可以利用Store来派发行为。当然，我们也可以用Store的select()方法获取可观察对象，然后订阅观察，在状态变化之后做出反应。
4. **Selector** - 可见示例代码
5. **Effects** - Redux 中的 Reducer 已经是一个纯函数，而且是完全的只对状态数据进行处理的纯函数。在发出某个 Action 之后，Reducer 会对状态数据进行处理然后返回。但一般来说，其实在执行 Action 后我们还是经常会可以称为 Effect 的动作，比如：进行 HTTP 请求，导航，写文件等等。而这些事情恰恰是 Redux 本身无法解决的，@ngrx/effects 用于解决这类场景，一个 http 请求的示例如下 [https://gist.github.com/hijiangtao/d4def77867ff4aec2740ba6ab83b24bf](https://gist.github.com/hijiangtao/d4def77867ff4aec2740ba6ab83b24bf)

    ```tsx
    @Component({
      template: `
        <div *ngFor="let movie of movies$ | async">
          {{ movie.name }}
        </div>
      `
    })
    export class MoviesPageComponent {
      movies$: Observable<Movie[]> = this.store.select(state => state.movies);
     
      constructor(private store: Store<{ movies: Movie[] }>) {}
     
      ngOnInit() {
        this.store.dispatch({ type: '[Movies Page] Load Movies' });
      }
    }
    ```

### 最佳实践

1. 根 store 模块 - 创建根 store 模块作为一个完整的 Angular 模块，与 NgRx 的 store 逻辑绑定在一起。功能 store 模块将被导入到根 store 中，这样唯一的根 store 模块将被导入到应用程序的主 App Module 模块中。
2. 创建功能 store 模块
    1. 方式一：Entity Feature Module - 定义 actions / 创建 state / 创建 reducer / 创建 selector / 创建 effects
    2. 方式二：标准的功能模块 - 同上
    3. 模块导入 angular - app.module.ts 引入

### 优势

1. **中心化，状态不可变** - 所有相关应用程序的状态都缓存在一个位置。这样可以很容易地跟踪问题，因为错误时的状态快照可以提供重要的见解，并且可以轻松的重新重现这个问题。这也使得众多困难问题，例如在Store应用程序的上下文中撤消/重做某一步骤，并且实现了更强大的功能的工具。
2. **性能** - 由于状态集合中应用程序的顶层，因为数据更新可以通过组件依赖于Store。Angular构建如这样的数据流布置进行优化，并且可以在组件依赖于没有发布新值的Observables的情况下禁用变化检测。
3. **测试** - 所有状态更新都是在recudes中处理的，它们是纯函数。纯函数测试非常简单，因为它只是输入，反对输出。这样可以测试应用程序中最关键的方面，而无需使用mock，或其他的测试技巧，可以使测试复杂且容易出错。

### 其他

可以结合 Redux Dewvtools 实现在线状态调试

- 扩展地址 [https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd?hl=en](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd?hl=en)
- 视频演示 [https://youtu.be/VbPgAf3FUU8](https://youtu.be/VbPgAf3FUU8)

ngrx 存在版本更迭，不少中文教程采用老 API 演示，如 StoreModule.provideStore / StoreModule.forRoot 等，以官方文档为准

官网 [https://github.com/ngrx/platform](https://github.com/ngrx/platform)

### 示例

[https://github.com/hijiangtao/ngrx-store-example](https://github.com/hijiangtao/ngrx-store-example)

## 3 / ngxs

在ngxs出来之前，angular有ngrx（来自redux的灵感），这很棒，但实际使用起来会非常费力，你会花大量的时间去为每一个action写reducer、effect。当然，付出这些代价的同时，我们的应用程序逻辑变得十分清晰，组件与组件的耦合变得更加松散，最内层的组件甚至只需要使用input和output负责展示数据，因此changedetection也可以使用onpush策略，整个组件也变得更加易于测试和维护。

ngxs更加活用了angular的特性，使用装饰器，并且隐藏了reducer的概念，鼓励程序员使用rxjs进行一系列的流式处理，这在一定程度上大大缩减了我们的代码量，使得一些中小项目使用状态管理框架的成本变得很低。

语法与 Angular 现有的写法及运作方式几乎是一样的，学习门槛变得很低。

![Angular%2042de371f584f465d91ae8d0d49f49bea/Untitled%201.png](/assets/in-post/2020-05-08-Angular-State-Management-Invest-Report-1.png)

### 基本原则/概念

- Store: Global state container, action dispatcher and selector
- Actions: Class describing the action to take and its associated metadata
- State: Class definition of the state
- Selects: State slice selectors

### 关键使用步骤注解

1. **注册** - 在 app.module.ts 中注册，与 ngrx 类似 `NgxsModule.forRoot([ZoosState])` 即可
2. **action 定义** - 基本与 ngrx 类似

    ```tsx
    export class AddAnimal {
      static readonly type = '[Zoo] Add Animal';
      constructor(public name: string) {}
    }
    ```

3. **model 定义** - 即 state interface 定义

    ```tsx
    export interface ZooStateModel {}
    ```

4. **建立 state** - 通过 `@State` decorator 来描述 state 的内容，Interface 建议以 Model 结尾，例如

    ```tsx
    @State<ZooStateModel>({
      name: 'zoo',
      defaults: {
        feed: false
      }
    })
    @Injectable() // 也可以依赖注入
    export class ZooState {
      constructor(private zooService: ZooService) {}

      @Action(FeedAnimals)
      feedAnimals(ctx: StateContext<ZooStateModel>) {
        const state = ctx.getState();
        ctx.setState({
          ...state,
          feed: !state.feed
        });
      }
    }
    ```

5. **派发 dispatch** - 在 comoponent view 上注入 store，然后进行派发 dispatch，操作过程中需要注意的是 dispatch 返回是空，如果需要获取 state 可以使用 @Select 进行链式调用

    ```tsx
    import { Store, Select } from '@ngxs/store';
    import { Observable } from 'rxjs';
    import { withLatestFrom } from 'rxjs/operators';
    import { AddAnimal } from './animal.actions';

    @Component({ ... })
    export class ZooComponent {
      @Select(state => state.animals) animals$: Observable<any>;

      constructor(private store: Store) {}

      addAnimal(name: string) {
        this.store
          .dispatch([new AddAnimal('Panda'), new AddAnimal('Zebra')])
          .pipe(withLatestFrom(this.animals$))
          .subscribe(([_, animals]) => {
            // do something with animals
            this.form.reset();
          });
      }
    }
    ```

6. **select** - 选中 state 的部分内容，具体使用可见上例
7. **获取 snapshot** - `store.snapshot()`
8. **reset** - `store.reset()`

### 示例与其他

示例略

官网 [https://www.ngxs.io/](https://www.ngxs.io/)

## 4 / 对比

ngxs vs ngrx 概念对比

![Angular%2042de371f584f465d91ae8d0d49f49bea/Untitled%202.png](/assets/in-post/2020-05-08-Angular-State-Management-Invest-Report-2.png)

1. ngrx 这个基本上是把 Redux 强行搬到 Angular 中，本来 Redux 就被吐槽不好用，看到各种 Switch 就高兴不起来，并且繁琐，写起来费劲；多 store 通过 `.forFeature()` 实现（lazy loading modules）；
2. ngxs 这个框架其实就是使用 RxJS 管理状态，感觉比 ngrx 好用，使用装饰器定义 State 和 Action，组件通过 `store.dispatch(new AddTodo('title'))` 调用对应的 `Action` 方法 , 充分利用了 Angular 和 TypeScript 的特质；单一 store；
3. 观点
    1. Difference in performance between ngrx and ngxs? [https://stackoverflow.com/questions/50704430/difference-in-performance-between-ngrx-and-ngxs](https://stackoverflow.com/questions/50704430/difference-in-performance-between-ngrx-and-ngxs) 
    2. Why I Prefer NGXS over NGRX [https://blog.singular.uk/why-i-prefer-ngxs-over-ngrx-df727cd868b5](https://blog.singular.uk/why-i-prefer-ngxs-over-ngrx-df727cd868b5)
    3. NGRX VS. NGXS VS. AKITA VS. RXJS: FIGHT! [https://ordina-jworks.github.io/angular/2018/10/08/angular-state-management-comparison.html](https://ordina-jworks.github.io/angular/2018/10/08/angular-state-management-comparison.html)
    4. Angular + Redux [https://medium.com/supercharges-mobile-product-guide/angular-redux-the-lesson-weve-learned-for-you-93bc94391958](https://medium.com/supercharges-mobile-product-guide/angular-redux-the-lesson-weve-learned-for-you-93bc94391958)
    5. Migrating from NGRX to NGXS in Angular 6 [https://medium.com/@joshblf/migrating-from-ngrx-to-ngxs-in-angular-6-ddddcdce543e](https://medium.com/@joshblf/migrating-from-ngrx-to-ngxs-in-angular-6-ddddcdce543e)

## 参考与扩展阅读

- [https://medium.com/@dan_abramov/you-might-not-need-redux-be46360cf367](https://medium.com/@dan_abramov/you-might-not-need-redux-be46360cf367)
- [https://zhuanlan.zhihu.com/p/45121775](https://zhuanlan.zhihu.com/p/45121775)
- [https://www.ngxs.io/](https://www.ngxs.io/)
- [https://github.com/ngrx/platform](https://github.com/ngrx/platform)
- [https://stackoverflow.com/questions/49409381/multiple-stores-in-ngrx](https://stackoverflow.com/questions/49409381/multiple-stores-in-ngrx)
- [https://medium.com/supercharges-mobile-product-guide/angular-redux-the-lesson-weve-learned-for-you-93bc94391958](https://medium.com/supercharges-mobile-product-guide/angular-redux-the-lesson-weve-learned-for-you-93bc94391958)
- [https://github.com/datorama/akita](https://github.com/datorama/akita)