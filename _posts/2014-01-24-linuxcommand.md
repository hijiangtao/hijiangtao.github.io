---
date: 2014-01-24
layout: post
title: Linux命令使用小结
thread: 5
categories: Tutorial
tags: [linux]
excerpt: Linux Commands.
---

上一次开心的折腾Linux还是跟着学长在去年暑假的时候，最近事挺多的我竟然还花了两天又重新折腾了一次Linux，接下来不多的日子还是要好好看看书了所以就以今天为一个节点，对近日经常使用的Linux命令进行个总结，也便于自己以后使用时查看，省去了大部分去GOOGLE的时间。

* rm删除命令
    * 将 Finished 子目录及子目录中所有档案删除,并且不用一一确认：`rm -rf Finished`
    * 删除可能仍有数据的目录 (只限超级用户)：`rm -d Directory`
    * 删除过程中忽略不存在的文件，从不给出提示：`rm -f`

* mv移动/改名命令
    * 将文件test.log重命名为test1.txt:`mv test.log test1.txt`
    * 将test1.txt文件移到目录test3中:`mv test1.txt test3`
    * 将文件log1.txt,log2.txt,log3.txt移动到目录test3中:`mv log1.txt log2.txt log3.txt test3`
    * 将文件file1改名为file2，如果file2已经存在，则询问是否覆盖:`mv -i log1.txt log2.txt`
    * -b ：若需覆盖文件，则覆盖前先行备份。 
    * -f ：force 强制的意思，如果目标文件已经存在，不会询问而直接覆盖；
    * -i ：若目标文件 (destination) 已经存在时，就会询问是否覆盖！
    * -u ：若目标文件已经存在，且 source 比较新，才会更新(update).
    * -t ：即指定mv的目标目录，该选项适用于移动多个源文件到一个目录的情况，此时目标目录在前，源文件在后。

