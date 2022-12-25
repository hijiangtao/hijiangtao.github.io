---
title: 网络安全科普：详解 HTTPS 与 TLS
layout: post
thread: 286
date: 2022-12-25
author: Joe Jiang
categories: Document
tags: [HTTPS, TLS, mTLS, DTLS, SSL, CA, 证书, 网络安全, HTTP]
excerpt: 作为普通用户，当我们上网冲浪时，是否想过为什么越来越多的域名输入时是 HTTPS 开头而非 HTTP 么？HTTPS 相比 HTTP 多出来的 S 到底多了些什么？TLS 和 SSL 又是什么，握手机制是如何进行的？其在七层协议中处于什么位置，与 HTTPS 相关的概念比如 CA 证书、Keyless、DTLS、mTLS 又分别是些啥？当我们使用 wireshark 时又该怎么抓包分析……种种疑问，希望能通过这篇文章的介绍为大家解答其中的部分解惑。
toc: true
header:
  image: ../assets/in-post/2022-12-25-HTTP-and-TLS-Teaser.png
  caption: "©️hijiangtao"
---

## 引言

现在的网站都推荐使用 HTTPS 来确保用户数据的安全，验证网站的所有权，防止攻击者创建虚假网站版本，以及将信任传达给用户。如果网站要求用户登录、输入个人详细信息（例如其信用卡号）或查看机密信息（例如，健康福利或财务信息），则必须对数据保密。

作为普通用户，当我们上网冲浪时，是否想过为什么越来越多的域名输入时是 HTTPS 开头而非 HTTP 么？HTTPS 相比 HTTP 多出来的 S 到底多了些什么？TLS 和 SSL 又是什么，握手机制是如何进行的？其在七层协议中处于什么位置，与 HTTPS 相关的概念比如 CA 证书、Keyless、DTLS、mTLS 又分别是些啥？当我们使用 wireshark 时又该怎么抓包分析……种种疑问，希望能通过这篇文章的介绍为大家解答其中的部分解惑。

## 背景与介绍

### 什么是 HTTPS

超文本传输协议 (Hypertext Transfer Protocol, HTTP) 是设计用于在 Web 上传输内容的协议。 HTTP 是一种简单协议，它利用可靠的传输控制协议 (Transmission Control Protocol, TCP) 服务来执行其内容传输功能。由于数据在传输过程中是明文传输，因此无法保证网络通信在传输过程中不被篡改，安全性受到限制。

超文本传输安全协议 (HTTPS) 是 HTTP 的安全版本，但 HTTPS 并不是独立于 HTTP 的协议。它只是在 HTTP 协议的基础上使用 TLS/SSL 加密。HTTPS 经过加密，以提高数据传输的安全性。

### 为什么 HTTPS 可以保证安全

HTTPS 使用加密协议对通信进行加密。该协议称为传输层安全性 (TLS)，但以前称为安全套接字层 (SSL)。该协议通过使用所谓的非对称公钥基础架构来保护通信。这种类型的安全系统使用两个不同的密钥来加密两方之间的通信：

1. 私钥 - 此密钥由网站所有者控制，并且如读者所推测的那样，它是私有的。此密钥位于 Web 服务器上，用于解密通过公钥加密的信息。
2. 公钥 - 所有想要以安全方式与服务器交互的人都可以使用此密钥。用公钥加密的信息只能用私钥解密。

HTTPS安全是由一套安全机制来保证的，主要包含这4个特性：**机密性、完整性、真实性和不可否认性**。

- 机密性是指传输的数据是采用 Session Key（会话密钥）加密的，在网络上是看不到明文的。
- 完整性是指为了避免网络中传输的数据被非法篡改，使用 MAC 算法来保证消息的完整性。
- 真实性是指通信的对方是可信的，利用了 PKI（Public Key Infrastructure 即「公钥基础设施」）来保证公钥的真实性。
- 不可否认性是这个消息就是你给我发的，无法伪装和否认，是因为使用了签名的技术来保证的。

