---
title: 网络安全科普：奇妙的 SSL/TLS 证书（基础篇）
layout: post
thread: 282
date: 2022-11-16
author: Joe Jiang
categories: Document
tags: [TLS, HTTPS, 网络安全, 加密, SSL, CA, 证书, 证书链, 交叉证书, CSR, PKI, OCSP, X.509]
excerpt: 如果某个网站受 SSL 证书保护，其相应的 URL 中会显示 HTTPS（超文本传输安全协议）。单击浏览器地址栏的小绿锁，即可查看证书中的详细信息。但你是否曾好奇过一本证书是如何诞生的，以及 HTTPS 背后的 SSL/TLS 是如何在工作过程中发挥功效以保证通信安全的，什么是 CA、PCA，什么又是证书链和 X.509……
toc: true
header:
  image: ../assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-Teaser.png
  caption: "©️hijiangtao"
---

## 零、前言

如果某个网站受 SSL 证书保护，其相应的 URL 中会显示 HTTPS（超文本传输安全协议）。单击浏览器地址栏的小绿锁，即可查看证书中的详细信息。但你是否曾好奇过一本证书是如何诞生的，以及 HTTPS 背后的 SSL/TLS 是如何在工作过程中发挥功效以保证通信安全的，什么是 CA、PCA，什么又是证书链和 X.509……

在参与了一段时间的证书业务开发后，我将个人的一些理解和学习总结如下，希望这一篇文章，可以帮到正在或将要学习 SSL/TLS 证书的你。

**该网络安全科普系列一共分为上下两篇文章，除去前言、参考外，第一篇章为基础篇（第一章至第五章），第二篇章为进阶篇（第六章至第八章），第三篇章即“总结”会对全文结构和书写内容进行总结与梳理。** 此前未曾了解过 SSL/TLS 证书的同学可以从第一篇章开始看起，如果有一部分基础想深入的同学可以直接从第二篇章开始阅读。两篇文章均完成撰稿，地址如下：

1. [网络安全科普：奇妙的 SSL/TLS 证书（基础篇）](https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-One/)
2. [网络安全科普：奇妙的 SSL/TLS 证书（进阶篇）](https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-Two/)

本文为奇妙的 SSL/TLS 证书第一篇章——基础篇，以下开始正文。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-0.png)

## 一、术语表

为了方便大家阅读，特在此章将全文涉及到的一些网络安全与数字证书领域的专业术语进行整理，整理此术语表供大家查阅。

| 简称 | 英文全称 | 中文全称 |
| --- | --- | --- |
| CA | Certificate Authority / Certification Authority | 证书颁发机构 |
| SSL | Secure Sockets Layer | 安全套接字层协议 |
| TLS | Transport Layer Security | 传输层安全性协议 |
| EV SSL | Extended Validation SSL Certificates | EV 证书，又名扩展验证证书 |
| OV SSL | Organization Validated SSL Certificates | OV 证书，又名组织验证证书 |
| DV SSL | Domain Validated SSL Certificates | DV 证书，又名域验证证书 |
| Wildcard SSL | Wildcard SSL Certificate | 通配符证书 |
| MDC | Multi-Domain Certificates | 多域 SSL 证书 |
| UCC | Unified Communications Certificate | 统一通信证书 |
| TLD | Top-level domain | 顶级域 |
| PKI | Public key infrastructure | 公钥基础设施 |
| PCA | Private Certificate Authority | 私有证书颁发机构，又名私有 CA |
| HTTP | Hypertext Transfer Protocol | 超文本传输协议 |
| HTTPS | Hypertext Transfer Protocol Secure | 超文本传输安全协议 |
| - | Public key | 公钥 |
| - | Private key | 私钥 |
| X.509 | - | 密码学里的公钥证书格式标准 |
| CSR | Certificate signing request | 证书签名请求 |
| OCSP | Online Certificate Status Protocol | 在线证书状态协议 |
| CSP | Cryptographic Service Provider | 加密服务提供商 |

## 二、什么是 CA、证书及其分类

### CA 证书、SSL 证书及其区别

