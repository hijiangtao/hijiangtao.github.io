---
date: 2014-02-26
layout: post
title: Hadoop常用命令
thread: 52
categories: Tutorial
tags: [hadoop]
excerpt: 每次操作临时去查命令感觉挺烦的，于是就把常用命令搜齐一次性整理好，以下为Hadoop使用过程中经常会用到的命令汇总。
---

每次操作临时去查命令感觉挺烦的，于是就把常用命令搜齐一次性整理好，以下为Hadoop使用过程中经常会用到的命令汇总。

----

1、列出所有Hadoop Shell支持的命令

```
$ bin/hadoop fs -help
```

2、显示关于某个命令的详细信息

```
$ bin/hadoop fs -help command-name
```

3、用户可使用以下命令在指定路径下查看历史日志汇总

```
$ bin/hadoop job -history output-dir
```

这条命令会显示作业的细节信息，失败和终止的任务细节。

4、关于作业的更多细节，比如成功的任务，以及对每个任务的所做的尝试次数等可以用下面的命令查看

```
$ bin/hadoop job -history all output-dir
```

5、格式化一个新的分布式文件系统

```
$ bin/hadoop namenode -format
```

6、在分配的NameNode上，运行下面的命令启动HDFS

```
$ bin/start-dfs.sh
```

bin/start-dfs.sh脚本会参照NameNode上\${HADOOP_CONF_DIR}/slaves文件的内容，在所有列出的slave上启动DataNode守护进程。

7、在分配的JobTracker上，运行下面的命令启动Map/Reduce

```
$ bin/start-mapred.sh
```

bin/start-mapred.sh脚本会参照JobTracker上\${HADOOP_CONF_DIR}/slaves文件的内容，在所有列出的slave上启动TaskTracker守护进程。

8、在分配的NameNode上，执行下面的命令停止HDFS

```
$ bin/stop-dfs.sh
```

bin/stop-dfs.sh脚本会参照NameNode上\${HADOOP_CONF_DIR}/slaves文件的内容，在所有列出的slave上停止DataNode守护进程。

9、在分配的JobTracker上，运行下面的命令停止Map/Reduce：

```
$ bin/stop-mapred.sh
```

bin/stop-mapred.sh脚本会参照JobTracker上\${HADOOP_CONF_DIR}/slaves文件的内容，在所有列出的slave上停止TaskTracker守护进程。

10、创建一个名为 /foodir 的目录

```
$ bin/hadoop dfs -mkdir /foodir
```

11、查看名为 /foodir/myfile.txt 的文件内容

```
$ bin/hadoop dfs -cat /foodir/myfile.txt
```

12、将集群置于安全模式

```
$ bin/hadoop dfsadmin -safemode enter
```

13、显示Datanode列表

```
$ bin/hadoop dfsadmin -report
```

14、使Datanode节点 datanodename退役

```
$ bin/hadoop dfsadmin -decommission datanodename
```

15、`bin/hadoop dfsadmin -help` 命令能列出所有当前支持的命令。比如：

* -report：报告HDFS的基本统计信息。有些信息也可以在NameNode Web服务首页看到。
* -safemode：虽然通常并不需要，但是管理员的确可以手动让NameNode进入或离开安全模式。
* -finalizeUpgrade：删除上一次升级时制作的集群备份。

16、显式地将HDFS置于安全模式

```
$ bin/hadoop dfsadmin -safemode
```

17、在升级之前，管理员需要用（升级终结操作）命令删除存在的备份文件

```
$ bin/hadoop dfsadmin -finalizeUpgrade
```

18、能够知道是否需要对一个集群执行升级终结操作

```
$ dfsadmin -upgradeProgress status
```

19、使用-upgrade选项运行新的版本

```
$ bin/start-dfs.sh -upgrade
```

20、如果需要退回到老版本,就必须停止集群并且部署老版本的Hadoop，用回滚选项启动集群

```
$ bin/start-dfs.h -rollback
```

21、下面的新命令或新选项是用于支持配额的。 前两个是管理员命令。