### 什么是 SSL/TLS

SSL（Secure Socket Layer）是指安全套接字层，简而言之，它是一项标准技术，可确保互联网连接安全，保护两个系统之间发送的任何敏感数据，防止网络犯罪分子读取和修改任何传输信息，包括个人资料。TLS（Transport Layer Security，传输层安全）是更为安全的升级版 SSL。

TLS 1.0 版实际上最初作为 SSL 3.1 版开发，HTTPS 是在 HTTP 协议基础上实施 TLS 加密，所有网站以及其他部分 web 服务都使用该协议。因此，任何使用 HTTPS 的网站都使用 TLS 加密。

使用了 SSL/TLS 之后，因为数据被非对称加密手段加密了，即使被截获，也是获取不到信息的。

TLS 协议实现的功能有三个主要组成部分：加密、认证和完整性。

- **加密：** 隐藏从第三方传输的数据。
- **身份验证：** 确保交换信息的各方是他们所声称的身份。
- **完整性：** 验证数据未被伪造或篡改。

### 为什么 SSL/TLS 可以保证安全

网站或应用程序要使用 TLS，必须在其源服务器上安装 TLS 证书（由于上述命名混淆，该证书也被称为 SSL 证书），而 TLS 连接是通过一个称为 TLS 握手的流程启动的，在这个过程中用户设备会和服务器交换确定信息，这些信息包括要使用的 TLS 版本、密码套件、TLS 证书、会话密钥等等。

而在浏览器端，当用户访问服务器页面的时候，浏览器会检查服务器的 SSL/TLS 许可是不是可用的，不可用的话，会提醒用户，这个网站不安全，也就是访问的数据可能被黑客截获；此时用户可以根据判断来不访问这个界面；许可都齐全的话，便可以安全的进行数据交互。

具体来说，SSL/TLS 在工作流程中通过如下三个方面保证安全性：

- 通过 CA 体系交换 public key
- 通过非对称加密算法，交换用于对称加密的密钥
- 通过对称加密算法，加密正常的网络通信

## 术语表

为了方便大家阅读，特在此章将全文涉及到的一些专业术语进行整理，整理此术语表供大家查阅。

| 简称    | 英文全称                                            | 中文全称             |
|-------|-------------------------------------------------|------------------|
| CA    | Certificate Authority / Certification Authority | 证书颁发机构           |
| SSL   | Secure Sockets Layer                            | 安全套接字层协议         |
| TLS   | Transport Layer Security                        | 传输层安全性协议         |
| PKI   | Public key infrastructure                       | 公钥基础设施           |
| PCA   | Private Certificate Authority                   | 私有证书颁发机构，又名私有 CA |
| HTTP  | Hypertext Transfer Protocol                     | 超文本传输协议          |
| HTTPS | Hypertext Transfer Protocol Secure              | 超文本传输安全协议        |
| -     | Public key                                      | 公钥               |
| -     | Private key                                     | 私钥               |
| OSI   | Open Systems Interconnection                    | 开放网络互联模型         |
| TCP   | Transmission Control Protocol                   | 传输控制协议           |
| DTLS  | Datagram Transport Layer Security               | 数据包传输层安全性协议      |
| mTLS  | Mutual Transport Layer Security                 | 双向 TLS           |
| DH    | Diffie-Hellman key exchange                     | 迪菲-赫尔曼密钥交换       |
| -     | premaster secret                                | 预主密钥             |

## TLS 相关协议详解

### HTTPS 协议组成

HTTP 协议是用于从网络传送超文本数据到本地浏览器的传送协议，HTTPS 协议简单讲是 HTTP 的安全版，在 HTTP 协议的基础上加入 SSL 层。

其中，HTTP的端口号为80， HTTPS的端口号为443，两者均为应用层协议，在 OSI 七层模型的最上层。

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-0.png)

### HTTPS 与 CA 证书

