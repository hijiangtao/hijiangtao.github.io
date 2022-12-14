---
title: 网络安全科普：奇妙的 SSL/TLS 证书（进阶篇）
layout: post
thread: 283
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

本文为奇妙的 SSL/TLS 证书第二篇章——进阶篇，以下开始正文。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-0.png)

## 一、关于 SSL/TLS 的来龙去脉

现在的网站都推荐使用 SSL 证书来确保用户数据的安全，验证网站的所有权，防止攻击者创建虚假网站版本，以及将信任传达给用户。

如果网站要求用户登录、输入个人详细信息（例如其信用卡号）或查看机密信息（例如，健康福利或财务信息），则必须对数据保密。

### SSL/TLS 是什么

SSL（Secure Socket Layer）是指安全套接字层，简而言之，它是一项标准技术，可确保互联网连接安全，保护两个系统之间发送的任何敏感数据，防止网络犯罪分子读取和修改任何传输信息，包括个人资料。TLS（Transport Layer Security，传输层安全）是更为安全的升级版 SSL。

TLS 1.0 版实际上最初作为 SSL 3.1 版开发，HTTPS 是在 HTTP 协议基础上实施 TLS 加密，所有网站以及其他部分 web 服务都使用该协议。因此，任何使用 HTTPS 的网站都使用 TLS 加密。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-9.png)

### 为什么需要 SSL/TLS

两者创建的目的都是提高网络中数据访问的安全性，因为在 http 携带需要传送的数据，数据没有任何的保护，是容易被黑客拦截下来的；使用了 SSL/TLS 之后，因为数据被非对称加密手段加密了，即使被截获，也是获取不到信息的。

TLS 协议实现的功能有三个主要组成部分：加密、认证和完整性。

- **加密：**隐藏从第三方传输的数据。
- **身份验证：**确保交换信息的各方是他们所声称的身份。
- **完整性：**验证数据未被伪造或篡改。

### SSL/TLS 是如何工作的

网站或应用程序要使用 TLS，必须在其源服务器上安装 TLS 证书（由于上述命名混淆，该证书也被称为 SSL 证书），而 TLS 连接是通过一个称为 TLS 握手的流程启动的，在这个过程中用户设备会和服务器交换确定信息，这些信息包括要使用的 TLS 版本、密码套件、TLS 证书、会话密钥等等。

而在浏览器端，当用户访问服务器页面的时候，浏览器会检查服务器的 SSL/TLS 许可是不是可用的，不可用的话，会提醒用户，这个网站不安全，也就是访问的数据可能被黑客截获；此时用户可以根据判断来不访问这个界面；许可都齐全的话，便可以安全的进行数据交互。

具体来说，SSL/TLS 在工作流程中通过如下三个方面保证安全性：

- 通过 CA 体系交换 public key
- 通过非对称加密算法，交换用于对称加密的密钥
- 通过对称加密算法，加密正常的网络通信

### SSL 证书、SSL/TLS、HTTP 和 HTTPS 的关系

TLS 已经完全的代替掉 SSL 了，所以只推荐 TLS；目前的 SSL 证书许可，下发的其实都是 SSL/TLS 证书。

HTTP 是超文本传输协议，信息是明文传输；HTTPS，也称作 HTTP over TLS，则是具有安全性的 SSL 加密传输协议。

HTTPS 协议需要到证书颁发机构 (Certificate Authority，简称 CA)申请证书，通过数字证书管理服务完成证书购买、申请，并将证书部署到您的 Web 服务器后，Web 服务将会通过 HTTPS 加密协议来传输数据。

## 二、证书与安全

### 信息加密与算法标准

在介绍证书的加密方式前，我们来回顾下都有哪些数据的传输方式。