* `dfsadmin -setquota<N><directory>...<directory>`
把每个目录配额设为N。这个命令会在每个目录上尝试， 如果N不是一个正的长整型数，目录不存在或是文件名， 或者目录超过配额，则会产生错误报告。
* `dfsadmin -clrquota<directory>...<director>`
为每个目录删除配额。这个命令会在每个目录上尝试，如果目录不存在或者是文件，则会产生错误报告。如果目录原来没有设置配额不会报错。
* `fs -count -q <directory>...<directory>`
使用-q选项，会报告每个目录设置的配额，以及剩余配额。 如果目录没有设置配额，会报告none和inf。

22、创建一个hadoop档案文件

```
$ hadoop archive -archiveName NAME <src>* <dest>
/*-archiveName NAME 要创建的档案的名字。
src 文件系统的路径名，和通常含正则表达的一样。
dest 保存档案文件的目标目录。*/
```

23、递归地拷贝文件或目录

```
$ hadoopdistcp<srcurl><desturl>
/*srcurl 源Url
desturl 目标Url*/
```

24、运行HDFS文件系统检查工具(fsck tools)

用法：`hadoop fsck [GENERIC_OPTIONS] <path> [-move | -delete | -openforwrite] [-files [-blocks [-locations | -racks]]]`

命令选项 描述

`<path>` 检查的起始目录。

`-move` 移动受损文件到`/lost+found`。

`-delete` 删除受损文件。

`-openforwrite` 打印出写打开的文件。

`-files` 打印出正被检查的文件。

`-blocks` 打印出块信息报告。

`-locations` 打印出每个块的位置信息。

`-racks` 打印出data-node的网络拓扑结构。

25、用于和Map Reduce作业交互和命令(jar)

用法：`hadoop job [GENERIC_OPTIONS] [-submit <job-file>] | [-status <job-id>] | [-counter <job-id><group-name><counter-name>] | [-kill <job-id>] | [-events <job-id><from-event-#><#-of-events>] | [-history [all] <jobOutputDir>] | [-list [all]] | [-kill-task <task-id>] | [-fail-task <task-id>]`

命令选项 描述

`-submit <job-file>` 提交作业。

`-status <job-id>` 打印map和reduce完成百分比和所有计数器。

`-counter <job-id><group-name><counter-name>` 打印计数器的值。

`-kill <job-id>` 杀死指定作业。

`-events <job-id><from-event-#><#-of-events>` 打印给定范围内jobtracker接收到的事件细节。

`-history [all] <jobOutputDir> -history <jobOutputDir>` 打印作业的细节、失败及被杀死原因的细节。更多的关于一个作业的细节比如成功的任务，做过的任务尝试等信息可以通过指定[all]选项查看。

`-list [all] -list all` 显示所有作业。-list只显示将要完成的作业。

`-kill-task <task-id>` 杀死任务。被杀死的任务不会不利于失败尝试。

`-fail-task <task-id>` 使任务失败。被失败的任务会对失败尝试不利。

26、运行pipes作业

用法：`hadoop pipes [-conf<path>] [-jobconf<key=value>, <key=value>, ...] [-input <path>] [-output <path>] [-jar <jar file>] [-inputformat<class>] [-map <class>] [-partitioner<class>] [-reduce <class>] [-writer <class>] [-program <executable>] [-reduces <num>]`

命令选项 描述

`-conf<path>` 作业的配置

`-jobconf<key=value>, <key=value>, ...` 增加/覆盖作业的配置项

`-input <path>` 输入目录

`-output <path>` 输出目录

`-jar <jar file>` Jar文件名

`-inputformat<class>` InputFormat类

`-map <class>` Java Map类

`-partitioner<class>` Java Partitioner

`-reduce <class>` Java Reduce类

`-writer <class>` Java RecordWriter

`-program <executable>` 可执行程序的URI

`-reduces <num>` reduce个数

27、打印版本信息。

用法：`hadoop version`

28、hadoop脚本可用于调调用任何类。

用法：`hadoop CLASSNAME`，运行名字为CLASSNAME的类。

29、运行集群平衡工具。管理员可以简单的按Ctrl-C来停止平衡过程(balancer)

用法：`hadoop balancer [-threshold <threshold>]`

命令选项 描述

`-threshold <threshold>` 磁盘容量的百分比。这会覆盖缺省的阀值。

30、获取或设置每个守护进程的日志级别(daemonlog)。

用法：`hadoopdaemonlog -getlevel<host:port><name>`

用法：`hadoopdaemonlog -setlevel<host:port><name><level>`

命令选项 描述

