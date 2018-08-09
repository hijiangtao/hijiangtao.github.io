---
title: 谈谈 App Shell 与 Skeleton Screen 实现
layout: post
thread: 201
date: 2018-08-09
author: Joe Jiang
categories: Documents
tags: [前端, Web, JavaScript, PWA, CSS]
excerpt: 作为前端开发老生常谈的话题之一，提升用户体验的口号一直不绝于耳。但怎样的体验改进才算是有提升，用户一方是否认可你的改进与优化，这些都是可以展开详细讨论的话题。
---

作为前端开发老生常谈的话题之一，提升用户体验的口号一直不绝于耳。但怎样的体验改进才算是有提升，用户一方是否认可你的改进与优化，这些都是可以展开详细讨论的话题。作为开发者，我们最容易想到的提升方法就是精简代码、合并文件，以减少用户访问网站时请求的资源大小与数量。

想必大家都看过这张图，一个很经典用于描述人眼存在视觉误差的例子——图中各条水平的线是否相互平行？

![image.png](/assets/in-post/2018-08-09-Talk-about-App-Shell-and-Skeleton-Screen-1.png )

我相信如果你是第一次看到这张图且手上没有尺子，当你知道结果时一定会怀疑自己的眼睛。同样的偏差也存在于 Web 应用中。**你是否想过如果页面实际加载时间变长，用户可能还会更满意？某种程度上说，App Shell 就能帮你达到这样的目的。**看看飞猪首页 filmstrip，你应该知道今天我想聊的话题了。

![image.png](/assets/in-post/2018-08-09-Talk-about-App-Shell-and-Skeleton-Screen-2.png )

作为 PWA 一揽子解决方案的一部分，App Shell 的初衷是为了改善用户首次访问页面时的体验、减少二次访问时因为资源重复加载的等待，说白了即减少 Web 应用的白屏等待、提高 Web 应用可用性反馈的速度。这周正好做了一些为现有多页面项目添加 App Shell 的工作，期间尝试了不同的解决方案，感觉可以拿来聊一聊。

## 一、App Shell 速览

Google 对 App Shell 的定义是——支持用户界面所需的最小的 HTML、CSS 和 JavaScript 集合。由于 PWA 推荐将 Web 应用基础框架（这里特指 Web 应用外壳）与数据分开，因此如果我们对基础框架进行离线缓存，可确保在用户重复访问时实现应用“骨架”的即时加载与应用“更新”的网络请求最小化。一张图来解释 App Shell 即为如此：

![image.png](/assets/in-post/2017-06-03-My-First-Progressive-Web-App-Coding-Notes.png )

## 二、先备知识 Skeleton Screen

有人叫他 Skeleton Screen，也有人叫他骨架屏，其解决的核心问题即通过锁定加载时的 loading 效果（动画）以提升用户体验。本文中之后会统一用 Skeleton Screen 称呼。

Skeleton Screen 原理是在页面数据尚未加载前先给用户展示出页面的大致结构，到请求数据返回后再渲染页面，将要显示的数据内容补充替换。其并在一定程度上限制了用户的操作。想象一下，在弱网环境下，网络请求可能很耗时，利用一些视觉元素预先渲染出页面结构布局，让用户可以预先了解到页面的内容结构，同时避免了长时间白屏的体验，这就是 Skeleton Screen 的优势所在。

![image.png](/assets/in-post/2018-08-09-Talk-about-App-Shell-and-Skeleton-Screen-3.png )

从实现的角度来看，要做到上图的效果，我们需要对现有页面做两点操作：

1. 创建与页面加载完毕后显示内容相似的 HTML 结构 
2. 在需要显示的内容元素上增加背景色（以及 loading 动画）

## 三、实现手段分析与对比

### 3.0 Loading 动画规定

为了实现 Skeleton Screen 页面的加载动画效果，接下来各类实现方法在动画上都沿用背景 animation 与空位用色块 absolute 定位的方法。

```css
@keyframes placeHolderShimmer {
  0% {
    background-position: -800px 0
  }
  100% {
    background-position: 800px 0
  }
}

.animated-background {
  animation-duration: 1s;
  animation-fill-mode: forwards;
  animation-iteration-count: infinite;
  animation-name: placeHolderShimmer;
  animation-timing-function: linear;
  background-color: #f6f7f8;
  background: linear-gradient(to right, #eeeeee 8%, #aaaaaa 18%, #eeeeee 33%);
  background-size: 800px 104px;
  height: 70px;
  position: relative;
}
``` 

