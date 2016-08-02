## Trade Area Analysis using User Generated Mobile Location Data

### Content

#### Key process

 - identifying the activity center of a mobile user
 - profiling users based on their location history
 - modeling users’ preference probability
 
#### USER GENERATED MOBILE LOCATION DATA (UGMLD) AND ITS LIMITATIONS

Data origins

 - Call Detail Records
 - IP Address
 - In-store sensor(e.g. bluetooth, WIFI, ultra sound sensing)
 - Collected by social networking services
 - Collected by various apps
 
The foursquare check-in dataset: uneven business category distribution, skewed user check-in distribution.

#### TRADE AREA ANALYSIS

TAA steps

1. Collect basic information about the store to be modeled, such
as location and store type, both of which have a large impact
on the store’s trade area. 
2. Select a sample of current customers and collect related
customer information, especially where they are from
(usually their home address) and their spending in the store.
3. Derive the travel distance polygon to identify the geographic
boundary of the customers’ locations.
4. Identify the user block group and related information. Create
customer profiles, such as block group “Psyte” profiles [19]
that represent people’s demographic information and income
levels, so the business can better understand its customer
type.
5. Incorporate other factors like competitors and sister stores. 

check-ins as customer visitation data: 由于社交网络上定位数据存在特定原因的偏移，比如用户偏爱在休闲娱乐场所定位来分享自己的生活，这对一些试验有影响。作者通过每天对用户在同一位置最多记录一个定位（venue-day check-in）的方法来做之后的实验。

derive trade area boundary using check-ins: 根据地理位置距离衰减定律，两地之间的互动频率会随着两地之间的距离增加而下降。大部分人的定位记录所在地点对这个人都会具有一定重要意义的作用。所以以在某个地点（KFC）定位过的用户的所有定位数据能够生成的一副地图，而这样的地图能大致刻画去过KFC的人群在生活中比较重要的地点都在哪里。而这里面以一个人数据为例，通过check-in heat map and trajectory netowork能够发现这个人的生活check-in包括几个cluster，比如home，work，workday lunch，shopping area。

用户在某一地点如果有很大几率出现，那么这样的地点被称作activity center。选取activity center替代home location有几个好处，activity center可能存在几个，比如家，工作地点等，而且这样的地点对于刻画用户行为有很大帮助。

定义activity center包括几种方法，比如一个人所有定位地点的质心，最频繁定位地点，最密集定位地点，最密集定位地点cluster的质心等等。

获取到数据后，通过drive-time/distance polygon 分别来刻画不同地点所在区域的边界。

location-based user profiling: In practice, businesses want to know more about current and prospective customers such as their shopping habits and demographic background. foursquare提供分层的9个话题分类，作者采用LDA来实现user profiling。LDA需要预定义的topic类别，作者采用6种不同的地点集合作为topic，然后对每个用户对这6个地点定位的数据进行比例计算。最后，对某一个地点定位过的人群进行topic统计。

Competition and gravity models: 用户对某一地点的访问次数除以对该类地点访问总次数，等于该用户的忠诚度。

#### BEYOND TRADITIONAL TRADE AREA ANALYSIS 

distance decay of customer's activity

For each customer, we calculate the Distance Decay Percentage (DDP). A high DDP (close to 1) means that the store is on the fringe of the customer’s activity area. A low DDP (close to 0) means that the store is close to the center of the customer’s activity area. X-axis is the activity DDP. Y-axis is the number of customers falling into each bucket. 之后我们便可以画出不同地点的的DDP；此外，DDP vs. Distance plot（家到某个地点的距离作为x轴）也可以观察该用户的pattern。这个方法从客户的角度分析了商家可能存在的和用户之间的互动pattern。

check-in sequences analysis & use: sequence check-in distribution, geo-fencing using check-in sequence data.

 - 选择地点，找出某一天里所有在该地定位过的用户的定位数据，然后选择距离该地点10km以内，以及在该地点定位前后10小时内的定位数据做bar chart；
 - 有别于以往的可用的商场边界信息或者预定义的距离圆环，作者采用基于定位数据来刻画fence，方法大致和TAA中drive distance方法类似，文中作者分别给出了覆盖60%和75%在该商场定位过的用户的商场边界。
