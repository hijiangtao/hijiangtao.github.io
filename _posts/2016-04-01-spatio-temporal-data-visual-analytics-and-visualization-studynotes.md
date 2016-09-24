---
title: 时空数据可视分析与可视化读书笔记
layout: post
thread: 165
date: 2016-04-01
author: Joe Jiang
categories: documents
tags: [visualization, city, spatio, temporal]
excerpt: 汇总最近看过的时空数据可视化原理与分享案例。
---

## 地图投影方法

 - 等角度：投影面上任何点上两个微分线段组成的角度投影前后保持不变，如：墨卡托投影。
 - 等面积：地图上任何图形面积经主比例尺放大以后与实地上相应图形面积大小保持不变，如：亚尔勃斯投影。
 - 等距离：在标准经纬度上无长度变形，地图上任意一点沿经度线到投影原点距离不变，如：方位角投影。
 
## 点数据可视化

通过地理空间中离散的点进行可视化是最基本的一种方法，但其不具备尺寸大小。用 `大小/颜色/图标/符号/向量型箭头` 等视觉元素进行可视化:

 - [颜色与标识]美国奥克兰地区犯罪地图：<http://oakland.crimespotting.org/  >
 - [向量型点数据]美国2010年中期大选和2008年大选各区域民意变化：<http://www.nytimes.com/>

存在问题：由于数据分布不均，容易导致在数据密集区域出现大量的数据相互遮盖现象。为了解决这个问题，一类方法是对区域做网格化处理，在每个网格内统计相关数据，利用三维柱状图进行显示；另一类则是将三维柱状图改成划分出的正交网格，然后用颜色来表示统计数据，例如六边形蜂窝状切割。

在除了离散数据之外，还有一种方法可以使可视化粒度更细，使提供的信息更完整，例如热力图。通过合适的重建或插值算法将数据转成连续的形式呈现。