### 3.1 简单 HTML 占位

最简单的方法莫过于将页面结构手写入 HTML，待实际数据请求获得时再对此 HTML 做替换。DOM 结构如下：

```html
<div class="main-item">
  <div class="static-background">
    <div class="background-masker btn-divide-left"></div>
  </div>
</div>
```

为了达到分隔左右内容栏的目的，我们还需要用绝对定位的方式给出如下样式表（容器给定白色背景色，其余分隔均有绝对定位加白色背景色进行处理）：

```css
.main-item {
  background-color: #fff;
}

.background-masker {
  background-color: #fff;
  position: absolute;
}

.btn-divide-left {
  top: 0;
  left: 25%;
  height: 100%;
  width: 5%;
}

.static-background {
  background-color: #f6f7f8;
  background-size: 800px 104px;
  height: 70px;
  position: relative;
  margin-bottom: 20px;
}
```

效果图如下所示：

![image.png](/assets/in-post/2018-08-09-Talk-about-App-Shell-and-Skeleton-Screen-4.png )

### 3.2 简单 HTML 占位 + 动画

要用动画我们只需要将上面的代码中 static-background 换成 animated-background 即可，DOM 结构如下：

```html
<div class="main-item">
  <div class="animated-background">
    <div class="background-masker btn-divide-left"></div>
  </div>
</div>
```

效果图见下（黑色渐变块会左右移动）：

![image.png](/assets/in-post/2018-08-09-Talk-about-App-Shell-and-Skeleton-Screen-5.png )

### 3.3 共用 HTML 结构但区分展示样式

以上简单实现的方法优点在于不用考虑现有页面结构的兼容性，但缺点也是显而易见的——需要同时维护 Skeleton DOM 和数据回来后的实际 DOM 两套结构。和之前的做法一样，设想如果每次真实组件有迭代，那么我们都需要手动去同步每一个变化到 Skeleton Screen 结构上的话，那实在是太繁琐了。当然，沿用上面的思路我们可以做一个显而易见的改进——共用 HTML 结构但采用不同样式。

最直接的做法就是在网络请求回来之后会填充数据的标签上都加上 loading class，但样式中不用再涉及 DOM 的宽高设置，例如：

```css
.static-background {
  background-color: #f6f7f8;
}
```