* cp复制命令
    * 将文档 file1复制成file2，复制后名称被改file2:`cp file1 file2`
    * 将文档 file1复制到dir1目录下，复制后名称仍为file1：`cp file1 dir1`
    * 将目录dir1复制到dir2目录下，复制结果目录被改名为dir2：`cp -r dir1 dir2`
    * 将目录dir1下所有文件包括文件夹，都复制到dir2目录下：``cp -r dir1/*.* dir2``
    * -a 保留链接和文件属性，递归拷贝目录，相当于下面的d、p、r三个选项组合。
    * -d 拷贝时保留链接。
    * -f 删除已经存在目标文件而不提示。
    * -i 覆盖目标文件前将给出确认提示，属交互式拷贝。
    * -p 复制源文件内容后，还将把其修改时间和访问权限也复制到新文件中。
    * -r 若源文件是一目录文件，此时cp将递归复制该目录下所有的子目录和文件。目标文件须为一个目录名。
    * -l 不作拷贝，只是链接文件。
    * -s 复制成符号连结文件 (symbolic link)，亦即『快捷方式』档案；
    * -u 若 destination 比 source 旧才更新 destination。

* 进入目录(Doc为文件位置)： `cd Doc`

* ls:列出目录下文件

    * `ls -a,-all` 列出目录下的所有文件，包括以 . 开头的隐含文件。
    * `-d, –directory` 将目录象文件一样显示，而不是显示其下的文件。
    * `-d, –directory` 将目录象文件一样显示，而不是显示其下的文件。
    * `-s, –size` 以块大小为单位列出所有文件的大小。
    * `-la` 显示所有文件。

* Jekyll的安装与使用(记住安装Jekyll前要先安装`Ruby1.9.1`和`Ruby1.9.1-dev`)

    ```
    ~$gem install jekyll     //使用gem 进行安装
    ~$jekyll new myblog     //新建
    ~$cd myblog              //切换目录
    ~/myblog$jekyll serve  //启动服务
    # => Now browse to http://localhost:4000
    ```

* Jekyll基本用法： `$jekyll build`(当前文件夹会被生成到./_site)

* 找到占用某个端口的程序pid： `netstat -tulpn | grep 3000`

* 杀死被占用的pid(我还不知道-9是什么意思，可能是执行优先级)： `kill -9 1877`

* 一款软件的安装(以GIT为例)： `sudo apt-get install git` 

* 确认Github用户名与邮箱：

    ```
    git config --global user.name "Your Name Here"
    git config --global user.email "Your_email@example.com"
    ```

* 操作：将代码托管到Github(其中，操作中若路径是.表示上传全部目录下的文件，可以是某个文件)

    ```
    git init
    git add .
    git commit -m ""
    git push origin master
    ```

* _config.yml配置默认值

	```
	safe:        false
	auto:        false
	server:      false
	server_port: 4000
	baseurl:    /

	source:      .
	destination: ./_site
	plugins:     ./_plugins

	future:      true
	lsi:         false
	pygments:    false
	markdown:    maruku
	permalink:   date

	maruku:
	  use_tex:    false
	  use_divs:   false
	  png_engine: blahtex
	  png_dir:    images/latex
	  png_url:    /images/latex

	rdiscount:
	  extensions: []

	kramdown:
	  auto_ids: true,
	  footnote_nr: 1
	  entity_output: as_char
	  toc_levels: 1..6
	  use_coderay: false
	  
	  coderay:
	    coderay_wrap: div
	    coderay_line_numbers: inline
	    coderay_line_numbers_start: 1
	    coderay_tab_width: 4
	    coderay_bold_every: 10
	    coderay_css: style
	```

* _config.yml文件设置汇总

<div class=''><table cellspacing="0" cols="4" width='100%'>
<tbody>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="17" align="CENTER"><b><font face="Times New Roman">设定</font></b></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><b><font face="Times New Roman">配置文件</font></b></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><b><font face="Times New Roman">命令行参数</font></b></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><b><font face="Times New Roman">简述</font></b></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="47" align="CENTER"><font face="Times New Roman">重新生成</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">auto: [boolean]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--no-auto --auto</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">允许或禁止Jekyll在文件被修改后重新生成整个站点</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="47" align="CENTER"><font face="Times New Roman">本地服务器</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">server: [boolean]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--server</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">自动开启一个用于托管_site目录的本地Web服务器</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="32" align="CENTER"><font face="Times New Roman">本地服务器端口</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">server_port: [integer]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--server [port]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">更改Jekyll所使用的服务器端口</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="32" align="CENTER"><font face="Times New Roman">Base&nbsp;URL</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">baseurl: [BASE_URL]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--base-url [url]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">使用指定的Base URL在服务器上运行站点</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="32" align="CENTER"><font face="Times New Roman">站点目的路径</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">destination: [dir]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">jekyll [dest]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">更改Jekyll存放生成文件的路径</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="32" align="CENTER"><font face="Times New Roman">站点源路径</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">source: [dir]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">jekyll [source] [dest]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">更改Jekyll所处理文件的路径</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="47" align="CENTER"><font face="Times New Roman">Markdown</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">markdown: [engine]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--rdiscount&nbsp;or&nbsp;--kramdown</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">使用RDiscount或[engine]以取代Maruku</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="32" align="CENTER"><font face="Times New Roman">Pygments</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">pygments: [boolean]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--pygments</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">允许Pygments处理代码语法高亮</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="17" align="CENTER"><font face="Times New Roman">LSI</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">lsi: [boolean]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--lsi</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">产生相关帖子的索引</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="32" align="CENTER"><font face="Times New Roman">固定链接</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">permalink: [style]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--permalink=[style]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">控制生成帖子的URL</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="62" align="CENTER"><font face="Times New Roman">分页</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">paginate: [per_page]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">--paginate [per_page]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">将你的帖子分成多个子目录："page2"、"page3"、……"pageN"</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="32" align="CENTER"><font face="Times New Roman">排除</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">exclude: [dir1, file1, dir2]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman"><br></font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">不需要进行转换的目录和文件列表</font></td>
</tr>

<tr>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" height="47" align="CENTER"><font face="Times New Roman">帖子限制</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">limit_posts: [max_posts]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman"> --limit_posts=[max_posts]</font></td>
<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000" align="CENTER"><font face="Times New Roman">限制被转换与发布的帖子数量</font></td>
</tr>

</tbody>

</table></div>
