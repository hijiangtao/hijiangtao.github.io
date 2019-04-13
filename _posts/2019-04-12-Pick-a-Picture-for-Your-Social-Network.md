---
title: 社交网络配图安全指南
layout: post
thread: 217
date: 2019-04-12
author: Joe Jiang
categories: Document
tags: [2019, 配图, 社交网络, JavaScript]
excerpt: 这两天「视觉中国」上了热搜，图片的版权问题成为了公众焦点。暂不就该新闻做进一步的讨论，我想以自己长期发水文的经验来聊聊，如何正确的在社交网络发图时规避版权问题风险。
header:
  image: ../assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-Teaser.png
  caption: "@hijiangtao"
---

这两天「视觉中国」上了热搜，图片的版权问题成为了公众焦点。暂不就该新闻做进一步的讨论，我想以自己长期发水文的经验来聊聊，如何正确的在社交网络发图时规避版权问题风险。

作为一名经常写博文的码农，翻翻自己[博客](https://hijiangtao.github.io/)，断断续续也在互联网上用文字记录下了过去六七年的时光，而每当抒发情感之际，配图是必不可少的一个增强点，但如果选择不当要么会出现随便来段 JavaScript 混淆代码混配任意编程语言的笑话：

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-1.png )

要么会出现侵犯他人作品版权的危险：

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-2.png )

有的时候也想过用自己拍摄的图片好了，但并不是所有人都能拍张好看并且合适的图片作为博客 teaser 的，比如手残的我前两天还被吐槽「拍的照片看上去不错，但全图实际找不到一个焦点」，推荐两个我在写博文时经常用到的安全配图方法。

这两个方法都有 JavaScript 实现，所以感兴趣的话你可以直接看看他们实现的源码咯。

## 1. Geometric Primitive 

这是一个利用原始几何图像匹配堆叠的原理，以重绘一张图片的方法。

你首先需要选择一张图片作为程序输入，然后算法会试图计算并找到最小化目标图像和绘制图像之间像素误差的最佳几何形状。算法每一次计算只添加一个形状，之后重复这个过程。循环次数可以通过输入指定。

拿我的头像来看看效果吧，以下是我头像原图，高清无码：

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-3.png )

指定124次循环迭代，并设置填充几何体为三角形后，效果如下：

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-4.png )

该方法已经有开源实现，JavaScript 版实现 GitHub 地址见 <https://github.com/ondras/primitive.js>

## 2. Emojis

这个方法的原理在于通过不断堆叠色彩上最合适的 emoji，以达到创作一个与原图最相近的 emoji 镶嵌图片作品。

当然如何摆放 emoji 的位置以及 emoji 颜色的选择都是一个需要考虑的问题，感兴趣的话可以直接看代码实现。

用这个方法处理了一版我的头像，效果如下：

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-5.jpg )

该方法的 JavaScript 版实现 GitHub 地址见 <https://github.com/ericandrewlewis/emoji-mosaic>

虽然原始图片的版权不在你手上，但重新创作过的图片应该就不涉及侵权问题，你可以放心使用了。

附上几张自己的创作作品，其中有两张是用的自己拍的照片啦。

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-6.png )

![](/assets/in-post/2018-07-01-Goodbye-UCAS-1.jpeg )

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-7.png )

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-8.jpeg )

![](/assets/in-post/2019-04-12-Pick-a-Picture-for-Your-Social-Network-9.png )