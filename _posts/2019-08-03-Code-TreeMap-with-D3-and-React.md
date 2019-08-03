---
title: 用 D3 和 React 造一个更科学的 TreeMap
layout: post
thread: 228
date: 2019-08-03
author: Joe Jiang
categories: Document
tags: [2019, D3, TreeMap, React, 可视化, Visualization]
excerpt: 在 Google 里输入 D3 TreeMap 两个关键词，结果就能出来一大堆，但查到的几个 demo 都还不太能满足我的需求，相比基础的 TreeMap 布局，除了 demo 一般抽象粒度都不太够外，我还希望……
---

在 Google 里输入 D3 TreeMap 两个关键词，结果就能出来一大堆，但查到的几个 demo 都还不太能满足我的需求，相比基础的 TreeMap 布局，除了 demo 一般抽象粒度都不太够外，我还希望：

* 支持固定大小与相对双布局；
* 元素的移动动画要支持溯源；
* 添加动画开关并在 React 调用；

在解决问题之前，先把涉及到的 D3 API 整理一下：

1. `d3.hierarchy()` - 这个 API 用于生成树形层次结构的数据。通过运行分层布局，可以返回节点数组及指定的根节点。布局的输入参数为分层的根节点，输出返回值为一个数组，表示计算过的所有节点的位置。如果你的数据还不符合层次结构（即具备父子关系的 JSON 格式），那么你可以尝试使用 `d3.stratify` 来处理你的数据。
2. `d3.stratify()` - 将平级的数据构建为具有层次结构的数据。
3. `d3.treemap()` - 这个 API 用于创建 TreeMap 布局，输入为一个具有层次结构数据的根结点。
4. `d3.schemeCategory10` - 用于颜色映射使用的 API，为一个数组，其中包含十个分类颜色，每个颜色元素表示为 RGB 十六进制字符串。
5. `d3.select()` - 元素选择器，可以用它设置属性，样式，属性，HTML 或文本内容等。
6. `selection.transition()` - 这个 API 用于构造指定元素的新转换。
7. `transition.tween()` - 当你需要为每个元素的转换添加补间动画时，你会用上这个 API。

接下来便挨个解决这几个问题，本文所使用的数据集格式可参见 <https://github.com/hijiangtao/d3-treemap-with-react-demo/blob/master/src/mock.js>。

在线 Demo 见 <https://hijiangtao.github.io/d3-treemap-with-react-demo/>。

<video style="width: 100%; height: auto;" src="/assets/in-post/2019-08-03-Code-TreeMap-with-D3-and-React.mp4" controls="controls" ></video>

## 解决问题

### 1 / 双布局

Treemap 作为一种可视化形式，非常适合展现具有层级关系的数据，利用它能够直观体现同级之间的比较。利用布局 API d3.treemap 以及一个固定大小的画布，通过更新数据源便可以看到数据的变化情况。当每帧图像中数据总量不变的时候，我们用固定大小的容器是没有问题的，但若数据总量会动态变化，那么画布也应该随之改变以体现数据的增减，所以灵活的 TreeMap 应该提供有两类布局。这里我们来看看如何实现动态调整的布局。

首先是配置 TreeMap 布局函数：

```
const tm = d3.treemap()
    .tile(tileType) // 布局类型
    .size([width, height]) // 长宽像素
    .padding(d => d.height === 1 ? 1 : 0) // 边距
    .round(true);
```

然后便是调用布局函数生成带有实际位置信息的节点集。为了实现不同帧画面的布局变化，首先我们需要对每帧数据进行加和计算并对大小进行排序，其次是根据 ID 对节点进行重排：

```
// 加和计算和大小排序使用 .sum() 和 .sort() API
const root = tm(d3.hierarchy(mapdata)
    .sum(d => {
      return d.values ? d.values[index] : 0
    })
    .sort((a, b) => {
      return b.value - a.value
    }));
```

再来看看我们的布局代码，我们最后更新每个节点的大小时会传入一个系数，这个系数用于计算画布偏移及更新最后节点位置信息：

