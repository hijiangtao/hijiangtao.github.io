---
title: \[译\]超大型 JavaScript 应用设计的哲学
layout: post
thread: 195
date: 2018-04-20
author: Joe Jiang
categories: Documents
tags: [Application, Design, JavaScript, Software, 软件开发, 软件设计]
excerpt: 一个超大型 JavaScript 应用该如何设计，其中蕴含哪些哲学？来看看 Malte 在 JSConf 上是怎么说的吧。
header:
  image: ../assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-1.png
  caption: "From medium.com/@cramforce"
---

*前言：前两天情封大大给我推荐了一篇文章，问我是否有意翻译分享一下。乍一看这个才发表两天的文章就有6000多次鼓掌（现在快一万了），快速扫了全文感觉是篇很棒的演讲，便决定开始干，于是，真正的痛苦便开始了。*

*Medium 预估原文阅读需耗时21分钟，这足以表明原文长度了，但这还不是最糟的，由于文章根据 Malte 演讲视频整理而来，速记稿中有很多字句的取舍以及遗漏，使得翻译过程发现语段间缺失了不少上下文（但并不妨碍这是一篇好文）。自己答应大大做的事，喊着泪也要完成。于是打开 Youtube 开始了一遍遍的视频暂停、播放、回放等的过程，堪比高考做听力的那段痛苦经历啊。由于文中存在诸多口语表述，翻译时也不像技术文档或者教程那么连贯，也是难点之一。*

