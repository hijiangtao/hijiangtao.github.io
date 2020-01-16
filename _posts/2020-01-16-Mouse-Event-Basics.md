---
title: 鼠标事件基础回顾
layout: post
thread: 239
date: 2020-01-16
author: Joe Jiang
categories: Document
tags: [Event, 事件, MDN, 点击, 前端基础]
excerpt: 回到图形化编辑器的开发上，当用户添加文字、图片或者任何其他素材时，选中、取消选中以及成组等复杂操作是必不可少的功能之一，这里要用的便是鼠标事件了。
---

回到图形化编辑器的开发上，当用户添加文字、图片或者任何其他素材时，选中、取消选中以及成组等复杂操作是必不可少的功能之一，这里要用的便是鼠标事件了。简单鼠标事件类型分以下几类：

- `mousedown/mouseup`：事件在指针设备按钮按下时/释放时触发。
- `mouseover/mouseout`： 事件在指针设备进入/离开一个元素时触发。
- `mousemove`：事件在指针设备移动于一个元素上时触发。
- `contextmenu`：事件在尝试打开上下文菜单时触发。通常，这会在按下鼠标右键时发生，当然还有一些特殊键盘键可以触发此事件，因此其并非完全为鼠标事件。

复杂事件类型则有以下几种：

- `click`：如果使用鼠标左键，则在 mousedown 及 mouseup 相继触发后触发该事件。
- `dblclick`：事件在对元素进行双击后触发。

需要注意的是，复杂事件是由简单事件组成的，即一个动作可能会触发多个事件。比如，在按下鼠标按钮时，单击会首先触发 `mousedown`，释放鼠标按钮时触发 `mouseup` 和 `click`。在单个动作触发多个事件时，它们的顺序是固定的。也就是说会遵循 `mousedown` → `mouseup` → `click` 的顺序；而双击的触发顺序则为 `mousedown` → `mouseup` → `click`→ `mousedown` → `mouseup` → `click`→ `dblclick`。

如果按照常用的操作习惯来处理，我们肯定希望我们的编辑器在选中内容的同时支持多选，而这个时候除了鼠标事件外我们还要捕获一些具体按键，比如 Ctrl 键。常见的鼠标事件都会在接口对象上挂有如下几个属性用于辅助判断：

|属性|类型|描述|
|---|---|---|
|ctrlKey|	boolean |	当事件被触发时ctrl按键被按下时为true，否则为false。|
|shiftKey |	boolean |当事件被触发时shift按键被按下时为true，否则为false。|
|altKey |	boolean	|当事件被触发时alt按键被按下时为true，否则为false。|
|metaKey|	boolean	|当事件被触发时meta按键被按下时为true，否则为false。|

当然，一个编辑器在选中时可能还要对具体点击了元素的哪个位置进行计算，从而做不同响应，这个时候接口对象的如下几个属性既可以派上用场：

|属性|类型|描述|
|---|---|---|
|target |	EventTarget	事件对应的 DOM 树顶级顶级元素|
|currentTarget |	EventTarget	挂载监听器的节点|
|screenX |	long	全局屏幕坐标系下鼠标指针的 X 轴坐标值|
|screenY |	long	全局屏幕坐标系下鼠标指针的 Y 轴坐标值|
|clientX |	long	当前（DOM 元素）坐标系下鼠标指针的 X 轴坐标值|
|clientY |	long	当前（DOM 元素）坐标系下鼠标指针的 Y 轴坐标值|

关于 click 事件存在一些细节，咬文嚼字一下：

- 事件需要在按下和释放操作时，指针设备都位于元素内。若按下之后，鼠标移动使得指针离开该元素，那么事件将会在包含两个元素的最近祖先元素（the most specific ancestor element）上触发；
- 与 click 相关的事件都具有 `which` 属性，该属性允许用户获知具体哪个鼠标按钮被按下。我们不会将其用于 `click`和 `contextmenu` 事件，因为前者只发生在左键，而后者只发生在右键。 `which` 有三个枚举值，1 表示左键，2表示中间按钮，3表示右键。

一些基础知识，回顾一下。

参考

- [https://javascript.info/mouse-events-basics](https://javascript.info/mouse-events-basics)
- [https://developer.mozilla.org/en-US/docs/Web/API/Element/mousedown_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/mousedown_event)
- [https://developer.mozilla.org/en-US/docs/Web/API/Element/mouseup_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/mouseup_event)
- [https://developer.mozilla.org/en-US/docs/Web/API/Element/mousemove_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/mousemove_event)
- [https://developer.mozilla.org/en-US/docs/Web/API/Element/click_even](https://developer.mozilla.org/en-US/docs/Web/API/Element/mousemove_event)[t](https://developer.mozilla.org/en-US/docs/Web/API/Element/click_event)
- [https://developer.mozilla.org/en-US/docs/Web/API/Element/dblclick_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/dblclick_event)
- [https://developer.mozilla.org/en-US/docs/Web/API/Element/contextmenu_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/contextmenu_event)