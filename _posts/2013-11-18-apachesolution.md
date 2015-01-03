---
date: 2013-11-18
layout: post
title: 有关apache+mysql+php开发环境安装配置时Apache无法启动的问题
thread: 16
categories: Tutorial
tags: [apache]
excerpt: Resolution of Apache Unable Start Problem.
---

这几天一直在搭建APACHE+MYSQL+PHP环境，各种错误层出不穷啊。理论上，在安装程序结束之后，在浏览器地址栏里输入<http://localhost/>，只要能运行就说明Apache安装成功，具体怎么样安装和配置PHP这里就不多说了。

接下来我主要说说安装PHP的时候出现的错误：

>Requested operation has failed！

按照网上找到的教程步骤一步一步配置好PHP，然后打开Apache Service Monitor，点击start，弹出错误:

>Requested operation has failed

说明Apache没有成功启动。接下来，请按照以下步骤来解决这个问题：

`cmd`进入D:\apache\bin目录，输入`httpd -t`，提示：

>httpd: Syntax error on line 175 of D:/apache/conf/httpd.conf: Can’t locate API module structure `php4_module’ in file D:/php/php5apache2_2.dll: No error

从上述信息中我们可以看出错误出在httpd.conf中175行的代码`LoadModele php4_module D:\php\php5apache2_2.dll`，其中说明我模块选择错了。由于apache版本的不同，在配置`LoadModule php4_module D:\php\php5apache2_2.dll`这段代码的时候一定要特别注意。

然后改成`LoadModele php5_module D:\php\php5apache2_2.dll`，再运行`httpd -t`，提示： 

>[Fri Nov 16 20:30:31 2013] [crit] Apache is running a threaded MPM, but your PHP Module is not compiled to be threadsafe.  You need to recompile PHP.
Pre-configuration failed 

意思就是说我下载的php不能进行编译，其实当时在下载的时候看到好多版本就非常犹豫，而想起我下载的时候选择的是“Non Thread Safe”版本，于是就又去php官网选择“Thread Safe”下载。

重新配置，运行`httpd -t`，提示：

>Syntax OK

再打开Apache Service Monitor，点击start，总算成功启动了。

附：**“Non Thread Safe”和“Thread Safe”的区别**

“Non Thread Safe”和“Thread Safe”从字面意思上理解，Thread Safe 是线程安全，执行时会进行线程（Thread）安全检查，以防止有新要求就启动新线程的 CGI 执行方式而耗尽系统资源。Non Thread Safe 是非线程安全，在执行时不进行线程（Thread）安全检查。

PHP 的两种执行方式：ISAPI 和 FastCGI。

ISAPI 执行方式是以 DLL 动态库的形式使用，可以在被用户请求后执行，在处理完一个用户请求后不会马上消失，所以需要进行线程安全检查，这样来提高程序的执行效率，所以如果是以 ISAPI 来执行 PHP，建议选择 Thread Safe 版本；

而 FastCGI 执行方式是以单一线程来执行操作，所以不需要进行线程的安全检查，除去线程安全检查的防护反而可以提高执行效率，所以，如果是以 FastCGI 来执行 PHP，建议选择 Non Thread Safe 版本。

官方并不建议你将Non Thread Safe 应用于生产环境，所以我们也选择Thread Safe 版本的PHP来使用。
