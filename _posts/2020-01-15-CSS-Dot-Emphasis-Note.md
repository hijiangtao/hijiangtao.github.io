---
title: 如何用 CSS 强调标记文本元素
layout: post
thread: 238
date: 2020-01-15
author: Joe Jiang
categories: Document
tags: [CSS, 打点, 强调标记, 字符, 文本]
excerpt: 当我们在 Web 上做文本编辑器时，最常见的一个场景便是和文字样式打交道了。比如像语文课本那样需要在每篇文章要学习的生字上标上一个小黑点，这个时候就该用到 CSS 中 text-emphasis-style 这个属性。
---

当我们在 Web 上做文本编辑器时，最常见的一个场景便是和文字样式打交道了。比如像语文课本那样需要在每篇文章要学习的生字上标上一个小黑点，这个时候就该用到 CSS 中 text-emphasis-style 这个属性。

text-emphasis-style 属性用于定义强调标记所使用的类型，它也可以使用 text-emphasis 简写属性来设置与重置。你可以选中你的 DOM 元素为其加上这个属性，一些常见例子如下：

    /* Initial value */
    text-emphasis-style: none; /* No emphasis marks */
    
    /*  value */
    text-emphasis-style: 'x';
    text-emphasis-style: '点';
    text-emphasis-style: '\25B2';
    text-emphasis-style: '*';
    text-emphasis-style: 'foo'; /* Should NOT use. It may be computed to or rendered as 'f' only */
    
    /* Keywords value */
    text-emphasis-style: filled;
    text-emphasis-style: open;
    text-emphasis-style: filled sesame;
    text-emphasis-style: open sesame;
    
    /* Global values */
    text-emphasis-style: inherit;
    text-emphasis-style: initial;
    text-emphasis-style: unset;

当然，这些强调标记具体显示在元素上方或下方，需要结合 `text-emphasis-positon` 进行指定。其中：

- `none`——无强调标记；
- `filled`——填充纯色的形状。如果既不存在 `filled` 也不存在 `open`，这是默认的值；
- `open`——空心形状；
- `dot`——显示小圆圈作为标记。实心点是 `•`（`U+2022`），空心点是 `◦`（`U+25E6`）；
- `circle`——显示大圆圈作为标记。实心圆是 `●`（`U+25CF`），空心圆是 `○`（`U+25CB`）；这是在没有给出其他形状的情况下在水平方向的writing modes 下的默认形状；
- `double-circle`——显示双圈作为标记。实心的双圈为 `◉`（`U+25C9`），空心的双圈为`◎`（`U+25CE`）；
- `triangle`——显示三角形作为标记。实心三角形是 `▲`（`U+25B2`），空心三角形是 `△`（`U+25B3`）。`sesame`——显示芝麻形状作为标记。实心芝麻是 `﹅`（`U+FE45`），空心芝麻是 `﹆`（`U+FE46`）。这是在没有给出其他形状的情况下垂直方向的writing modes下的默认形状；
- `<string>`——显示给定的字符串作为标记，比如 `\25CF` 表示 circle 对应的圆点样式，但 `<string>` 中不应指定一个以上的字符，因为 UA 可能会截断或忽略由多个字符组成的字符串；

其实，如果只是给文本下方打点而不注重对齐，你大可使用很多其它方式比如 border 样式，但如果要准备对应到每个元素，并显示成适当大小，那 text-emphasis-style 默认给的选择可能并不是那么尽如人意，MDN 中只显式标记了 dot 和 circle 两个值用于显示实心点，但其绘制圆点的显示效果要么太大、要么太小。「∙」「•」「・」「●」，几个小小的点可能就会把你难倒。

经过调研和尝试，一些可用于画实心点的 Unicode 字符由大到小的效果排布如下：

- U+26AB - medium circle black
- U+25CF - black circle, 对应到默认 circle 样式（大点）
- U+2981 - z notation spot
- U+2022 - bullet, 对应到默认 dot 样式（小点）
- U+22C5 - dot operator
- U+00B7 - middle dot
- U+0387 - greek ano teleia

我的 CSS 依旧是一如既往的差，以上内容供参考。

注：中国大陆的规范字符是 Unicode 00B7，即 middle dot，和常用的「间隔号」为同一个字符。

相关文档链接如下：

- Interpunct Wikipedia [https://en.wikipedia.org/wiki/Interpunct](https://en.wikipedia.org/wiki/Interpunct)
- text-emphasis-style MDN [https://developer.mozilla.org/en-US/docs/Web/CSS/text-emphasis-style](https://developer.mozilla.org/en-US/docs/Web/CSS/text-emphasis-style)
- text-emphasis MDN [https://developer.mozilla.org/en-US/docs/Web/CSS/text-emphasis](https://developer.mozilla.org/en-US/docs/Web/CSS/text-emphasis)
- text-emphasis-position MDN [https://developer.mozilla.org/en-US/docs/Web/CSS/text-emphasis-position](https://developer.mozilla.org/en-US/docs/Web/CSS/text-emphasis-position)
- How to Add a Dotted Underline Beneath HTML Text? [https://stackoverflow.com/questions/15252597/how-to-add-a-dotted-underline-beneath-html-text](https://stackoverflow.com/questions/15252597/how-to-add-a-dotted-underline-beneath-html-text)