在 HTTPS 的工作流程中，一个重要的角色便是证书，他的正常运行需要有一个证书（CA 证书）：由专门的证书机构颁发。在知道了 TLS 的握手流程后，我们来看看证书在其中所起到的作用。

当客户端向服务端发送请求，请求中会向服务器提供以下信息：客户端支持的协议版本，比如TLS 1.0 版，此后，服务器返回经过 CA 认证的数字证书，证书里面包含了服务器的 public key，接下来证书在客户端的工作流程如下：

- 客户端读取证书中的相关的明文信息，采用相同的散列函数计算得到信息摘要，然后，利用对应CA的公钥解密签名数据，对比证书的信息摘要，如果一致，则可以确认证书的合法性，即公钥合法；
- 客户端然后验证证书相关的域名信息、有效时间等信息；
- 客户端会内置信任 CA 的证书信息（此处一般指顶级 CA 的自签根证书，包含公钥），如果 CA 不被信任，则找不到对应 CA 的证书，证书也会被判定非法；此外，客户端还会通过 OCSP 对证书状态进行查询；
- 客户端在完成对数字证书的验证后，用自己浏览器内置的 CA 证书解密得到服务器的 public key；
- 客户端用服务器的 public key 加密一个预主密钥（这个密钥将在之后结合随机数等信息被用于客户端和服务端各自生成用于网络通信的对称密钥），传给服务器。因为只有服务器有 private key 可以解密，所以不用担心中间人拦截这个加密数据而获取其中的密钥信息；
- 服务器拿到这个加密的密钥，解密获取信息，再依据双方约定好的参数生成对称加密密钥，并以此和客户端完成接下来的网络通信；

关于 TLS 证书/CA 证书的更多细节，可以参见文章《[奇妙的 SSL/TLS 证书](https://hijiangtao.github.io/2022/11/16/Dig-Out-All-Secrets-Behind-TLS-Certificate-One/)》，本文不再深入探讨。

### TLS/SSL 握手与密钥交换

HTTPS 连接建立过程和 HTTP 差不多，区别在于 HTTP（默认端口 80） 请求只要在 TCP 连接建立后就可以发起，而 HTTPS（默认端口 443） 在 TCP 连接建立后，还需要经历 SSL 协议握手，成功后才能发起请求。

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-1.png)

#### TLS 1.2 握手流程

在 TLS1.2 以前，需要2-RTT时间进行握手，我们具体来看每一步操作：

1. **第1步：**整个连接是从客户端向服务器发送“Client Hello”消息开始。该消息由加密信息组成，与此同时客户端也会将本身支持的所有密码套件（Cipher Suite）列表发送过去，包括支持的协议和支持的密码套件，也包含一个随机值或随机字节串。
2. **第2步：**响应客户端的“客户端问候”消息，服务器以“Server Hello”消息响应。此消息包含服务器已从客户端提供的 CipherSuite 中选择的 CipherSuite。服务器还会将其证书以及会话ID和另一个随机值一起发送。
3. **第3步：**客户端验证服务器发送的证书。验证完成后，它会发送一个随机字节字符串，也称为“预主密钥”，并使用服务器证书的公钥对其进行加密。客户端向服务器发送“ChangeCipherSpec”消息，通过会话密钥的帮助让它知道它将切换到对称加密。与此同时，它还发送“客户端已完成”消息。
4. **第4步：**一旦服务器收到预主密钥，客户端和服务器都会生成一个主密钥以及会话密钥(临时密钥)。这些会话密钥将用于对称加密数据。在答复客户端的“更改密码规范”消息时，服务器执行相同操作并将其安全状态切换为对称加密。服务器通过发送“服务器已完成”消息来结束握手。

在客户端和服务器之间进行了两次往返（2-RTT）以完成握手。 平均而言，这需要0.25秒到0.5秒之间的时间。而这只是握手过程，实际的数据传输还没有开始。我们绘制示意图如下解释如上流程：

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-2.png)

#### TLS 1.3 握手流程

