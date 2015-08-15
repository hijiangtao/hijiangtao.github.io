---
date: 2013-11-18
layout: post
title: 在xampp环境下搭建本地的wordpress站点教程
thread: 14
categories: Tutorial
tags: [wordpress, xampp]
---

本人在**PHP+APACHE+MYSQL**三个软件单独安装配置环境一直久久无果的情况下，最终决定投入了XAMPP集成环境的怀抱。

不言而喻，本篇文章就是介绍如何通过XAMPP来配置搭建本地的wordpress环境。

**首先，什么是WORDPRESS？**

WordPress中文官方站点告诉我们：WordPress是一个注重美学、易用性和网络标准的个人信息发布平台。使用WordPress可以搭建功能强大的网络信息发布平台，但更多的是应用于个性化的博客。针对博客的应用，WordPress能让您省却对后台技术的担心，集中精力做好网站的内容。

想必大家都有做一个专属于自己网站的梦想，但大多情况下又无从下手。毋庸置疑，weebly是一个极其便利的网站搭建工具，但是如果你拥有一定的html、css、php编写能力，而与此同时你又想建一个不那么简单化的网站，那么无疑wordpress是你很不错的一个选择。当然，拿wordpress相比ghost，我更看好后者。

好吧废话不多说，下面开始一步步的教大家如何建立一个wordpress环境。

**首先**， 在你电脑的桌面上或者是xampp的安装盘里面找到他的启用按钮XAMPP Control Panel，然后双击打开，打开之后会弹出如下图所示的窗口，这个时候我就只需要点击Apache和Mysql后面的start按钮来启用服务器和数据库，当前面显示绿色的Running就表示我们的本的服务器和数据库启用成功。如下图所示：

![](/assets/2013-11-18-wordpress-1.jpg)

需要注意的是：apache默认监听端口是80，而系统在很多时候80端口都是会被其他程序占用的，所以大家在配置时最好把httpd.conf文件中监听端口80改掉，改成81就行。具体配置方法和路径如下：

![](/assets/2013-11-18-wordpress-2.png)

![](/assets/2013-11-18-wordpress-3.png)

接下来我们需要做的就是创建一个数据库，点击Mysql后面的**Admin**按钮，然后会弹出如下图的页面：你只需要在红色框出的表单里面随便填写一个名字就可以了，不过名字一定要是英文或拼音的，然后点击创建按钮，数据库就创建成功了。 我在这里建立的数据库名称是opensource。

![](/assets/2013-11-18-wordpress-4.jpg)

数据库创建成功之后当然是要准备我们的最后一步，就是下载wordpress程序包，下载地址为： <http://cn.wordpress.org/>

**第二步**：导入wordpress程序把下载下来的wordpress程序包解压，然后点击xampp界面上面的Explore按钮，如图：

![](/assets/2013-11-18-wordpress-5.png)

点击之后会弹出一个文件夹的窗口，找到名字为htdocs的文件夹，然后把我们解压好的wordpress文件夹复制粘贴到这个文件夹里面，OK大功告成，程序导入成功，这一步如果是在空间上面搭建的话需要用到一款软件，叫FTP，不过由于是在本地搭建，所以我就不再多做介绍了。

**第三步**：安装wordpress打开我们的浏览器，然后在网址栏里面输入[localhost:81/wordpress](localhost:81/wordpress),点击回车会跳转到wordpress的安装界面，这个时候我们什么都不用管，直接点击下面的创建配置按钮，接下来会跳转到数据库的配置页面，这个时候会叫你输一下数据：数据库名（就是我们刚才创建的那个，比如opensource），数据库用户名（用户名填写root，xampp搭建的所有的本地网站数据库用户名都是root），数据库密码：（密码为空，跟前面的一样所有的都是为空）然后其他的不要修改，保存默认就行，点击安装。

![](/assets/2013-11-18-wordpress-6.jpg)

出现如上界面后，然后点击登陆。恭喜你一个本地网站就搭建成功了 。

![](/assets/2013-11-18-wordpress-7.jpg)

后台管理程序如上所示，从现在起，尽情享受wordpress建站给你带来的前所未有的便捷吧！

同时，如果你和我一样对建站、LAMP/WAMP拥有浓厚的兴趣，欢迎和我一起研究讨论ghost！

**Ghost: Just a blogging platform.**

**Ghost is a platform dedicated to one thing: Publishing.** It's beautifully designed, completely customisable and completely Open Source. Ghost allows you to write and publish your own blog, giving you the tools to make it easy and even fun to do. It's simple, elegant, and designed so that you can spend less time messing with making your blog work - and more time blogging. 

The site: <https://ghost.org/>
