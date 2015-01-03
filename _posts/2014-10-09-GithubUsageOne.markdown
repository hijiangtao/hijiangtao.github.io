---
title: Github使用简易教程（一）
thread: 152
date: 2014-10-09 08:00:00
categories: Tutorial
tags: [Github]
layout: post
excerpt: 仓库（Repository）：一个仓库包括了所有的版本信息、所有的分支和标记信息……
---

##一、术语介绍

<!--more-->

* 仓库（Repository）：一个仓库包括了所有的版本信息、所有的分支和标记信息。在Git中仓库的每份拷贝都是完整的。仓库让你可以从中取得你的工作副本。
* 分支（Branches）：一个分支意味着一个独立的、拥有自己历史信息的代码线（code line）。你可以从已有的代码中生成一个新的分支，这个分支与剩余的分支完全独立。默认的分支往往是叫master。用户可以选择一个分支，选择一个分支叫做checkout。
* 标记（Tags）：一个标记指的是某个分支某个特定时间点的状态。通过标记，可以很方便的切换到标记时的状态，例如2009年1月25号在testing分支上的代码状态。
* 提交（Commit）：提交代码后，仓库会创建一个新的版本。这个版本可以在后续被重新获得。每次提交都包括作者和提交者，作者和提交者可以是不同的人。
* URL：URL用来标识一个仓库的位置。
* 修订（Revision）：用来表示代码的一个版本状态。Git通过用SHA1 hash算法表示的id来标识不同的版本。每一个SHA1 id都是160位长,16进制标识的字符串.最新的版本可以通过HEAD来获取.之前的版本可以通过”HEAD~1”来获取，以此类推。

##二、设置

Ubuntu下的Git安装指令：

```
sudo apt-get install git-core
```

Msysgit项目提供了Windows版本的Git，地址是<http://code.google.com/p/msysgit/>.

Git有一个工具被称为git config，它允许你获得和设置配置变量；这些变量可以控制Git的外观和操作的各个方面，具体可以通过.gitconfig文件实现。

通过设置name和email让计算机知道你的姓名和邮件地址。

```
$ git config --global user.name "Your Name"
$ git config --global user.email "your_email@whatever.com"
```

获取Git配置信息：

```
git config --list
```

以下命令会为中端配置高亮：

```
git config --global color.status auto
git config --global color.branch auto
```

可以配置Git忽略特定的文件或者是文件夹。这些配置都放在.gitignore文件中。例如，为了让Git忽略bin文件夹，在主目录下放置.gitignore文件，其中内容为bin。

如果想查看更改，可以使用`git diff`命令，然后通过`git commit -a -m "Commit Reason"`实现提交。

通过git amend命令，我们可以修改最后提交的的信息。

```
git commit --amend -m "More changes - now correct"
```

如果需要删除一个在版本控制之下的文件，那么使用`git add .`将不起作用，如下操作：

```
# Create a file and put it under version control
touch nonsense.txt
git add . && git commit -m "a new file has been created"
# Remove the file
rm nonsense.txt
# Try standard way of committing -> will not work
git add . && git commit -m "a new file has been created"
# Now commit with the -a flag
git commit -a -m "File nonsense.txt is now removed"
# Alternatively you could add deleted files to the staging index via
git add -A . 
git commit -m "File nonsense.txt is now removed"
```

##三、远端仓库

###3.1 设置远端git仓库

远端Git仓库和标准的Git仓库有如下差别：一个标准的Git仓库包括了源代码和历史信息记录。我们可以直接在这个基础上修改代码，因为它已经包含了一个工作副本。但是远端仓库没有包括工作副本，只包括了历史信息。

```
# Switch to the first repository
cd ~/repo01
# 
git clone --bare . ../remote-repository.git
# Check the content, it is identical to the .git directory in repo01
ls ~/remote-repository.git
```

###3.2 推送

做一些更改，推送到其他仓库。

```
# Switch to the repository
cd ~/repo01
# Make some changes to your repo
echo "Hello, hello. Turn your radio on" > test01
echo "Bye, bye. Turn your radio off" > test02
#
git commit -a -m "Some changes"
# Push it to other repo
git push ../remote-repository.git
```

###3.3 添加远端仓库

除了通过完整的URL来访问Git仓库外，还可以通过git remote add命令为仓库添加一个短名称。当你克隆了一个仓库以后，origin表示所克隆的原始仓库。即使我们从零开始，这个名称也存在。

```
# Add ../remote-repository.git with the name origin
git remote add origin ../remote-repository.git 
# Again some changes
echo "I added a remote repo" > test02
# Commit
git commit -a -m "This is a test for the new remote origin"
# If you do not label a repository it will push to origin
git push origin
```

另外可以通过`git remote`指令来显示已有的远端仓库。

###3.4 克隆与拉取(Pull)仓库

进入仓库路径，然后克隆代码：

```
mkdir repo01
cd repo01
git clone ../remote-repository.git .
```

通过拉取，可以从其他的仓库中获取带项目代码最新的更改。简单说，在B仓库中，做一些更改，然后将更改推送到远端的仓库中。然后A仓库拉取这些更改对自己进行代码更新。

```
# Switch to the first repository and pull in the changes
cd ~/repo01
git pull ../remote-repository.git/
# Check the changes
less test01
```

###3.5 还原更改

如果你已经创建了不想被提交的更改文件后，可以通过以下命令完成还原操作。

```
# Make a dry-run to see what would happen
# -n is the same as --dry-run 
git clean -n
# Now delete
git clean -f
```

如果你还未把更改加入到索引中，你也可以直接还原所有的更改。

```
#Some nonsense change
echo "nonsense change" > test01
# Not added to the staging index. Therefore we can 
# just checkout the old version
git checkout test01
# Check the result
cat test01
```

另一种还原更改：

```
# Another nonsense change
echo "another nonsense change" > test01
# We add the file to the staging index
git add test01
# Restore the file in the staging index
git reset HEAD test01
# Get the old version from the staging index
git checkout test01
```

而如果删除了一个未添加到索引和提交的文件，你也可以还原。

```
rm test01
git checkout test01
```

如果你已经添加一个文件到索引中，但是未提交。可以通过`git resetfile` 命令将这个文件从索引中删除。

```
// Create a file
touch incorrect.txt
// Accidently add it to the index
git add .
// Remove it from the index
git reset incorrect.txt
// Delete the file
rm incorrect.txt
```

###3.6 标记

Git可以使用对历史记录中的任一版本进行标记。这样在后续的版本中就能轻松的找到。一般来说，被用来标记某个发行的版本。可以通过git tag命令列出所有的标记，通过如下命令来创建一个标记和恢复到一个标记。

```
git tag version1.6 -m 'version 1.6'      
git checkout <tag_name>
```