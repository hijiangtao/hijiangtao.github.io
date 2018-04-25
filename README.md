# [Joe's Blog](https://hijiangtao.github.io/)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/cd4fd74b864245a391d8678f1f458359)](https://www.codacy.com/app/hijiangtao/hijiangtao.github.io?utm_source=github.com&utm_medium=referral&utm_content=hijiangtao/hijiangtao.github.io&utm_campaign=badger) [![GitHub contributors](https://img.shields.io/github/contributors/hijiangtao/hijiangtao.github.io.svg)]() [![GitHub issues](https://img.shields.io/github/issues/hijiangtao/hijiangtao.github.io.svg)]() [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contribute) [![license](https://img.shields.io/github/license/hijiangtao/hijiangtao.github.io.svg)]() [![Travis](https://img.shields.io/travis/hijiangtao/hijiangtao.github.io/master.svg)]()

## Introduction

The blog is based on mmistakes' contribution for [Minimal Mistakes Jekyll Theme](https://github.com/mmistakes/minimal-mistakes), the version is 4.11.1. Besides, I create a new layout named `keynote`, which allows you to present nicely IFRAME content in your blog. I also introduced [Gitment](https://github.com/imsun/gitment) into current theme.

Currently, the repositry contains not only the blog theme code, but also my articles' markdown files and other assets like photos. A seperate pure theme of this blog will be extracted in the soon future.

## Feature - Presentation Post

This kind of layout allows you to present nicely IFRAME content in your blog, such as a presentation created with reveal.js.

**Usage**: Specify the `layout: keynote`, and add a extra `iframe` value to define the url of your HTML content, the format of `keynote` layout post shows below: 

```
---
date: XXXX-XX-XX
layout: keynote
title: THIS IS YOUR ARTICLE TITLE
thread: THREAD ID
categories: CATEGORY
tags: [tag1, tag2]
excerpt: Introduction
iframe: PUT YOUR URL HERE, such as https://hijiangtao.github.io/slides/s-D3-Basic-Tutorial
---
```

## Feature - Gitment

Gitment is a comment system based on GitHub Issues, which can be used in the frontend without any server-side implementation. To open it, you should specify some properties in `_config.yml`, an example shows below:

```
comments:
  provider               : "gitment"
  gitment:
    repo                 : "hijiangtao.github.io.comments"
    oauth_id             : Your_Oauth_ID
    oauth_secret         : Your_Oauth_Secret
    owner                : "hijiangtao"
```

The comment repositry of this blog is [hijiangtao/hijiangtao.github.io.comments](https://github.com/hijiangtao/hijiangtao.github.io.comments).


## Serve locally

```
git clone git@github.com:hijiangtao/hijiangtao.github.io.git
bundle install
bundle exec jekyll serve
```

## About

[Create](https://github.com/hijiangtao/hijiangtao.github.io/issues/new) a new issue to report bugs or communicate with me about your insights.

This is the source code for my personal website.

Unless stated otherwise, all content is MIT-licensed.

Joe Jiang

2018.4
