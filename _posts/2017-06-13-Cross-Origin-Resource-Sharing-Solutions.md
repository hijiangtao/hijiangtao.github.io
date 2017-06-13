---
title: 前端跨域请求解决方案汇总
layout: post
thread: 175
date: 2017-06-13
author: Joe Jiang
categories: documents
tags: [跨域, CORS, HTTP]
excerpt: 同源策略限制从一个源加载的文档或脚本如何与来自另一个源的资源进行交互。这是一个用于隔离潜在恶意文件的关键的安全机制。但是有时候跨域请求资源是合理的需求，本文尝试从多篇文章中汇总至今存在的所有跨域请求解决方案。
---

同源策略限制从一个源加载的文档或脚本如何与来自另一个源的资源进行交互。这是一个用于隔离潜在恶意文件的关键的安全机制。但是有时候跨域请求资源是合理的需求，本文尝试从多篇文章中汇总至今存在的所有跨域请求解决方案。

## 跨域请求

首先需要了解的是同源和跨源的概念。对于相同源，其定义为：如果协议、端口（如果指定了一个）和主机对于两个页面是相同的，则两个页面具有相同的源。只要三者之一任意一点有不同，那么就为不同源。当一个资源从与该资源本身所在的服务器的域或端口不同的域或不同的端口请求一个资源时，资源会发起一个跨域 HTTP 请求。而有关跨域请求受到限制的原因可以参考如下 MDN 文档片段：

> 跨域不一定是浏览器限制了发起跨站请求，而也可能是跨站请求可以正常发起，但是返回结果被浏览器拦截了。最好的例子是 CSRF 跨站攻击原理，请求是发送到了后端服务器无论是否跨域！注意：有些浏览器不允许从 HTTPS 的域跨域访问 HTTP，比如  Chrome 和 Firefox，这些浏览器在请求还未发出的时候就会拦截请求，这是一个特例。

## 解决方法汇总

以下我们由简及深介绍各种存在的跨域请求解决方案，包括 `document.domain, location.hash, window.name, window.postMessage, JSONP, WebSocket, CORS`。

### document.domain

`document.domain` 的作用是用来获取/设置当前文档的原始域部分，例如：

```javascript
// 对于文档 www.example.xxx/good.html
document.domain="www.example.xxx"

// 对于URI http://developer.mozilla.org/en/docs/DOM 
document.domain="developer.mozilla.org"
```

> 如果当前文档的域无法识别，那么 domain 属性会返回 null。
> 
> 在根域范围内，Mozilla允许你把domain属性的值设置为它的上一级域。例如，在 developer.mozilla.org 域内，可以把domain设置为 "mozilla.org" 但不能设置为 "mozilla.com" 或者"org"。

因此，若两个源所用协议、端口一致，主域相同而二级域名不同的话，可以借鉴该方法解决跨域请求。

比如若我们在 <http://a.github.io> 页面执行以下语句：

```javascript
document.domain = "github.io"
```

那么之后页面对 `github.io` 发起请求时页面则会成功通过对 `github.io` 的同源检测。比较直接的一个操作是，当我们在 `a.github.io` 页面中利用 iframe 去加载 `github.io` 时，通过如上的赋值后，我们可以在 `a.github.io` 页面中去操作 iframe 里的内容。

我们同时考虑另一种情况：存在两个子域名 `a.github.io` 以及 `b.github.io`， 其中前者域名下网页 a.html 通过 iframe 引入了后者域名下的 b.html，此时在 a.html 中是无法直接操作 b.html 的内容的。

同样利用 `document.domain`，我们在两个页面中均加入

```javascript
document.domain='github.io'
```

这样在以上的 a.html 中就可以操作通过 iframe 引入的 b.html 了。

**document.domain** 的优点在于解决了主语相同的跨域请求，但是其缺点也是很明显的：比如一个站点受到攻击后，另一个站点会因此引起安全漏洞；若一个页面中引入多个 iframe，想要操作所有的 iframe 则需要设置相同的 domain。

### location.hash

`location.hash` 是一个可读可写的字符串，该字符串是 URL 的锚部分（从 # 号开始的部分）。例如：

```
// 对于页面 http://example.com:1234/test.htm#part2
location.hash = "#part2"
```

同时，由于我们知道改变 hash 并不会导致页面刷新，所以可以利用 hash 在不同源间传递数据。

假设 `github.io` 域名下 a.html 和 `shaonian.eu` 域名下 b.html 存在跨域请求，那么利用 location.hash 的一个解决方案如下：

* a.html 页面中创建一个隐藏的 iframe， src 指向 b.html，其中 src 中可以通过 hash 传入参数给 b.html
* b.html 页面在处理完传入的 hash 后通过修改 a.html 的 hash 值达到将数据传送给 a.html 的目的
* a.html 页面添加一个定时器，每隔一定时间判断自身的 location.hash 是否变化，以此响应处理

