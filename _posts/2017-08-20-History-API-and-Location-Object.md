---
title: HTML5 History API 和 Location 对象剖析
layout: post
thread: 180
date: 2017-08-20
author: Joe Jiang
categories: documents
tags: [DOM, JavaScript, History, Location]
excerpt: 这次也不长篇大论，只搞清楚两件事 —— History API & Location 对象。了解清楚这些，将能够使我们在不同 web 页面之间穿梭自如。
---

这次也不长篇大论，只搞清楚两件事 —— History API & Location 对象。了解清楚这些，将能够使我们在不同 web 页面之间穿梭自如。

## History API

History 作为一个全局变量（即 window.history），不继承任何属性，在 HTML4 时代就已经存在，通过这个接口，我们可以操纵浏览器中曾经访问过的会话历史记录，但当时我们能使用的属性与方法只有这么几个：

* **History.length** 属性: 返回一个整数，该整数表示会话历史中元素的数目，包括当前加载的页。例如，在一个新的选项卡加载的一个页面中，这个属性返回1。
* **History.back()** 方法：前往上一页, 用户可点击浏览器左上角的返回按钮模拟此方法。等价于 history.go(-1).
* **History.forward()** 方法：在浏览器历史记录里前往下一页，用户可点击浏览器左上角的前进按钮模拟此方法。等价于 history.go(1).
* **History.go()** 方法：通过当前页面的相对位置从浏览器历史记录( 会话记录 )加载页面。比如：参数为-1的时候为上一页，参数为1的时候为下一页. 当整数参数超出界限时，那么这个方法没有任何效果也不会报错。调用没有参数的 go() 方法或者不是整数的参数时也没有效果。

从 HTML5 开始，增加了两个新的方法：

* **History.pushState(state, title [, url])** 方法：往历史堆栈的顶部添加一个状态。pushState() 带有三个参数：一个状态对象，一个标题（现在被忽略了），以及一个可选的URL地址。state为一个对象或null，它会在触发window的popstate事件（window.onpopstate）时，作为参数的state属性传递过去；如果你像pushState() 方法传递了一个序列化表示大于640k 的state对象，这个方法将扔出一个异常。如果你需要更多的空间，推荐使用sessionStorage或者localStorage。title为页面的标题，但当前所有浏览器都忽略这个参数。URL为页面的URL，不写则为当前页；新URL必须和当前URL在同一个源下；否则，pushState() 将丢出异常。

* **History.replaceState(state, title [, url])**：更改当前页面的历史记录值。参数同上。这种更改并不会去访问该URL。

至此，这个 API 拥有的方法就都梳理完了。但是刚刚说到了 state 对象关联的一个事件，所以在这里把 popstate 事件也描述一下。

* **popstate**事件：当活动历史记录条目更改时，将触发popstate事件。如果被激活的历史记录条目是通过对history.pushState()的调用创建的，或者受到对history.replaceState()的调用的影响，popstate事件的state属性包含历史条目的状态对象的副本。需要注意的是调用history.pushState()或history.replaceState()不会触发popstate事件。只有在做出浏览器动作时，才会触发该事件，如用户点击浏览器的回退按钮。当我们需要监听该事件并作出相应响应时，我们应该这样组织代码：

```
window.onpopstate = function(event) {
  alert("location: " 
    + document.location 
    + ", state: " 
    + JSON.stringify(event.state));
};
```

大致上看，history API 的支持情况还是很不错的，可以点击[此处](http://caniuse.com/#feat=history)查看各个浏览器对 history 的支持情况。

## Location 对象

当然，当我们更改URL时，可能会出现这样一种情况：我们只更改了URL的片段标识符 (跟在＃符号后面的URL部分，包括＃符号)，这种情况下将触发 hashchange 事件，使用方法如下：

```
window.addEventListener("hashchange", funcRef, false);

// 或者

window.onhashchange = funcRef;
```

其中，提到的 hash 属性可以通过 `location.hash` 获得。从这里开始，我们引出 Location 对象。Location 对象包含有关当前 URL 的信息。针对一个示例 `http://b.a.com:88/index.php?name=kang&when=2011#first` 我们整理一下各个属性与其含义的分别所指内容是啥。

|属性    |	描述|   值|
|---| ----- | -------- |
|hash    |	设置或返回从井号 (#) 开始的 URL（锚）。|"#first"|
|host   |	设置或返回主机名和当前 URL 的端口号。|"b.a.com:88"|
|hostname   |	设置或返回当前 URL 的主机名。|"b.a.com"|
|href   |	设置或返回完整的 URL。|"http://b.a.com:88/index.php?name=kang&when=2011#first"|
|pathname   |	设置或返回当前 URL 的路径部分。|"/index.php"|
|port   |	设置或返回当前 URL 的端口号。|88|
|protocol   |	设置或返回当前 URL 的协议。|"http:"|
|search |	设置或返回从问号 (?) 开始的 URL（查询部分）。|"?name=kang&when=2011"|

window.location和document.location互相等价的，可以交换使用。且 location 的8个属性都是可读写的，但是只有href与hash的写才有意义。例如改变location.href会重新定位到一个URL，而修改location.hash会跳到当前页面中的anchor名字的标记(如果有)，而且页面不会被重新加载。

通过 location 我们可以作如下几种方法的操作：

* **assign()** 方法：加载新的文档；
* **reload()** 方法：重新加载当前文档；
* **replace()** 方法：用新的文档替换当前文档。

导航到一个新页面的方法：

```
window.location.assign("http://www.mozilla.org"); // or
window.location = "http://www.mozilla.org";
```

针对 reload 需要说明的是，如果该方法没有规定参数，或者参数是 false，它就会用 HTTP 头 If-Modified-Since 来检测服务器上的文档是否已改变。如果文档已改变，reload() 会再次下载该文档。如果文档未改变，则该方法将从缓存中装载文档。这与用户单击浏览器的刷新按钮的效果是完全一样的。如果把该方法的参数设置为 true，那么无论文档的最后修改日期是什么，它都会绕过缓存，从服务器上重新下载该文档。这与用户在单击浏览器的刷新按钮时按住 Shift 健的效果是完全一样：

```
window.location.reload(true);
```

replace() 方法不会在 History 对象中生成一个新的记录。当使用该方法时，新的 URL 将覆盖 History 对象中的当前记录。用法为：

```
window.location.replace('http://example.com/'); 
```

通过 location 的属性与方法，我们可以做很多事情，详情可以查看 [MDN](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/location)。
