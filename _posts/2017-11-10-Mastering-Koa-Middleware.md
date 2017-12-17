---
title: \[译\] 掌握 Koa 中间件
layout: post
thread: 181
date: 2017-11-10
author: Joe Jiang
categories: documents
tags: [Koa, JavaScript, Middleware, Nodejs, Koajs, Expressjs, Translation]
excerpt: 随着 Node 默默的实现了 async-await 的用法，Koa2 也在最近发布了。Express 似乎还占领着这场人气比赛的上风，但自 Koa2 发布以来我一直愉快的使用着，并且总是害怕回到老项目中去使用 Express...
---

随着 Node 默默的[实现了 async-await](https://www.infoq.com/news/2017/02/node-76-async-await) 的用法，Koa2 也在最近[发布](https://github.com/koajs/koa/commit/6c6aa4dab41bd3d11a62afe5de9fc144f9b2add3)了。Express 似乎还占领着这场人气比赛的上风，但自 Koa2 发布以来我一直愉快的使用着，并且总是害怕回到老项目中去使用 Express.

我偶尔出没在 [Koa Gitter](https://gitter.im/koajs/koa) 为大家答疑解惑，而我回答最多的是与魔法般的Koa中间件系统有关的问题，所以我居然定在这个问题上好好写写。

有很多 Koa 新手曾经使用过 Express，所以我会在两者之间进行大量的比较。

> 这篇文章针对的是 Koa 新人，以及正在考虑在他们下一个项目中使用 Koa 的人。

## 基本概念

让我们从最重要的开始。在 Koa 和 Express 中，所有关于 HTTP 请求的事情都是在中间件内部完成的，最重要的则是理解**中间件延续传递**的概念。这听起来很奇特，但事实并非如此。它的思想是，一旦中间件完成了它的事情，它可以选择调用链中的下一个中间件。

### Express

```javascript
const express = require('express')
const app = express()
// Middleware 1
app.use((req, res, next) => {
  res.status(200)
  console.log('Setting status')
  // Call the next middleware
  next()
})
// Middleware 2
app.use((req, res) => {
  console.log('Setting body')
  res.send(`Hello from Express`)
})
app.listen(3001, () => console.log('Express app listening on 3001'))
```

### Koa

```javascript
const Koa = require('koa')
const app = new Koa()
// Middleware 1
app.use(async (ctx, next) => {
  ctx.status = 200
  console.log('Setting status')
  // Call the next middleware, wait for it to complete
  await next()
})
// Middleware 2
app.use((ctx) => {
  console.log('Setting body')
  ctx.body = 'Hello from Koa'
})
app.listen(3002, () => console.log('Koa app listening on 3002'))
```

让我们用 `curl` 命令来测试下两者：

```
$ curl http://localhost:3001
Hello from Express
$ curl http://localhost:3002
Hello from Koa
```

两个例子都做了同样的事情，并且都在终端上打印了相同的输出信息：

```
Setting status
Setting body
```

这表明在两种情况下，中间件都是自上而下的。

这里最大的区别在于 Express 中间件链是*基于回调*的，而 Koa 是*基于 Promise* 的。

让我们看看如果我们在两个例子中都省略了 `next()`，会发生什么。

### Express

```
$ curl http://localhost:3001
 
```

...它永不结束。这是因为在 Express 中，你必须在调用 `next()` 和发送 response 两个做法中二选一——否则请求永远不会完成。

### Koa

```
$ curl http://localhost:3002
OK
```

啊，所有 Koa 会完成请求，它虽然有状态码信息，但是没有任何 body 信息。所以第二个中间件是没有被调用的。

但是对于 Koa 来说还有一件事情至关重要。如果你调用 `next()`，你必须等待它！

下面就是最好的例子：

```javascript
// Simple Promise delay
function delay (ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms)
  })
}
app.use(async (ctx, next) => {
  ctx.status = 200
  console.log('Setting status')
  next() // forgot await!
})
app.use(async (ctx) => {
  await delay(1000) // simulate actual async behavior
  console.log('Setting body')
  ctx.body = 'Hello from Koa'
})
```

让我们看看发生了什么。

```
$ curl http://localhost:3002
OK
```

嗯，我们调用了 `next()`，但是没有任何 body 信息传递？这是因为 Koa 在中间件 Promise 链被解析了之后就结束了请求。这意味着在我们设置 `ctx.body` 之前，*response 就已经被发送给了客户端*！

另一个需要明白的是如果你在使用纯粹的 `Promise.then()` 替代 `async-await` 时，你的中间件需要返回一个 promise。当返回的 promise 被解析时，Koa 会在此时恢复之前的中间件。

```javascript
app.use((ctx, next) => {
  ctx.status = 200
  console.log('Setting status')
  // need to return here, not using async-await
  return next()
})
```

一个更好的使用纯粹 promise 的例子：

```javascript
// We don't call `next()` because
// we don't want anything else to happen.
app.use((ctx) => {
  return delay(1000).then(() => {
    console.log('Setting body')
    ctx.body = 'Hello from Koa'
  })
})
```

## Koa 中间件——改变游戏规则的特性

在之前的章节我写到：

> Koa 会在此时恢复之前的中间件

这可能会让你有些失望，请允许我解释一下。

在 Express，一个中间件只能在调用 `next()` 之前做相关操作，而不是之后。一旦你调用 `next()`，请求将永远不再接触到这个中间件。这可能会有些失望，人们（包括 Express 作者自己）已经找到了一些聪明的解决方法，比如当 header 获得写入时观察响应流，但是对于普通用户来说只会感觉到尴尬。

举个例子，要实现一个记录完成请求所需的时间并将其发送到 X-ResponseTime 头部的中间件，需要一个“在下一个调用之前”的代码点和一个“在下一个调用之后”的代码点。在 Express 中，它使用流观察的技术来实现。

让我们在 Koa 中来实现它。

```javascript
async function responseTime (ctx, next) {
  console.log('Started tracking response time')
  const started = Date.now()
  await next()
  // once all middleware below completes, this continues
  const ellapsed = (Date.now() - started) + 'ms'
  console.log('Response time is:', ellapsed)
  ctx.set('X-ResponseTime', ellapsed)
}
app.use(responseTime)
app.use(async (ctx, next) => {
  ctx.status = 200
  console.log('Setting status')
  await next()
})
app.use(async (ctx) => {
  await delay(1000)
  console.log('Setting body')
  ctx.body = 'Hello from Koa'
})
```

8行，只需要这么多。没有 tricky 的流嗅探，只是看起来非常棒的 async-await 代码。让我们运行一下！这里的 `-i` 标记是告诉 curl 同时也为我们显示响应的头部信息。

```
$ curl -i http://localhost:3002
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 14
X-ResponseTime: 1001ms
Date: Thu, 30 Mar 2017 12:52:48 GMT
Connection: keep-alive
Hello from Koa
```

非常棒！我们在 HTTP 头部中找到了响应时间。让我们再看看终端上的日志吧，看看日志是以什么顺序输出的。

```
Started tracking response time
Setting status
Setting body
Response time is: 1001ms
```

看，就是这样。Koa 让我们完全控制了中间件流程。实现类似身份验证以及错误处理的事情将会变得非常简单！

## 错误处理

这是我最喜欢的关于 Koa 的地方，它是由上面详述的强大的中间件 Promise 链所支持的。

为了做好度量，让我们看看我们如何在 Express 中做到这一点。

### Express

错误处理是在一个特殊签名的中间件中完成的，他必须被添加到链的最后才能工作。

```javascript
app.use((req, res) => {
  if (req.query.greet !== 'world') {
    throw new Error('can only greet "world"')
  }
  res.status(200)
  res.send(`Hello ${req.query.greet} from Express`)
})
// Error handler
app.use((err, req, res, next) => {
  if (!err) {
    next()
    return
  }
  console.log('Error handler:', err.message)
  res.status(400)
  res.send('Uh-oh: ' + err.message)
})
```

这是一个最好的例子。如果您正在处理来自回调或 Promise 的异步错误，则会变得非常冗长。 例如：

```javascript
app.use((req, res, next) => {
  loadCurrentWeather(req.query.city, (err, weather) => {
    if (err) {
      return next(err)
    }
    
    loadForecast(req.query.city, (err, forecast) => {
      if (err) {
        return next(err)
      }
      
      res.status(200).send({
        weather: weather,
        forecast: forecast
      })
    })
  })
  
  next()
})
```

> 我完全知道使用模块来处理回调地狱更容易，这里仅仅是为了证明在 Express 中简单的错误处理变得笨拙，更不用说你还需要考虑异步错误与同步错误等。

### Koa

错误处理也是使用 promise 完成的。Koa 总是为我们将 `next()` 包装在一个 promise 中，所以我们甚至不必担心异步与同步错误。

**错误处理中间件在最顶端运行**，因为它“*绕过*”了每一个后续的中间件。这意味着在错误处理之后添加的任何错误都会被捕获（*是的，感受一下！*）

```javascript
app.use(async (ctx, next) => {
  try {
    await next()
  } catch (err) {
    ctx.status = 400
    ctx.body = `Uh-oh: ${err.message}`
    console.log('Error handler:', err.message)
  }
})
app.use(async (ctx) => {
  if (ctx.query.greet !== 'world') {
    throw new Error('can only greet "world"')
  }
  
  console.log('Sending response')
  ctx.status = 200
  ctx.body = `Hello ${ctx.query.greet} from Koa`
})
```

是的，一个 `try-catch`。对于错误处理，*这是多么合适！*非 `async-await` 的方式如下所示：

```javascript
app.use((ctx, next) => {
  return next().catch(err => {
    ctx.status = 400
    ctx.body = `Uh-oh: ${err.message}`
    console.log('Error handler:', err.message)
  })
})
```

让我们出发一个错误：

```
$ curl http://localhost:3002?greet=jeff
Uh-oh: can only greet "world"
```

控制台如预期般般输出：

```
Error handler: can only greet "world"
```

## 路由

与 Express 不同，Koa 几乎没有任何东西可用。没有 bodyparser，也没有路由。

在 Koa 有许多路由的选择，例如 `koa-route` 和 `koa-router`。我更喜欢后者。

### Express

Express 中的路由是内置的。

```javascript
app.get('/todos', (req, res) => {
  res.status(200).send([{
    id: 1,
    text: 'Switch to Koa'
  }, {
    id: 2,
    text: '???'
  }, {
    id: 3,
    text: 'Profit'
  }])
})
```

### Koa

在这个例子中我选择 `koa-router` 因为它是我正在使用的路由。

```javascript
const Router = require('koa-router')
const router = new Router()
router.get('/todos', (ctx) => {
  ctx.status = 200
  ctx.body = [{
    id: 1,
    text: 'Switch to Koa',
    completed: true
  }, {
    id: 2,
    text: '???',
    completed: true
  }, {
    id: 3,
    text: 'Profit',
    completed: true
  }]
})
app.use(router.routes())
// makes sure a 405 Method Not Allowed is sent
app.use(router.allowedMethods())
```

## 结论

Koa 很酷。基于中间件链的完全控制，并且基于 Promise 的事实使得一切都变得容易操作起来。不再是到处的 `if (err) return next(err)` 而只有 promise.

通过超强大的错误处理程序，我们可以抛出错误，更加优雅地脱离我们的代码的运行路径（想想验证错误，业务逻辑违规）。

下面是我经常使用的中间件列表（没有特定的顺序）：

* koa-compress
* koa-respond
* kcors
* koa-convert
* koa-bodyparser
* koa-compose
* koa-router

**最好知道**：并不是所有的中间件都是基于 Koa 2 可用的，然后他们可以在运行时通过 `koa-convert` 进行转换，所以不用担心。

## 原文链接

[Mastering Koa Middleware](https://medium.com/netscape/mastering-koa-middleware-f0af6d327a69), 作者 Twitter [@Jeffijoe](https://twitter.com/jeffijoe)