CA 证书是由 CA 颁发的电子证书，又被称为数字证书，证书主要包含证书拥有者的身份信息，CA 机构的签名，公钥和私钥。 CA 证书是一串能够表明网络用户身份信息的数字，提供了一种在计算机网络上验证网络用户身份的方式，因此数字证书又称为数字标识。

SSL 证书是一个数字证书，用于认证网站的身份并启用加密连接。SSL 代表安全套接字层，这是一个安全协议，可在 Web 服务器和 Web 浏览器之间创建加密链接。

关于 CA 证书和 SSL 证书之间的关系，其实某种意义上，大家会将其认为等价，不过稍有不同：CA 是证书颁发机构，由 CA 机构颁发的证书都可以成为 CA 证书，SSL 证书只是 CA 机构颁发证书的其中一种。

### SSL 证书类别

SSL 证书根据验证级别主要分为六种类型：

1. **扩展验证证书 (EV SSL)：** 这是等级最高、最昂贵的 SSL 证书类型。它倾向于用于收集数据并涉及在线支付的高知名度网站。安装后，此 SSL 证书在浏览器地址栏上显示挂锁、HTTPS、企业名称和国家/地区。在地址栏中显示网站所有者的信息有助于将网站与恶意网站区分开。要设置 EV SSL 证书，网站所有者必须经历标准化的身份验证过程，以确认他们已获得该域的专有权利的合法授权。EV SSL证书遵循全球统一的严格身份验证标准，是目前业界安全级别最高的顶级（Class 4级）SSL证书。常见客户为金融、银行等。
2. **组织验证证书 (OV SSL)：** 此 SSL 证书版本具有与 EV SSL 证书类似的保证级别，这是因为，要获得此证书，网站所有者需要完成实质性的验证过程。此类型的证书也会在地址栏中显示网站所有者的信息，以区别于恶意网站。OV SSL 证书往往是价格第二高的证书（仅次于 EV SSL），其主要目的是在交易期间对用户的敏感信息进行加密。商业或面向公众的网站必须安装 OV SSL 证书，以确保共享的任何客户信息都得到保密。对于政府、学术机构、无盈利组织或涉及信息交互的企业类网站来说使用DV证书。
3. **域验证证书 (DV SSL)：** 获得此 SSL 证书类型的验证过程是最简单的，因此，域验证 SSL 证书提供了较低程度的保证和最低程度的加密。它们通常用于博客或信息类网站，即，不涉及数据收集或在线支付的网站。此 SSL 证书类型是成本最低、获取速度最快的证书之一。验证过程仅要求网站所有者通过答复电子邮件或电话来证明域所有权。浏览器地址栏仅显示 HTTPS 和一个挂锁，没有显示公司名称。
4. **通配符 SSL 证书：** 通配符 SSL 证书使您可以在单个证书上保护基本域和无限的子域。如果您有多个要保护的子域，那么，购买通配符 SSL 证书要比为每个子域购买单独的 SSL 证书便宜得多。通配符 SSL 证书的公用名中带有星号 *，其中，星号表示具有相同基本域的任何有效子域。常见客户为个人博客等。
5. **多域 SSL 证书 (MDC)：** 多域证书可用于保护许多域和/或子域名。这包括完全唯一的域和具有不同 TLD（顶级域）的子域（本地/内部域除外）的组合。例如：example.com、a.org、this-domain.net；默认情况下，多域证书不支持子域。如果您需要使用一个多域证书来保护 www.example.com 和 example.com，那么，在获取证书时，应同时指定两个主机名。
6. **统一通信证书 (UCC)：** 统一通信证书也被视为多域 SSL 证书。UCC 最初的设计意图是保护 Microsoft Exchange 和 Live Communications 服务器。如今，任何网站所有者都可以使用这些证书，以允许在一个证书上保护多个域名。UCC 证书经过组织验证，并在浏览器上显示挂锁。UCC 可以用作 EV SSL 证书，它会显示为绿色的地址栏，为网站访问者提供最高等级的保证。