以上步骤中需要注意第二点：如何在 iframe 页面中修改 父亲页面的 hash 值。由于在 IE 和 Chrome 下，两个不同域的页面是不允许 `parent.location.hash` 这样赋值的，所以对于这种情况，我们需要在父亲页面域名下添加另一个页面来实现跨域请求，具体如下：

* 假设 a.html 中 iframe 引入了 b.html, 数据需要在这两个页面之间传递，且 c.html 是一个与 a.html 同源的页面
* a.html 通过 iframe 将数据通过 hash 传给 b.html
* b.html 通过 iframe 将数据通过 hash 传给 c.html
* c.html 通过 `parent.parent.location.hash` 设置 a.html 的 hash 达到传递数据的目的

**location.bash** 方法的优点在于可以解决域名完全不同的跨域请求，并且可以实现双向通讯；而缺点则包括以下几点：

* 利用这种方法传递的数据量受到 url 大小的限制，传递数据类型有限
* 由于数据直接暴露在 url 中则存在安全问题
* 若浏览器不支持 `onhashchange` 事件，则需要通过轮训来获知 url 的变化
* 有些浏览器会在 hash 变化时产生历史记录，因此可能影响用户体验

### window.name

该属性用于获取/设置窗口的名称。其特征在于：一个窗口的生命周期内，窗口载入的所有页面共享该值，且都具有对该属性的读写权限。这意味着如果不修改该值，那么在不同页面加载之后该值也不会变，且其支持长达 2MB 的存储量。

利用该特性我们可以将跨域请求用如下步骤解决：

* 在 a.github.io/a.html 中创建 iframe 指向 b.github.io/b.html (页面会将自身的 window.name 附在 iframe 上)
* 给 a.github.io/a.html 添加监听 iframe 的 onload 事件，在该事件中将 iframe 的 src 设置为本地域的代理文件（代理文件和a.html处于同一域下，可以相互通信），同时可以传出 iframe 的 name 值
* 获取数据后销毁 iframe，释放内存，同时也保证了安全

**window.name** 的优势在于巧妙地绕过了浏览器的跨域访问限制，但同时它又是安全操作。

### window.postMessage

HTML5 为了解决这个问题，引入了一个全新的 API：跨文档通信 API（Cross-document messaging）。这个 API 为 window 对象新增了一个 window.postMessage 方法，允许跨窗口通信，不论这两个窗口是否同源。

API 的详细使用方法请见 [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage)。

### JSONP

JSONP, 全称 JSON with Padding，是使用 AJAX 实现的请求不同源的跨域。其基本原理：网页通过添加一个 `<script>` 元素，向服务器请求 JSON 数据，这种做法不受同源政策限制；服务器收到请求后，将数据放在一个指定名字的回调函数里传回来。

以下为一个例子，由于 test.js 返回的内容直接作为代码运行，所以只要 a.html 中定义了 `callback` 函数, 它就会立即被调用。

```
// 当前页面 a.com/a.html
<script type="text/javascript">
//回调函数
function callback(data) {
    alert(data.message);
}
</script>
<script type="text/javascript" src="http://b.com/test.js"></script>

// test.js
// 调用callback函数，并以json数据形式作为阐述传递，完成回调
callback({message:"success"}); 
```

为了保证 script 的灵活，我们可以通过 JavaScript 动态创建 script 标签，并通过 HTTP 参数向服务器传入回调函数名，案例如下所示：

```
<script type="text/javascript">
    // 添加<script>标签的方法
    function addScriptTag(src){
        var script = document.createElement('script');
        script.setAttribute("type","text/javascript");
        script.src = src;
        document.body.appendChild(script);
    }
    
    window.onload = function(){
        // 搜索apple，将自定义的回调函数名result传入callback参数中
        addScriptTag("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=apple&callback=result");
        
    }
    // 自定义的回调函数result
    function result(data) {
        // 我们就简单的获取apple搜索结果的第一条记录中url数据
        alert(data.responseData.results[0].unescapedUrl);
    }
</script>
```