```
// 获取当前数据集最大值，由 maxLayout 控制是全数据集还是当前帧数据集
const getMaxs = (data, index = -1) => {
  const sums = data.keys.map((d, i) => d3.hierarchy(data).sum(d => d.values ? Math.round(d.values[i]) : 0).value);
  return index === -1 ? d3.max(sums) : sums[index];
}

const maxIndex = maxLayout ? -1 : index;
const k = Math.sqrt(root.sum(d => d.values ? d.values[index] : 0).value / getMaxs(mapdata, maxIndex));

// 像素系数，由 k 控制偏移 
const x = (1 - k) / 2 * width;
const y = (1 - k) / 2 * height;

// 更新每个节点位置信息
const leaves = tm.size([width * k, height * k])(root)
  .each(d => (d.x0 += x, d.x1 += x, d.y0 += y, d.y1 += y))
  .leaves();
```

由上可以看出，最终操控布局是固定大小还是动态调整大小的系数是由 x/y 控制，然后遍历节点时传入进行更新。

### 2 / 动画溯源

动画溯源比较好解，由于我们在调用布局函数时已经进行过排序计算，这使得我们可以获得变更后的每个节点位置信息，那么我们只需要将返回的每条数据与前一帧时每条数据对应上，由于在添加元素时我们都有生成一个 id，故这里通过遍历完成查找和位置更新：

```
// 生成元素时的 ID 赋值
leaf.append("rect")
    .attr("id", d => (d.leafUid = UID('leaf')).id)
......

// 调用组件时所用到的 sortTransition API 用于控制动画是否溯源
// 如果不开启，那么直接返回节点集
if (!mapdata.children[0].values || !sortTransition) return leaves;

const newLeaves = new Array(leaves.length);
// 获取 ID 集合，其在数据中的位置即为其上一帧的位置
const keyList = mapdata.children.map(({id}) => id);

// 构造结果集 newLeaves
leaves.map(item => {
  const itemIndex = keyList.indexOf(item.data.id);
  newLeaves[itemIndex] = item;
})

......
```

但这是一个溯源思路，看到代码中有这么一个判断 `!mapdata.children[0].values || !sortTransition`，这个意思即根节点层内元素如果包含的不是可遍历的节点（即其子元素仍旧是一个多层结构），那么我们将不进行溯源处理，这是因为我们后续的 ID 匹配只匹配到了根节点下面的第一层，如果需要支持多层级数据，那么如上的 leaves 遍历以及 newLeaves 构造都需要进行更改。这部分的工作会更加复杂，本文暂不涉及。

### 3 / 动画开关与在 React 中使用

动画开关其实在以上两点中已有涉及，其中 `sortTransition` 用于控制动画中节点是否溯源，而是否让 TreeMap 自动启动动画我们只需要在 React 中动态更改 state 并重新调用组件即可，这里解释下最后封装的 API：

```javascript
<TreeMap 
  configs={
    {
      width, // 画布宽度
      height, // 画布高度
      tileType, // 布局类型
      maxLayout, // 是否动态布局
      sortTransition, // 是否动画溯源
    }
  }
  index={count} // 画面帧数，当不开启自动动画播放时有效
  animation={animation} // 是否开启自动动画播放
  data={MOCK_TREEMAP} // TreeMap 层次数据
/>
```

而一个简单的 React 封装即始终让组件返回 svg 元素，但通过 id 绑定元素查询以及数据更新的逻辑。详见这57行代码 <https://github.com/hijiangtao/d3-treemap-with-react-demo/blob/master/src/TreeMap.js#L101-L157>.

完整代码见 <https://github.com/hijiangtao/d3-treemap-with-react-demo>, 在线 Demo 见 <https://hijiangtao.github.io/d3-treemap-with-react-demo/>。

## 参考

* <https://github.com/d3/d3-hierarchy/blob/master/README.md#treemap>
* <https://observablehq.com/d/2992c7a66ba9a23b>