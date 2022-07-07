---
title: 前端开发中的流程自动化与提效实践
layout: post
thread: 280
date: 2022-07-07
author: Joe Jiang
categories: Document
tags: [自动化, 提效, 前端, CHANGELOG, 脚手架, craco, husky, git hooks]
excerpt: 随着前端的发展，越来越多的工具库、方法被用在日常研发流程中，这大大提升了业务开发的效率，而随着各类自动化流程的建设，开发同学也不再需要关注到每一个细节。前段时间项目阶段性交付，在推进的过程中也做了不少尝试，虽然从长期看，这类工作最后可能都该收敛到基础设施部门或者标准的自动化流程中去，但并不妨碍我通过实践来落实一些对项目开发的思考和想法。
header:
  image: ../assets/in-post/2022-07-07-Practice-of-Project-Development-and-Auto-Workflow-Teaser.png
  caption: "©️hijiangtao"
---

随着前端的发展，越来越多的工具库、方法被用在日常研发流程中，这大大提升了业务开发的效率，而随着各类自动化流程的建设，开发同学也不再需要关注到每一个细节。前段时间项目阶段性交付，在推进的过程中也做了不少尝试，虽然从长期看，这类工作最后可能都该收敛到基础设施部门或者标准的自动化流程中去，但并不妨碍我通过实践来落实一些对项目开发的思考和想法。

如果你是一名有经验的开发者，可以直接跳到文章末尾，「总结」一章有对全文内容的精简描述。

接下来，我来分享下在项目开发中尝试的一些自动化和提效实践。本文在撰写中涉及的 UI 框架主要以 create-react-app 所产生的 React 项目为主，会辅以部分其他框架的解决方案以说明。

## 新建项目第一步：脚手架

如果你的项目选型是 Angular 的话，那么选择不多可以直接上 Angular CLI；如果是 React 或 Vue 的话，那么会有不少脚手架可以选择，国内很多开发者都有开源不同方案。其中，大多方案会有一些组件库、开源库的绑定，如果你希望一个更加自由的框架搭建，官方脚手架 create-create-app (CRA) 肯定会是第一选择。

通过 npx 执行如下命令，我们可以通过 CRA 快速创建一个 TypeScript 项目：

```tsx
npx create-react-app project --template typescript
```

但随着 CRA 的发展，官方脚手架也将原来暴露在模版中的越来越多细节封装到 react-scripts 包里，简单举个例子，比如你想修改项目 webpack 构建流程，用官方模版无法直接上手。

官方模版提供了 `npm run eject` 命令，执行这个命令会将潜藏的一系列配置文件和一些依赖项都“弹出”到项目中，然后就可以由你自己完全控制增删，但是该操作是不可逆的。在配置文件被“弹出”后，你后续将无法跟随官方的脚步去升级项目所使用的 react-script 版本了。