*好在最终坚持下来完成了，感谢印记中文小伙伴 [QC-L](https://github.com/QC-L) 帮忙校对，感谢情封大大的推荐，感谢 Malte 的演讲。*

本文基于 [Malte Ubl](https://medium.com/@cramforce) 在 JSConf Australia 的演讲速记稿和现场视频整理而来，[你可以在 YouTube 上观看完整演讲](https://www.youtube.com/watch?v=ZZmUwXEiPm4)。由于全文大部分内容转自口述，译稿并不细究字词的严格一致，但尽力保证了原文语义和结构不发生变化。希望本文能让大家有所收获。

Malte 在文中主要讨论了两件事：一是如何构建高度复杂的 web 应用，以确保不论开发人员多少、不论应用逻辑和 UI 多么繁重，用户在交互时首屏加载负担都能维持在较好的水平；二是如何保证应用在整个生命周期的轻量运行，即加载当前不需要的 JS 代码。整体演讲中，Malte 提到了几个概念，分别是懒惰装饰（lazy decoration），异步依赖注入（asynchronous dependency injection）和模块系统的反向依赖关系（reverse dependencies）。

原文 [Designing very large (JavaScript) applications](https://medium.com/@cramforce/designing-very-large-javascript-applications-6e013a3291a3)，译者 [hijiangtao](https://github.com/hijiangtao)，以下开始正文。

![Slide text: Hello, I used to build very large JavaScript applications.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-1.png)
<center><small>嗨，我曾经开发过非常大型的 JavaScript 应用</small></center>

嗨，我曾经开发过非常大型的 JavaScript 应用。但我现在已不再做了，因此是时候回顾一下我的收获，并将它们分享出来了。昨天聚会上我正拿着一杯啤酒，被人问到：“嗨 Malte，究竟是什么经历让你能够讨论这个话题的？”尽管谈论自己让我觉得有些奇怪，但我想问题的答案实际上就是这篇演讲的主题。我在 Google 开发了一个 JavaScript 框架，它被用在诸如 Photos，Sites，Plus，Drive，Play 以及搜索等站点上。你可能也使用过不少了，其中一些（网站）规模还挺大。

![Slide text: I thought React was good.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-2.png)
<center><small>我认为 React 很好</small></center>

我所说的这个 JavaScript 框架并不是开源的，原因在于它与 React 同时出现，而我的观点是“世界上真的需要另一个 JS 框架供大家选择么？”。Google 已经有一些相似的框架了——Angular 和 Polymer，再来一个只会让人感到困惑，所以还是将它留给我们自己好了。但即使没有开源，它身上依旧有诸多可鉴之处，一路走来我们收获巨大，我认为将它分享出来是非常有价值的。

![Picture of lots of people.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-3.png)
<center><small>人山人海</small></center>

那么，让我们来谈谈开发超大型应用的团队都有哪些共同的特点吧。当然，都会有很多的开发者。可能几十个也可能更多，而他们都是有情感以及需要处理人际关系的人类，这一点是你必须考虑的事。

![Picture of very old building.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-4.png)
<center><small>古老建筑</small></center>

即便你的团队不大，你也负责该项目有一段时间了，但由于你可能不是第一个维护它的人，因此你无法了解所有背景。或者你不太明白其中的一些细节，或者你的团队中可能有人根本不了解这个应用。当我们负责开发超大型应用时，这些都是我们必须考虑的事情。

![Tweet saying: A team of senior engineers without junior engineers is a team of engineers.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-5.png)
<center><small>一个没有初级工程师的高级工程师团队是一个工程师团队</small></center>

我还想说另外一点，即从职业生涯的角度来给出一些我的思考。我想我们当中很多人都会立志成为一名高级工程师。或许还在奋斗的路上，但我们的目标是达到那样的水平。在我看来，高级一词意味着我有能力解决别人抛来的几乎所有问题，我掌握开发工具的用法，我了解所在领域的动态。而另一个很重要的部分在于我能够让初级工程师最终成为高级工程师。

![Slide text: Junior -> Senior -> ?](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-6.png)
<center><small>初级 -> 高级 -> ?</small></center>

当我们达到高级工程师的水平，接下可能我们就开始迷茫了：“下一阶段会是什么？”。一些人可能认为，成为管理人员吧，但我认为这不应该是所有人心中唯一的答案，因为并不是每个人都应该成为一名经理，对吧？我们当中有不少非常优秀的工程师，为什么不在余生中继续坚持下去呢？

![Slide text: “I know how I would solve the problem”](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-7.png)
<center><small>“我知道我会如何解决这个问题”</small></center>

我想提出一种突破高级水平这一层的方法。作为一名高级工程师，我会这样形容我自己——“我知道自己该如何解决这个问题”。换句话说，既然我知道如何解决这个问题，那么我也可以教别人如何去做。

![Slide text: “I know how others would solve the problem”](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-8.png)
<center><small>“我知道别人会如何解决这个问题”</small></center>

我的方法论是，下一层次应该是我可以对自己说：“我知道*别人*会如何解决这个问题”。

![Slide text: “I can anticipate how API choices and abstractions impact the way other people would solve the problem.”](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-9.png)
<center><small>“我可以预见 API 的选择和抽象方式是如何影响他人解决这个问题的”</small></center>

让我们更具体一点。达到这个水平，你应该做到：“我可以预见，我决定和选择的 API 以及在项目中引入的抽象，是如何影响到其他人解决一个问题的。”我认为这是一个很厉害的概念，它使我能够推断我正在做的决定是如何影响到一个应用（发展）的。

![Slide text: An application of empathy.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-10.png)
<center><small>有共鸣的应用</small></center>

你在考虑与其他软件工程师合作，考虑你所做的事情以及你给他们提供的 API，会如何影响到他们开发软件的过程。我会把通过这种方式开发出来的产品称为有共鸣（empathy）的应用。

![Slide text: Empathy on easy mode.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-11.png)
<center><small>简单层面的共鸣</small></center>

幸运的是这是简单层面的共鸣。要达到共鸣通常来说很难，而且一直以来都是如此。但令人欣慰的是，毕竟和你产生共鸣的那些人也是软件工程师。尽管你们可能千差万别，但至少有共同之处，那就是都在开发软件应用。日积月累，随着你的经验增长，你可以很好的掌握这类共鸣方法。

![Slide text: Programming model](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-12.png)
<center><small>编程模型</small></center>

众多话题中我想挑一个重要的谈谈，那就是编程模型——接下来我将会多次提到它。它代表“给定一套 API、库、框架或者工具集，告诉人们如何利用它们开发软件。”接下来的部分将实际讨论 API 上的细微变化将会如何影响到编程模型。

*译者注：有关编程模型的具体定义可以参见 [Wiki](https://en.wikipedia.org/wiki/Programming_model)*

![Slide text: Programming model impact examples: React, Preact, Redux, Date picker from npm, npm](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-13.png)
<center><small>编程模型影响示例：React，Preact，Redux，来自 npm 的 Date picker 包，npm</small></center>

我想举几个影响编程模型（同后文提到的开发应用一词）的例子：假设你有一个 Angular 项目，然后你说“我准备把它移植到 React 上”，这显然会改变我们开发应用的方式，对吧？接下来你可能会说“啊，为了实现虚拟 DOM 操作就要浪费 60KB，让我们换到 Preact 吧”，这是一个兼容 React API 的库，它不会改变我们开发应用的方式。也许不久又你会觉得“这真的很复杂，我应该用一些东西来管理我的应用状态，我准备引入 Redux”，这将会改变我们开发应用的方式。然后你收到一个需求：“我们需要一个日期选择器”，你在 npm 上查到了近500个结果，你选了一个。选择哪个很重要么？它绝对不会改变你开发软件的方式。但由于 npm 触手可及，其中包含有庞大的模块库，这绝对已经改变了你开发应用的方式。当然，这些只是可能影响到人们开发应用的几个例子。

![Slide text: Code splitting](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-14.png)
<center><small>代码分离</small></center>

现在我想谈谈所有大型 JavaScript 应用在分发给用户时都有的一个共同点：它们的体积最终会变得很大，以至于你不想一次将它们分发完毕。为此，我们都曾引入过代码分离。代码分离意味着你为应用程序定义了一组 bundle。你会说“有些用户只使用应用的这一部分，有些用户使用另一部分”，因此你只需要在用户真正用到对应部分之前，将涉及到的代码 bundle 加载下来就好，我们都可以做到这一点。像许多事情一样，它是由闭包编译器实现的，至少在 JavaScript 世界中是这样的。但我认为最流行的方式应该是使用 webpack 进行代码分离。如果你在使用 RollupJS，也是一个超级棒的库，应该知道他们最近也增加了对代码分离的支持。显然，在代码分离上我们都应该做些什么，但将它引入你的应用之前确实需要稍作考虑，因为它确实会影响到编程模型。

![Slide text: Sync -> Async](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-15.png)
<center><small>Sync -> Async</small></center>

有些内容过去是同步的，现在变成了异步。值得注意的一点是，在没有代码分离时，你的应用非常简洁，它启动之后运行稳定，你不用等待返回结果便可以推断它的状态；而有了代码分离，你可能就会说“哦，我需要这个 bundle”，你需要去请求网络，你必须考虑这些可能发生的事情，因此你的应用变得更加复杂。

![Slide text: Human](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-16.png)
<center><small>人类</small></center>

此外，人类参与了这部分工作，因为代码分离需要你给 bundle 定义分类并确定它们的加载时机，因此团队中工程师需要考虑这些逻辑，即何时何地加载这些 bundle。当每次有人参与时，编程模型都会明显地受到影响，因为人们需要考虑许多诸如此类的事情。

![Slide text: Route based code splitting](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-17.png)
<center><small>基于路径的代码分离</small></center>

有一种非常成熟的代码分离方法可以解决这个问题，将我们从一团混乱中解救出来，这就是所谓的基于路径的代码分离。如果你还没实践过代码分离，那它可能是你第一次做代码分离时会遵循的方式。不同路径是你应用的 URL 结构基础。例如，你可能在 `/product/` 上部署产品页面，在其他地方放置了类别页面。如此一来，你只需为每个路径设计一个 bundle，你的路由便可以理解代码分离了。每当用户转到一个路径，路由就会加载相关的 bundle，之后在该路径中，你便可以忽略现有的代码分离。此时你又回到了开始的编程模型，即一个 bundle 涵盖几乎一切内容，这是一个非常好的实现方法，绝对是很好的第一步。

但本演讲的标题是设计**非常**大型的 JavaScript 应用，由于每个路径上的内容都变得巨大，以致为每个路径单独打一个 bundle 不再可行。实际上我有个很好的例子来解释什么是一个足够大的应用。

![Google Search query screenshot for “public speaking 101”](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-18.png)
<center><small>基于 “public speaking 101” 关键词的 Google 查询截图</small></center>

如图，我正在寻找如何成为这场演讲的公共演讲者，我也得到了这些包含蓝色链接还不错的结果列表。你可以设想这个页面能很好地适用于单路径 bundle 的方法。

![Google Search query screenshot for “weath”](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-19.png)
<center><small>基于 “weath” 关键词的 Google 查询截图</small></center>

因为加州的冬天非常难熬，后来我开始担忧天气，通过搜索，于是突然出现一个完全不同的模块。这个看似简单的路径比我们想象的要更加复杂。

![Google Search query screenshot for “20 usd to aud”](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-20.png)
<center><small>基于 “20 usd to aud” 关键词的 Google 查询截图</small></center>

之后，我被邀请参加这次会议，我查看了美元和澳元之间的汇率，这里有一个复杂的货币转换器。很显然，这些专用模块大约有1000多个，将它们放在一个 bundle 中是不可行的。bundle 增到几兆大小，用户会变得非常不高兴的。

![Slide text: Lazy load at component level?](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-21.png)
<center><small>在组件层面上延迟加载？</small></center>

所以，我们不能只使用基于路径的代码分离，我们必须想出其他方式来做到这一点。基于路径的代码拆分很不错，因为你在最粗的粒度上拆分应用，而所有进一步深入的内容都可以忽略它。我想，既然我喜欢简单的事情，那么做超级细粒度的分离而不是超级粗粒度的分离会如何呢。我们来看看如果懒惰加载网站中的每一个组件，会发生什么。当你只考虑带宽时，从实现效率的角度来看，这似乎非常好。但从延时等其他角度来考虑，这是非常糟糕的，但这种做法肯定是值得考虑的一点。

![Slide text: React component statically depend on their children.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-22.png)
<center><small>React 组件静态依赖于它们的子元素</small></center>

让我们想象一下，例如，你使用 React 开发这个应用。在 React 中，组件静态依赖于它们的子元素。因为你懒加载子元素的缘故，这意味着如果你停止这么做，将会改变你的编程模型，事情将变糟。

![ES6 import example.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-23.png)
<center><small>ES6 import 示例</small></center>

假设你有一个货币转换器组件，你想把它放在你的搜索页面上，你可以 import 它，对吧？在 ES6 模块中这是它的正常用法。

![Loadable component example.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-24.png)
<center><small>可加载组件示例</small></center>

如果你想延迟加载它，你会这样写：使用动态 import——一个新奇的延迟加载 ES6 模块的方法，将 import 包装在一个可加载组件中。当然，可以有成千上万种方法做到这点，我并不是 React 专家，但所有这些方式都会改变你开发应用的方式。

![Slide text: Static -> Dynanic](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-25.png)
<center><small>静态 -> 动态</small></center>

事情不再那么美好——一些静态的东西现在变成了动态的，这是改变编程模型的又一个影响因素。

![Slide text: Who decides what to lazy load when?](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-26.png)
<center><small>“谁决定什么时候延迟加载？”</small></center>

你必须思考“谁决定什么时候延迟加载”，因为这将会影响到你的应用延时。

![Slide text: Static or dynamic?](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-27.png)
<center><small>静态还是动态？</small></center>

人类这时再次出现，他们必须思考“有静态 import 和动态 import，我什么时候应该使用哪一个？”。弄错是非常糟糕的，因为混淆两种方式使用 import 时，可能会将一段代码打包到一个不属于它的 bundle 中。当你的应用需要很多工程师且长时间工作时，这些错误就可能会出现。

![Slide text: Split logic and rendering](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-28.png)
<center><small>分割逻辑与渲染</small></center>

现在我将谈谈 Google 是怎么做的，以及获得良好编程模型的一种方式，与此同时它具有良好的性能。我们所做的是根据渲染顺序以及应用逻辑来分割我们的组件，就像当你按下货币转换器上的按钮时发生的情况一样。

![Slide text: Only load logic if it was rendered.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-29.png)
<center><small>仅在渲染完成时加载逻辑</small></center>

所以，现在我们有两件分开的事情要做，且我们只在内容渲染完毕后才加载组件的应用程序逻辑。事实证明这是一个非常简单的模型，因为你可以在服务器端渲染一个页面，且不管渲染内容如何，然后触发加载相关联的应用 bundle。这使得人们所扮演的角色从应用中脱离了出来，因为加载是通过渲染自动触发的。

![Slide text: Currency converter on search result page.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-30.png)
<center><small>搜索结果页面上的货币转换器</small></center>

这个模型看起来不错，但它确实有一些折衷。你可能知道诸如 React 或 Vue.js 等框架是如何实现服务器端渲染的，他们所做的是一个称为 hydration 的过程。hydration 作用的方式是在服务器端渲染一些东西，然后在客户端再次渲染它，这意味着你必须加载一些代码来渲染已经存在于页面上的内容，这在加载代码以及执行上都是非常低效浪费的。这浪费了一堆带宽和 CPU 资源——但它对开发者非常友好，因为你在客户端可以忽略服务器端渲染出来的东西。我们在 Google 不采用这种方法。所以，当你设计这个超大应用时，你需要思考：我是采用更复杂的高效方法，还是利用 hydration 过程？后者虽然效率较低，但不乏是一个好的编程模型。

![Slide text: 2017 Happy New Year](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-31.png)
<center><small>2017年新年快乐</small></center>

下一个话题是我在计算机科学领域中最喜欢的问题了 - 虽然我起了个不好的名字，但它并不特指什么，这就是 *“2017年假日特别问题”*。你肯定遇到过：这段代码是谁写的，现在貌似已不再需要了，但它仍然存在于你的代码库中？这种事情经常发生，且常出现在 CSS 代码中。你有个巨大的 CSS 文件，其中有个选择器，谁知道这是否还与你应用中的某些内容相关联呢？所以，你只能把它留在那里。我认为 CSS 社区处于变革的最前沿，因为他们意识到这是一个问题，并创建了诸如 CSS-in-JS 之类的解决方案。换个角度，若你有一个单独的文件组件，例如 2017HolidaySpecialComponent，你可以说由于“不再是2017年了”，所以你便毫无顾忌的删除整个组件。这使得删除代码的操作变得非常容易。我认为这是一个非常大的想法，且不仅仅只适用于 CSS 领域。

![Slide text: Avoid central configuration at all cost](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-32.png)
<center><small>不惜一切代价避免中心化配置</small></center>

我想举几个例子来阐明一个观点，即你该不惜一切代价避免对应用进行中心化配置，因为中心化配置（比如项目中只有一个 CSS 文件）会使得删除代码变得非常困难。

![Slide text: routes.js](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-33.png)
<center><small>routes.js</small></center>

我之前在应用开发中就谈论过路径这个事。许多应用都会有一个类似 “routes.js” 的文件，其中包含应用涉及的所有路径，然后这些路径会将自己映射到某些根组件上。这是一个中心化配置的例子，是大型应用中不需要的。当它存在时，有些工程师可能会抱怨：“我是否需要那个根组件？因为修改它的文件权限可能归其他团队所有或者类似的原因，我不知道自己是否能够修改它，算了，也许我明天再做吧”。于是这些文件就变得多余了。

![Slide text: webpack.config.js](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-34.png)
<center><small>webpack.config.js</small></center>

另一个反例是 webpack.config.js 文件，你利用它为整个应用进行配置。这可能会奏效一段时间，但最终会让你难以知道其他团队在应用中每个地方都做过什么样的改动。再强调一次，我们需要一个模式来展现如何将我们构建过程的配置去中心化。

![Slide text: package.json](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-35.png)
<center><small>package.json</small></center>

npm 所使用的 package.json 就是一个很好的例子。每个软件包的这个文件中都会写到“我有这些依赖关系，这就是你如何运行我（的方式），这就是你如何构建我（的方式）”。显然，若是为 npm 生态只准备一个巨大的配置文件是不可行的，成千上万的文件只要稍作改动，肯定会带来很多的 git 合并冲突。npm 生态确实非常大，比我们的应用大不少，但我认为我们的许多应用也已经足够大到需要考虑同样的问题，且必须采用相同的模式来解决它们。我没有万能的解决方案，但我认为 CSS-in-JS 所带来的思路可以借鉴到我们应用的一些方面上。

![Slide text: Dependency trees](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-36.png)
<center><small>依赖关系树</small></center>

更抽象一点，我会这样描述这个解决思路：我们负责处理抽象中应用的设计方式、组织方式，即*负责构建应用的依赖关系树*。当我说“依赖”时，它是非常抽象的。它可能是模块依赖关系、数据依赖关系、服务依赖关系以及其他很多不同的类型。

![Slide text: Example dependency tree with router and 3 root components.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-37.png)
<center><small>带有路由器和3个根组件的示例依赖关系树</small></center>

显然，我们都有超复杂的应用，但在这里我会用一个非常简单的例子。它只有4个组件，一个路由器负责处理应用如何从一个路径跳到另一个路径，以及 A，B，C 等几个跟组件。

![Slide text: The central import problem.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-38.png)
<center><small>中心化 import 带来的问题</small></center>

如上文所述，这里存在一个中心化 import 带来的问题。

![Slide text: Example dependency tree with router and 3 root components. Router imports root components.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-39.png)
<center><small>带有路由器和3个根组件的示例依赖关系树。由路由引入根组件。</small></center>

因为现在路由必须 import 所有的根组件，所以当你想删除其中一个（组件）时，你必须前往路由（所在的文件），删除所有 import 关系以及相应路径，于是你遇到了“2017年假日特别问题”。

![Slide text: Import -> Enhance](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-40.png)
<center><small>Import -> Enhance</small></center>

在 Google，我们已经为此提出了一个解决方案，在此向你们介绍一下，我想之前我们从来没有公开谈过这件事。我们创造了一个新概念，它被称为 enhance。你可以用它来替代 import。

![Slide text: Import -> Enhance](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-41.png)
<center><small>Import -> Enhance</small></center>

实际上，它与 import 正好相反。它是一个逆向依赖。如果你 enhance 一个模块，你会让这个模块对你产生依赖。

![Slide text: Example dependency tree with router and 3 root components. Root components enhance router.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-42.png)
<center><small>带有路由器和3个根组件的示例依赖关系树。根组件增强了路由。</small></center>

看看依赖关系图发生了什么，组件保持不变，但箭头指向相反的方向。因此，根组件会对路由使用 enhance 方式来声明自己，以取代让路由 import 根组件的方式。这意味着当我删除根组件时我仅需要删除相应文件即可。因为它不再 enhance 路由，当我们删除组件时，这是唯一需要做的操作。

![Slide text: Who decides when to use enhance?](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-43.png)
<center><small>谁决定何时使用 enhance？</small></center>

这真的很好，因为人们不再需要考虑诸如“我该用 import 还是使用 enhance 呢？我在什么情况下该使用哪一种？”的问题了。

![Image: Danger. Hazardous chemicals.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-44.png)
<center><small>危险化学品</small></center>

但值得注意的是这其实是个特别糟糕的情况，由于我们增强了模块的能力，即让系统中所有其他内容都可以依赖于某个模块是非常危险的（如果出错的话），这将会造成严重的后果。因此在 Google 我们认为这是一个好主意，但我们把它定为非法操作，没人会使用它，除非你用它来生成代码。增强方式（enhance）非常适合用在实际生成代码中，它解决了生成代码一些固有的问题。有时在生成代码后，你需要从中 import 一些你根本看不到的文件，并猜测他们的名字。如果基于这些生成的文件使用 enhance，那么就不存在这些问题了。你永远不需要了解这些文件细节，enhance 操作就像魔术一般增强了中心化注册（central registry），且它们能够很好的运行。

![Slide text: Single file component pointing to its parts that enhance a router.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-45.png)
<center><small>指向增强路由组件们的单个文件组件</small></center>

我们来看一个具体的例子。我们这里有单个文件组件。我们用一个代码生成器来运行它，并从中提取这个小小的路径定义文件。只见那个路径文件说“嘿，路由，我在这里，请 enhance 我”。显然，你可以将这种模式用于各类事情，比如 GraphQL，由于你的路由知道你的数据依赖关系，于是你可以使用这种模式，这是非常强大的。

![Slide text: The base bundle](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-46.png)
<center><small>基础 bundle</small></center>

除了以上内容我们还应该知道些别的。下面是计算机科学中我第二喜欢的问题，我称之为“基础 bundle 垃圾”。基础 bundle 是指应用 bundle 图中那些总是会被加载的 bundle，它与用户和应用的交互方式无关。所以，这一点尤其重要，因为如果它很大，那么接下来展开的其他内容都会很大。如果它很小，那么依赖它的 bundle 至少有可能很小。一个小插曲：曾经，我加入 Google Plus JavaScript 基础设施团队时，发现他们的基础 bundle 包含800KB的 JavaScript 文件。所以，一个警告是：如果你的应用想比 Google Plus 更成功，那么在你的基础 bundle 不要超过800KB。不幸的是，这种糟糕的状态很普遍。

![Slide text: Base bundle pointing to 3 different dependencies.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-47.png)
<center><small>指向3个不同依赖项的基本 bundle</small></center>

举个例子。你的基础 bundle 需要依赖于具体路由，因为当你从 A 跳到 B 时，你需要确保路由对于 B 能正确处理。但是你并不想在基础 bundle 中放入任何形式的 UI 代码，因为对于用户来说，不同的进入方式会产生不同的用户界面。举个例子，日期选择器就绝对不应该放在你的基础 bundle 中，结账流程（指图中 CHECKOUT FLOW 组件）也不应该。所以该怎么做呢？不幸的是 import 非常脆弱。你可能无意中引入了很酷的 *util* 包，只因为它包含生成随机数的函数。然后有人说：“我需要一个用于自动驾驶汽车的工具”，你便立刻将用于自驾车的机器学习算法引入到你的基础 bundle 中。类似的事情很容易发生，因为引入（其他包）是具有传递性的，这些东西随着时间的推移而累积在一起。

![Slide text: Forbidden dependency tests.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-48.png)
<center><small>禁止依赖测试</small></center>

对此，我们的解决方案是*禁止依赖测试*。禁止依赖测试是一种断言，例如判断你的基础 bundle 是否不依赖任何 UI。

![Slide text: Assert that base bundle does not depend on React.Component](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-49.png)
<center><small>断言基础 bundle 不依赖于 React.Component</small></center>

我们来看一个具体的例子。在 React 中，每个组件都需要继承自 React.Component。因此，如果你的目标是基本 bundle 中没有 UI 代码，只需添加一个测试，断言 React.Component 不是你基本 bundle 的传递依赖。

![Forbidden dependencies crossed out.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-50.png)
<center><small>删除禁止依赖</small></center>

让我们回到之前的例子，当有人想添加日期选择器时，你会得到一个测试未通过的信息。而这个问题通常来说都很好解决，因为这个人可能并不是真的想要添加这个依赖项 - 它只是通过其他一些传递引入的。与此相比，若是这种依赖关系已经存在2年而你甚至没写过一个测试，在这些情况下，通过重构代码来摆脱依赖关系通常来说都是非常难的。

![Slide text: The most natural path](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-51.png)
<center><small>最自然的方式</small></center>

理想情况下，你会能找到最自然的方式避免基础 bundle 垃圾。

![Slide text: Most straightforward way must be the right way.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-52.png)
<center><small>最直接的方式一定是正确的方式</small></center>

你肯定想过，要是能做到无论你团队中的工程师做什么，都能保证最直接的方式就是正确的方式就好了 - 这样他们就不会走错路，自然而然就能在正确的开发路上走下去。

![Slide text: Otherwise add a test that ensure the right way,](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-53.png)
<center><small>否则，添加一个测试确保是正确的方式</small></center>

但很多人并不认为自己有能力做到这一点，所以，请记得添加一个测试。**你一定有能力向你的应用添加测试，以确保基础架构满足主要的约束条件。**测试不仅仅是为了验证你的数学函数是否正常工作，它们也用于验证基础架构和应用主要功能的正确性。

![Slide text: Avoid human judgement outside of application domain.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-54.png)
<center><small>避免在应用领域之外进行人为判断</small></center>

尽可能避免在应用领域之外进行人为判断。在开发应用时，我们必须了解业务，但对于代码分离来说并非团队中每位工程师都能理解它是如何工作的，而且他们也不需要这么做。试着将这些内容以一种较好的方式引入到你的应用中，而不是让每个人都理解并精通它们。

![Slide text: Make it easy to delete code.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-55.png)
<center><small>让删除代码变得轻松</small></center>

让删除代码变得轻松些吧。我的演讲取名为“构建超大型 JavaScript 应用”，我想我可以给出的最好建议是：不要让你的应用变得非常庞大。而实现这一点最好的办法是及时开始删除工作。

![Slide text: No abstraction is better than the wrong abstraction.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-56.png)
<center><small>没有抽象比错误的抽象更好</small></center>

我想再多说一点，那就是人们有时会说，根本没有抽象比错误的抽象要好。这其实意味着错误抽象的代价非常高，所以要小心。但我认为有时这句话被误解了，这并不意味着你应该不要抽象，这只是说你在设计抽象时必须非常小心。

> *我们必须善于找到正确的抽象。*

![Slide text: Empathy and experience -> Right abstractions.](/assets/in-post/2018-04-20-Designing-Very-Large-JavaScript-Applications-57.png)
<center><small>共鸣和经验 -> 正确的抽象</small></center>

正如我在演讲开始时所说的：和团队中的工程师们一起思考吧，想想他们会如何使用你的 API​​ 与抽象。我做过不少错误的尝试，现在可能仍在继续，但我觉得应该是在向好的方向发展了。请记住，在为你的应用选择正确的抽象方式前，想办法与团队协作产生共鸣，并运用已有的经验来辅助自己。

谢谢！

（完）

*题图来自 <https://medium.com/@cramforce>*