jQuery 有相应的 JSONP 的实现方法，见 [API](http://api.jquery.com/jquery.getjson/)。

**JSONP**的优点在于简单适用，老式浏览器全部支持，服务器改造小。不需要XMLHttpRequest或ActiveX的支持；但缺点是只支持 GET 请求。

### WebSocket

WebSocket 协议不实行同源政策，只要服务器支持，就可以通过它进行跨源通信。

### CORS

> CORS是一个W3C标准，全称是"跨域资源共享"（Cross-origin resource sharing）。它允许浏览器向跨源服务器，发出XMLHttpRequest请求，从而克服了AJAX只能同源使用的限制。

跨域资源共享（ CORS ）机制允许 Web 应用服务器进行跨域访问控制，从而使跨域数据传输得以安全进行。其需要服务端和客户端同时支持。

> 跨域资源共享标准（ cross-origin sharing standard ）允许在下列场景中使用跨域 HTTP 请求：
> 
> 由 XMLHttpRequest 或 Fetch 发起的跨域 HTTP 请求
> 
> Web 字体 (CSS 中通过 @font-face 使用跨域字体资源), 因此，网站就可以发布 TrueType 字体资源，并只允许已授权网站进行跨站调用
> 
> WebGL 贴图
> 
> 使用 drawImage 将 Images/video 画面绘制到 canvas
> 
> 样式表（使用 CSSOM）
> 
> Scripts (未处理的异常)

CORS 存在以下三种主要场景，分别是**简单请求，预检请求和附带身份凭证的请求**。

* **简单请求**：若只使用 GET, HEAD 或者 POST 请求，且除 CORS 安全的首部字段集合外，无人为设置该集合之外的其他首部字段，同时 Content-Type 值属于下列之一，那么该请求则可以被视为简单请求：

```
application/x-www-form-urlencoded
multipart/form-data
text/plain
```

此情况下，若服务端返回的 `Access-Control-Allow-Origin: *` ，则表明该资源可以被任意外域访问。若要指定仅允许来自某些域的访问，需要将 `*` 设定为该域，例如：

```
Access-Control-Allow-Origin: http://foo.example
```

* **预检请求**：与前述简单请求不同，该要求必须首先使用 OPTIONS   方法发起一个预检请求到服务器，以获知服务器是否允许该实际请求。当请求满足以下三个条件任意之一时，
即应首先发送预检请求：

1. 使用了 PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH 中任一的 HTTP 方法
2. 人为设置了对 CORS 安全的首部字段集合之外的其他首部字段
3. Content-Type 的值不属于下列之一

```
application/x-www-form-urlencoded
multipart/form-data
text/plain
```

预检请求完成之后（通过 OPTIONS 方法实现），才发送实际请求。一个示范 HTTP 请求如下所示：

```javascript
var invocation = new XMLHttpRequest();
var url = 'http://bar.other/resources/post-here/';
var body = '<?xml version="1.0"?><person><name>Arun</name></person>';
    
function callOtherDomain(){
  if(invocation)
    {
      invocation.open('POST', url, true);
      invocation.setRequestHeader('X-PINGOTHER', 'pingpong');
      invocation.setRequestHeader('Content-Type', 'application/xml');
      invocation.onreadystatechange = handler;
      invocation.send(body); 
    }
}
```

* **附带身份凭证的请求**：这种方式的特点在于能够在跨域请求时向服务器发送凭证请求，例如 Cookies (withCredentials 标志设置为 true)。

一般而言，对于跨域 XMLHttpRequest 或 Fetch 请求，浏览器不会发送身份凭证信息。如果要发送凭证信息，需要设置 XMLHttpRequest 的某个特殊标志位。但是需要注意的是，如果服务器端的响应中未携带 `Access-Control-Allow-Credentials: true`，浏览器将不会把响应内容返回给请求的发送者。

> 附带身份凭证的请求与通配符
> 
> 对于附带身份凭证的请求，服务器不得设置 Access-Control-Allow-Origin 的值为“*”。
> 
> 这是因为请求的首部中携带了 Cookie 信息，如果 Access-Control-Allow-Origin 的值为“*”，请求将会失败。而将 Access-Control-Allow-Origin 的值设置为 http://foo.example，则请求将成功执行。
> 
> 另外，响应首部中也携带了 Set-Cookie 字段，尝试对 Cookie 进行修改。如果操作失败，将会抛出异常。

MDN 引例如下：

```javascript
var invocation = new XMLHttpRequest();
var url = 'http://bar.other/resources/credentialed-content/';
    
function callOtherDomain(){
  if(invocation) {
    invocation.open('GET', url, true);
    invocation.withCredentials = true;
    invocation.onreadystatechange = handler;
    invocation.send(); 
  }
}
```

其实由上我们知道，**CORS** 的优点也非常明显：CORS支持所有类型的HTTP请求，是跨域HTTP请求的根本解决方案。

以上就是所有的跨域请求解决方案，根据实际生产环境，总有一款适合你。

## 参考

* <https://github.com/wengjq/Blog/issues/2>
* <https://developer.mozilla.org/zh-CN/docs/Web/Security/Same-origin_policy>
* <https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Access_control_CORS>
* <http://www.cnblogs.com/zichi/p/4620656.html>