那么，如果你想要一个可以覆盖配置，但又与官方版本保持同步的方案，则可以试试 craco [https://github.com/dilanx/craco](https://github.com/dilanx/craco)

## 样式隔离方案：CSS Modules

这一部分接着上文继续。这可能是一个已经被大家熟知且默认开启的选项了，其起源也在于对组件样式的隔离需求，且如果你的项目是一个CRA 官方其实已经支持对 CSS Modules 的启用，按照规定的格式命名你的样式文件，CRA 便可自动对样式进行解析处理。

但如前文所述，如果你想做一些样式 loader 的修改，就比如默认的解析方式不支持样式变量的驼峰式命名。要达到目的，你可以在集成 craco 后在配置 craco.config.js 中这么写，扩充 css loader 配置选项：

```tsx
module.exports = {
  style: {
    css: {
      mode: "extends",
      loaderOptions: {
        modules: {
          auto: true,
          exportLocalsConvention: 'camelCaseOnly',
        },
      },
    },
  },
};
```

当然，当我们在 TypeScript 文件中引用 CSS Modules 变量时，由于 TypeScript 并不知道除了 .ts 以及 .tsx 文件外的文件内容，为了防止 IDE 在语法检查上报错，我们还需要针对特定文件后缀声明下环境变量。针对 CRA 新建的项目，你可以简单建立一个 react-app-env.d.ts 文件来补充上如下说明：

```tsx
/// <reference types="node" />
/// <reference types="react" />
/// <reference types="react-dom" />
/// <reference types="react-scripts" />

declare module '*.module.css' {
  const classes: { readonly [key: string]: string };
  export default classes;
}

declare module '*.module.scss' {
  const classes: { readonly [key: string]: string };
  export default classes;
}

declare module '*.module.sass' {
  const classes: { readonly [key: string]: string };
  export default classes;
}
```

此外，通过 craco 你还可以修改些其他内容，比如配置 babel 不对 ES6 模块做转译、修改打包路径、自定义热更新方案等等。

## ESLINT 代码检查：两个自定义 lint 场景分享

为了保证统一一致的代码风格，比如在项目中避免使用 `var`，我们可以引入 eslint rules 对提交的代码进行规范。当然，如今大多数脚手架在新建项目时，应该都替你集成好了 eslint，要么是 .eslintrc.json、.eslintrc.js 或者直接在 package.json 中添加 eslintConfig 属性开干。

除了开启默认的规则集外，在开发过程中，为了让项目在多人之间能够更高效地推进协作开发，肯定有不少细节需要处理，这里我简单分享两例。

第一点，当我们对代码做了一些增删操作，就可能产生冗余的 import 声明，这个时候我们当然希望它在提交时被删除。

在 eslint 中，插件可以暴露额外的规则以供使用。如果要达到我们刚刚说的目的，这个时候可以引入 [unused-imports](https://github.com/sweepline/eslint-plugin-unused-imports) 插件对 es6 imports 进行代码检查（比如对于未使用到的 import 声明进行 error 提示）：

```tsx
{
	"plugins": ["unused-imports"],
  "rules": {
    "no-unused-vars": "off",
    "unused-imports/no-unused-imports": "error",
    "unused-imports/no-unused-vars": [
      "warn",
      { "vars": "all", "varsIgnorePattern": "^_", "args": "after-used", "argsIgnorePattern": "^_" }
    ]
  }
}
```

借助 IDE 或者 IDE 插件，我们还可以前置到每次保存时执行对 import 引用的清理。

多人协作中还容易出现一类问题，那就是代码冲突。当多人同时修改一个文件时，可能会同时引入新的模块，如果不对代码进行统一风格管理，那么很容易出现“import 冲突”。为了解决这个问题，可以引入 [simple-import-sort](https://github.com/lydell/eslint-plugin-simple-import-sort) 插件，插件还支持对 export 进行排序处理：

```tsx
{
  "plugins": ["simple-import-sort"],
  "rules": {
    "simple-import-sort/imports": "error",
    "simple-import-sort/exports": "error"
  }
}
```

这样，在代码提交前执行一遍 eslint —fix 便可完成代码的检查与修复，关于这部分我们在后面 git hook 一章中详细介绍。

其他还有一些与框架相关的，比如从 React 17 开始，我们可以通过配置 eslint rules 达到无需在代码中引入 React 的目的，关于这一部分的实现可以参考 [React 官方指导](https://reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transform.html)，以下为一段简单的前后代码对比：

```tsx
// 以前
import React from 'react';

function App() {
  return <h1>Hello World</h1>;
}

// 现在
function App() {
  return <h1>Hello World</h1>;
}
```

## 自动化环境配置：git hook 钩子定义

husky 是一个为 git 客户端增加 hook 的工具，可以被用于我们配置本地自动化环境。我们可以安装 husky 并定制我们需要的 git 钩子及具体需要执行的任务，这样可以方便我们在对代码执行 git 操作时，在特定时机对代码进行特定的检查与处理，常见的钩子有如下两个：

- commit-msg - 提交信息钩子，在执行 git commit 或者 git merge 时触发
- pre-commit - 预先提交钩子，在执行 git commit 时触发

如下为一段 husky 安装和初始化代码：

```tsx
npm install husky -D
npx husky-init && npm install 

// 添加任务一条 commit-msg 钩子
npx husky add .husky/commit-msg './node_modules/.bin/commitlint --from=HEAD~1'
```

举个例子，比如我们可以结合 commitlint 工具，在 commit-msg 阶段针对 commit 信息进行检查和处理（如上代码所示），又或者在 pre-commit 阶段对将要提交的代码进行格式化操作。

## 自定义命令调用：代码风格统一与 commit 信息规范

不仅是对于开发代码，对于 commit 信息来说，五花八门的书写风格，也十分不利于阅读和维护，比如，当我们需要翻阅历史提交来定位具体 commit 所带来的代码变动时，这依赖于规范的 commit 信息。借助 commitlint 可以帮助我们达到这一点。

commitlint 需要配合 husky 一起使用，具体来说，通过 husky 来保证针对具体钩子的命令配置，通过 commitlint 保证 命令执行能够对 commit msg 信息进行特定检查。一个简单的 commitlint 安装和配置如下：

```tsx
# 安装
npm install --save-dev @commitlint/{config-conventional,cli}

# 配置
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js
```

配置了 commitlint 之后，若是使用默认配置，那么只有当我们的 commit msg 符合如下规范时，commit 操作才能正常完成执行，否则中断（其中 scope 为可选）：

```tsx
<type>(<scope>): description
```

如果需要自定义规则，则需要我们更改 commitlint.config.js 文件，为其增添 rules，关于这一部分可以参考官方文档 [https://commitlint.js.org/](https://commitlint.js.org/)。

此外，在添加了 commitlint 配置文件后，我们可能会看到 IDE 对这个文件的检查标红，由于在项目构建中我们并不关注该配置文件的格式等内容（因为他只是对 commitlint 的简单配置），所以我们可以在 eslint 配置文件中将其忽略掉。同样的，如果有其他的文件属于类似的定位，你也可以一并将其加入：

```tsx
{
  "ignorePatterns": ["commitlint.config.js"]
}
```

说完 commit 规范，我们的代码格式本身也需要规范，比如针对 TypeScript 代码会有变量命名和排序的规则，针对 html 模版会有缩进、标签闭合等规则，这些也可以利用工具结合 git hook 来实现，此处，我们介绍下 linter 工具：lint-staged。

lint-staged 是一个在 git 暂存文件上运行 linters 的工具，通过 lint-staged 定制各类文件格式化的操作（主要通过 eslint 和 prettier 保证执行）。结合 pre-commit git hook，我们在此钩子被触发时执行 lint-staged，便能完成对相应文件的格式化处理。如何让工具针对不同类型的文件区分处理呢？这里可以通过配置达到目的，即在 pakage.json 中对 lint-staged 字段进行声明：

```tsx
{
  ...,
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint -c ./.eslintrc.json --fix"
    ],
    "(*.json|.eslintrc|.prettierrc)": [
      "jsonlint --in-place"
    ],
    "*.{s,}css": [
      "prettier --write"
    ],
    "*.{html,md}": [
      "prettier --write"
    ]
  }
}
```

如上代码表明，lint-staged 可以针对 JavaScript/TypeScript 类文件执行 eslint 处理，针对 json 类文件执行 jsonlint 处理，而对样式文件和 html 文件都用 prettier 处理。

## 本地开发代理环境

从本地开发的场景来看，最需要完善的一个功能就是转发 API 请求了，用以规避可能存在的 CORS 错误，或者绕开一些请求限制，形式上可以是针对特定请求变更 header 信息，也可以是针对特定请求变更实际请求的域名与路径。但无外乎都需要在本地建立一个代理环境。前端项目在本地开发时，我们可以通过一个叫做 [http-proxy-middleware](https://github.com/chimurai/http-proxy-middleware) 的库来增强本地 dev server 的能力。

通过文档介绍，我们知道可以通过调用 createProxyMiddleware API 来构造一个中间件，以供 Node.js 项目使用，针对 express 应用可以通过如下配置完成代理服务器中间件的配置：

```tsx
import * as express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';

const app = express();

app.use(
  '/api',
  createProxyMiddleware({
    target: 'http://www.example.org/api',
    changeOrigin: true,
  })
);

app.listen(3000);
```

而对于通过 CRA 构建的项目，由于 CRA 已经做了一些封装工作，于是在本地开发时，我们不再需要显式地起一个 Node.js 应用，而如上对代理中间件地调用，也可以在指定文件中按照规范书写（文件名以及方法签名需要规范，此处不列举，CRA 官方文档有说明）。

## 代码复用：组件模版与 code snippets

当我们新建一个项目时，我们会找脚手架替我们搭建一个合适的架子，然后我们往里面填充组件、页面、服务等等，而针对更细粒度的代码，我们同样可以考虑通过代码复用来提升我们的开发效率，这里的场景主要可以分为两类：

1. Code snippets 类代码片段
2. 组件粒度的文件代码

针对第一类场景，我们在 IDE 中安装的不少插件都替我们达到了这个目的。当我们在特定类型的文件中敲出几个字母，然后一回车，就能快速生成一段代码片段。举个例子，比如当我们使用 RxJS 时经常需要定义 BehaviorSubject 及其 getter & setter，要是输入 `bgs` 就能出现如下代码，便能提高我们在写一些初始化代码时的效率：

```tsx
/* TODO: 数据流定义 */
behaviorName$ = new BehaviorSubject<string>(initialValue);

get behaviorName() {
     return this.behaviorName$;
}

set behaviorName(value: string) {
     this.behaviorName$.next(value);
}
```

而我们要做的事情就是将 `bgs` 和上述代码（及特定占位符）连接起来，实现方案可以是 VS Code 插件，比如我之前写过一个 [https://marketplace.visualstudio.com/items?itemName=hijiangtao.tutor-code-snippets](https://marketplace.visualstudio.com/items?itemName=hijiangtao.tutor-code-snippets)，也可以是 WebStorm 插件或者 live templates。

针对第二类场景，我们需要的往往是指定路径下一套遵循我们命名规范的模版、样式和 TypeScript 逻辑代码。举个例子，在 Angular 项目中，当我们新建一个组件时，我们需要同时生成 HTML、JavaScript、CSS 文件并更新离其最近的 `*.module.ts` 文件：

```tsx
CREATE projects/src/app/demo/demo.component.css (0 bytes)
CREATE projects/src/app/demo/demo.component.html (19 bytes)
CREATE projects/src/app/demo/demo.component.spec.ts (612 bytes)
CREATE projects/src/app/demo/demo.component.ts (267 bytes)
UPDATE projects/src/app/app.module.ts (1723 bytes)
```

在 Angular 项目中，我们可以通过 Angular schematics 来很方便的实现这一目的；而针对 React 或者 Vue 项目，社区也有不少实现方案，比如 [generate-react-cli](https://github.com/arminbro/generate-react-cli)。

如果不借助社区或者官方方案，要实现第二类场景所需的工具，也可以自己开发一个 npm 包并暴露相应 bin 脚本，然后通过 npx 执行来达到目的，关于 npx 的介绍可以参考我之前写过的一篇博文[《记录一下 npx 的使用场景》](https://hijiangtao.github.io/2021/07/24/npx/)。

## 版本发布：发版与 CHANGELOG 自动化

每当我们需要上线一个新需求时，为了更好的记录变动，我们一般需要发个版本，并同时记录一些 CHANGELOG，如果能把这部分工作完全自动化，毋庸置疑可以提升我们的项目规范和发版效率。这里以 standard-version 举例。我们引入 standard-version 对自动打 tag 以及 CHANGELOG 生成进行规范，具体来说，是期望通过 standard-version 达到如下目的：

- 根据指定规则自动升级项目不同级别（major、minor、patch）的版本并打 tag
- 对比历史 commit 提交自动生成不同版本间的可阅读、分类的 CHANGELOG 日志

通过配置，我们还可以重命名上文提到的 commit 信息中的 type 字段在 CHANGELOG 中的标题展示，如下为一个示例配置：

```tsx
module.exports = {
    "types": [
        { "type": "feat", "section": "Features" },
        { "type": "fix", "section": "Bug Fixes" },
        { "type": "test", "section": "Tests" },
        { "type": "doc", "section": "Document" },
        { "type": "build", "section": "Build System" },
        { "type": "ci", "hidden": true }
    ]
}
```

如下为自动生成的 CHANGELOG 示例：

```markdown
# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.11.0](https://git.woa.com/test/project/compare/v1.10.1...v1.11.0) (2022-06-28)

### Features

- 测试 feature 提交 @hijiangtao (merge request !65) ([a091125](https://git.woa.com/test/project/commit/xxx))

### [1.10.1](https://git.woa.com/test/project/compare/v1.10.0...v1.10.1) (2022-06-24)

### Bug Fixes

- 修改 XXX，并新增 YYY (merge request !63) ([e3a01ce](https://git.woa.com/test/project/commit/yyy))
```

在使用 standard-version 的时候，默认的配置可以满足绝大部分场景了，但更细粒度的控制仍需要我们修改命令或者配置。比如，当我们在 package.json 中指定了仓库 url 后，我们便可以在 commit 信息中通过 @ 符号指定对应用户、通过 # 引用对应 issue/PR，这些在生成 CHANGELOG 时都会被转成对应包含链接地址的超链接，如下列上一些我在开发中的版本自动生成所涉及的应用场景及注意事项：

```tsx
// 首次执行（不变更版本）
standard-version -a -- --first-release 

// 但是如果项目版本不符合规范，还是需要手动发布，因为需要保证项目从 v1.0.0 开始
// https://github.com/conventional-changelog/standard-version/issues/131
standard-version -a -- --release-as 1.0.0

// 在 package.json 中确保项目正确配置 repository 对象
repository.url

// 带通知具体 user 的 commit-msg 
git commit -m "fix: bug produced by @timojiang" 

// 带 issue 的 commit-msg
git commit -m "fix: implement functionality discussed in issue #2"
```

## 总结

本文从项目初始化选用脚手架开始、样式隔离、lint 规则与 git hook 再到模版工具和自动化版本日志，介绍了本人在开发过程中的一些实践和思考，旨在指出一个项目从代码初始化到交付上线过程中可能涉及到的不同流程中，存在的不同提交效率和自动化流程的工作，囿于文章篇幅，没有针对所有涉及到的流程和工具进行详细的 API 介绍，但你仍可以针对其中提到的各类关键词在互联网上进行搜索和查看。

本文在撰写时也尽量针对不同流程换用了普适的一些描述，以保证所提供的方案在替换了具体工具库后仍是长期可用的，防止文章内容受工具的时效性影响。

**全文来看，主要有这么几点实践总结：**

1. **在脚手架的选择上，你可以使用 create-react-app 或者 umi 等社区方案，但如果想要更灵活的脚手架，当你使用 CRA 的时候，可以一并考虑 craco；**
2. **CSS Modules 的作用无需多说，但同样需要注意 TypeScript 检查以及你在命名 CSS 变量写法上的兼容；**
3. **ESLINT 现在已经是大部分项目的标配了，如果你的项目涉及多人协作，可以配置一些额外的 plugin 协助保持风格一致、减少代码合并冲突。当然，在统一代码风格上，还可以通过 husky 定制 git 钩子与具体需要执行的任务，比如：**
   1. **commit-msg**
   2. **pre-commit**
4. **其中通过 lint-staged 在 pre-commit 时机定制各类文件格式化的操作（主要用 eslint 和 prettier 保证执行），通过 commitlint 保证 commit msg 信息符合规范。**
5. **本地开发代理环境在很多团队是必须的，你可以选用一个中间件来增强你的 dev server。**
6. **我们同样可以考虑通过代码复用来提升我们的开发效率，这里的场景主要可以分为两类：code snippets 以及组件级别的文件修改。**
7. **每当项目上线，规范来说，都需要发版及记录日志变更，我们可以引入 standard-version 对自动打 tag 以及 CHANGELOG 生成进行规范。**
