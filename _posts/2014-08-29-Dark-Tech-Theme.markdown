---
title: Dark-Tech, A New Hexo Theme
thread: 143
date: 2014-08-29 20:00
categories: Tutorial
tags: [hexo]
layout: post
excerpt: Dark-Tech.
---

## Dark-Tech : A New Hexo Theme

![](/assets/in-post/2014-08-29-Dark-Tech-Theme.jpg )

Dark-Tech theme is really a cool ideal personal-blog resolution, which is inspired by Hacker Cultrue and Metro-light Theme(Author:[halfer53](https://github.com/halfer53/)). It’s a flat, minimal and responsive theme designed for hexo, and developed based on dark. Welcome the Redevelopment based on Dark-Tech as well as the Use of it.

<!--more-->

## Installation

### Theme Installation

```javascript
git clone https://github/com/hijiangtao/dark-tech.git themes/dark-tech
```

*Dark-Tech Theme's working requires Hexo 2.4.5 and above.*

### Enable

Modify the `theme` setting which is folded in blog folder: change the text behind the `_config.yml` to `dark-tech`.

### Update

```javascript
cd themes/dark-tech
git pull
```

*please backup your `_config.yml` file before update.*

## Configuration

```
menu:
  Home: /dark-tech/
  Archives: /dark-tech/archives
  About: /dark-tech/about
  Lab: /dark-tech/lab
  ## You can modify the url to your own personal setting.
  
widgets:
- search
## the search box
- category
## category
- recent_posts
## your recent posts show
- tagcloud
## the tag of your articles with an effect of wordcloud
- weibo
## your weibo show
- blogroll
## friendly link

excerpt_link: Continue Reading

comment:
  duoshuo: false
  duoshuo_short_name: 
## to enable disqus, you need to fill in the disqus_shortname in config.yml
## to enable duoshuo, you need duoshuo id and set duosuo to true

## share plugins at the bottom of the article
share:
  enable: true
  jiathis: true
  twitter: false
  google: false

bottom_link:
  google_plus: 
  ## e.g. 104684175089936429154 for https://plus.google.com/u/0/104684175089936429154/posts
  github: 
  twitter: 
  ## e.g. ffff for https://twitter.com/ffff
  weibo: 
  facebook: 
  ## e.g. ffff for https://www.facebook.com/ffff
  renren: 
  ## e.g. 333333333 for http://www.renren.com/333333333

logo:
  enable: true  
  ## display img
  src: img/favicon.png 
  ## 32 * 32px, logo img
  apple_icon: img/apple-icon.ico 
  ## logo img for apple icon, 114 * 114 px

## your personal page, could be your github account page, twitter or google plus personal page
## By default its your homepage
personal_site: 

addthis:
  enable: true
  pubid: 
  facebook: true
  twitter: true
  google: true

fancybox: false

## you can change the custom font in head.ejs
CustomFont: true

## google analytics id, e.g.UA-28532742-2
google_analytics: 

## url of your rss
## it is highly recommanded to use rss plugins, https://github.com/hexojs/hexo-generator-feed
rss: 

## for Chinese users
ChineseUser: false
## 默认false. 如果你的访客大部分来自中国, 那么请设置为true, cdn将会调换为360和百度公共库, 同时lang和content-language也会被修改
```

## Wait to be solved

* Code Highlight’s Improvement
* Font-Setting’s Improvement

Thanks for halfer53’s working for metro-light theme.

[Joe Jiang](http://hijiangtao.github.io/)

2014.08
