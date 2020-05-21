---
title: 前端组件库本地开发调试的自动化流程实现
layout: post
thread: 248
date: 2020-05-21
author: Joe Jiang
categories: Document
tags: [Angular, 依赖, 调试, 自动化, 前端, JavaScript]
excerpt: 关于在 Angular 项目中引入状态管理方案的一些调研内容。
---

*注：文中涉及到的三方/二方组件库、组件、本地依赖、依赖、开源库、component 和 library 等词汇在此均指同一概念，即抽象出来的通用组件。*

## 问题与背景

如果不对项目进行设计，我们写的所有代码都会存于同一个仓库，，当需要本地调试编码效果时，一条 `npm run start` 或者 `npm run dev` 便可把我们所需的服务启动，但随着时间推移，这个项目无法避免会成为一个「巨无霸」，而其带给我们的伤害会远大于收益，于是我们想到了拆分，那么，就将一些 UI 或者计算逻辑单独抽成包吧。

![Untitled%2086967d1b580b474eacd008215dcae42f/.001.png](/assets/in-post/2020-05-21-A-Better-Library-Development-Workflow-1.png)

<center><small>图1 - 代码都在一个仓库中的调试流程</small></center>

假设我们维护的主应用就叫 `big-platform`，其中有一些通用逻辑我们给抽象到了一个 Node package 里，暂且取名 `@fudao/hello` 并发布到 npm 上，等其他同学开发需要用到这个组件或者逻辑时，一条 `npm install @fudao/hello --save` 便能搞定，是不是方便了不少。

调用组件是一个非常开心的事情，理论上你啥也不需要管，调调 API 就能得到想要的一切。但是，如果这是一个有问题的组件，怎么办？当我们遇到组件实际显示效果和文档中预期不一致时，浮现在脑中的第一想法便是上报 Bug 然后等作者更新，但麻烦之处在于你需要将现象描述清楚，并附上一可复现 Bug 的示例，而至于作者何时响应，更是不得而知。你可能头皮发麻，心想自己直接把他给改了得了。

![Untitled%2086967d1b580b474eacd008215dcae42f/.002.png](/assets/in-post/2020-05-21-A-Better-Library-Development-Workflow-2.png)

<center><small>图2 - 项目与 library 分开发维护的调试流程</small></center>

当我们需要修改二方或者三方组件库时，写代码都好说，但如何调试往往难倒了很多同学。为了验证修改没有问题再发布，我们的验证过程成了这期间最耗时的任务。这么长串的一个流程，我们有没有什么办法可以让三方组件库在本地开发和调试时就像内嵌在项目中一样流畅呢（无额外感知成本）？

## 现有开发调试方案

大致来看，存在几种不那么方便的复制粘贴大法。

第一种是利用 `npm link` 来做手动搬运。每当变更过 library 上的代码后，我们在其所在目录执行

```tsx
npm run build // 执行构建
cd dist/hello // 进入构建后结果目录
npm link // 将 library 链接到全局
```

然后到项目所在目录重新绑定并重启服务

```tsx
npm link @fudao/hello 
npm run start // 对应到具体执行脚本
```

这种方式的痛苦之处在于你的 `npm run build` 和 `npm link` 需要在每次 library 代码更改后重新执行一遍，而后你还需要停止调试服务，在项目中更新依赖并重启服务。

我们接着来看第二种搬运方式。假设你的项目调试服务可以对 node_modules 中依赖包变更进行监听，那么其实你有两种方式来实现在项目服务不重启的情况下将依赖包的变更“推送”到运行的项目中：

1. 复制构建后文件夹到项目 node_modules 目录
2. 在项目中安装依赖时使用文件路径安装

第一种方式你可能会用上如下命令：

```bash
cp -r dist/hello/ /project/node_modules/@fudao/hello
```

而第二种方式则需要在执行依赖安装的时候将具体包名替换为本地路径，安装完成后你的 `package.json` 大致会变成这样：

```bash
{
  "name": "big-platform",
  "dependencies": {
    "@fudao/hello": "file:../hello/dist/hello"
  }
}
```

但一定记着，上线之前你需要把这个依赖改回去，这还是不怎么方便啊；此外，这两种方式都需要你在 library 代码变更后先执行一次包的构建命令，毕竟，要先得到最近的构建包。

