---
date: 2014-02-13
layout: post
title: 因修改/etc/sudoers权限导致sudo和su无法使用的解决方法
thread: 27
categories: Tutorial
tags: [ubuntu]
---

**系统环境**：Linux ubuntu-13.04-desktop-i386

###解决方案

在hadoop环境配置过程中由于增加了一个用户组，对sudoers进行了修改，导致之后的sudo或者su的任何命令都无法执行，均显示如下错误：

```
    ~$ sudo
    sudo： >>> /etc/sudoers：syntax error 在行 21 附近<<<
    sudo： /etc/sudoers 中第 21 行附近有解析错误
    sudo： 没有找到有效的 sudoers 资源，退出
    sudo： 无法初始化策略插件
```

如下为权限修复的解决方案：

1. 重启ubuntu，启动时按Esc或Shift键，可以看到引导选项；

2. 在引导选项中选择ubuntu advanced进入Recovery模式的那一项来引导；

3. 进入Recovery Menu页面，选择`root`，也就是进入试用root用户进行系统恢复，在这里可以执行超级用户的权限的操作，首先第一步需要你输入自己的系统设置密码，然后回车便可以看到`root@user ~# `命令提示符；

4. 设置或者撤销`/etc/sudoers`文件的权限，也可以将该文件改回到发生错误之前的状态。

```
    chmod 666 /dev/null
    mount -o remount rw /
    vi /etc/sudoers 
    //恢复修改前本文件内容并保存
```

注：如果出现在VIM中编辑后无法保存所编辑内容时，即：`E45: 'readonly' option is set (add ! to override)`，解决方法为：将“:w”换为“:wq!”

最后，退出Recovery模式，重新启动ubuntu即可。

当然从网上搜索到的解决方法来看，你也可以用ubuntu光盘引导系统，然后mount相应的磁盘，然后修改/etc/sudoers文件，进入系统，就可以正常启动了。以下附上该解决方案代码：

```javascript
# /etc/sudoers 
# 
# This file MUST be edited with the 'visudo' command as root. 
# 
# See the man page for details on how to write a sudoers file. 
# 
 
Defaults env_reset 
 
# Host alias specification 
 
# User alias specification 
 
# Cmnd alias specification 
 
# User privilege specification 
root ALL=(ALL) ALL 
 
# Allow members of group sudo to execute any command after they have 
# provided their password 
# (Note that later entries override this, so you might need to move 
# it further down) 
%sudo ALL=(ALL) ALL 
# 
#includedir /etc/sudoers.d 
 
# Members of the admin group may gain root privileges 
%admin ALL=(ALL) ALL
```