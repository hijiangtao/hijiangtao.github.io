---
title: A reusable visualization component
layout: post
thread: 162
date: 2015-09-08
author: Joe Jiang
categories: documents
tags: [JavaScript, D3]
excerpt: This is a simple reusable library for drawing vis charts and tables like C3 or Echarts, etc. 
---

This component was developed from the examples that I had my internship in DeepGlint, which aims to visualize the system's monitor states in realtime. When I worked to complete the DEVELOPER platform, I thought if I can integrate it into a reusable library for further aims.

The full name of it is 'An Integrated Version of Security Monitor Vis System', each chart shows in demo page is an independent component for drawing beautiful chart. Once you ge the dataset, you can drive the chart without other settings. All the charts include `function generate()`, `function redraw()` and getting data part(which is setInterval part in my demo page).

All the visualization results are developed in [D3][1], and the css is modified based on bootstrap.

Some 3D trying is also used in the visualizations, such living map. These trying have two approaches, one is [three.js][2], and another is CSS 3D Transition.

The main page of component:

![The main page of vis component][3]

The demo page of visualization charts are in [http://hijiangtao.github.io/ss-vis-component/][4].

Three Cubes Test: Use mesh to test cube's display in Three.js.

[http://hijiangtao.github.io/ss-vis-component/three-test-cubes.html][5]

Three Texture Test: Use a map picture to test the effect of Three.js texture, combined with texture both on ground and particleSystem.

[http://hijiangtao.github.io/ss-vis-component/three-test-texture.html][6]

Three Particles and Index Test: Simulate lots of particles to test the data updating and animation styles in Three.js.

[http://hijiangtao.github.io/ss-vis-component/three-test-index.html][7]

CSS 3D People Monitor Test: Use pure CSS 3D Stylesheets and JavaScript to simulate the 3D space (such as webgl tech) effect.

[http://hijiangtao.github.io/ss-vis-component/css3d-test-people.html][8]

Other test vis pic:

![Cubes][9]

![Texture][10]

![CSS 3D][11]


  [1]: http://d3js.org/ "Data-Driven Documents"
  [2]: http://threejs.org/ "three.js"
  [3]: http://hijiangtao.github.io/ss-vis-component/assets/Example.png "The main page of vis component"
  [4]: http://hijiangtao.github.io/ss-vis-component/
  [5]: http://hijiangtao.github.io/ss-vis-component/three-test-cubes.html
  [6]: http://hijiangtao.github.io/ss-vis-component/three-test-texture.html
  [7]: http://hijiangtao.github.io/ss-vis-component/three-test-index.html
  [8]: http://hijiangtao.github.io/ss-vis-component/css3d-test-people.html
  [9]: /assets/2015-09-08-reusable-vis-component-1.png "Pic 1"
  [10]: /assets/2015-09-08-reusable-vis-component-2.png
  [11]: /assets/2015-09-08-reusable-vis-component-3.png