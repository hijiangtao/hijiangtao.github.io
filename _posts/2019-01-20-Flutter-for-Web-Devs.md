---
title: 为前端工程师准备的 Flutter 入门指南
layout: post
thread: 211
date: 2019-01-20
author: Joe Jiang
categories: Document
tags: [2019, Flutter, 前端, 移动开发, 指南]
excerpt: 学习如何把 Web 的开发经验应用到 Flutter 应用的开发中。
header:
  image: ../assets/in-post/2019-01-20-Flutter-for-Web-Devs-Teaser.png
  caption: "@flutter.io"

---

如果你恰好是一名前端工程师，且对 Flutter 抱有兴趣，那么真的是太好了，这篇文章完全就是为你准备的。写惯了 HTML、CSS 与 JavaScript,要不要来是试试 Dart？如果你不熟悉 Flutter 但仍对其感兴趣，可以先看看「[让我们在2019年重新认识 Flutter](https://hijiangtao.github.io/2019/01/17/Say-Hello-to-Flutter-at-Beginning-of-2019/)」一文了解些 Flutter 基础。

在接下来的章节中，我们仔细来对比下平时用 HTML/CSS 代码所实现的效果，如果替换为等价的 Flutter/Dart 代码，会是什么样子。

本文结构如下：

1. 基础布局
2. 位置与大小
3. 图形/形状
4. 文本

**注：本文只摘录 Web 到 Flutter 中一些特性的转换介绍，详细及完整的使用方法与语法请查阅 Flutter/Dart 官网 <https://flutter.io>, <https://flutter.cn> 与 <https://www.dartlang.org>.**

本文示例中默认已包含如下假设：

* HTML 文件均会以 `<!DOCTYPE html>` 开头，且为了与 Flutter 模型保持一致，所有 HTML 元素的 CSS 盒模型被设置为 [`border-box`](https://css-tricks.com/box-sizing/)。
  ```css
  {
    box-sizing: border-box;
  }
  ```
* 在 Flutter 中，为了保持语法简洁，示例中所用的 "Lorem ipsum" 文本的默认样式由如下 `bold24Roboto` 变量定义：
  ```dart
  TextStyle bold24Roboto = TextStyle(
    color: Colors.white,
    fontSize: 24.0,
    fontWeight: FontWeight.w900,
  );
  ```

*Flutter UI 采用声明式编程，欲了解其与传统命令式风格的不同，请查阅[声明式 UI 介绍](https://flutter.io/docs/get-started/flutter-for/declarative)。*

## 一、基础布局

先来看看最常见的一些 UI 布局操作。

### 1.1 文本样式与对齐

我们在 CSS 中设置的字体样式、大小以及其他文本属性，都是 Flutter 中一个 [Text](https://docs.flutter.io/flutter/widgets/Text-class.html) widget 子元素 [TextStyle](https://docs.flutter.io/flutter/painting/TextStyle-class.html) 中单独的属性。

不论是 HTML 还是 Flutter，子元素或者 widget 都默认锚定在左上方。

* Web

```html
<div class="greybox">
    Lorem ipsum
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Georgia;
}
```

* Dart

```dart
var container = Container( // grey box
  child: Text(
    "Lorem ipsum",
    style: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w900,
      fontFamily: "Georgia",
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 1.2 背景颜色

在 Flutter 中，你可以通过 [Container](https://docs.flutter.io/flutter/widgets/Container-class.html) 的 `decoration` 属性来设置背景颜色。

CSS 示例中我们使用等价的十六进制颜色表示。

* Web

```html
<div class="greybox">
  Lorem ipsum
</div>

.greybox {
  background-color: #e0e0e0;  /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
}
```

* Dart

```dart
var container = Container( // grey box
    child: Text(
      "Lorem ipsum",
      style: bold24Roboto,
    ),
    width: 320.0,
    height: 240.0,
    color: Colors.grey[300],
  );
```

### 1.3 居中元素

在 Flutter 中，[Center](https://docs.flutter.io/flutter/widgets/Center-class.html) widget 可以将它的子元素水平和垂直居中。

要用 CSS 实现相似的效果，其父元素则需要使用一个 flex 或者 table-cell 显示布局。本节示例使用的是 flex 布局。

* Web

```html
<div class="greybox">
  Lorem ipsum
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center; 
}
```

* Dart

```dart
var container = Container( // grey box
  child:  Center(
    child:  Text(
      "Lorem ipsum",
      style: bold24Roboto,
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 1.4 设置容器宽度

[Container](https://docs.flutter.io/flutter/widgets/Container-class.html)
widget 的宽度可以用它的 `width` 属性指定，但需要注意的是，和 CSS 中的 max-width 属性用于指定容器可调整的最大宽度值不同的是，这里指定的是一个固定宽度。要在 Flutter 中模拟 max-width 的效果，可以使用 Container 的 `constraints` 属性。新建一个带有 `minWidth` 和 `maxWidth` 属性的 [BoxConstraints](https://docs.flutter.io/flutter/rendering/BoxConstraints-class.html) widget。 
而对嵌套的 Container 来说，如果其父元素宽度小于子元素宽度，则子元素实际尺寸以父元素大小为准。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px; 
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  width: 100%;
  max-width: 240px; 
}
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red box
      child: Text(
        "Lorem ipsum",
        style: bold24Roboto,
      ),
      decoration: BoxDecoration(
        color: Colors.red[400],
      ),
      padding: EdgeInsets.all(16.0),
      width: 240.0, //max-width is 240.0
    ),
  ),
  width: 320.0, 
  height: 240.0,
  color: Colors.grey[300],
);
```

## 二、位置与大小

以下示例将展示如何对 widget 的位置、大小以及背景进行更复杂的操作。

### 2.1 绝对定位

默认情况下， widget 是相对于其父元素定位的。要通过 x-y 坐标指定一个 widget 的绝对位置，请把它嵌套在一个 [Positioned](https://docs.flutter.io/flutter/widgets/Positioned-class.html)
widget 中，而该 widget 则需被嵌套在一个 [Stack](https://docs.flutter.io/flutter/widgets/Stack-class.html) widget 中。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  position: relative; 
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  position: absolute;
  top: 24px;
  left: 24px; 
}
```

* Dart

```dart
var container = Container( // grey box
  child: Stack(
    children: [
      Positioned( // red box
        child:  Container(
          child: Text(
            "Lorem ipsum",
            style: bold24Roboto,
          ),
          decoration: BoxDecoration(
            color: Colors.red[400],
          ),
          padding: EdgeInsets.all(16.0),
        ),
        left: 24.0,
        top: 24.0,
      ),
    ],
  ), 
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 2.2 旋转

要旋转一个 widget，请将它嵌套在 [Transform](https://docs.flutter.io/flutter/widgets/Transform-class.html)
widget 中。其中，使用 Transform widget 的 `alignment` 和 `origin` 属性分别来指定转换原点的具体位置信息。

对于简单的 2D 旋转，widget 是依据弧度在 Z 轴上旋转的。(角度 × π / 180)

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  transform: rotate(15deg); 
}
```

* Dart

```dart
var container = Container( // gray box
  child: Center(
    child:  Transform(
      child:  Container( // red box
        child: Text(
          "Lorem ipsum",
          style: bold24Roboto,
          textAlign: TextAlign.center,
        ),
        decoration: BoxDecoration(
          color: Colors.red[400],
        ),
        padding: EdgeInsets.all(16.0),
      ),
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(15 * 3.1415927 / 180),
    ), 
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 2.3 缩放元素

将元素嵌套在一个 [Transform](https://docs.flutter.io/flutter/widgets/Transform-class.html)
widget 中，可以实现缩放。使用 Transform widget 的 `alignment` 和 `origin` 属性分别来指定缩放原点的具体位置信息。

对于沿 x 轴的简单缩放操作，新建一个 [Matrix4](https://docs.flutter.io/flutter/vector_math_64/Matrix4-class.html) 标识对象并用它的 scale() 方法来指定缩放因系数。

当你缩放一个父 widget 时，它的子 widget 也会相应被缩放。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  transform: scale(1.5); 
}
```

* Dart

```dart
var container = Container( // gray box
  child: Center(
    child:  Transform(
      child:  Container( // red box
        child: Text(
          "Lorem ipsum",
          style: bold24Roboto,
          textAlign: TextAlign.center,
        ),
        decoration: BoxDecoration(
          color: Colors.red[400],
        ),
        padding: EdgeInsets.all(16.0),
      ),
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(1.5),
     ), 
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 2.4 线性变换

将元素嵌套在一个 [Container](https://docs.flutter.io/flutter/widgets/Container-class.html) widget 中，可以将线性变换应用在 widget 的背景上。之后，再用 Container widget 的 `decoration` 属性生成一个 [BoxDecoration](https://docs.flutter.io/flutter/painting/BoxDecoration-class.html) 对象，然后使用 BoxDecoration 的 `gradient` 属性来变换背景填充内容。

变换“角度”基于 Alignment (x, y) 取值来定：

* 如果开始和结束的 x 值相同，变换将是垂直的（0° | 180°）。
* 如果开始和结束的 y 值相同，变换将是水平的（90° | 270°）。

这里，只展示垂直变换的代码差异：

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  padding: 16px;
  color: #ffffff;
  background: linear-gradient(180deg, #ef5350, rgba(0, 0, 0, 0) 80%); 
}
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red box
      child: Text(
        "Lorem ipsum",
        style: bold24Roboto,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.0, -1.0),
          end: const Alignment(0.0, 0.6),
          colors: <Color>[
            const Color(0xffef5350),
            const Color(0x00ef5350)
          ],
        ),
      ), 
      padding: EdgeInsets.all(16.0),
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

## 三、图形/形状

以下示例将展示如何新建和自定义图形。

### 3.1 圆角

在矩形上实现圆角，可以用 [BoxDecoration](https://docs.flutter.io/flutter/painting/BoxDecoration-class.html) 对象的 `borderRadius` 属性。新建一个 [BorderRadius](https://docs.flutter.io/flutter/painting/BorderRadius-class.html) 对象来指定每个圆角的半径大小。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* gray 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  border-radius: 8px; 
}
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red circle
      child: Text(
        "Lorem ipsum",
        style: bold24Roboto,
      ),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.all(
          const Radius.circular(8.0),
        ), 
      ),
      padding: EdgeInsets.all(16.0),
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 3.2 阴影

在 CSS 中你可以通过 box-shadow 属性快速指定阴影偏移与模糊范围。比如如下两个盒阴影的属性设置：

*  `xOffset: 0px, yOffset: 2px, blur: 4px, color: black @80% alpha`
*  `xOffset: 0px, yOffset: 06x, blur: 20px, color: black @50% alpha`

在 Flutter 中，每个属性与其取值都是单独指定的。请使用 BoxDecoration 的 `boxShadow` 属性来生成一系列 [BoxShadow](https://docs.flutter.io/flutter/painting/BoxShadow-class.html)
widget。你可以定义一个或多个 BoxShadow widget，这些 widget 共同用于设置阴影深度、颜色等等。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.8),
              0 6px 20px rgba(0, 0, 0, 0.5);
}
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red box
      child: Text(
        "Lorem ipsum",
        style: bold24Roboto,
      ),
      decoration: BoxDecoration(
        color: Colors.red[400],
        boxShadow: <BoxShadow>[
          BoxShadow (
            color: const Color(0xcc000000),
            offset: Offset(0.0, 2.0),
            blurRadius: 4.0,
          ),
          BoxShadow (
            color: const Color(0x80000000),
            offset: Offset(0.0, 6.0),
            blurRadius: 20.0,
          ),
        ], 
      ),
      padding: EdgeInsets.all(16.0),
    ),
  ),
  width: 320.0,
  height: 240.0,
  decoration: BoxDecoration(
    color: Colors.grey[300],
  ),
  margin: EdgeInsets.only(bottom: 16.0),
);
```

### 3.3 圆与椭圆

尽管 CSS 中有[基础图形](https://developer.mozilla.org/en-US/docs/Web/CSS/basic-shape)，CSS 中一个生成圆的变通方案是：将矩形的四边 border-radius 均设成50%。

虽然 [BoxDecoration](https://docs.flutter.io/flutter/painting/BoxDecoration-class.html) 的 `borderRadius` 属性支持这样设置，Flutter 为 [BoxShape enum](https://docs.flutter.io/flutter/painting/BoxShape-class.html) 提供一个 `shape` 属性也用于实现同样的目的。

* Web

```html
<div class="greybox">
  <div class="redcircle">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* gray 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redcircle {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  text-align: center;
  width: 160px;
  height: 160px;
  border-radius: 50%; 
}
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red circle
      child: Text(
        "Lorem ipsum",
        style: bold24Roboto,
        textAlign: TextAlign.center, 
      ),
      decoration: BoxDecoration(
        color: Colors.red[400],
        shape: BoxShape.circle, 
      ),
      padding: EdgeInsets.all(16.0),
      width: 160.0,
      height: 160.0, 
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

## 四、文本

以下示例展示了如何设置字体和其他文本属性，除此外还包括一些特性比如如何变换文本字符、自定义间距以及生成摘录。

### 4.1 文字间距

在 CSS 中你可以通过分别给 letter-spacing 和 word-spacing 属性的长度赋值来指定每个字母以及每个单词间的空白距离。距离的单位可以是 px, pt, cm, em 等等。

在 Flutter 中，你可以在 Text widget 子元素 [TextStyle](https://docs.flutter.io/flutter/painting/TextStyle-class.html) 的 `letterSpacing` 与 `wordSpacing` 属性中将间距设置为逻辑像素（允许负值）。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  letter-spacing: 4px; 
}
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red box
      child: Text(
        "Lorem ipsum",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 4.0, 
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.red[400],
      ),
      padding: EdgeInsets.all(16.0),
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 4.2 内联样式

一个 [Text](https://docs.flutter.io/flutter/widgets/Text-class.html) widget 可以展示同一类样式的文本。为了展现具有多种样式的文本，需要改用 [RichText](https://docs.flutter.io/flutter/widgets/RichText-class.html) widget。它的 `text` 属性可以指定一个或多个可以单独设置样式的 [TextSpan](https://docs.flutter.io/flutter/painting/TextSpan-class.html) widget。

在下例中，"Lorem" 位于 TextSpan widget 中，具有默认（继承自其父元素）文本样式，"ipsum" 位于具有自定义样式、单独的一个 TextSpan 中。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem <em>ipsum</em> 
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto; 
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
}
 .redbox em {
  font: 300 48px Roboto;
  font-style: italic;
} 
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red box
      child:  RichText(
        text: TextSpan(
          style: bold24Roboto,
          children: <TextSpan>[
            TextSpan(text: "Lorem "),
            TextSpan(
              text: "ipsum",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                fontSize: 48.0,
              ),
            ),
          ],
        ),
      ), 
      decoration: BoxDecoration(
        backgroundColor: Colors.red[400],
      ),
      padding: EdgeInsets.all(16.0),
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

### 4.3 文本摘要

在 Web 中，我们常用省略号处理溢出的文本内容，且在 HTML/CSS 中，摘要不能超过一行。 如果要在多行之后进行截断，那么就需要 JavaScript 的帮助了。

在 Flutter 中，使用 [Text](https://docs.flutter.io/flutter/widgets/Text-class.html) widget 的 `maxLines` 属性来指定包含在摘要中的行数，以及 `overflow` 属性来处理溢出文本。

* Web

```html
<div class="greybox">
  <div class="redbox">
    Lorem ipsum dolor sit amet, consec etur
  </div>
</div>

.greybox {
  background-color: #e0e0e0; /* grey 300 */
  width: 320px;
  height: 240px;
  font: 900 24px Roboto;
  display: flex;
  align-items: center;
  justify-content: center;
}
.redbox {
  background-color: #ef5350; /* red 400 */
  padding: 16px;
  color: #ffffff;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap; 
}
```

* Dart

```dart
var container = Container( // grey box
  child: Center(
    child: Container( // red box
      child: Text(
        "Lorem ipsum dolor sit amet, consec etur",
        style: bold24Roboto,
        overflow: TextOverflow.ellipsis,
        maxLines: 1, 
      ),
      decoration: BoxDecoration(
        backgroundColor: Colors.red[400],
      ),
      padding: EdgeInsets.all(16.0),
    ),
  ),
  width: 320.0,
  height: 240.0,
  color: Colors.grey[300],
);
```

*Teaser 截图自 flutter.io 官网。*
