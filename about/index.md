---
layout: page
title: About
---

<ul class="nav nav-tabs" id="about-info">
    <li class="active"><a href="#intro" data-toggle="tab">Intro</a></li>
    <li><a href="#focus" data-toggle="tab">Focus</a></li>
    <li><a href="#contact" data-toggle="tab">Contact</a></li>
    <li><a href="#links" data-toggle="tab">Links</a></li>
</ul>
<br/>

<div class="tab-content">
    <div class="tab-pane fade in active" id="intro">
        <section>

            <p>Greetings, I’m an undergraduate student at School of Software, Beijing Institute of Technology.
                The Director of Data Mining Laboratory, which belongs to the Software Technology Innovation Base of BIT. I’m very interested in things about Internet, including about all knids of products and technologies, I will focus on TMT and related aspects in my free time to help me know more about the world that I loved deeply.<br />
            I did some Computer Vision job and 3D Game in courses projects, I’d attend some National competitions and got some good awards. I am intersted in Data visualization and Digital Media. I had three years experience in Students’ Union and some Students Society.<br />
            一名非常平凡但不甘于平凡的大学生，北京理工大学软件学院本科在读。<br />
            现任北京理工大学软件学院创新创业基地数据智能实验室主任，热爱互联网新奇事物与技术，平时没事时喜欢鼓捣视频剪辑、特效处理的小技术，闲暇之余喜欢关注前端技术、TMT行业动态。参加过一些科技竞赛并获得过国家级奖项，并在大学三年生活中积攒了一些学生工作的组织经验。</p>

            <div class="row">
                <div class="col-xs-6 col-sm-4"><img class="img-responsive" src="/album/me.jpg" /></div>
                <div class="col-xs-6 col-sm-4"><img class="img-responsive" src="/album/me.jpg" /></div>
				<div class="col-xs-6 col-sm-4"><img class="img-responsive" src="/album/me.jpg" /></div>
            </div>
        </section>
    </div>
    <div class="tab-pane fade" id="focus">
        <section>
            <p class="lead">Research Directions / 研究方向</p>
            <p>Data Mining and visualization.<br>数据挖掘与可视化</p>
            <p class="lead">Researching Project / 参与项目</p>
            <p>January,2014 - now: Project about Big Data with Professor Tang in Data Mining and Processing.</p>
            <p class="lead">Work at / 工作经验</p>

            <p>2013 奇虎360科技有限公司 荣誉顾问<br />
            2014.12 - Now 新浪云计算SAE中级开发者<br />
            2012.9 - 2013.6 北京理工大学学生社团联合会主席团直属中心新闻信息中心主任、北京理工大学科学技术协会宣传部部长<br>
            2013.9 - 2014.1 北京理工大学软件学院学生会宣传部副部长</p>
        </section>
        
    </div>
    <div class="tab-pane fade" id="contact">
        <section>
            <p class="lead">Contact / 联系方式</p>
            <p>
            <span class="glyphicon glyphicon-user"></span> 
            <a class="btn btn-large btn-success" href="/">主页/HomePage</a>
            <a class="btn btn-large btn-success" href="/blog/">博客/Blog</a>
            <a class="btn btn-large btn-success" href="http://weibo.com/jiangtaotao">微博/Weibo</a>
            <a class="btn btn-large btn-success" href="http://www.zhihu.com/people/hijiangtao">知乎/Zhihu</a>
            </p>
            
            <p class="lead">Address / 联系地址</p>
            <p>School of Software, Beijing Institute of Technology,5 South Zhongguancun Street, Haidian District, Beijing China, 100081<br />
            北京市海淀区中关村南大街5号北京理工大学软件学院，100081</p>
            <table>
                <tr><td>
                    <address>
                        <p>E-mail </td>
                    <td><a class="btn btn-default" href="mailto:{{site.contact_email}}"><span class="glyphicon glyphicon-envelope"></span> {{site.contact_email}}</a></p>
                        </address>
                    </td></tr>
            </table>
        </section>
    </div>
    <div class="tab-pane fade" id="links">
        * [Jark's Blog](http://wuchong.me/)
        * [Willzhang's Blog](http://myincubator.sinaapp.com/)
    </div>
</div>
<script>
    $(function () {
        $('#about-info a:first').tab('show')
    })
</script>