*注：EV/OV/DV 为根据不同验证强度而指定的不同证书类型；此外，DV/OV SSL 证书均有支持通配符（泛域名）的 SSL 证书，但是 EV 不支持，如果需要达到相似的目的，那么需要使用 MDC，即多域 SSL 证书，MDC 为 EV 类型；DV/OV/EV 三种等级的 SSL 证书均可支持签发 UCC SSL证书。*

### 如何在日常浏览中区分 SSL 证书类别

根据证书类别的不同定义，我们可以通过证书字段比如组织（Organization）、公用名/域名（Common Name）等信息来对证书类别进行区分，但若我们只是普通用户，日常访问网站时能有什么办法对证书类别进行区分吗？这里介绍一些简单的方法。

在这里，我们以 DV、OV、EV 的区分举例。

首先，区分 DV 和 非 DV 证书比较简单，由于 OV 和 EV 证书均需要更高级别的验证，即验证组织信息，所以我们可以通过点击浏览器地址栏旁的小锁，并打开其中的证书信息来判断，若是颁发对象中“组织(O)”字段为空，则为 DV 证书，否则则不是。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-1.png)

其次，对于 EV 和 OV 证书，我们在详细信息的主题背景一栏中，可以发现 EV 证书比 OV 证书多了很多其他信息，最明显的区别是显示了序列号等信息，这是EV证书特有的字段。这是区分 EV 和 OV 证书的第一个方法。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-2.png)

此外，不同浏览器针对 EV 都有不同程度的提醒，以 chrome 为例，当你点击地址栏旁的小绿锁时，若数字证书为 EV 类型，证书状态下方会有一行小字显示其“颁发对象”具体信息。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-3.png)

### CA 分类与 PCA

按照颁发机构及受信状态不同，CA 可以分为两类：一类是**受信任的 CA**，也称商业 CA，是为申请证书的企业组织颁发数字证书的权威性第三方机构，并管理最终用户数据加密的公共密钥和证书；另一类为**私有 CA**，私有证书颁发机构（也称私有 PKI）是内部 CA，通常存在于大型企业中，企业自己创建、颁发数字证书，所以也称为自建 CA。

私有证书管理（Private Certificate Authority，PCA）是一个私有CA和私有证书管理平台。它允许用户建立自己完整的CA层次体系并使用它签发证书，实现了在组织内部签发和管理自签名私有证书。主要用于对组织内部的应用身份认证和数据加解密。

PCA 服务适用于企业对内使用和企业合规使用两种场景：

- 企业对内使用：一般用于不涉及监管、行业规范等要求，仅涉及企业内部应用数据需要密码技术提供加密的场景。企业内部应用（例如，内部的OA、HR等系统）可以使用PCA服务的密码技术进行应用间数据安全传输、数据加解密和身份认证。
- 企业合规使用：一般应用于密评或者要求满足电子认证服务相关要求的场景，例如，银企直连、电子签名等。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-4.png)

## 三、证书内容、格式与证书链

### 证书内容

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-5.png)

我将证书信息主要分为三类，主要包含：

1. 被颁发者信息：颁发的域名、关联子域以及所颁给的个人、企业、组织信息等等
2. 证书机构信息：证书颁发机构名称、数字签名等等
3. 证书信息：证书的版本号、序列号、签名算法、签发日期、到期日期、公钥等等

### 证书格式标准 X.509

X.509 是密码学里公钥证书的格式标准。X.509 证书已应用在包括 TLS/SSL 在内的众多网络协议里，同时它也用在很多非在线应用场景里，比如电子签名服务。X.509 证书里含有公钥、身份信息（比如网络主机名，组织的名称或个体名称等）和签名信息（可以是证书签发机构 CA 的签名，也可以是自签名）。我们所说的 CA 颁发的证书或者 SSL/TLS 证书指的都是符合 X.509 格式的证书。

另外，X.509 有多种常用的扩展名，比如 .pem、.cer、.crt、.der 等等。其中一些格式只能保存证书，比如 .cer、.der 等，其他一些格式还可以用于其它用途，就是说具有这个扩展名的文件可能并不是证书，比如说可能只是保存了私钥。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-6.png)

### SSL 证书链