`-getlevel<host:port><name>` 打印运行在<host:port>的守护进程的日志级别。这个命令内部会连接`http://<host:port>/logLevel?log=<name>`

`-setlevel<host:port><name><level>` 设置运行在<host:port>的守护进程的日志级别。这个命令内部会连接`http://<host:port>/logLevel?log=<name>`

31、运行一个HDFS的datanode。

用法：`hadoopdatanode [-rollback]`

命令选项 描述

-rollback 将datanode回滚到前一个版本。这需要在停止datanode，分发老的hadoop版本之后使用。

32、运行一个HDFS的dfsadmin客户端。

用法：`hadoop dfsadmin [GENERIC_OPTIONS] [-report] [-safemode enter | leave | get | wait] [-refreshNodes] [-finalizeUpgrade] [-upgradeProgress status | details | force] [-metasave filename] [-setQuota<quota><dirname>...<dirname>] [-clrQuota<dirname>...<dirname>] [-help [cmd]]`

命令选项 描述

`-report` 报告文件系统的基本信息和统计信息。

`-safemode enter | leave | get | wait` 安全模式维护命令。安全模式是Namenode的一个状态，这种状态下，Namenode不接受对名字空间的更改(只读)；不复制或删除块。Namenode会在启动时自动进入安全模式，当配置的块最小百分比数满足最小的副本数条件时，会自动离开安全模式。安全模式可以手动进入，但是这样的话也必须手动关闭安全模式。

`-refreshNodes` 重新读取hosts和exclude文件，更新允许连到Namenode的或那些需要退出或入编的Datanode的集合。

`-finalizeUpgrade` 终结HDFS的升级操作。Datanode删除前一个版本的工作目录，之后Namenode也这样做。这个操作完结整个升级过程。

`-upgradeProgress status | details | force` 请求当前系统的升级状态，状态的细节，或者强制升级操作进行。

`-metasave filename` 保存Namenode的主要数据结构到hadoop.log.dir属性指定的目录下的`<filename>`文件。对于下面的每一项，`<filename>`中都会一行内容与之对应

1. Namenode收到的Datanode的心跳信号
2. 等待被复制的块
3. 正在被复制的块
4. 等待被删除的块

`-setQuota<quota><dirname>...<dirname>` 为每个目录 `<dirname>`设定配额`<quota>`。目录配额是一个长整型整数，强制限定了目录树下的名字个数。
命令会在这个目录上工作良好，以下情况会报错：

1. N不是一个正整数，或者
2. 用户不是管理员，或者
3. 这个目录不存在或是文件，或者
4. 目录会马上超出新设定的配额。

`-clrQuota<dirname>...<dirname>` 为每一个目录`<dirname>`清除配额设定。
命令会在这个目录上工作良好，以下情况会报错：

1. 这个目录不存在或是文件，或者
2. 用户不是管理员。

如果目录原来没有配额不会报错。`-help [cmd]` 显示给定命令的帮助信息，如果没有给定命令，则显示所有命令的帮助信息。

33、运行MapReduce job Tracker节点(jobtracker)。

用法：`hadoop jobtracker`

34、运行namenode。有关升级，回滚，升级终结的更多信息请参考升级和回滚。

用法：`hadoop namenode [-format] | [-upgrade] | [-rollback] | [-finalize] | [-importCheckpoint]`

命令选项 描述

`-format` 格式化namenode。它启动namenode，格式化namenode，之后关闭namenode。

`-upgrade` 分发新版本的hadoop后，namenode应以upgrade选项启动。

`-rollback` 将namenode回滚到前一版本。这个选项要在停止集群，分发老的hadoop版本后使用。

`-finalize finalize`会删除文件系统的前一状态。最近的升级会被持久化，rollback选项将再不可用，升级终结操作之后，它会停掉namenode。

`-importCheckpoint` 从检查点目录装载镜像并保存到当前检查点目录，检查点目录由fs.checkpoint.dir指定。

35、运行HDFS的secondary namenode。

用法：`hadoopsecondarynamenode [-checkpoint [force]] | [-geteditsize]`

命令选项 描述

`-checkpoint [force]` 如果EditLog的大小 >= fs.checkpoint.size，启动Secondary namenode的检查点过程。 如果使用了-force，将不考虑EditLog的大小。

`-geteditsize` 打印EditLog大小。

37、运行MapReduce的task Tracker节点。

用法：`hadoop tasktracker`