TLS1.3 在握手上做了优化，只需要一次时延往返就可以建立连接（1-RTT），其握手基本步骤为：

- **客户端问候：**客户端发送客户端问候消息，内含协议版本、客户端随机数和密码套件列表。由于已从 TLS 1.3 中删除了对不安全密码套件的支持，因此可能的密码套件数量大大减少。客户端问候消息还包括将用于计算预主密钥的参数。
- **服务器生成主密钥：**此时，服务器已经接收到客户端随机数以及客户端的参数和密码套件。它已经拥有服务器随机数，因为它可以自己生成。因此，服务器可以创建主密钥。
- **服务器问候和“完成”：**服务器问候包括服务器的证书、数字签名、服务器随机数和选择的密码套件。因为它已经有了主密钥，所以它也发送了一个“完成”消息。
- **最后步骤和客户端“完成”：**客户端验证签名和证书，生成主密钥，并发送“完成”消息。
- **实现安全对称加密：**依据双方约定好的参数生成的对称加密主密钥，将被用在接下来客户端和服务端的网络通信中；

TLS 1.3 的核心宗旨是简单性。在新版本中，除去了 Diffie-Hellman（DH）密钥交换以外的所有密钥交换算法。简而言之，DH 算法（Diffie-Hellman 算法）可以保证在双方不直接传输原始密钥的情况下，完成双方密钥交换。

TLS 1.3 还定义了一组经过测试的 DH 参数，无需与服务器协商参数。由于只有一个密钥交换算法（具有内置参数）和少数支持的密码，因此设置 TLS 1.3 通道所需的绝对带宽比早期版本要少得多。示意图流程如下：

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-3.png)

### 基于 UDP 的 TLS 协议：DTLS

#### DTLS 介绍

DTLS 是基于 UDP 场景下数据包可能丢失或重新排序的现实情况下，为 UDP 定制和改进的 TLS 协议。

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-4.png)

DTLS 协议由两层组成: Record 协议 和 Handshake 协议

1. Record 协议：使用对称密钥对传输数据进行加密，并使用 HMAC 对数据进行完整性校验，实现了数据的安全传输。
2. Handshake 协议：使用非对称加密算法，完成 Record 协议使用的对称密钥的协商。

#### DTLS 与 TLS 握手差异

与 TLS 的握手流程相比，DTLS 的握手流程存在如下几点差异（左为 TLS 握手，右为 DTLS 握手）：

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-5.png)

1. HelloVerifyRequest 用于服务端对客户端实现二次校验；DTLS 的 RecordLayer 新增了 SequenceNumber 和 Epoch，以及 ClientHello 中新增了 Cookie，以及 Handshake 中新增了 Fragment 信息（防止超过 UDP 的 MTU），都是为了适应 UDP 的丢包以及容易被攻击做的改进；
2. Certificate 是交换的证书，由协商后的算法确定是否需要传输；
3. TLS 没有发送 CertificateRequest，这个也不是必须的，是反向验证即服务器验证客户端；当服务端要求验证客户端身份时，发起 CertificateRequest，此时客户端需要发送证书；
4. ChangeCipherSpec 是一个简单的标记，标明当前已经完成密钥协商，可以准备传输；
5. Finished 消息表示握手结束，通常会携带加密数据由对端进行初次验证。

#### DTLS 的握手防护、加密方式与应用场景

在实现机制上，DTLS 还存在几个特点，首先是握手防护机制，在这个机制中，除了上文说到的防止被攻击等在握手阶段引入的改进措施外，还有一个机制叫重传：

- DTLS 每一方在每次握手中传送的第一个消息总是有 message_seq = 0。每当有新消息产生时，message_seq 的值就会增加1。
- DTLS需兼容多种出错场景，出错时往往直接丢弃处理，而在 TLS 中，如果出错，则会中断连接；

