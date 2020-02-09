---
title: Code Review 时能用上的一些 Git 操作
layout: post
thread: 236
date: 2020-01-12
author: Joe Jiang
categories: Document
tags: [Git, CR, Shell]
excerpt: 本文从只会 add/commit/push 三连的新手出发，看看 Code Review 时遇到的一些 Git 问题都要如何处理。
header:
  image: ../assets/in-post/2020-01-12-Tips-of-Git-for-Code-Review-Teaser.png
---

往日干活，都是自己代码一时爽，后人维护XXX。如果可以的话，还是要坚持 Code Review (CR)，不仅团队内熟悉代码风格，更能在学习他人优秀的代码风格的同时补足自己的短板。

但是第一次 CR 时，如果你不是一个 git 高手，肯定会有那么一些手足无措，比如提交代码如何增量更新、混乱分支后如何撤销变更等等，本文从只会 add/commit/push 三连的新手出发，看看 Code Review 时遇到的一些 Git 问题都要如何处理。

首先是配置了 git 密钥，以及自己的用户名和邮箱，过于基础直接略过。

    ssh-keygen // 生成 SSH Key
    
    // ...
    
    git config user.name "hijiangtao" // 配置用户名
    git config user.email "hijiangtao@gmail.com" // 配置用户邮箱

当我完成代码的增删改，一次再正常不过的提交，所需要用到的 git 命令也就这些：

    git add -A
    git commit -m "MOD: Some changes"
    git push origin dev

如果在处理 Code Review 过程中你使用的是类似 gerrit 的工具，那么你的 push 可能会需要稍作更改，比如在你的 `.git/config` 中自定义一个 push 到类似 `HEAD:refs/for/dev` 的命令，当然我们按照 GitHub 的标准流程往下走。

## 问题一：你本次提交的代码需要更改

你的 commit 被打回了，那你需要修改后继续 CR，如果你当前需要更改的 commit 就是本地最新 commit，那么如下代码即可

    git add -A
    git commit --amend

输入第二行命令后，你会进入一个文本编辑器界面，里面有你的 commit 信息，修改后保存退出即可，然后

    git push origin dev

其实，以上 `git commit --amend` 的意思是告诉 git 在不增加一个新的 commit-id 的情况下将修改内容追加到上一次 commit-id 中。

## 问题二：很早之前的 commit 需要更改

当你已经迭代到N.0版本时，发现1.0上的代码需要修改怎么办？这时你的需求变成了修改最近一次提交以前的某次提交，这也是可以做的，不过当操作完成后，你的这次修改提交到最新提交之间的所有提交 hash 值都会改变。

