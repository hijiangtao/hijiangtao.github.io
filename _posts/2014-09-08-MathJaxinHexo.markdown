---
title: Hexo上使用MathJax来实现数学公式的表达
thread: 149
date: 2014-09-08 19:00:00
categories: Tutorial
tags: [MathJax]
layout: post
excerpt: Feel free to use MathJax in Hexo
---

原生的Hexo是不支持数学公式的显示的，但听说过Latex所以在网上搜教程来着，大部分搜到的渲染公式的方法都分为两个步骤：

1. 在theme的header中插入对MathJax CDN script的引用，并配置inline math；
2. 在文章中用inline math插入公式。
3. 但其中似乎存在两个缺点：
4. 需要人肉进行的工作太多；
5. 遇到特殊符号需要人肉escape，否则会被markdown parser吃掉。

于是引用了CATX开发的一款插件来实现这个功能。

##安装与初始化

```
$ npm install hexo-math --save
```

在blog文件夹中执行：

```
$ hexo math install
```

在_config.yml中添加：

```
plugins: 
- hexo-math
```

部署完之后，相关的ejs等文件就会自动生成在你的theme相应的文件夹里了。

##使用

简单的公式：

```
Simple inline $a = b + c$.
```

效果： 

Simple inline $$a = b + c$$.

复杂一点的独立公式：

```
$$\frac{\partial u}{\partial t}
= h^2 \left( \frac{\partial^2 u}{\partial x^2} +
\frac{\partial^2 u}{\partial y^2} +
\frac{\partial^2 u}{\partial z^2}\right)$$
```

效果： 

$$\frac{\partial u}{\partial t}= h^2 \left( \frac{\partial^2 u}{\partial x^2} + \frac{\partial^2 u}{\partial y^2} + \frac{\partial^2 u}{\partial z^2}\right)$$

```
$\cos 2\theta = \cos^2 \theta - \sin^2 \theta =  2 \cos^2 \theta - 1$
```

效果：

$$\cos 2\theta = \cos^2 \theta - \sin^2 \theta =  2 \cos^2 \theta - 1$$

最后来个牛逼的吧，薛定谔方程，大学物理考试貌似还复习过这个公式，虽然现在已经记不清是什么意思来着了：

```
$$ i\hbar\frac{\partial \psi}{\partial t}
= \frac{-\hbar^2}{2m} \left(
\frac{\partial^2}{\partial x^2}
+ \frac{\partial^2}{\partial y^2}
+ \frac{\partial^2}{\partial z^2}
\right) \psi + V \psi.$$
```

$$ i\hbar\frac{\partial \psi}{\partial t}= \frac{-\hbar^2}{2m}\left(\frac{\partial^2}{\partial x^2}+ \frac{\partial^2}{\partial y^2}+ \frac{\partial^2}{\partial z^2}\right) \psi + V \psi.$$

##注意

* 对了，在书写的过程中碰到了几个头疼的问题在这里记录一下，防止以后犯错：

* Markdown会将一些标记给编译掉，所以在打{时不能知只打`\{`，需要再加一个斜线来编译，即`\\{`。因为`\{`在markdown编译的时候成了`{`，然后mathjax再编译就……一定记着编译过程有两次：第一次markdown，第二次mathjax。

* 编写带有下标的公式时要在下划线前加上\，比如`x_i`应该写成x\_i。

* 数学公式属于符号后面应该有个空格：`x_i\in C`。

* 有关MathJax语法的教程网上特别多就不一一列举了，搜了一下可以参考《[MathJax使用LaTeX语法编写数学公式教程](http://iori.sinaapp.com/17.html/comment-page-1?replytocom=2)》。最后，感觉没学过编译原理这门课有点遗憾，感谢师傅Willzhang在我头疼过程中的指点。