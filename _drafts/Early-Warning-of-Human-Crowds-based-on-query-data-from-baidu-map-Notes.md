## 文章内容分析

 - 讨论主题：在公共事件中，如何管理拥挤人流对于公共安全来说是非常重要的；避免产生公共事故是一项艰巨的任务，因为它取决于对异常拥挤人流的精准预测；由于传统对异常人流检测的方法基于传感器和计算机视觉技术，他们仍然存在着一些不足（对可见的环境噪声过于敏感；城市里的摄像头传感器有限；检测方法不能在异常拥挤人流事件发生前给管理人员提供足够长的应对时间）。
 - 讨论目的：本文提出了一种有效对异常拥挤人流进行提前预警的方法，与此同时，我们采用机器学习模型对拥挤人流密度进行预测。
 - 目标读者：紧急事件提前预警的决策者；异常拥挤人流检测研究人员；时空数据挖掘研究人员。
- 工作框架：通过结合路径规划/路线搜索数据和定位数据，来实现异常拥挤现象提前预警和对拥挤人流密度的预测。

## 案例观察
 - 数据处理分两部分：
    - Map Query number: 在一段时间间隔内，统计路线搜索中目的地是特定地点的查询数量；
    - Positioning number：在某个特定地区一段时间间隔内，开起了百度地图定位功能的用户数；
 - 案例观察1：Human population density of the stampede area was higher than others.
 - 案例观察2：Human population density of the disaster area was higher than the ones at other times.
 - 案例观察3：Human flow directions of the disaster
area were more chaotic.

## 作者论述与观点

 - A strong correlation pattern between the number of map query and the number of subsequent positioning users in an area.
    - People usually plan their trip on Baidu map before departure;
    - Baidu map takes more than 70% market share overall in China;
 - There usually are an abnormally large number of queries on Baidu map about the crowd event places emerging 0.5-2 hours before the abnormal crowd event being perceptible to human beings.
     - analyzing the data on the Shanghai Stampede and other crowd events in diff places;
 - The peak value of the map query number appears, generally, several hours before the peak value of the positioning number in each day.
     - 计算上海踩踏事件地点一年内每天路线搜索峰值和定位数据峰值的时间差，统计出概率分布情况；
     - 通过互信息分析，路径查询数量可以帮助预测定位数据；
 - 方法的通用性：适用于不同城市中对异常人流情况的检测。
     - 对北京公共事件场所、地标建筑和交通枢纽进行类似分析；得到同样的两种数据之间存在着关系的结论；
     - 通过对故宫地点的分析，发现每天在定位数据达到峰值前，路径查询数据会有两个时间序列上的峰值；这体现人物行为在不同环境下的动态变化与多样性；
     
## 决策方法：用地图查询数据预测异常拥挤人流

 - 分别对两类时空数据建模，自变量为时间，因变量为人数；依次用变量表示单天的人流峰值；
 - 假设峰值变量遵从对数正态分布，用一年的数据对两个变量计算分别获得无偏估计量（unbiased estimation, 均值与方差）;
 - 对于地图搜索数据，warning line是两个无偏估计量的线型组合；对于定位数据，同样如此；
 - 决策方法：如果地图搜索数据大于warning line, 那么在将来一段时间内（T=3 HOURS）实际人流也会超过定位数据的warning line；
 - 通过北京、上海等地几个事件数据进行示范；
 - performance evaluation of the decision method: 通过调整map query number warning line 的表达式中参数，查看预测效果，分别用precision recall and F1-score进行了评估。
 
## 对潜在的拥挤事故进行风险控制的机器学习模型

 - 设定时间间隔为1小时，通过过去时间内的map query number & positioning number做为输入，下一小时positioning number做为输出，训练该预测模型；
 - GBDT ( gradient boosting decision tree ) model. 采用了47个特征，对6个地点的POI做了分别的训练（input=past 60 days）。
 - feature评估：Gini importantance score for each feature;
 - 比较试验：对map query的作用进行了对照实验，采用MAE（平均绝对误差）评估预测与实际值之间的相近关系。
 
## 疑问

 - 作者对两类数据的统计表示如何规避不规则的用户数据？例如，一个用户在一小时内反复定位与查询、一个用户未在一小时内进行任何操作；
 - 观察结果三中的方向信息统计分布如何计算？
 - 为什么采用mutual information以及如何利用该值？
 - 利用对数正态分布进行预测时，对warning line的参数选择？预警时间为何是3小时内？
 - precision recall F1具体对比的变量条件与单位？
 - 可视化使用的技术与工具？

