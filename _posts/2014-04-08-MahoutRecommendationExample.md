---
date: 2014-04-08 17:00:00
layout: post
title: Mahout分布式运行实例：基于矩阵分解的协同过滤评分系统
thread: 109
categories: Tutorial
tags: [Mahout, hadoop, 协同过滤]
---

**前言**：之前配置Mahout时测试过一个简单的推荐例子，当时是在Eclipse上运行的，由于集成插件的缘故，所以一切进行的都比较顺利，唯一不足的是那是单机运行的，没有急于分布式系统处理。所以基于测试分布式处理环境的目的，下午找了一个实例来运行，推荐系统原型是一个电影评分的系统。

----

##一、问题描述

对于协同过滤(Collaborative Filtering)，我们就是要预测用户所喜欢的但是又没有发现的物品。下面给出一个明确的评分(1.0-5.0)矩阵，设为矩阵A。但是A有一部分没有值，表明用户没有对此物品评分，于是我们需要预测出没有值的评分部分。

![](/assets/2014-04-08-MahoutRecommendationExampleMA.png "评分矩阵(user X item) A")
<center>评分矩阵(user X item) A</center>

----

##二、解决思路

当然我们知道有基于用户（userBased）和基于物品（itemBased）协同过滤算法。通过计算用户或物品的相似度来求得所缺失的打分。

**基于用户的协同过滤推荐**大致原理如下：根据所有用户对物品或者信息的偏好，发现与当前用户口味和偏好相似的“邻居”用户群，在一般的应用中是采用计算“K-邻居”的算法；然后，基于这 K 个邻居的历史偏好信息，为当前用户进行推荐。

**基于项目（物品）的协同过滤推荐**的基本原理也是类似的，只是说它使用所有用户对物品或者信息的偏好，发现物品和物品之间的相似度，然后根据用户的历史偏好信息，将类似的物品推荐给用户。

假设用户 A 喜欢物品 A 和物品 C，用户 B 喜欢物品 A，物品 B 和物品 C，用户 C 喜欢物品 A，从这些用户的历史喜好可以分析出物品 A 和物品 C 时比较类似的，喜欢物品 A 的人都喜欢物品 C，基于这个数据可以推断用户 C 很有可能也喜欢物品 C，所以系统会将物品 C 推荐给用户 C。

基于Mahout上运行的本例程序，我们这里讲潜在因子模型(latent factor model)方法。用户和物品分布在一个k维的特征空间，用户的未知评分可以简单的通过相应的用户和物品的向量的乘积得到。

也就是将矩阵A分解成两个矩阵U和M。

用户特征矩阵U：

![](/assets/2014-04-08-MahoutRecommendationExampleMU.png "用户x特征(users X features)矩阵U")
<center>用户x特征(users X features)矩阵U</center>

 物品特征矩阵M：

![](/assets/2014-04-08-MahoutRecommendationExampleMM.png "物品x特征(items X features)矩阵M")
<center>物品x特征(items X features)矩阵M</center>

可以通过计算U(users X features) 与M’ (features X items)的乘积A_k (users X items)来接近A。

>A_k = UM’

![](/assets/2014-04-08-MahoutRecommendationExampleAK.png "A_k矩阵")
<center>A_k矩阵</center>

这样就预测到了用户对未知物品的评分。

----

##三、Mahout算法原理

那么该如何来分解A为U和M呢？

Mahout使用的是这篇论文**《Large-scale Parallel Collaborative Filtering for the Netflix Prize》**中的加权lambda正规化的交替最小二乘法(ALS-WR)。（我暂时还没研究具体原理）

----

##四、Mahout运行步骤

在MovieLens上找到电影数据记的下载压缩包，下载IM的数据：[下载地址](http://files.grouplens.org/datasets/movielens/ml-1m.zip)

解压出ratings.dat文件，并利用如下命令转换成用逗号分开的ratings.csv文件（其中类似/home/mhadoop/的路径均为我电脑上的配置，具体因不同电脑环境而异，下文中均如此不再赘述，请注意）：

```
/*转换文件命令*/
cat /home/mhadoop/data/ratings.dat |sed -e s/::/,/g| cut -d, -f1,2,3 > /home/mhadoop/data/ratings.csv
```

然后将csv表文件上传到HDFS，假设在hdfs的路径为/home/mhadoop/input/ratings.csv：

```
hadoop dfs -mkdir /home/mhadoop/input
hadoop dfs -put /home/mhadoop/input/ratings.csv /home/mhadoop/input
```

将rating分为预测集（10%）和训练集（90%）：

```
mahout splitDataset -i /home/mhadoop/input/ratings.csv -o /home/mhadoop/dataset –t 0.9 –p 0.1
```

运行分布式的ALS-WR算法来进行矩阵的分解(matrix factorization)：

```
mahout parallelALS -i /home/mhadoop/dataset/trainingSet/ -o /home/mhadoop/out --numFeatures 20 --numIterations 10 --lambda 0.065
```

之后会在/home/mhadoop/out生成M和U以及保存的评分，可以通过命令`hadoop dfs -ls`或者`hadoop dfs -cat`查看相关文件及内容。

通过预测集来对模型进行评价，评价标准是RMSE：

```
mahout evaluateFactorization -i /home/mhadoop/dataset/probeSet/ -o /home/mhadoop/out/rmse/ --userFeatures /home/mhadoop/out/U/ --itemFeatures /home/mhadoop/out/M/
```

RMSE结果会输出在/home/mhadoop/out/rmse/rmse.txt。

最后进行推荐：

```
mahout recommendfactorized -i /home/mhadoop/out/userRatings/ -o /home/mhadoop/recommendations/ --userFeatures /home/mhadoop/out/U/ --itemFeatures /home/mhadoop/out/M/ --numRecommendations 6 --maxRating 5
```

结果在/home/mhadoop/recommendations/。

以上文件以及最终推荐结果可以在命令行中通过cat命令查看，同时也可以在浏览器通过50030端口的HDFS文件系统查看，以下为HDFS查看下效果图：

![](/assets/2014-04-08-MahoutRecommendationExampleResult.png "文件系统中评分结果图")
<center>文件系统中评分结果图</center>

----

**结语**：好吧，虽然跑通了分布式例子但是原理还不是特别理解，所以找论文找书籍找技术宅的博客去看看。感谢 GOOGLE，[ Wikipedia - Collaborative filtering](http://en.wikipedia.org/wiki/Collaborative_filtering)， [King's Notes](http://hnote.org/big-data/mahout/mahout-movielens-example-matrix-factorization) 以及 Apache Mahout官方文档的帮助。