证书包含的内容可以概述为三部分，用户的信息、用户的公钥、还有CA中心对该证书里面的信息的签名。我们在验证证书的有效性的时候，会逐级去寻找签发者的证书，直至根证书为结束，然后通过公钥一级一级验证数字签名的正确性。这里一系列的证书，便是证书链。

从组织结构来看，证书链是从终端用户证书到其后跟着的一系列 CA 证书，而通常最后一个（即根证书）是自签名证书，并且有如下关系：

1. 在证书链上除最后一个证书外，证书颁发者等于其后一个证书的主题。
2. 除了最后一个证书，每个证书都是由其后的一个证书签名的。
3. 最后的证书一般由操作系统直接内置，可以直接信任。

证书链可以用于检查目标证书（证书链里的第一个证书）里的公钥及其它数据是否属于其主题。检查是这么做的：用证书链中的后一个证书的公钥来验证它的签名，一直检查到证书链的尾端，如果所有验证都成功通过，那个这个证书就是可信的。

在此过程中，涉及到的证书包含如下几类：

1. 叶子证书，即最终的实体证书。
2. 中间证书，全称为中间证书颁发机构，是证书颁发机构（CA）为了自我隔离而颁发的证书。 其作用是通过中间证书的私钥来签署最终用户 SSL 证书，通过中间根对另一个中间根进行签名，然后 CA 使用它来对证书进行签名。
3. 根证书，证书颁发机构的自签名根证书。它的颁发者和主题是相同的，可以用自身的公钥进行合法认证。证书认证过程也将在此终止。

### 交叉证书

交叉证书的应用场景是这样的：假如现在小白成为一个新的根CA机构，那小白签发的证书想要浏览器信任的话，小白的根证书就需要内置在各大操作系统和浏览器中，这需要较长时间的部署，那在没有完全部署完成之前，小白签发的证书怎么才能让浏览器信任呢，这就需要用到交叉证书了。

简单来说，交叉证书会利用已有根 CA 的来为新 CA 签发一个交叉证书，在这个交叉证书里主题是新 CA 根证书信息，但是签发者是已有的根 CA。由于篇幅所限，本文不再针对交叉证书的具体工作原理进一步探究。

关于这部分的描述可以参照 Let’s Encrypt 的证书链示意图，或者参考文章 [https://scotthelme.co.uk/cross-signing-alternate-trust-paths-how-they-work/](https://scotthelme.co.uk/cross-signing-alternate-trust-paths-how-they-work/)

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-7.png)

## 四、证书工具与其他概念

### CSR 生成与解析

证书签名请求，全称 Certificate signing request，在公钥基础设施(PKI)系统中，证书签名请求（也称为 CSR 或证书请求）是从申请人发送到公钥基础设施的证书颁发机构以申请数字身份证书的消息。它通常包含应为其颁发证书的公钥、识别信息（例如域名）和完整性保护（例如数字签名）。

通常情况下，在申请一本证书时，证书申请者在申请数字证书时由 CSP（加密服务提供者）在生成私钥的同时也生成证书请求文件，证书申请者只要把 CSR 文件提交给证书颁发机构后，证书颁发机构使用其根证书私钥签名就生成了证书公钥文件，也就是颁发给用户的证书。

通过我们的证书工具，你可以填入必要的信息以生成一个符合规格的 CSR 信息及对应密钥；当然，当你拿到一串 CSR 明文后，你也可以逆向将其解析，以得到其中的域名、企业、部门等信息。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-8.png)

### PKI

公钥基础设施(PKI)是创建、管理、分发、使用、存储和撤销数字证书以及管理公钥加密所需的一组角色、策略、硬件、软件和程序。在密码学中，PKI 是一种将公钥与实体（如人和组织）的相应身份绑定的安排。

### OCSP、OCSP Stapling 与证书吊销

在线证书状态协议（英语：Online Certificate Status Protocol，缩写：OCSP）是一个用于获取 X.509 数字证书撤销状态的网际协议。