以握手的第一阶段举例，客户端发送 Client Hello（不带 Cookie，区别于握手流程中的第二次 Client Hello）之后，启动一个定时器，等待服务端返回 HelloVerifyRequest，如果超过了定时器时间客户端还没有收到 HelloVerifyRequest，那么客户端就会知道要么是 Client Hello 消息丢了要么是 Hello Verify Request 消息丢了，客户端就会再次发送相同的 Client Hello 消息，即使服务端确实发送了 Hello Verify Request 还是收到了 Client Hello 消息，它也知道是需要重传，并再次发送 Hello Verify Request 消息，同样地，服务端也会启动定时器来等待下一条消息。

由于 DTLS 依赖 UDP，而 SSL/TLS 依赖 TCP，所以两者在加密方式上存在如下差异：

1. SSL/TLS 不能独立解密单个封包，SSL/TLS 对于封包的认证需要序号作为输入，在 SSL/TLS 中并未直接传递序号，因为 TCP 是可靠的，所以 SSL/TLS 的两端各自维护自身的收发序号；
2. DTLS 支持独立解密，其通过在每条记录中显式携带的序号作为解码的输入；此外，由于算法加解密的限制，DTLS所支持的加密算法为 TLS 的子集。

DTLS 主要被用在 WebRTC 协议中，以保证媒体传输的安全性。

### 客户端身份校验与 mTLS

在基础的 TLS 认证流程中，大量的场景都是确保用户访问的是真正的服务方，如：银行、电商网站等等，即保证用户不会被钓鱼网站或是中间人攻击，此时我们只需要在客户端侧对服务端身份进行校验。

#### SSL 连接中的客户端身份校验

在典型的 SSL 连接场景中，通过 HTTPS 连接到服务器的客户端会检查服务器的有效性，它会在启动 SSL 握手时检查服务器返回证书的有效性。但是，有时你可能希望将服务器配置为对与其连接的客户端进行身份验证。这样，你便可以只允许使用证书进行身份验证的用户访问 web 服务器上的资源。

启用客户端身份校验的两个基本步骤：

1. 客户端需要获取、并安装经过 CA 认证的 SSL/TLS 证书
2. 服务端需要开启客户端身份验证选项

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-6.png)

由于客户端安装证书的不方便性、成本高以及双因素身份验证的快速推行，客户端身份验证并没有得到广泛使用。

#### mTLS 介绍

很多时候，比如在一些支付场景下，我们和支付机构、商户构成的三者关系中，在商户和支付机构间需要保证相互的身份认证，以保证支付信息在两者间正常流转，这时便需要我们使用双向认证，即相互 TLS。

相互 TLS，简称 mTLS，是一种相互身份验证的方法。mTLS 通过验证他们都拥有正确的私人密钥来确保网络连接两端的各方都是他们声称的身份。他们各自的 TLS 证书中的信息提供了额外的验证。

#### mTLS 与 TLS 流程的区别

一个典型的 TLS 流程应该包含如下几步：

1. 客户端连接到服务器
2. 服务器出示其 TLS 证书
3. 客户端验证服务器的证书
4. 客户端和服务器通过加密的 TLS 连接交换信息

相比之下，mTLS 会在客户端验证服务器证书后加上几步，以保证服务端可以对客户端身份进行验证，并授予访问权限，一个完整的 mTLS 流程如下：

1. 客户端连接到服务器
2. 服务器出示其 TLS 证书
3. 客户端验证服务器的证书
4. **客户端出示其 TLS 证书**
5. **服务器验证客户端的证书**
6. **服务器授予访问权限**
7. 客户端和服务器通过加密的 TLS 连接交换信息

#### mTLS 的应用场景与安全性

由于公共互联网上亟待解决的问题是防止被访问的网站内容被篡改，保证用户不会访问到钓鱼网站；此外，再加上将 TLS 证书分发到所有终端用户设备上是非常困难的现状，mTLS 并没有被运用到整个互联网。mTLS 对于较小范围内的组织验证和通信非常有用，除了验证信息外，他还可以防止各种类型的攻击，比如在途攻击、网络钓鱼攻击以及恶意 API 请求等等。

