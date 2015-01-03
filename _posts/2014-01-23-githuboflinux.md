---
date: 2014-01-23
layout: post
title: 在linux上使用github维护个人站点小结
thread: 3
categories: Documents
tags: [linux, github]
---

好吧，刚写完第一篇博客想用LINUX的终端把文章传上github时出了好多小插曲，由于不太理解github在终端上的一些用法，于是睡觉的时刻又狠狠的往后拖了半个小时，虽然最终把今天一天的修改过的版本都莫名的删除光了，但还好本地有备份，再加上鼓捣出来了维护的正确方法，下面就记录一下自己是如何操作来如何维护一个已有的Repository。

以我的个人博客[hijiangtao.github.io](https://github.com/hijiangtao/hijiangtao.github.io)为例，我现在写了一篇文章要更新到github自己的仓库里，那么我该完成的有以下几步：

* 打开终端，并进入你将要上传的代码文件夹位置（以下为我要进入的DataBlog）。

{% highlight javascript linenos %}
    cd '/home/data/文档/resolutions/DataBlog' 
{% endhighlight %}

* 在当前目录下创建一个.git文件夹。

{% highlight javascript linenos %}
    git init
{% endhighlight %}

* 把当前路径下的所有文件，添加到待上传的文件列表中(我本来只需要更新一个文件，但如果只选中待更新文件而不是全部的话，执行之后的指令得到的结果就是代码仓库里只有这一个文件，而且版本历史也被全部清空了，暂时还不知道为什么)。

{% highlight javascript linenos %}
    git add .
{% endhighlight %}

* 给即将上传的文件统一添加Commit summary.

{% highlight javascript linenos %}
    git commit -m "xxxxx" 
{% endhighlight %}

* 通过push修改到origin中，更新代码。

{% highlight javascript linenos %}
    git push -u origin master
{% endhighlight %}

至此，已经将本地的更新代码上传到GitHub服务器了。但其中有几点关键还是不太明白，明天再看看争取弄清楚，比如不同分支在代码仓库中所起到的作用。

而有关在linux下如何使用GitHub我也在网上搜索到一篇较为详细的教程，以供参考。

* [Github详细教程](http://blog.csdn.net/lishuo_os_ds/article/details/8078475#sec-1.4.2)
 