在网络请求回来之后，通过 API 方法 [`document.getElementsByClassName('static-background')`](https://developer.mozilla.org/en/docs/Web/API/Document/getElementsByClassName) 找到所有符合条件的元素然后将他们的对应 class 去除即可，这里可以用上 [`classList`](https://developer.mozilla.org/en/docs/Web/API/Element/classList) API.

### 3.4 利用 CSS :empty 伪类辅助实现

当然，当你页面中需要处理的元素很多时，共用 HTML 但区分样式的方法也是很耗费资源的。如果你擅长 CSS 就会想到可以利用伪类来实现这一操作。

伪类的实现原理是使用 CSS `:empty` 伪类定义 Skeleton Screen 骨架，当元素内容为空时，加载伪类定义样式；而元素内容存在时，则加载实际样式。

以下给一个案例，通过自定义 `backgroun-image` 来实现带层次的预加载样式，添加了一个圆形与几个矩形形状，其中通过 [radial-gradient](https://developer.mozilla.org/en-US/docs/Web/CSS/radial-gradient) 属性实现圆角效果，以下为 DOM 结构：

```html
<div class="css-dom"></div>
```

以下为 CSS 样式：

```css
.css-dom:empty {
  width: 280px;
  height: 220px;
  border-radius: 6px;
  box-shadow: 0 10px 45px rgba(0, 0, 0, .2);
  background-repeat: no-repeat;
  
  background-image:
    radial-gradient(circle 16px, lightgray 99%, transparent 0),
    linear-gradient(lightgray, lightgray),
    linear-gradient(lightgray, lightgray),
    linear-gradient(lightgray, lightgray),
    linear-gradient(lightgray, lightgray),
    linear-gradient(#fff, #fff); 
  
  background-size:
    32px 32px,
    200px 32px,
    180px 32px,
    230px 16px,
    100% 40px,
    280px 100%;
  
  background-position:
    24px 30px,
    66px 30px,
    24px 90px,
    24px 142px,
    0 180px,
    0 0;
}
```

以下为实际效果：

![image.png](/assets/in-post/2018-08-09-Talk-about-App-Shell-and-Skeleton-Screen-6.png )

### 3.5 预渲染/服务端渲染

当然，上一个方法的缺点依旧显而易见。虽然不需要手动处理内容加载后的样式变化，但是对于伪类样式的定义依旧比较繁琐。因为你需要设置不同背景图片的大小、颜色与位置。

预渲染也好，服务端渲染也罢，本质都是选取现有业务代码进行 Skeleton Screen 的构建。如果使用 React 的同学可以使用 `renderToString` 方法对渲染输出的 HTML 进行控制，保证首次输出即可具有初步的 HTML 结构。为了达到 Skeleton Screen 效果，原来这样写的代码：

```javascript
class Example extends React.Component {
  render() {
    // ......
    return (
      <div>
        {dataA ? <CarInfo /> : null}
        {!dataB ? <Address /> :null}
        {dataC ? <BusDetailBooks /> : null}
      </div>
    )
  }
}
```

改改风格就成这样了（其中，你可以通过 ifInit 来控制判断网络请求是否已经返回）：

```javascript
class Example extends React.Component {
  render() {
    // ......
    const { ifInit } = this.state;
    return (
      <div>
        <CarInfo dataA={dataA} className={ifInit? 'animated-background':''} />
        <Address dataB={dataB} className={ifInit? 'animated-background':''} />
        <BusDetailBooks dataC={dataC} className={ifInit? 'animated-background':''} />
      </div>
    )
  }
}
```

预渲染与服务端渲染区别在于预渲染发生在构建时期，而服务端渲染发生在服务器响应请求处理过程中。但考虑到类似 Vue，React 等框架对服务端渲染的支持，你也可以将服务端渲染挪挪位置。不用真正运行于服务器时再做处理，而是在构建时用它把组件的空状态预先渲染成字符串并注入到 HTML 模板中。

在我看来，这算是可以给用户很好感知又在代码层面很干净的处理方式了。

## 四、PWA 改造

由于 Skeleton Screen 涉及 HTML 与 CSS 的内容，因此我们可以将 PWA 中 App Shell 用 Skeleton Screen 实现，然后将相应 HTML 文件写入 Service Worker 待缓存文件列表，这样用户再次访问该站点时，将会获得“秒开”且有明显视觉反馈的体验。

多说一句，虽然 Google 将 App Shell 定义为 HTML/CSS/JavaScript 集合，但考虑到资源的加载耗时，建议在 App Shell 实现上可以裁去 JavaScript 部分，并将 CSS 内容以 inline css 形式写入 HTML。个人观点，供参考。

## 五、后记

Skeleton Screen 已经是一个非常成熟的技术方案，国外诸如 Facebook、Google 等等，国内诸如豆瓣、饿了么、微博等等都在移动端站点广泛采用 Skeleton Screen，且有不少专用于实现 Skeleton Screen 的框架，实现方案虽然不尽相同但目的近乎一致，都是为了提升用户体验。进一步说，技术社区还有很多别的实现方案或策略例如 svg 占位等等，本文总结的实现方案肯定不是最全的，但其实我想表达的观点在于，作为程序员的洁癖，但凡我们遇到问题时，都应该在实现的基础上按照层层递进的思路去思考，自己的代码是否有优化的空间，扩展性又如何。

但实际使用何种方式来改造你的页面，这完全取决于你的需求，没有最好的解决方案，但针对你的场景一定有一个最合适的。

<p data-height="265" data-theme-id="0" data-slug-hash="VBEvMW" data-default-tab="css,result" data-user="hijiangtao" data-pen-title="Skeleton Screen Demo" class="codepen">See the Pen <a href="https://codepen.io/hijiangtao/pen/VBEvMW/">Skeleton Screen Demo</a> by Joe (<a href="https://codepen.io/hijiangtao">@hijiangtao</a>) on <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

文中所有涉及的代码可以查看 [Codepen](https://codepen.io/hijiangtao/pen/VBEvMW).