mTLS 通常被用于零信任安全框架，以验证组织内的用户、设备和服务器。它也可以帮助保持 API 的安全。

### HTTPS 与 Keyless SSL

虽然 HTTPS 可以解决传输的安全性但是引入了私钥的安全和管理问题。只要拿到了私钥，HTTPS 就如同虚设。尤其是在传统 CDN 加速场景下，需要将私钥证书同步给 CDN，无形中增加了风险，所以诞生了 Keyless 技术。这项技术可以使得客户在使用 CDN 进行 HTTPS 加速时保留其自身 SSL 的私钥，在仅有公钥的场景下顺利完成 SSL 握手。

在 Keyless 的作用下，服务端不解密密文，而是将经加密后的预主密钥（premaster secret）等数据打包发送给远端 key server，由其进行加工并返回数据；针对 DH 协商密钥的流程，服务端则负责将 DH 参数、服务端随机数、客户端随机数等数据传给 key server，由 key server 处理后返回 DH 数据以及证书等信息。

以 CloudFlare 为例，我们看看 Keyless 在部署时有设计哪些额外的流程以保证安全。为了使 Keyless SSL 安全，CloudFlare 边缘到 key server 的连接也需要安全。key server 可以为所有能够访问它的人提供私钥操作，就像一个密码数据库。保证只有 CloudFlare 可以访问 key server 来执行操作对 Keyless SSL 至关重要。

CloudFlare 通过相互认证的 TLS 机制来保证 CloudFlare 和 key server 之间的连接安全。在握手环节一章，我们提到了客户端对服务端的单方向身份认证，是通过验证 CA 证书来进行的，而后我们也提到了客户端身份校验，这在这里便派上了用场。在 TLS 双向认证中，客户端和服务端都由对方的证书并相互认证。

在 Keyless SSL 中，key server 仅允许携带 CloudFlare 内部签发的证书的连接。CloudFlare 使用我们自己签发的证书来进行双向认证。

在这里，我们以 RSA 为例，如下两图展示了在接入 Keyless 前后，TLS 握手过程的变化差异。

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-7.png)

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-8.png)

### RFC 协议标准

本文介绍的各类协议均有对应的 RFC 标准，罗列于此供读者参考：

