---
date: 2014-04-06 19:00:00
layout: post
title: JavaScript脚本代码摆放位置
thread: 107
categories: Documents
tags: [JavaScript]
excerpt: 
---

1. HEAD中的脚本，是可以保证脚本在任何调用之前被加载。

2. BODY中的脚本，当页面被加载时执行的脚本放在HTML的body部分。放在body部分的脚本通常被用来生成页面的内容。

3. Javascript可以放在页面的任何地方，它的加载顺序与页面的加载顺序一致，页面加载时，先加载head部分，后加载body部分，所以当把javascript代码块放在HTML前面时，它将先于head被加载，当放在head里面时，它将先于body被加载，当放在页面最后的的html之外时，它将最后被加载。

----

但js文件最好是独立出来存放，多个Javascript文件，为了减少对站点的请求次数（提高性能），应该把这些.js文件合并在一个文件中。

资料源自[SegmentFault社区](http://segmentfault.com/)