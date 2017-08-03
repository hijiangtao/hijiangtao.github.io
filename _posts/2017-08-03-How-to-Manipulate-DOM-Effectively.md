---
title: 如何监听页面 DOM 变动并高效响应
layout: post
thread: 179
date: 2017-08-03
author: Joe Jiang
categories: documents
tags: [DOM, JavaScript, Event]
excerpt: 最近在做 chrome 插件开发，既然是插件那就难免不对现有页面做一些控制，比如事件监听、调整布局、对 DOM 元素的增删改查等等。其中有一个需求比较有意思，便整理一下顺便把涉及到的知识点复习一遍。
---

最近在做 chrome 插件开发，既然是插件那就难免不对现有页面做一些控制，比如事件监听、调整布局、对 DOM 元素的增删改查等等。其中有一个需求比较有意思，便整理一下顺便把涉及到的知识点复习一遍。

需求是这样的：在一个包含懒加载资源以及动态 DOM 元素生成的页面中，需要针对页面中存在的元素添加属性显示标签。

### 从 DOM 变动事件监听说起

首先假设大家已经知道 JavaScript 中事件的发生阶段（捕获-命中-冒泡），附上一张图带过这个内容，我们直接进入寻找解决方法的过程。

![](https://www.w3.org/TR/DOM-Level-3-Events/images/eventflow.svg )

*[Graphical representation of an event dispatched in a DOM tree using the DOM event flow](https://www.w3.org/TR/DOM-Level-3-Events/#dom-event-architecture)*

开始的时候我一直在 window 状态改变涉及到的事件中寻找，一圈搜寻下来发现也就 `onload` 事件最接近了，所以我们看看 MDN 对该事件的定义：

> The load event is fired when a resource and its dependent resources have finished loading.

怎么理解资源及其依赖资源已加载完毕呢？简单来说，如果一个页面涉及到图片资源，那么 onload 事件会在页面完全载入（包括图片、css文件等等）后触发。一个简单的监听事件用 JavaScript 应该这样书写（注意不同环境下 load 和 onload 的差异）：

```javascript
<script>
  window.addEventListener("load", function(event) {
    console.log("All resources finished loading!");
  });
  
  // or
  window.onload=function(){
    console.log("All resources finished loading!");
  };
  
  // HTML
  <body onload="SomeJavaScriptCode">
  
  // jQuery
  $( window ).on( "load", handler )
</script>
```

当然，说到 `onload` 事件，有一个 jQuery 中相似的事件一定会被提及—— `ready` 事件。jQuery 中这样定义这个事件：

> Specify a function to execute when the DOM is fully loaded.

需要知道的是 jQuery 定义的 `ready` 事件实质上是为 `DOMContentLoaded` 事件设计的，所以当我们谈论加载时应该区分的事件其实是 `onload`（接口 UIEvent） 以及 `DOMContentLoaded`（接口 Event），MDN 这样描述 `DOMContentLoaded`：

> 当初始HTML文档被完全加载和解析时，DOMContentLoaded 事件被触发，而无需等待样式表、图像和子框架完成加载。另一个不同的事件 load 应该仅用于检测一个完全加载的页面。

所以可以知道，当一个页面加载时应先触发 `DOMContentLoaded` 然后才是 `onload`. 类似的事件及区别包括以下几类：

* **DOMContentLoaded**: 当初始HTML文档被完全加载和解析时，DOMContentLoaded 事件被触发，而无需等待样式表、图像和子框架完成加载；
* **readystatechange**: 一个document 的 Document.readyState 属性描述了文档的加载状态，当这个状态发生了变化，就会触发该事件；
* **load**: 当一个资源及其依赖资源已完成加载时，将触发load事件；
* **beforeunload**: 当浏览器窗口，文档或其资源将要卸载时，会触发beforeunload事件。
* **unload**: 当文档或一个子资源正在被卸载时, 触发 unload事件。

细心点会发现上面在介绍事件时提到了 UIEvent 以及 Event，这是什么呢？这些都是事件——可以被 JavaScript 侦测到的行为。其他的事件接口还包括 KeyboardEvent ／ VRDisplayEvent （是的，没错，这就是你感兴趣且熟知的那个 VR）等等；如果在搜索引擎中稍加搜索，你会发现有些资料里写到事件可以分为以下几类：

* UI事件
* 焦点事件
* 鼠标与滚轮事件
* 键盘与文本事件
* 复合事件
* 变动事件
* HTML5 事件
* 设备事件
* 触摸与手势事件

但这样写实在有些凌乱，其中一些是 DOM3 定义的事件，有一些是单独列出的事件，如果你觉得熟悉那么你会发现这是 JavaScript 高级程序设计里的叙述模式，在我看来，理解这些事件可以按照 DOM3 事件以及其他事件来做区分：其中，DOM3 级事件规定了以下几类事件 - UI 事件, 焦点事件, 鼠标事件, 滚轮事件, 文本事件, 键盘事件, 合成事件, 变动事件, 变动名称事件; 而剩下的例如 HTML5 事件可以单独做了解。而刚开始提到的 Event 作为一个主要接口，是很多事件的实现父类。有关 Web API 接口可以在[这里](https://developer.mozilla.org/zh-CN/docs/Web/API)查到，里面可以看到有很多 Event 字眼。

好吧，事件说了这么多，我们还是没有解决刚开始提出的问题，如果监听页面中动态生成的元素呢？想到动态生成的元素都是需要通过网络请求获取资源的，那么是否可以监听所有 HTTP 请求呢？查看 jQuery 文档可以知道每当一个Ajax请求完成，jQuery 就会触发 ajaxComplete 事件，在这个时间点所有处理函数会使用 .ajaxComplete() 方法注册并执行。但是谁能保证所有 ajax 都从 jQuery 走呢？所以应该在**变动事件**中做出选择，我们来看看 DOM2 定义的如下变动事件：

* **DOMSubtreeModified**: 在DOM结构发生任何变化的时候。这个事件在其他事件触发后都会触发；
* **DOMNodeInserted**: 当一个节点作为子节点被插入到另一个节点中时触发；
* **DOMNodeRemoved**: 在节点从其父节点中移除时触发；
* **DOMNodeInsertedIntoDocument**: 在一个节点被直接插入文档或通过子树间接插入文档之后触发。这个事件在 DOMNodeInserted 之后触发；
* **DOMNodeRemovedFromDocument**: 在一个节点被直接从文档移除或通过子树间接从文档移除之前触发。这个事件在 DOMNodeRemoved 之后触发；
* **DOMAttrModified**: 在特性被修改之后触发；
* **DOMCharacterDataModified**: 在文本节点的值发生变化时触发；

所以，用 DOMSubtreeModified 好像没错。师兄旁边提醒，用 **MutationObserver**, 于是又搜到了一个新大陆。MDN 这样描述 MutationObserver：

> MutationObserver给开发者们提供了一种能在某个范围内的DOM树发生变化时作出适当反应的能力.该API设计用来替换掉在DOM3事件规范中引入的Mutation事件.

DOM3 事件规范中的 Mutation 事件可以被简单看成是 DOM2 事件规范中定义的 Mutation 事件的一个扩展，但是这些都不重要了，因为他们都要被 MutationObserver 替代了。好了，那么来详细介绍一下 MutationObserver 吧。文章《[Mutation Observer API](http://javascript.ruanyifeng.com/dom/mutationobserver.html)》对 MutationObserver 的用法介绍的比较详细，所以我挑几点能直接解决我们需求的说一说。

既然要监听 DOM 的变化，我们来看看 Observer 的作用都有哪些：

> 它等待所有脚本任务完成后，才会运行，即采用异步方式。

> 它把 DOM 变动记录封装成一个数组进行处理，而不是一条条地个别处理 DOM 变动。

> 它既可以观察发生在 DOM 的所有类型变动，也可以观察某一类变动。

MutationObserver 的构造函数比较简单，传入一个回调函数即可（回调函数接受两个参数，第一个是变动数组，第二个是观察器实例）：

```javascript
let observer = new MutationObserver(callback);
```

观察器实例使用 `observe` 方法来监听， `disconnect` 方法停止监听，`takeRecords` 方法来清除变动记录。

```javascript
let article = document.body;

let  options = {
  'childList': true,
  'attributes':true
} ;

observer.observe(article, options);
```

`observe` 方法中第一个参数是所要观察的变动 DOM 元素，第二个参数则接收所要观察的变动类型（子节点变动和属性变动）。变动类型包括以下几种：

* childList：子节点的变动。
* attributes：属性的变动。
* characterData：节点内容或节点文本的变动。
* subtree：所有后代节点的变动。

想要观察哪一种变动类型，就在 option 对象中指定它的值为 true。需要注意的是，如果设置观察 subtree 的变动，必须同时指定  childList、attributes 和 characterData 中的一种或多种。`disconnect` 方法和 `takeRecords` 方法则直接调用即可，无传入参数。

好的，我们已经搞定了 DOM 变动的监听，将代码刷新一下看下效果吧，因为页面由很多动态生成的商品组成，那么我应该在 body 上添加变动监听，所以 options 应该这样设置：

```
var options = {
	'attributes': true,
	'subtree': true
}
```

咦？页面往下拉一小点就触发了 observer 几十次？这样 DOM 哪吃得消啊，查看了页面的变动记录发现每次新进的资源底层都调用了 [Node.insertBefore()](https://developer.mozilla.org/en-US/docs/Web/API/Node/insertBefore) 方法...

### 再聊聊 JavaScript 中的截流／节流函数

现在遇到的一个麻烦是， DOM 变动太频繁了，如果每次变动都监听那真是太耗费资源了。一个简单的解决办法是我就放弃监听了，而采用 [setInterval](https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/setInterval) 方法定时执行更新逻辑。是的，虽然方法原始了一点，但是性能上比 Observer “改进”了不少。

这个时候，又来了师兄的助攻：“用用截流函数”。记起之前看《[JavaScript 语言精粹](https://book.douban.com/subject/3590768/)》的时候看到是用 `setTimeout` 方法自调用来解决 `setInteval` 的频繁执行吃资源的现象，不知道两者是不是有关联。网上一查发现有两个“jie流函数”。需求来自于这里：

> 在前端开发中，页面有时会绑定scroll或resize事件等频繁触发的事件，也就意味着在正常的操作之内，会多次调用绑定的程序，然而有些时候javascript需要处理的事情特别多，频繁出发就会导致性能下降、成页面卡顿甚至是浏览器奔溃。

如果重复利用 setTimeout 和 clearTimeout 方法，我们好像可以解决这个频繁触发的执行。每次事件触发的时候我首先判断一下当前有没有一个 setTimeout 定时器，如果有的话我们先将它清除，然后再新建一个 setTimeout 定时器来延迟我的响应行为。这样听上去还不错，因为我们每次都不立即执行我们的响应，而频繁触发过程我们又能保持响应函数一直存在（且只存在一个），除了会有些延迟响应外，没什么不好的。是的这就是**截流函数（debounce）**，有一篇[博客](http://www.cnblogs.com/ambar/archive/2011/10/08/throttle-and-debounce.html)用这个小故事介绍它：

> 形像的比喻是橡皮球。如果手指按住橡皮球不放，它就一直受力，不能反弹起来，直到松手。debounce 的关注点是空闲的间隔时间。

在我的业务中，在 observer 实例中调用下面写的这个截流函数就可以啦

```javascript
/**
* fn 执行函数
* context 绑定上下文
* timeout 延时数值
**/
let debounce = function(fn, context, timeout) {
	let timer;
    
    // 利用闭包将内容传递出去
	return function() {
		if (timer) {
		    // 清除定时器
			clearTimeout(timer); 
		}
		
		// 设置一个新的定时器
		timer = setTimeout(function(){
			fn.apply(context, arguments)
		}, timeout);
	}
}
```

当然，解决了自己的问题，但还有一个概念没有说到——“节流函数”。同一篇博文里也使用了一个例子来说明它：

> 形像的比喻是水龙头或机枪，你可以控制它的流量或频率。throttle 的关注点是连续的执行间隔时间。

函数节流的原理也挺简单，一样还是定时器。当我触发一个时间时，先setTimout让这个事件延迟一会再执行，如果在这个时间间隔内又触发了事件，那我们就清除原来的定时器，再setTimeout一个新的定时器延迟一会执行。函数节流的出发点，就是让一个函数不要执行得太频繁，减少一些过快的调用来节流。这里引用 [AlloyTeam](http://www.alloyteam.com/2012/11/javascript-throttle/) 的节流代码实现来解释：

```javascript
// 参数同上
var throttle = function(fn, delay, mustRunDelay){
 var timer = null;
 var t_start;
 return function(){
 	var context = this, args = arguments, t_curr = +new Date();
 	
 	// 清除定时器
 	clearTimeout(timer);
 	
 	// 函数初始化判断
 	if(!t_start){
 		t_start = t_curr;
 	}
 	
 	// 超时（指定的时间间隔）判断
 	if(t_curr - t_start >= mustRunDelay){
 		fn.apply(context, args);
 		t_start = t_curr;
 	}
 	else {
 		timer = setTimeout(function(){
 			fn.apply(context, args);
 		}, delay);
 	}
 };
};
```

当然，AlloyTeam 那篇文章将这里所说的截流函数作为节流函数的 V1.0 版本，你也可以这样认为。毕竟，设置了必然触发执行的时间间隔（即 mustRunDelay 函数），可以使得截流函数不会在“疯狂事件”情况下无止境的循环下去。

Observer 和截流函数一结合，问题解决啦嘿嘿。当然还有很多坑，下次再开一篇说说吧。

### 参考

* <https://developer.mozilla.org/en-US/docs/Web/Events/DOMContentLoaded>
* <https://developer.mozilla.org/zh-CN/docs/Web/Events/load>
* <https://developer.mozilla.org/zh-CN/docs/Web/API/EventTarget/addEventListener>
* <http://www.cnblogs.com/fsjohnhuang/p/4147810.html>
* <http://www.alloyteam.com/2012/11/javascript-throttle/>
