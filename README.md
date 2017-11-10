# [Joe's Blog](https://hijiangtao.github.io/)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/cd4fd74b864245a391d8678f1f458359)](https://www.codacy.com/app/hijiangtao/hijiangtao.github.io?utm_source=github.com&utm_medium=referral&utm_content=hijiangtao/hijiangtao.github.io&utm_campaign=badger) [![GitHub contributors](https://img.shields.io/github/contributors/hijiangtao/hijiangtao.github.io.svg)]() [![GitHub issues](https://img.shields.io/github/issues/hijiangtao/hijiangtao.github.io.svg)]() [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contribute) [![license](https://img.shields.io/github/license/hijiangtao/hijiangtao.github.io.svg)]() [![Travis](https://img.shields.io/travis/hijiangtao/hijiangtao.github.io/master.svg)]()

## Features

The blog is based on mmistakes' contribution for [Minimal Mistakes Jekyll Theme](https://github.com/mmistakes/minimal-mistakes). Besides, I create a new layout `keynote`, to combine nicely HTML Presentation content and your blog post.

**Usage**: a extra `iframe` is used to define the url of your HTML Presentation, the format of `keynote` layout shows below: 

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

Progressive Web APP Support: TBD

## Serve locally

```
git clone git@github.com:hijiangtao/hijiangtao.github.io.git
bundle exec jekyll serve
```

## About

[Create](https://github.com/hijiangtao/hijiangtao.github.io/issues/new) a new issue to report bugs or communicate with me about your insights.

This is the source code for my personal website.

Unless stated otherwise, all content is MIT-licensed.

Joe Jiang

2017.2
