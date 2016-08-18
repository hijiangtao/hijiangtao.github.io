---
date: 2014-02-07
layout: post
title: 2014年美国数学建模题目及翻译
thread: 22
categories: Documents
tags: [数学建模]
excerpt: 
---

参加数学建模，刚拿到题目便开始了繁忙的翻译工作，以下为我的翻译成果，顺带附上一些参考资料与常识。

### Problem A: The Keep-Right-Except-To-Pass Rule

In countries where driving automobiles on the right is the rule (that is, USA, China and most other countries except for Great Britain, Australia, and some former British colonies), multi-lane freeways often employ a rule that requires drivers to drive in the right-most lane unless they are passing another vehicle, in which case they move one lane to the left, pass, and return to their former travel lane.

Build and analyze a mathematical model to analyze the performance of this rule in light and heavy traffic. You may wish to examine tradeoffs between traffic flow and safety, the role of under- or over-posted speed limits (that is, speed limits that are too low or too high), and/or other factors that may not be explicitly called out in this problem statement. Is this rule effective in promoting better traffic flow? If not, suggest and analyze alternatives (to include possibly no rule of this kind at all) that might promote greater traffic flow, safety, and/or other factors that you deem important.

In countries where driving automobiles on the left is the norm, argue whether or not your solution can be carried over with a simple change of orientation, or would additional requirements be needed.

Lastly, the rule as stated above relies upon human judgment for compliance. If vehicle transportation on the same roadway was fully under the control of an intelligent system – either part of the road network or imbedded in the design of all vehicles using the roadway – to what extent would this change the results of your earlier analysis?

**翻译结果：**

在一些执行右行交通规则的国家（即美国，中国和其他大多数国家，除了英国，澳大利亚和一些前英国殖民地），多车道的高速公路经常采取如下一条规则：要求平时司机在最右侧车道行驶，除非它们想超过另一辆车。在超车时，他们应该向左移动一个车道，前进超车，然后恢复到原来的行驶车道（即最右车道）。

建立和分析一个数学模型，来考究这一规则分别在轻型和重型交通（即车辆较少和交通拥堵时）中的性能。你不妨衡量一下交通流量和行驶安全两者之间的关系，最高限速和最低限速对其的作用（即过低或过高的车速限制），和在这个问题的陈述中没有明确给出的其他权衡因素。这种规则是否有效的促进了更好的交通流量提升？如果没有，建议和分析其替代方案（以包括这个方案中根本不存在的一些规则），以促使更多的交通流量、更好的安全性和您认为重要的其他因素。

在一些国家，汽车行驶在左边是常态，对你的方案进行讨论，研究在一个简单的方向改变下你的方案是否仍然适用，或者还需其他额外的一些要求。

最后，如上所述的规则依赖于人的判断为标准。如果相同的道路运输完全处于一个智能系统的控制下（无论是部分路网或嵌入使用道路的车辆的设计），在何种程度上这会改变你刚才分析的结果？

### Problem B: College Coaching Legends

Sports Illustrated, a magazine for sports enthusiasts, is looking for the “best all time college coach” male or female for the previous century. Build a mathematical model to choose the best college coach or coaches (past or present) from among either male or female coaches in such sports as college hockey or field hockey, football, baseball or softball, basketball, or soccer. Does it make a difference which time line horizon that you use in your analysis, i.e., does coaching in 1913 differ from coaching in 2013? Clearly articulate your metrics for assessment. Discuss how your model can be applied in general across both genders and all possible sports. Present your model’s top 5 coaches in each of 3 different sports.

In addition to the MCM format and requirements, prepare a 1-2 page article for Sports Illustrated that explains your results and includes a non-technical explanation of your mathematical model that sports fans will understand.

为运动爱好者准备的一份杂志——《体育画报》，正在挑选上个世纪男性或女性中“最好的全职大学教练”。建立数学模型，在以下的体育运动中（高校曲棍球或曲棍球，足球，棒球或垒球，篮球，足球）从男性或女性教练中选择其中最好的大学教练或教练（过去或现在）。在你使用的分析因素组成的时间里程碑上他是否有所作为，这也就是说，在1913年执教是否不同于同样的任务在2013年执行？清楚地说明为了进行评估您所选取的指标。讨论你的模型如何才可以适用于跨越男女性别和其他因素的所有可能体育运动。展示你的模型在3个不同的运动中各自排名前5的教练。

除了MCM的格式和要求，为体育画报准备一份1-2页的文章，用来解释你的结果和包含普通体育迷都明白的该数学模型的非技术性解释。

----

相关知识：

1. **靠左行可以上溯到罗马帝国时代。**罗马帝国时代，骑士骑马是左脚先上马蹬，右脚再跨上马背，因此，骑士通常是在路的左边上马；而骑士是右手持武器，左手执盾、韁，为了方便保护自己，自然靠左行。当时的逻辑是：两人在路上相遇，最好的位置就是能够利用箭来保护自己，而当大多数人都是"右撇子"时，靠左行就成了保护自己的最好位置。西元1300年左右，教皇Benefice正式昭告清教徒靠左行。英国是在1773年一般高速公路法案中，建议民众靠左行，1835年进一步将靠左行纳入法律条文中。

2. **全球左右两行向形成：**当年靠左行的英国藉由扩张领土，将靠左行驶推展到各殖民地，包括：印度、巴基斯坦、新加坡、澳洲和非洲的部分国家。靠右行的国家则和法国的拿破仑有关。法国大革命以前，本来也是靠左行，1790年法国大革命时，受压迫的农夫为了确保安全，区分「靠左行」的贵族与特权，改为靠右行，后来贵族为了自保，也加入靠右行的行列。1794年，巴黎正式规定靠右行。拿破仑上台后，法国占领了那里，就把靠右行带到那里，德国、俄国、义大利、西班牙、比利时等。英国的殖民地里，美国是例外，美国独立战争后为了和英国画清界限，选择了靠右行。瑞典本来是靠左行，1969年因为引进比较便宜的德国车子后，才改为靠右行。

3. 全球有59个国家靠左行走。中国大陆则是国民政府在1946年起规定靠右行。

4. “右派”，多是典型大陆国家，如美国、中国、俄罗斯、德国、法国、巴西等；“左派”，多是典型岛国和半岛、次大陆国家：英国、日本、印度、巴基斯坦、印尼、泰国、澳大利亚、新西兰等。

5. 《体育画报》，一个专门为体育爱好者提供的杂志，正在寻找上个世纪以来一直以来最优秀的大学男女教练。建立一个数学模型来选择以下项目：校园曲棍球、曲棍球、橄榄球、棒球、垒球、篮球、足球中最好的大学男女教练（以前或者现在）。时间的先后是否是一个影响因素，比如在1913年和2013年的教练是否不一样？清楚的表达你所评选的标准。讨论以下你的模型怎么广泛应用，比如所有性别和运动项目。展示你模型中在3个运动项目中最顶尖的5个教练。
