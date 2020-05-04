---
title: HTML Drag/Drop API 介绍
layout: post
thread: 246
date: 2020-05-04
author: Joe Jiang
categories: Document
tags: [Drag, Drop, HTML, 拖拽, JavaScript]
excerpt: 
---

HTML 的拖拽接口有 DragEvent, DataTransfer, DataTransferItem 和DataTransferItemList。本文着重介绍前两者。

## 事件与流程

一个典型的 drag 操作是这样开始的：用户用鼠标选中一个可拖动的（draggable）元素，移动鼠标到一个可放置的（droppable）元素，然后释放鼠标。 在操作期间，会触发一些事件类型，有一些事件类型可能会被多次触发。这个流程可以分解为三部分：

**1. 选中**：在 HTML5 标准中，为了使元素可拖动，把 draggable 属性设置为 true 即可。其中，文本、图片和链接是默认可以拖放的，draggable 属性默认为 true。而在触发时机上，图片和链接按住鼠标左键选中，就可以拖放，文本只有在被选中的情况下才能拖放。如果显示设置文本的 draggable 属性为 true，按住鼠标左键也可以直接拖放。该属性语法为 `<element draggable="true | false | auto" >`

* true: 可以拖动
* false: 禁止拖动
* auto: 跟随浏览器定义是否可以拖动`

**2. 拖动**：每一个可拖动的元素，都会经历三个过程，即「拖动开始-拖动过程中-拖动结束」，相关事件如下：

![](/assets/in-post/2020-05-04-Darg-and-Drop-1.png )

dragenter 和 dragover 事件的默认行为是拒绝接受任何被拖放的元素。因此，必须用 `e.preventDefault()` 阻止浏览器这种默认行为。

**3. 释放**：当元素在目的地区域释放后，会触发目的地对象上的 `drop` 事件，此时也需要取消浏览器的默认行为。

## 拖动数据

除了流程上对应不同事件外，还需要了解 DataTransfer 对象。每一个 DataTransfer 对象代表一个单独的拖动项，每一项有一个 kind 属性，代表数据的 kind（string 或 file），还有一个 type 属性，代表数据项的 type（例如MIME类型）。

**1. 属性**：需要关注的属性包含这几个 dropEffect / effectAllowed / files / types。

`dropEffect` 属性用于获取 / 设置实际的放置效果，它应该始终设置成 effectAllowed  的可能值之一。

* copy: 复制到新的位置
* move: 移动到新的位置
* link: 建立一个源位置到新位置的链接
* none: 禁止放置（禁止任何操作）

`effectAllowed` 用来指定拖动时被允许的效果。

`files` 包含一个在数据传输上所有可用的本地文件列表。如果拖动操作不涉及拖动文件，此属性是一个空列表。

`types` 保存一个被存储数据的类型列表作为第一项，顺序与被添加数据的顺序一致。如果没有添加数据将返回一个空列表。

**2. 方法**：需要关注的属性包含这几个 setData /getData / clearData / setDragImage。

## 示例

下面的例子展示了一个处理程序，从拖动数据中获取事件源元素的 id 然后根据 id 移动源元素到目标元素。

```html
<script>
function dragstart_handler(ev) {
 // Add the target element's id to the data transfer object
 ev.dataTransfer.setData("application/my-app", ev.target.id);
 ev.dataTransfer.dropEffect = "move";
}
function dragover_handler(ev) {
 ev.preventDefault();
 ev.dataTransfer.dropEffect = "move"
}
function drop_handler(ev) {
 ev.preventDefault();
 // Get the id of the target and add the moved element to the target's DOM
 var data = ev.dataTransfer.getData("application/my-app");
 ev.target.appendChild(document.getElementById(data));
}
</script>

<p id="p1" draggable="true" ondragstart="dragstart_handler(event)">This element is draggable.</p>
<div id="target" ondrop="drop_handler(event)" ondragover="dragover_handler(event)">Drop Zone</div>
```