1. **明文传输：** HTTP协议是明文传输的，明文就是未被加密过的原始数据，解析传输数据包中截获到的内容便可直接获知传输的内容是什么。
2. **对称加密：** 加密和解密的秘钥使用的是同一个，通常用来加密消息体。常见的对称加密算法包含有 AES、DES、3DES、TDEA、Blowfish、RC4、RC5、IDEA 等等。由于加密算法是公开的，若要保证安全性，密钥不能对外公开。
3. **非对称加密：** 与对称加密算法不同，非对称加密算法需要两个密钥：公开密钥（public key）和私有密钥（private key）。非对称加密算法实现机密信息交换的基本过程是：甲方生成一对密钥并将其中的一把作为公用密钥向其它方公开；得到该公用密钥的乙方使用该密钥对机密信息进行加密后再发送给甲方；甲方再用自己保存的另一把专用密钥对加密后的信息进行解密。甲方只能用其专用密钥解密由其公用密钥加密后的任何信息。常见的非对称加密算法包含有 RSA、DSA/DSS、Elgamal、Rabin、D-H、ECC 等等*。
4. **单向加密摘要：** 哈希(Hash)算法，即散列函数。它是一种单向密码体制，即它是一个从明文到密文的不可逆的映射，只有加密过程，没有解密过程。同时，哈希函数可以将任意长度的输入经过变化以后得到固定长度的输出。

**注：文中虽然提到“常见的非对称加密算法包含有 RSA、DSA/DSS、ElGamal、Rabin、D-H、ECC 等等”，但在实际实践中由于安全性及用途等区别，仍会有一些出入，在此作简单解释：其中 RSA、ECC 是生成 SSL/TLS 证书所使用的主要算法；DSA 即数字签名算法，被美国国家标准局用来做DSS数据签名标准，在安全性上存在隐患；D-H 算法作为密钥一致协议，作为确保共享 KEY 安全穿越不安全网络的方法理论；ElGamal 加密算法是一个基于迪菲-赫尔曼密钥交换的非对称加密算法；Rabin 算法是一种基于模平方和模平方根的非对称加密算法。*

TLS/SSL 的功能实现主要依赖于**三类基本算法**：**散列（哈希）函数 Hash**、**对称加密**和**非对称加密**，其利用非对称加密实现身份认证和密钥协商，对称加密算法采用协商的密钥对数据加密，基于散列（哈希）函数验证信息的完整性。

具体来说，hash 主要用来生成签名，签名是加在信息后面的，可以证明信息没有被修改过。一般对信息先做 hash 计算得到一个 hash 值，然后用私钥加密（这个加密一般是非对称加密）作为一个签名和信息一起发送。接收方收到信息后重新计算信息的 hash 值，且和信息所附带的 hash 值解密后进行对比。如果一样则认为没有被修改，反之则认为修改过，不做处理。

除了上面提到的算法外，常见的公有云厂商售卖中还会提供一种叫 SM 的加密方式，即国密算法，即国家商用密码算法。这是由国家密码管理局认定和公布的密码算法标准及其应用规范，其中部分密码算法已经成为国际标准。国密算法主要有 SM1，SM2，SM3，SM4。

### 从签发过程来看如何确保证书的安全性

要完成一本证书的签发与使用，通常包含如下流程：

1. 首先，需求方向第三方机构 CA （中间 CA，或者是供应商代理）提交公钥、组织信息、个人信息（域名）等信息并申请认证，私钥自己保存不做提交；
2. CA 通过线上、线下等多种手段验证申请者提供信息的真实性，如组织是否存在、企业是否合法，是否拥有域名的所有权等；
3. 如信息审核通过，CA 会向申请者签发认证文件，即 TLS/SSL 证书。 颁发的证书中会包含以下信息：申请者公钥、申请者的组织信息和个人信息、签发机构 CA 的信息、有效时间、证书序列号等信息的明文，同时包含一个签名；
4. 签名的产生算法在上文也提到过，这里再简要介绍一下：首先，使用散列函数计算公开的明文信息的信息摘要；然后，采用 CA 的私钥对信息摘要进行加密，密文即签名；
5. 此后，需求方便可将证书存放在服务器上，当用户从客户端向服务器发出请求时，服务器可以返回证书文件；

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-10.png)

## 三、HTTPS 与安全

### 什么是 HTTPS

超文本传输协议安全 (HTTPS) 是 HTTP 的安全版本，HTTP 是用于在 Web 浏览器和网站之间发送数据的主要协议。HTTPS 并不是独立于 HTTP 的协议。它只是在 HTTP 协议的基础上使用 TLS/SSL 加密。HTTPS 经过加密，以提高数据传输的安全性。