由数字证书认证机构运行的 OCSP 服务器会对请求返回经过其签名的证书状态信息，分别为：正常（Good）、已废除（Revoked）、未知（Unknown）。如果有无法处理的请求，则会返回一个错误码。OCSP 在极端情况下可能遭受来自中间人的重放攻击。

当我们一直在讨论从 HTTP 切换到 HTTPS 之后的安全性保证，但是切换之后连接变慢也是真实存在的一个问题，影响其中速度之一的因素便是 OCSP 状态查询。由于 OCSP 要求浏览器直接请求第三方 CA 以确认证书的有效性，当客户端访问 OCSP 服务器延时较高时，打开链接的速度就会相对变慢，从而影响访问体验。而对于 CA 来说，它也因为客户端的查询而知道哪些用户访问了哪些网站，这在隐私性上也存在问题。

为了解决访问速度以及保护隐私，OCSP Stapling 应运而生。OCSP Stapling，又名 TLS 证书状态查询扩展，其原理是：网站服务器将自行查询 OCSP 服务器并缓存响应结果，然后在与浏览器进行 TLS 连接时返回给浏览器，这样浏览器就不需要再去查询了。

![](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-12.png)

证书吊销指在证书到期前，将已经签发的证书从签发机构处注销。通过我们的证书工具，你可以将想查询的域名输入，点击查询，便可得到该域名下的证书序列号、吊销信息以及吊销时间等信息。

### 其他

在我们的日常浏览中，我们肯定看到过各类因为 SSL 证书状态无效/错误而被浏览器提示的场景页面，这里有一个网址提供有针对 SSL 证书各类错误状态的验证体验，感兴趣的话也可以移步 [https://badssl.com/](https://badssl.com/) 进行查看。

## 五、总结

全文在个人经过一段时间的实践后，并结合自身理解和学习进行总结，希望带大家了解关于 SSL/TLS 证书的方方面面。

**从文章结构上看，正文主体部分一共分为八个章节。其中[第一篇章](https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-One/)为基础篇，我们首先为全文提到的术语进行了归纳总结，而后从 CA、证书及其分类开始对证书进行正式介绍，之后对证书内容、证书格式、证书链及交叉证书进行了详细的阐述，本部分最后一章提及了一些实用的证书工具并对相关概念进行释义；[第二篇章](https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-Two/)为进阶篇，以“什么是 SSL/TLS 及其工作原理”开篇，然后通过证书、HTTPS 两个大方向来分别来介绍 SSL 证书是如何保证通信安全的。**

本文为该网络安全科普系列的第一篇——基础篇，地址为 <https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-One/>。关于第二篇的详细内容可以移步 <https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-Two/> 进行查看。正文部分到此结束，文中若有描述不准确的地方，还望指出，欢迎讨论交流。

## 参考

1. [https://en.wikipedia.org/wiki/Public_key_infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure)
2. [https://en.wikipedia.org/wiki/X.509](https://en.wikipedia.org/wiki/X.509)
3. [https://www.cloudflare.com/zh-cn/learning/ssl/what-is-https/](https://www.cloudflare.com/zh-cn/learning/ssl/what-is-https/)
4. [https://zhuanlan.zhihu.com/p/36981565](https://zhuanlan.zhihu.com/p/36981565)
5. [https://zhuanlan.zhihu.com/p/60033345](https://zhuanlan.zhihu.com/p/60033345)
6. [https://www.cnblogs.com/xdyixia/p/11610102.html](https://www.cnblogs.com/xdyixia/p/11610102.html)
7. [https://www.websecurity.digicert.com/zh/cn/security-topics/what-is-ssl-tls-https](https://www.websecurity.digicert.com/zh/cn/security-topics/what-is-ssl-tls-https)
8. [https://badssl.com/](https://badssl.com/)
9. [https://www.ssl2buy.com/wiki/how-to-view-ev-ssl-certificate-details-in-chrome-77](https://www.ssl2buy.com/wiki/how-to-view-ev-ssl-certificate-details-in-chrome-77)
10. [https://scotthelme.co.uk/cross-signing-alternate-trust-paths-how-they-work/](https://scotthelme.co.uk/cross-signing-alternate-trust-paths-how-they-work/)