事实上，绘制每个数据点能让可视化展现更多的细节，假设某个场景下对数据中每个点的关注要大于显示的统计数据，那么这时候需要通过调整数据点的位置来解决重叠的问题。最常见的方法是将重叠的点在一个目标位置周围的小范围内随机移动，如PixelMap算法 [143](http://bib.dbvis.de/uploadedFiles/143.pdf  );

 - [Chicago Boundaries - radicalcartography](http://www.radicalcartography.net/index.html?chicagodots  ): 添加了半透明模式的可视化，可以清晰辨别不同种群的聚居区域，也可以了解到聚居区交接的区域存在的混居现象
 
## 线可视化

线数据通常指连接两个或多个地点的线段或路径。线数据具有长度属性。线数据绘制时，通常可以结合颜色、线的类型和宽度、标注等数据属性。线数据中值得关注的一个问题是，如何减少重叠和交叉的相关算法。

 - 一种简化算法是将大量的线条聚类并简化为若干线束来展示，例如Aaron Koblin的[美国国内飞机航线的可视化](http://www.aaronkoblin.com/work/flightpatterns/  )，不同颜色表示不同型号，透明度表示航班的数量。
 
海量数据线可视化除了要解决视觉复杂度之外，对计算能力也是非常大的挑战，对数据做适当的抽象和聚合可缓解问题。

 - [Facebook Friendship](http://www.facebook.com/notes/facebook-engineering/visualizing-friendships/469716398919  ), 通过从黑色到蓝色到白色之间的不同颜色来表示两地之间的好友关系，所有数据基于城市进行了聚合。

![Facebook](/assets/in-post/2016-04-01-facebook-map.png)


除此外，在大量线条重叠和交叉阻碍信息检索的效率时，可以通过连线绑定技术改变连线布局从而降低视觉复杂度，这样的图可以看成流程图和地图的结合，称为流型图（flow map）。

![global excess](/assets/in-post/2016-04-01-global-excess.png)

 - [法国葡萄酒出口图](http://en.wikipedia.org/wiki/Flow_map  )
 
基于此，Phan等人提出了自动绘制和优化流型图的算法[flow_map_layout](http://vis.stanford.edu/files/2005-FlowMapLayout-InfoVis.pdf  )。其中主要两个步骤是计算连线绑定好优化连线布局。

![Japan](/assets/in-post/2016-04-01-japan.png)

## 区域数据可视化

区域数据包含了比点数据和线数据更多的信息，最常用的是采用颜色来表示这些属性的值。

 - Choropleth地图，其假设一个区域内的数据是均匀分布的，例如2008年[美国总统大选结果](http://elections.nytimes.com/2008/results/president/map.html  )，其最大的问题在于数据分布和地理区域大小的不对称。
 - Cartogram地图，其按照地理区域的属性值对各个区域进行了适当的变形，以客服Choropleth地图的不合理性。这种方法需要在保持区域相对位置和区域原始形状中进行取舍，即连续性和非连续性的Cartogram。非连续性方法[01438259](http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=1438259  )，连续性方法[2008美国总统大选](http://www-personal.umich.edu/~mejn/election/2008/  )
 - 规则形状地图：标准的几何图形让用户可以更容易的判断区域的面积大小，[A Map of Olympic Medals](http://www.nytimes.com/interactive/2008/08/04/sports/olympics/20080804_MEDALCOUNT_MAP.html  )
 - 多元关系地图：[气泡集合, 05290706](http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5290706  )，[线集合, 06064991](http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=6064991  )
 
## 地理信息可视化应用

 - [地理与生存环境]: [Tokyo Wind Map](http://air.nullschool.net/  )
 - [地理与生存环境]: [Weather Radar and Maps for Washington, DC](https://weather.com/weather/radar/interactive/l/USDC0001:1:US  )
 - [城市与日常生活]：[美国旧金山地区各地点的交通时间与房价](http://maps.onebayarea.org/travel_housing/#9.00/37.7880/-122.3915  )
 - [城市与日常生活]：通过传感器和移动设备采集的城市运行实时数据，[Live Singapore](http://senseable.mit.edu/livesingapore/visualizations.html  )
 - [城市与日常生活]：[2011年311日本大地震及海啸期间Twitter上消息传播](https://blog.twitter.com/2011/global-pulse  )
 - [城市与日常生活]：[1000条Nike+跑步路线道路可视化](http://cargocollective.com/coopersmith/WIRED-Joggers-Logged-1 ) 
 - [地理时空数据]：[Data Visualization: Journalism's Voyage West](http://web.stanford.edu/group/ruralwest/cgi-bin/drupal/visualizations/us_newspapers  ), This visualization plots over 140,000 newspapers published over three centuries in the United States. The data comes from the Library of Congress' "Chronicling America" project, which maintains a regularly updated directory of newspapers. 
 - [复杂地理数据可视分析]：[Statistics Explorer](http://stats.oecd.org/OECDregionalstatistics/)

 ![heatmap](/assets/in-post/2016-04-01-heatmap-bridges.png)

 ![most-popular-bike-routes](/assets/in-post/2016-04-01-most-popular-bike-routes.png)

 ![onebayarea](/assets/in-post/2016-04-01-onebayarea.png)

 ![OECD](/assets/in-post/2016-04-01-oecd.png)

 ![Singapore](/assets/in-post/2016-04-01-singapore-1.png)

 ![Singapore](/assets/in-post/2016-04-01-singapore-2.png)

## 其他可视化展现形式

 - [Data Heatmap: Les Misérables Co-occurrence](https://bost.ocks.org/mike/miserables/ )
 - [TreeMap](http://bl.ocks.org/mbostock/raw/4063582/ ), A treemap recursively subdivides area into rectangles; the area of any node in the tree corresponds to its value. This example uses color to encode different packages of the Flare visualization toolkit. 
 - [Visualizing a genetic algorithm ](http://karstenahnert.com/gp/)
 - [Global Landscapes Initiative - Excess Nitrogen](http://sunsp.net/demo/GeogTreeMaps/)

 ![Visualizing a genetic algorithm](/assets/in-post/2016-04-01-algorithm.png)

## 城市研究资源

 - [BCL](http://www.beijingcitylab.com/)
 - [Beihang Interest Group on SmartCity (BIGSCity)](http://www.smartcity-buaa.org/)

 ![BIGSCity](/assets/in-post/2016-04-01-smartcity-beijing-subway-inter-line-passenger-flow.png)

*本文未做明确引述来源的文字部分来源于《[数据可视化](https://book.douban.com/subject/25760272/)》一书。本文配图均源自上下文链接网站的屏幕截图、相关网址中Youtube链接截图以及文章配图。*

END