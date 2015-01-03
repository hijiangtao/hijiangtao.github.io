---
date: 2014-01-23
layout: post
title: 新手该如何使用git命令同步自己本地代码到github
thread: 4
categories: Documents
tags: [github]
excerpe: Github.
---

昨天的问题本以为已经解决，今天刷着微博正准备看书时，发现老毛病又翻了，当输完`git push -u origin master`后，显示出来的又是如下语句，于是弱弱的我又打开google，准备解决这个问题。

```javascript
 ! [rejected]        master -> master (non-fast-forward)
error: 无法推送一些引用到 'https://github.com/hijiangtao/hijiangtao.github.io.git'
提示：更新被拒绝，因为您当前分支的最新提交落后于其对应的远程分支。
提示：再次推送前，先与远程变更合并（如 'git pull'）。详见
提示：'git push --help' 中的 'Note about fast-forwards' 小节。
```

再来重述一下我的问题所在：我已经建立了一个repository名为`hijiangtao.github.io`，现在我又写了一篇日志想提交到github上。简述为：github本地子模块更改后，update整个项目失败。

1. 首先依旧是`git init//初始化，会出现一个.get文件,可以通过ls -la查看`。

2. 添加本地已有文件到本地仓库：`git add _posts/2014-01-23-hello.md`,其中2014-01-23-hello.md是我测试用的文件。

3. 添加更新commit：`git commit  -m  "说明标签"`

4. `git remote add origin https://github.com/用户名/库.git`,经过搜索发现其实origin相当于是个别名，这个可以自己随便写也可以写成当前文件夹的名。

5. 直到上一布过程都进行的正常，现在开始push操作：`git push -u origin master`,期间会会提示输入用户名和密码。而输入完之后会出现以下错误：

	```javascript
    To https://github.com/hijiangtao/hijiangtao.github.io.git
     ! [rejected]        master -> master (non-fast-forward)
    error: 无法推送一些引用到 'https://github.com/hijiangtao/hijiangtao.github.io.git'
    提示：更新被拒绝，因为您当前分支的最新提交落后于其对应的远程分支。
    提示：再次推送前，先与远程变更合并（如 'git pull'）。详见
    提示：'git push --help' 中的 'Note about fast-forwards' 小节。
	```

接下来就是解决办法了。

* 输入如下语句：

	```javascript
    git config branch.master.remote origin
    git config branch.master.merge refs/heads/master
    git pull/*这时会出现一个配置文件，保存然后把他关了即可。*/
	```

* 输入如下语句：

	```javascript
    git add _posts/2014-01-23-hello.md
    git commit -m "second push"
	```

* 输入完你会发现出现如下信息，这说明你到现在都运行正常：

	```javascript
    # 位于分支 master
    # 您的分支领先 'origin/master' 共 2 个提交。
    #   (use "git push" to publish your local commits)
    #
    nothing to commit, working directory clean
	```

* 最后执行`git push -u origin master`，等待更新完毕，同步代码成功啦！

----

最后，附上github官方自带的两个方法：

* Create a new repository on the command line

	```javascript
    touch README.md
    git init
    git add README.md
    git commit -m "first commit"
    git remote add origin https://github.com/用户名/项目.git
    git push -u origin master
	```

* Push an existing repository from the command line

	```javascript
    git remote add origin https://github.com/用户名/项目.git
    git push -u origin master
	```