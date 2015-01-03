---
title: Github使用简易教程（二）
thread: 153
date: 2014-10-10 08:00:00
categories: Tutorial
tags: [Github]
layout: post
excerpt: 此篇教程继前一篇文章Github使用简易教程（一）继续记录有关Github的一些使用方法。
---

此篇教程继前一篇文章《[Github使用简易教程（一）](http://hijiangtao.github.io/2014/10/09/GithubUsageOne/)》继续记录有关Github的一些使用方法。

##四、分支合并

通过建立分支，可以创造独立的代码副本。Git在创建分支时只需要很少的资源即可完成任务，通过以下命令可以查看当前所有的本地分支：

<!--more-->

```
git branch
```

查看远端仓库的分支：

```
git branch -a
```

创建新的分支：

```
git branch testing
```

合并分支：

```
git merge testing
```

一旦合并发生了冲突，Git会标志出来，开发人员需要手工的去解决这些冲突。解决冲突以后，就可以将文件添加到索引中，然后提交更改。

删除分支：

```
git branch -d testing
```

如何推送一个分支到远端仓库？默认情况下，git只会推送匹配的分支的远端仓库。这意味着在使用git push指令前，你需要手工推送一次你的分支。

```
git push origin testing
git checkout testing
#some changes
echo "News" > test01
git commit -a -m "new feature in branch"
#push all including branch
git push
```

如果两个不同的开发人员对同一个文件进行了修改，那么合并冲突就会发生。而Git没有智能到自动解决合并两个修改。

下面产生一个合并冲突，先产生一个更改：

```
# Switch to the first directory
cd ~/repo01
# Make changes
touch mergeconflict.txt
echo "Change in the first repository" > mergeconflict.txt
# Stage and commit
git add . && git commit -a -m "Will create merge conflict 1"
```

然后在另一个repo中修改：

```
# Switch to the second directory
cd ~/repo02
# Make changes
touch mergeconflict.txt
echo "Change in the second repository" > mergeconflict.txt
# Stage and commit
git add . && git commit -a -m "Will create merge conflict 2"
# Push to the master repository
git push
```

现在回过来再push第一个分支：

```
# Switch to the first directory
cd ~/repo01
# Try to push --> you will get an error message
git push
# Get the changes
git pull origin master
```

Git将冲突放在受到影响的文件中，文件内容如下：

```
<<<<<<< HEAD
Change in the first repository
=======
Change in the second repository
>>>>>>> b29196692f5ebfd10d8a9ca1911c8b08127c85f8
```

上面部分是你的本地仓库，下面部分是远端仓库。现在编辑这个文件，然后commit更改。你也可以使用git mergetool命令：

```
# Either edit the file manually or use 
git mergetool
# You will be prompted to select which merge tool you want to use
# For example on Ubuntu you can use the tool "meld"
# After  merging the changes manually, commit them
git commit -m "merged changes"
```

##五、变基

在同一分支中应用Rebase Commit。通过rebase命令可以合并多个commit为一个。这样用户push更改到远端仓库的时候就可以先修改commit历史，如下例：

```
# Create a new file
touch rebase.txt
# Add it to git
git add . && git commit -m "rebase.txt added to index"
# Do some silly changes and commit
echo "content" >> rebase.txt
git add . && git commit -m "added content"
echo " more content" >> rebase.txt
git add . && git commit -m "added more content"
echo " more content" >> rebase.txt
git add . && git commit -m "added more content"
echo " more content" >> rebase.txt
git add . && git commit -m "added more content"
echo " more content" >> rebase.txt
git add . && git commit -m "added more content"
echo " more content" >> rebase.txt
git add . && git commit -m "added more content"
# Check the git log message
git log
```

然后通过如下的命令交互的完成：

```
git rebase -i HEAD~7
```

这个命令会打开编辑器让你修改commit的信息。

Rebasing多个分支:你也可以对两个分支进行rebase操作。如下所述，merge命令合并两个分支的更改。rebase命令为一个分支的更改生成一个补丁，然后应用这个补丁到另一分支中。

使用merge和rebase，最后的源代码是一样的，但是使用rebase产生的commit历史更加的少，而且历史记录看上去更加的线性。

```
# Create new branch 
git branch testing
# Checkout the branch
git checkout testing
# Make some changes
echo "This will be rebased to master" > test01
# Commit into testing branch
git commit -a -m "New feature in branch"
# Rebase the master
git rebase master
```

##六、放弃跟踪文件

有时候，你不希望某些文件或者文件夹被包含在Git仓库中。但是如果你把它们加到.gitignore文件中以后，Git会停止跟踪这个文件。但是它不会将这个文件从仓库中删除。这导致了文件或者文件夹的最后一个版本还是存在于仓库中。使用如下例子取消跟踪这些文件或文件夹：

```
# Remove directory .metadata from git repo
git rm -r --cached .metadata
# Remove file test.txt from repo
git rm --cached test.txt
```

##七、Git服务提供商

* Github <https://github.com/>
* Bitbucket <https://bitbucket.org/>