HTTPS 使用加密协议对通信进行加密。该协议称为传输层安全性 (TLS)，但以前称为安全套接字层 (SSL)。该协议通过使用所谓的非对称公钥基础架构来保护通信。这种类型的安全系统使用两个不同的密钥来加密两方之间的通信：

1. 私钥 - 此密钥由网站所有者控制，并且如读者所推测的那样，它是私有的。此密钥位于 Web 服务器上，用于解密通过公钥加密的信息。
2. 公钥 - 所有想要以安全方式与服务器交互的人都可以使用此密钥。用公钥加密的信息只能用私钥解密。

![Untitled](/assets/in-post/2022-11-16-Dig-Out-All-Secrets-Behind-TLS-Certificate-11.png)

### 从 HTTPS 工作流程再谈安全性

结合上文提到的证书签发过程中，我们继续结合 HTTPS 的工作流程来看看如何通过证书保证通信的安全性：

- 当客户端向服务端发送请求，请求中会向服务器提供以下信息：客户端支持的协议版本，比如TLS 1.0 版；
- 服务器返回经过 CA 认证的数字证书，证书里面包含了服务器的 public key；
- 客户端读取证书中的相关的明文信息，采用相同的散列函数计算得到信息摘要，然后，利用对应CA的公钥解密签名数据，对比证书的信息摘要，如果一致，则可以确认证书的合法性，即公钥合法；
- 客户端然后验证证书相关的域名信息、有效时间等信息；
- 客户端会内置信任 CA 的证书信息（此处一般指顶级 CA 的自签根证书，包含公钥），如果 CA 不被信任，则找不到对应 CA 的证书，证书也会被判定非法；
- 客户端在完成对数字证书的验证后，用自己浏览器内置的 CA 证书解密得到服务器的 public key；
- 客户端用服务器的 public key 加密一个预主密钥（这个密钥将在之后结合随机数等信息被用于客户端和服务端各自生成用于网络通信的对称密钥），传给服务器。因为只有服务器有 private key 可以解密，所以不用担心中间人拦截这个加密数据而获取其中的密钥信息；
- 服务器拿到这个加密的密钥，解密获取信息，再依据双方约定好的参数生成对称加密密钥，并以此和客户端完成接下来的网络通信；

### 为什么 HTTPS 是安全的

HTTPS安全是由一套安全机制来保证的，主要包含这4个特性：**机密性、完整性、真实性和不可否认性**。

- 机密性是指传输的数据是采用 Session Key（会话密钥）加密的，在网络上是看不到明文的。
- 完整性是指为了避免网络中传输的数据被非法篡改，使用 MAC 算法来保证消息的完整性。
- 真实性是指通信的对方是可信的，利用了 PKI（Public Key Infrastructure 即「公钥基础设施」）来保证公钥的真实性。
- 不可否认性是这个消息就是你给我发的，无法伪装和否认，是因为使用了签名的技术来保证的。

## 四、总结

全文在个人经过一段时间的实践后，并结合自身理解和学习进行总结，希望带大家了解关于 SSL/TLS 证书的方方面面。

**从文章结构上看，正文主体部分一共分为八个章节。其中[第一篇章](https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-One/)为基础篇，我们首先为全文提到的术语进行了归纳总结，而后从 CA、证书及其分类开始对证书进行正式介绍，之后对证书内容、证书格式、证书链及交叉证书进行了详细的阐述，本部分最后一章提及了一些实用的证书工具并对相关概念进行释义；[第二篇章](https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-Two/)为进阶篇，以“什么是 SSL/TLS 及其工作原理”开篇，然后通过证书、HTTPS 两个大方向来分别来介绍 SSL 证书是如何保证通信安全的。**

本文为该网络安全科普系列的第二篇——进阶篇，地址为 <https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-Two/>。关于前一篇的详细内容可以移步 <https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-One/> 进行查看。正文部分到此结束，文中若有描述不准确的地方，还望指出，欢迎讨论交流。

## 附：术语表

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
