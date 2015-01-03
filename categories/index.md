---
layout: page
title: Categories
---

<ul class="list-unstyled">
	{% for cat in site.categories %}
	  <li class="list-unstyled" id="{{ cat[0] }}"><h3>{{ cat[0] }}</h3></li>
		{% for post in cat[1] %}
		  <li class="list-style">
		  <p><time datetime="{{ post.date | date:"%Y-%m-%d" }}">&middot; {{ post.date | date:"%Y-%m-%d" }}</time>
		  &gt;&gt; <a href="{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a></p>
		  </li>
		{% endfor %}
	{% endfor %}
</ul>
