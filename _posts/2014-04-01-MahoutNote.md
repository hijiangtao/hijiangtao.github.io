---
date: 2014-04-01 10:00:00
layout: post
title: Mahout学习资料整理
thread: 99
categories: Documents
tags: [Mahout]
excerpt: 
---

##前言

由于要基于hadoop环境实例进行数据分析的操作，所以在听说Mahout对常用的机器学习算法已经集成后准备开始学习Mahout，一方面可以熟悉操作，另一方面也便于自己入门这个较难的领域。

学习资料整理自逍遥冲博客，未改动的原稿地址请见：[Mahout学习资料整理](http://www.xiaoyaochong.net/wordpress/index.php/2013/10/12/mahout%E5%AD%A6%E4%B9%A0%E8%B5%84%E6%96%99%E6%95%B4%E7%90%86/)

----

##Mahout简介

Mahout 是 Apache Software Foundation（ASF） 旗下的一个开源项目，提供一些可扩展的机器学习领域经典算法的实现，旨在帮助开发人员更加方便快捷地创建智能应用程序。

----

##Mahout相关资源

* Mahout主页:<http://mahout.apache.org/>
* Mahout 最新版本0.8下载: <http://mirrors.hust.edu.cn/apache/mahout/0.8/> 使用mahout-distribution-0.8.tar.gz可试跑，源码在mahout-distribution-0.8-src.tar.gz中。

----

##Mahout 简要安装步骤

如无需修改源代码，只是试用试跑，请无需安装maven(网上许多教程会有这个弯路，请跳过)，具体可以参考以下教程<http://www.hadoopor.com/thread-983-1-1.html>

如果需要能修改源代码并重新编译打包，需要安装maven，请参考如下图文教程：<http://wenku.baidu.com/view/dbd15bd276a20029bd642d55.html>

**Mahout 专业教程** ：《Mahout in action》，链接地址<http://yunpan.taobao.com/share/link/R56BdLH5O>

*注： 出版时间2012年， 对应mahout版本0.5， 是目前mahout最新的书籍读物。目前只有英文版，但是翻了一下，里面词汇基本都是计算机基础词汇，且配图和源代码，是适合阅读的。*

IBM mahout简介: <http://www.ibm.com/developerworks/cn/java/j-mahout/>

*注：中文版， 更新是时间为09年，但是里面对于mahout阐述较全面，推荐阅读，特别是最后的书籍清单，适合深入了解。*

----

##Mahout模块详解

Mahout目前专注于推荐(RECOMMENDATIONS)、聚类(CLUSTERING)、分类(CLASSIFICATION)三大部分，具体事例可见Mahout In Action

**推荐(RECOMMENDATIONS)**

推荐算法介绍
<http://www.ibm.com/developerworks/cn/web/1103_zhaoct_recommstudy2/index.html>

Item Based Algothrim
<https://cwiki.apache.org/confluence/display/MAHOUT/Itembased+Collaborative+Filtering>

Collaborative Filtering using a parallel matrix factorization
<https://cwiki.apache.org/confluence/display/MAHOUT/Collaborative+Filtering+with+ALS-WR>

*注：基于矩阵因子分解的方法，由于需要不断迭代，所以在mapreduce框架下效率会受影响*

Non-distributed recommenders
<https://cwiki.apache.org/confluence/display/MAHOUT/Recommender+Documentatio>

*注：mahout中也提供了推荐算法的非分布式的实现，其中有代号为”taste”的开源推荐引擎*

**分类(CLUSTERING)**

Bayesian 贝叶斯分类

<http://blog.echen.me/2011/08/22/introduction-to-latent-dirichlet-allocation/>

*注：其中同时实现了Naive Bayes和Complementary Naive*

BayesRandom Forests 随机森林
<https://cwiki.apache.org/confluence/display/MAHOUT/Random+Forests>

*注：在公司内部，GBDT(内部称treelink)有着广泛的引用，附介绍文章*
<http://www.searchtb.com/2010/12/an-introduction-to-treelink.html> (tbsearch博客)
<http://www.cnblogs.com/LeftNotEasy/archive/2011/03/07/random-forest-and-gbdt.html> (介绍随机森林与GBDT的博客)

Logistic Regression(逻辑回归)
<https://cwiki.apache.org/confluence/display/MAHOUT/Logistic+Regression>

*注：是用SGD(Stochastic Gradient Descent,随机梯度下降)的方法实现的，也可用liblinear: <http://www.csie.ntu.edu.tw/~cjlin/liblinear/> (其中支持L1&L2 regularized logistic regression)*

**SVM(支持向量机)**

目前mahout这个模块还在开发，尚未集成入发布包，如有需要，建议使用台大的libSVM包
<http://www.csie.ntu.edu.tw/~cjlin/libsvmtools/>

**聚类(CLASSIFICATION)**

聚类方法简述

<http://www.ibm.com/developerworks/cn/web/1103_zhaoct_recommstudy3/>

Canopy Clustering模块分析

<http://www.cnblogs.com/vivounicorn/archive/2011/09/23/2186483.html> (中文博客)

<https://cwiki.apache.org/confluence/display/MAHOUT/Canopy+Clustering> (英文文档)

Kmeans模块分析

<http://www.cnblogs.com/vivounicorn/archive/2011/10/08/2201986.html> （中文博客）

<https://cwiki.apache.org/confluence/display/MAHOUT/K-Means+Clustering> (英文文档)

Fuzz Kmeans

<https://cwiki.apache.org/confluence/display/MAHOUT/Fuzzy+K-Means>

Mean Shift Clustering

<https://cwiki.apache.org/confluence/display/MAHOUT/Mean+Shift+Clustering>

注：目前主要用于图像分割和跟踪等计算机视觉领域*

Latent Dirichlet Allocation(LDA)

<https://cwiki.apache.org/confluence/display/MAHOUT/Latent+Dirichlet+Allocation>

*注：经典方法，附论文英文原著论文*
<http://machinelearning.wustl.edu/mlpapers/paper_files/BleiNJ03.pdf> (引用数:6829)
<http://www.docin.com/p-413125834.html> (基于LDA话题演化研究方法综述)
<http://leyew.blog.51cto.com/5043877/860255> (中文博客学习笔记)
<http://blog.echen.me/2011/08/22/introduction-to-latent-dirichlet-allocation/> (英文入门博客)

Pattern Mining 模式挖掘

Parallel Frequent Pattern Mining 并行频繁模式挖掘

论文《在Query推荐中的应用》
<https://cwiki.apache.org/confluence/display/MAHOUT/Parallel+Frequent+Pattern+Mining>

<http://wenku.baidu.com/view/9cce67ed172ded630b1cb615.html>

Dimension reduction 降维

Singular Value Decomposition(SVD) 奇异值分解
<https://cwiki.apache.org/confluence/display/MAHOUT/Dimensional+Reduction>

SVD介绍： <http://wenku.baidu.com/view/7f483a6b561252d380eb6ea6.html>

Evolutionary Algorithms 进化算法框架

进化算法介绍:
<http://www.geatbx.com/docu/algindex.html>

框架使用方法:
<https://cwiki.apache.org/confluence/display/MAHOUT/Mahout.GA.Tutorial>

*注：目前mahout只是提供一套进化算法的并行化实现框架，但具体的进化算法，如遗传算法、模拟退火算法、蚁群算法等，还未集成到开发包中。*

----

##相关工具书

**统计学习书籍**

* 统计学习基础 — 数据挖掘、推理与预测(中文版)：<http://yunpan.taobao.com/share/link/R56BeLI6O>

*注：此书英文版每年都在更新，但是中文版只有2004年一版，而且网上纸质书早就脱销了，由于是统计学习基础，所以大多数经典内容还是可读的*

* 统计学习基础 — 数据挖掘、推理与预测(英文版)(The Elements of Statistical Learning)：<http://yunpan.taobao.com/share/link/D56BeLKYE>，可与中文版对照看

**概率论与数理统计基础书籍**

1. 经典的教科书：浙大概率论与数理统计第三版 - <http://yunpan.taobao.com/share/link/U56BeLWBT>
2. 统计学的百科全书：统计学完全教程(中文版) - <http://yunpan.taobao.com/share/link/756BeLYAa>

**数据挖掘概述书籍**

1. 数据挖掘导论(中文版) - <http://yunpan.taobao.com/share/link/O56BeLoPx>
2. Data Mining.Concepts and Techniques.3Ed(英文版) - <http://yunpan.taobao.com/share/link/256BeLopX>

*注：中文版还是2000年的老版，起不到参考作用，所以放了最新的英文版*

**统计学习在自然语言处理方面应用的书籍**

统计自然语言处理基础(中文版)：<http://yunpan.taobao.com/share/link/25VBpL7X>