再来说一种方式，即源码引用。如果是 React 或者 Vue 项目，将 library 声明为一个 ES Module 并列好入口文件，那么直接更改项目中 import 方式（从包名改为路径形式）或是直接拷贝未构建代码均可达到调试的效果。如果是 Angular 项目，你可以在 tsconfig.json 中指定 library 的路径映射（直接引入），但 Angular library 在项目中的使用，用源码引入和实际构建后引入这两种方式仍然存在一些差异，所以这么来看，也还是不太方便。

看看上面这些方法，我们再回头来看本地项目中调试 library 的流程图，发现这些方法要么是解决了前半部分的流程问题，要么是便利了后半部分的同步问题，但与此同时又都引入了一些额外的处理流程，如果能把这些内容全部自动化就好了。

![Untitled%2086967d1b580b474eacd008215dcae42f/.003.png](/assets/in-post/2020-05-21-A-Better-Library-Development-Workflow-3.png)

<center><small>图3 - 理想情况下项目与 library 分开发维护的本地调试流程</small></center>

## 相关技术探索

![Untitled%2086967d1b580b474eacd008215dcae42f/.004.png](/assets/in-post/2020-05-21-A-Better-Library-Development-Workflow-4.png)

<center><small>图4 - 如何把如上几部分串起来，使本地开发调试 workflow 更加顺畅</small></center>

如何把如上几部分串起来，使本地开发调试 workflow 更加顺畅？可能着重要看看监听后的任务构建、构建产物的推送更新以及项目重新编译三个部分。

网上搜了许多内容，最终在尝试后结合实际需要，我重新设计了一个用于本地 library 开发调试的自动化流程。

在我们说其中一些细节之前，我们先介绍两个社区开源库，nodemon 和 yalc，我将它们用于我的自动化流程中了。

### 文件监控开源库 nodemon

nodemon 是一个用来监视 Node.js 应用程序中文件更改并自动重启服务的开源库，仅用于开发环境（推荐）。

使用上不需要对项目代码做任何操作，命令也只是简单将 node 替换为 nodemon，你可以用如下命令安装它：

```bash
npm i -g nodemon
```

然后配置一下自定义参数，比如观察的文件类型（是只观察 .ts 文件还是 HTML/CSS/TypeScript 的文件变更都需要被监控）、需要观察的文件路径、需要忽略的路径（比如 node_modules）以及自定义命令等。

虽然 nodemon 被设计用来监控重启 Node 应用，但是也支持监控执行自定义命令，比如在我的项目中我通过如下命令使用 nodemon 来监控我的代码变更：

```bash
nodemon 
	--ignore dist/ # 忽略目录
	--ignore node_modules/ 
	--watch projects # 观察目录
	-C # 只在变更后执行，首次启动不执行命令
	-e ts,html,less,scss # 监控指定后缀名的文件
	--debug # 调试
	-x "npm run build && cd dist/hello && yalc push" # 自定义命令
```

你还可以通过 `nodemon -h` 了解更多，关于 nodemon 就介绍到这。

### 本地依赖管理开源库 yalc

如果你在本地调试过外部依赖库，那么一定对 `npm link` 不会陌生，通过 link 命令可以将我们要使用的外部依赖从本地链接到全局 `node_modules`，之后在具体项目中我们再把他 link 进来，则完成了一次操作。但如果我们的项目和 library 共同维护了一份框架代码副本，那么 link 可能还会有一些其他意想不到的错误。

yalc 是一个类似于本地化 npm 的解决方案，它在本地环境中创建了一个共享的 library 存储库，使得你在需要使用本地依赖时可以快速从这个存储库拉取资源进行消费。当在指定 library 中运行 `yalc publish` 时，它会将本来发布到 npm 上的相关文件存储在本地这个共享的全局存储中，而在项目中通过 yalc 添加依赖时， `yalc add @fudao/hello` 会从全局存储拉入信息到项目根目录的 `.yalc` 文件夹，并将一个文件 `"file:.yalc/@fudao/hello"` 注入 `package.json`。