1. TLS1.3 [https://www.rfc-editor.org/rfc/rfc8446](https://www.rfc-editor.org/rfc/rfc8446)
2. DTLS1.2 [https://www.rfc-editor.org/rfc/rfc6347.html](https://www.rfc-editor.org/rfc/rfc6347.html)
3. HTTPS [https://www.rfc-editor.org/rfc/rfc2818.html](https://www.rfc-editor.org/rfc/rfc2818.html)
4. MTLS [https://www.rfc-editor.org/rfc/rfc8705](https://www.rfc-editor.org/rfc/rfc8705)

## HTTPS 流量抓包与分析

利用 wireshark 我们可以对 https 流量进行抓包分析，下载地址见 [https://www.wireshark.org/#download](https://www.wireshark.org/#download)

### 操作与步骤

通过 Wireshark 我们可以很好的过滤 HTTPS 流量，比如如下常见的几个过滤条件：

```
// TLS加密传输数据的过滤器
ssl.record.content_type == 23  and tcp.dstport == 443

// TLS 建立连接
ssl.handshake.type == 1

// 在知道 IP 地址为A时的指定 TLS 流量
ip.addr == A && tcp.port == 443
```

但对于 HTTPS 流量，如果需要解密，我们还需要增加如下几个步骤来达成目的：

1. 在终端打开你的 chrome 浏览器，并指定你的 SSL key 的 log 日志存放地址，假设地址为A；
2. 在 WireShark 中，通过路径 Wireshark - Preferences - Protocols - TLS ，在 (Pre)-Master-Secret log filename 输入同样的地址 A，并保存；
3. 然后通过第一步打开的浏览器访问 https 协议的网站地址，并在 wireshark 中指定 filter 例如 `tls && ip.addr=1.1.1.1` 来过滤指定 tls 流量；

通过 Wireshark 抓包，以一个 TLS1.2 版本的 ClientHello 消息报文内容为例，我们可以看到其中包含了客户端支持的 TLS 版本、加密套件、以及用于连接的 SNI 等信息

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-9.png)

同样的，以一个 TLS1.2 版本的建立连接为例，我们可以看到 Server 在返回 Server Hello 之后还返回了证书、Server Key Exchange 以及 Server Done 等信息

![Untitled](/assets/in-post/2022-12-25-HTTP-and-TLS-10.png)

## 应用与拓展场景

### 实现 Charles 抓包代理

用过抓包工具的人都知道，比如 Charles，Fiddler 是可以抓取 HTTPS 请求并解密的，它们是如何做到的呢？

简单来说，Charles 作为一个“中间人代理”，当浏览器和服务器通信时，Charles 接收服务器的证书，然后动态生成一张证书发送给浏览器，也就是说 Charles 作为中间代理在浏览器和服务器之间通信，所以通信的数据可以被 Charles 拦截并解密，这包括服务器证书公钥和 HTTPS 连接的对称密钥。

由于 Charles 更改了证书，浏览器校验不通过会给出安全警告，所以 Charles 可以正常工作的前提在于必须安装 Charles 的证书，使系统信任。

### 为开发环境启动 HTTPS

在本地开发功能模块时，可能有些 Web API 前置要求环境为 HTTPS，这要求我们在本地开发环境也能够配置 HTTPS，OpenSSL 是 SSL 和 TLS 协议的开放式源代码实现，使用它，我们可以在本地生成一个自签名证书，以方便开发。如下一行命令可以帮助我们生成一个 HTTPS 证书以及私钥：

```
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem
```

社区里有一个开源库叫 mkcert，可以更便捷的为你生成 TLS 证书，这里不深入介绍，感兴趣可以移步 [https://github.com/FiloSottile/mkcert](https://github.com/FiloSottile/mkcert) 查看更多。

注：为了能够正常使用，本地生成的证书需要被加入信任列表才能正常使用。

## 参考

1. [https://www.cloudflare.com/zh-cn/learning/ssl/what-happens-in-a-tls-handshake/](https://www.cloudflare.com/zh-cn/learning/ssl/what-happens-in-a-tls-handshake/)
2. [https://tech.bytedance.net/articles/7166221771396349982](https://tech.bytedance.net/articles/7166221771396349982)
3. [https://blog.csdn.net/qzcsu/article/details/72861891](https://blog.csdn.net/qzcsu/article/details/72861891)
4. [https://tinychen.com/20200602-encryption-intro/](https://tinychen.com/20200602-encryption-intro/)
5. [https://comodosslstore.com/blog/what-is-ssl-tls-client-authentication-how-does-it-work.html](https://comodosslstore.com/blog/what-is-ssl-tls-client-authentication-how-does-it-work.html)
6. [https://web.dev/i18n/zh/how-to-use-local-https/](https://web.dev/i18n/zh/how-to-use-local-https/)
7. [https://blog.cloudflare.com/announcing-keyless-ssl-all-the-benefits-of-cloudflare-without-having-to-turn-over-your-private-ssl-keys/](https://blog.cloudflare.com/announcing-keyless-ssl-all-the-benefits-of-cloudflare-without-having-to-turn-over-your-private-ssl-keys/)
8. [https://blog.cloudflare.com/keyless-ssl-the-nitty-gritty-technical-details/](https://blog.cloudflare.com/keyless-ssl-the-nitty-gritty-technical-details/)
9. [https://tech.bytedance.net/articles/6915326021995200519](https://tech.bytedance.net/articles/6915326021995200519)
10. [https://www.cloudflare.com/zh-cn/learning/access-management/what-is-mutual-tls/](https://www.cloudflare.com/zh-cn/learning/access-management/what-is-mutual-tls/)