这种操作在 git 中称为[变基](https://git-scm.com/book/zh/v2/Git-分支-变基)。你要小心操作变基，多用 `git status` 检查你是否还处于变基流程中，防止误操作会后续提交历史造成影响。

首先查看提交日志：

    git log

找到你要修改的那次 commit，复制好它的前一次 commit hash 值以便确定修改范围。然后我们使用 rebase 操作：

    git rebase -i [Commit-range]

以上 `[Commit-range]` 可以是具体的 commit hash 值，也可以是类似 `commit~n` 或者 `commit^^` 这样的形式，前者表示当前提交到 n 次以前的提交，后者 `^` 符号越多表示的范围越大。命令中的 `-i` 参数表示进入交互模式。在输入命令后，你会进入一个文本编辑器，这时把你需要更改的 commit 中 开头的 `pick` 改为 `edit`，然后保存退出。

其中，变基命令打开的文本编辑器中的commit顺序跟 `git log` 看到的顺序相反的；另外，变基命令也可以同时对多个 commit 进行修改，只需要修改将对应行前的`pick`都修改为`edit`，后续操作完 commit 多次即可，但是祖先 commit 是不能修改的，即你一共存在10次 commit，那么只能修改最近9次（重排、删除以及合并都适用此规则）。

更改完代码后利用如下命令提交代码，进入文本编辑器的时候修改对应 commit 信息即可：

    git add -A
    git commit --amend

确认修改完毕，即完成变基操作，这时候输入下面一行：

    git rebase --continue

然后查看下日志，对比确认下变基前后的修改信息：

    git log

这里，刚刚提到的 pick 变为 edit，还存在一些其他变数。

- 如果你想重新重新排序 commit 历史或者删除一些误操作，比如将不希望公开的信息提交了，那么还是 `git rebase -i [Commit-range]` 命令，进入文本框内进行操作；
- 如果你认为有些提交历史过于啰嗦，需要合并，这个时候 rebase 进入文本编辑器时，将需要合并的 commit 前 pick 改为 squash 即可保存退出。这个操作会将标记为 squash 的所有提交，都合并到最近的一个祖先提交上。

## 问题三：提交了错误的代码

当你对以上命令还不熟的时候，你可能在操作中会混用 `git commit --amend` 和 `git rebase --continue` ；那么当你发现把代码提交到了错误 commit 下，该怎么撤销呢？这个相对好办：

    git revert [Commit-ID]

以上命令会补上一个提交将代码恢复到你上一次提交之前的状态，但注意这并不是抹去该 commit。

又或者你在 `git rebase --continue` 代码时发现了冲突，这个时候请按照如下步骤操作：

- 首先，解决本地代码的冲突；
- 然后，`git add -A` 提交变更；
- 最后，记得不是 `git commit --amend` 而是 `git rebase --continue` ，防止错误提交代码；
- 如果你没有按照第三步操作，那么就乖乖 revert 好了；

## 问题四：挑选合入其他分支的提交

比如我在 dev 分支提交了一个 commit A，这个时候我想起来 dev_2 分支也需要这个提交，那么我如何只“挑选” dev 分支的 A 到 dev_2 合入，而保持其他不变呢？此时， `cherry-pick` 登场。`cherry-pick` 可以理解为”挑拣”提交，它会获取某一个分支的单笔提交，并作为一个新的提交引入到你当前分支上。

    git checkout dev
    git log --oneline -3
    
    // A [Description]:dev commit 3
    // B [Description]:dev commit 2
    // C [Description]:dev commit 1
    
    git checkout dev_2
    git cherry-pick A
    git log --oneline -3
    
    // A [Description]:dev commit 3
    // ...

当然，如果 cherry-pick 遇到冲突，手动解决完 `git commit` 一次即可。

## 问题五：合并代码无法提交

当我们使用一些代码评审工具比如 Gerrit 时，在合并已审阅过的代码到特定分支时，可能会遇到无法提交的情况。失败时，命令行提示：

> ! [remote rejected] HEAD -> refs/for/*** (no new changes)

正常情况下我们合并代码只需要 `git merge branchA` 即可，但由此产生的合并，是个线性的合并。由于历史上的 commit 节点已经在 Gerrit 上都评审过了，所以此时 Gerrit 会认为没有新的提交。

这个问题非常好解，即给你的合并命令提交一个参数即可。在 `git merge branchA` 的时候，加上 `--no-ff` 参数，使其生成一个新的 commit 节点，这样便可以提交了。

## 问题零：远程 URL 变更

当然，还有一个小问题值得一提，你可能在克隆项目时用的是 HTTPS 方式，但却觉得每次输入用户名密码麻烦，最好的办法是将远程 URL 设置成 SSH 地址，这时就可以用到一个简单的命令解决问题：

    git remote set-url origin git@github.com:USERNAME/REPOSITORY.git

设置完成后，检查一下 remotes 是否更新生效即可。

    git remote -v
    
    // > origin  git@github.com:USERNAME/REPOSITORY.git (fetch)
    // > origin  git@github.com:USERNAME/REPOSITORY.git (push)

由于以上多个问题中涉及到的修改会直接对特定版本历史进行修改，在需要推送到远程仓库时，存在不成功的情况，所以你可以强行 push。但在多人协作的仓库中，你的修改会对其他人的远程操作也构成影响，故三思而后行。