yalc 比较诱人的一点在于他还有一个命令叫 `yalc publish --push` 或者简称 `yalc push`，他会将你的依赖发布到本地存储库（更新状态），并将所有更改传播到现有通过 `yalc`安装的依赖中，这个操作实际上进行了一次 `update` 操作，此处不再展开，感兴趣的同学可以移步[官方文档](https://github.com/whitecolor/yalc)查看更多。

如此一来，你可以完全按照 npm install 从远程 registry 拉取依赖的方式安装和消费一个本地依赖，Cool。

### 自动化方案

![Untitled%2086967d1b580b474eacd008215dcae42f/.005.png](/assets/in-post/2020-05-21-A-Better-Library-Development-Workflow-5.png)

<center><small>图5 - 设计后的自动化本地开发调试流程</small></center>

图中绿色部分皆为可自动化执行的流程，即我们只需要关注两个框内的代码更改，黄框对应 library 代码，蓝框对应项目代码，其他流程均在代码变更时自动触发并最终将变更产物刷新到浏览器中。

而项目调试服务采用的是 webpack-dev-server，这个便不多说，时至今日这已经是很多 CLI 本地起调试服务必备的技术之一了，以至于开发者在大部分时候都不需要关心它，一条类似于 `ng serve` 的命令便帮我们把背后的许多事都干了。

值得注意的是，因为引入了 library 构建的流程，你的任何代码改动都会触发整个流程重新执行一次，所以为了避免不必要的编译消耗，你可以将 Monitor 部分抽离出来，替换为一条执行命令，这样，只在你认为完成编码后再执行一次所以如果你不需要实时编译，这个可以具体分析来看。

![Untitled%2086967d1b580b474eacd008215dcae42f/.006.png](/assets/in-post/2020-05-21-A-Better-Library-Development-Workflow-6.png)

总结一下，我们的定义了一些 Make 脚本和 npm 脚本用于执行具体构建、推送和调试命令，我们用 nodemon 对 library 侧文件变更进行监控，并用 yalc 作为本地发布和推送更新的工具，最后 webpack 是本地调试热更新服务器的实现基础。

你可以将其中的实现替换为你喜欢的方案或软件，然后通过脚本串通整个流程。说到脚本，假设你采用我调研后决定使用的 yalc + nodemon 方案，那么在 library 项目中，你可以通过如下 Makefile 指定几个命令：

```bash
init: # 初始化环境
	npm install
	npm install -g yalc nodemon

push: # 手动构建与 push
	npm run build
	cd dist/hello && yalc push

watch: # 自动监听文件变化并执行构建与 push 任务
	nodemon --ignore dist/ --ignore node_modules/ --watch projects -C -e ts,html,less,scss --debug -x "npm run build && cd dist/hello && yalc push"
```

而在业务项目中，若是你不喜欢 Makefile，可以直接在 `package.json` 中指定几个 commands，这样你就可以直接 `npm run *` 一把梭了:

```bash
{
    "name": "big-platform",
    "version": "0.0.1",
    "scripts": {
        "ng": "ng",
        "start": "ng serve",
        "build": "ng build --base-href /big-platform/",
        "test": "ng test",
        "lint": "ng lint",
        "e2e": "ng e2e",
        "init": "npm install && npm install -g yalc",
        "link-hello": "yalc add @fudao/hello",
        "remove-hello": "yalc remove --all",
        ...
    },
    ...
}
```

关于上面说的一些解决方案，你也可以用来做其他有趣的事情，以下附上部分地址：

1. yalc [https://github.com/whitecolor/yalc](https://github.com/whitecolor/yalc)
2. nodemon [https://github.com/remy/nodemon](https://github.com/remy/nodemon)
3. webpack-dev-server [https://webpack.js.org/configuration/dev-server/](https://webpack.js.org/configuration/dev-server/)

## 总结

抛去具体实现方案，总结来看，我们的自动化开发调试流程也可以抽象为两个通用部分：

1. 本地开发调试阶段
    1. 在 library 侧，进入 library 所在目录启动监听器（nodemon），并附上 watch 变化后重新构建和推送新包的脚本命令（Makefile）；
    2. 在项目侧，注册对本地 library 的依赖并安装（yalc add @package），并启动本地开发服务（webpack-dev-server），负责调试服务和热更新等内容；
2. 在发布流程前
    1. 在 library 侧，关闭监听器并编译打包（npm run build），发布新版本至 npm；
    2. 在项目侧，移除对本地 library 依赖的声明（yalc remove --all），并构建打包、上线。

实际干活时，一条命令自动化整个本地开发调试过程。改造下来，开发流程顺畅了不少，感觉还不错。
