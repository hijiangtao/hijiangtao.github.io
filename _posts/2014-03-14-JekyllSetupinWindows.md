---
date: 2014-03-14 20:10:00
layout: post
title: Windows下搭建Jekyll本地测试环境安装笔记
thread: 80
categories: Tutorial
tags: [Jekyll]
---

前言：由于最近找到一个开源的数据可视化工具，这种东西在本地进行测试、修改和预览会效果更好，于是我准备在Windows下进行基于Jekyll的Github博客本地测试环境的搭建工作。网上随便找了本教程，搭建注意事项一样没写，于是困扰了我很久很久，但最终各种搜索还是完成了，将一些经验与失败经历记录下来，以便以后查看总结。

----

##一、Jekyll简介

Jekyll 是一个简洁的、特别针对博客平台的 静态网站 生成器。它使用一个模板目录作为网站布局的基础框架，并在其上运行 Textile 、 Markdown 或 Liquid 标记语言的转换器，最终生成一个完整的静态Web站点。

----

##二、配置Ruby环境

* **安装Ruby**

Jekyll使用动态脚本语言 Ruby 写成。因此在安装Jekyll前，必须先安装Ruby。这里选择Ruby 1.9.3-p392下载安装。下载地址：[点击下载](http://rubyforge.org/frs/download.php/76798/rubyinstaller-1.9.3-p392.exe)。当然，为了简便我们可以直接使用RubyInstaller来完成这一步：[RubyInstaller Download Link](http://rubyinstaller.org/downloads/)

这个和普通的Windows下其他软件安装部署一样，.exe文件点击安装即可，不做过多介绍。对了，记得安装的时候选上**Add Ruby executables to your PATH**（添加系统环境变量）。但是要注意非常重要的一点（这一点在DevKit安装时也要特别注意）：**安装目录一定不能存在空格，直接D：根目录下安装最好。**由于我一直习惯将程序装在Program Files文件夹中，所以在后来gem命令时一直重复了好多遍，但总是显示：

>Error installing rdiscount: ERROR: Failed to build gem native extension.

* **安装DevKit**

在后面安装一些gem native extension时需要DevKit，（比如更改默认的模板渲染器为rdiscount时），因此我们也先安好。DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe下载地址：[点击下载](https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe)

下载后，双击解压，并选择一个目录来安装，推荐`D:\DevKit`。

* **完成安装**

接下来开始运行安装脚本： 在命令行中输入

```
cd <你的DEVKIT安装目录>
```

定位到你的安装目录下；然后继续在命令行中输入

```
ruby dk.rb init
```

生成一个config.yml文件，这个文件在之后会使用到；输入

```
ruby dk.rb review
```

你可以看到你安装好的ruby会列出来（只有那些通过RubyInstaller包安装的才会被检测到）。

如果此时打开config.yml文件，你发现你刚刚安装好的Ruby安装目录写好在里面了，那就OK了；如果没有，或者你想使用其他版本的，可以在这个文件内编辑改写（注意目录前要加横线和空格，比如:`- C:/Ruby200`）。

最后输入以下命令完成安装。（如果失败，尝试在后面加上--force来强制更新下）

```
ruby dk.rb install
```

对了，到这一步最好去Windows的环境变量中把上面DevKit的安装目录加进去，不然运行下面命令时可能又会报错。

----

##三、安装Jekyll（需联网）

如果选择默认安装那么在最后调试的时候可能会由于你网站中的代码高亮等成分的存在而造成运行终止，所以安装Jekyll一定要注意版本号，这里推荐1.4.2，安装命令如下（不带命令版本的代码把--version及之后的代码删去即可）：

```
gem install jekyll --version "=1.4.2"
```

Jekyll依赖以下的gems模块： fast-stemmer 、 classifier 、 directory_watcher 、 syntax 、 maruku 、 kramdown 、yajl-ruby、 posix-spawn 和 pygments.rb都会被自动安装。

**更换Markdown渲染引擎为RDiscount**。确认安装：

```
gem install rdiscount -v=1.6.8 --platform=ruby
```

并通过以下命令行参数执行Jekyll：

```
jekyll --rdiscount
```

对了，在你站点下的 _config.yml 文件中加入以下配置，以便以后每次执行时不必再指定命令行参数：

```
markdown: rdiscount
```

将github网站克隆到本地: 

```
git clone git@github.com:username/username.github.com.git
```

然后CD进网站目录，由于版本问题，一个重要改动是启动服务器的命令，将以前的`--server`命令改为了serve，所以执行如下语句：

```
jekyll serve
```

启动服务器后在浏览器输入`localhost:4000`浏览搭建的博客。

但就是在这里环境开启一直不成功，错误显示：

>Error reading file 

>C:/Users/admin/Documents/GitHub/hijiangtao.github.io/_posts/2
013-03-04-blogsearcharchieve.md: invalid byte sequence in GBK

>error: invalid byte sequence in GBK. Use --trace to view backtrace

这是中文编码的错误，如果是写英文博客就不会出错，这似乎是 Jekyll 的一个 bug，解决方法是将 Ruby 安装文件路径下的`.\Ruby193\lib\ruby\gems\1.9.1\gems\jekyll-1.4.2\lib\jekyll\convertible.rb`的`self.content = File.read(File.join(base, name)……`这一行改成：

```
self.content = File.read(File.join(base, name), :encoding => "utf-8")
```

编码问题解决。但是`jekyll serve`发现还是存在问题。

经过反复推敲，发现是Pygments版本的问题，默认安装的版本是Pygments 0.5.4，但是我们需要的能运行的（支持代码高亮功能）版本应该是Pygments 0.5.0，所以执行：

```
gem uninstall pygments.rb --version "=0.5.4"
gem install pygments.rb --version "=0.5.0"
```

问题解决。

但是祸不单行啊，重新启动，错误信息貌似又指向了python，我的python可是很早以前就安装好并且运行过了啊。由于命令行已经关闭找不到自己当时的出错信息了，所以网上搜了一下，错误信息格式大致如下：

>Generating...   Liquid Exception: No such file or directory - python c:/Ruby200-x64/lib/ruby/gems/2.0.0/gems/pygments.rb-0.4.2/lib/pygments/mentos.py in 2013-04-22-hello-world.md

网上给的解释与解决方法是：

>**Possible Reason**: The PATH just set is yet to be effective.

>**Possible Solution**: First make sure no spaces or trailing slash in the PATH. Then restart Command Prompt. If it's not working, try logout Windows and log back in again. Or even try the ultimate and most powerful solution - "turning the computer off and on again".

大致意思就是要把Python的路径加进系统变量里。于是**我的电脑->属性->高级->环境变量->系统变量中的PATH**增加：

>;C:\Python27

好了，运行后终于出现了：

```
Configuration file: C:/Users/admin/Documents/GitHub/hijiangtao.github.io/_config
.yml
            Source: C:/Users/admin/Documents/GitHub/hijiangtao.github.io
       Destination: C:/Users/admin/Documents/GitHub/hijiangtao.github.io/_site
      Generating... done.
    Server address: http://0.0.0.0:4000
  Server running... press ctrl-c to stop.
```

但是，还没有完啊。当我打开浏览器输入网址准备浏览时，

>您访问的网页出错了！ Not Found!

这是闹哪样，我差点就喷血了！网上搜索，发现有一种解决方法：

>原来需要把博客代码仓库里的配置文件 _config.yml 中的 baseurl 删除，然后重启服务。

但不适合我，因为我都没有设置baseurl。但奇怪的是我用localhost:4000或者127.0.0.1:4000访问时，博客正常显示了，这是闹哪样。

好吧，有关这个问题我还是不解，为什么shell里显示的是让我访问server 0.0.0.0:4000而现实中却是和apache一样的本地地址才行的通？如果你知道为什么，衷心的希望你毫不吝啬的在下方留言告诉我，感谢你的耐心阅读与无私指导。

----

搞定一切，重新`jekyll serve`，漂亮本地网站出来了，虽然浏览器里输入的不是0.0.0.0:4000而是127.0.0.1:4000了。但毕竟如此一来，我已经可以开始昨天fork到的资源的调试工作了，开心。