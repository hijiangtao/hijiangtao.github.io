---
title: TLS/ESNI/ECH/DoT/DoH/JA3 - 谈谈 HTTPS 网络下浏览体验安全性的最后缝隙
layout: post
thread: 281
date: 2022-10-09
author: Joe Jiang
categories: Document
tags: [TLS, ESNI, ECH, DoT, DoH, JA3, HTTPS, 网络安全, 加密, DNS]
excerpt: 有了 HTTPS 我们的网络访问就完美无缺了吗？TLS 在握手 Client Hello 阶段的数据包，包含客户端想访问的地址等信息，而这些信息是明文传输的，这使得第三方可以通过监听等手段知道你想访问哪些网址。本文会按照加密方式的加工流程倒序介绍，先介绍关于 TLS 握手阶段的 SNI 相关信息，再谈谈 DNS 安全层，最后会介绍下 TLS 握手指纹……
toc: true
header:
  image: ../assets/in-post/2022-10-09-Secure-Your-Browsing-Experience-with-More-Encrypted-Tools-0.png
  caption: "©️hijiangtao"
---

![](/assets/in-post/2022-10-09-Secure-Your-Browsing-Experience-with-More-Encrypted-Tools-Teaser.png )

## 从 TLS 说起

TLS，全称 Transport Layer Security，安全传输层协议，前身为 SSL （Secure Socket Layer，安全套接层），位于 TCP 与应用层之间。HTTPS 相对于 HTTP 来说，协议本身并未改变，而是在 TCP 与 HTTP 间添加了一层 TLS 用作加密以保证信息安全。

从 TLS 的角度说起，它希望解决网络流量明文传输存在的几类风险：窃听、篡改、伪造，这里摘录 [https://zinglix.xyz/2019/05/07/tls-handshake/](https://zinglix.xyz/2019/05/07/tls-handshake/) 对 TLS 解决三类风险的一段总结：

- **窃听**：握手过程中信息交换是明文，但是只是关于加密套件及证书信息的交换，第三方获得也没有用。而关键的可获得密钥的预主密钥则通过非对称加密方式传输，握手完成后使用对称加密，窃听者均无法获得密钥所以无法窃听。
- **篡改**：握手过程中，证书有哈希这一过程无法被篡改，其他信息被篡改会导致之后双方通信无法进行。握手完成后，因为无法获得密钥进行加密，所以虽然可以修改包内容，但无法变成攻击者预期的内容。
- **伪造**：密钥协商中的预主密钥用的是证书公钥加密的，其中证书是被确定可信的，而只有证书拥有者能解密，所以密钥只有通信双方拥有，因此不可能被伪造。

但这么做就完美了吗？TLS 在握手 Client Hello 阶段的数据包，包含客户端想访问的地址等信息，而这些信息是明文传输的，这使得第三方可以通过监听等手段知道你想访问哪些网址。

本文会按照加密方式的加工流程倒序介绍，先介绍关于 TLS 握手阶段的 SNI 相关信息，再谈谈 DNS 安全层，最后会介绍下 TLS 握手指纹，通过本文，你或许可以对以下信息有更深入的了解：

1. 了解为什么 ESNI 对于保护隐私性和安全性必不可少
2. 了解 ESNI 如何使用公钥加密和 DNS 记录进行工作
3. 了解什么是 DNS 安全层，以及 DoT/DoH 实现标准都是什么
4. 了解什么是 ECH 以及其与 ESNI 的区别
5. 了解 TLS 握手指纹以及 JA3/JA3S/JARM 都是怎么计算得到的 

本文基于个人理解与学习进行整理，如有不准确的地方还望指出，所参考的资料均在文末参考一章中罗列。本文在最后一章节对全文整理的内容进行了概况总结，已经有相关基础的同学可以直接跳转查看。

## Server Name Indication (SNI)

### 为什么需要 SNI

当多个网站托管在一台服务器上并共享一个 IP 地址，并且每个网站都有自己的 SSL 证书，在客户端设备尝试安全地连接到其中一个网站时，服务器可能不知道显示哪个 SSL 证书。这是因为 SSL/TLS 握手发生在客户端设备通过 HTTP 指示连接到某个网站之前。

### 什么是 SNI

SNI (Server Name Indication，服务器名称指示) 是为了解决一个服务器使用多个域名和证书的 TLS扩展，主要解决一台服务器只能使用一个证书的缺点。SNI 是 TLS 协议（以前称为 SSL 协议）的扩展，该协议在 HTTPS 中使用。它包含在 TLS/SSL 握手流程中，以确保客户端设备能够看到他们尝试访问的网站的正确 SSL 证书。该扩展使得可以在 TLS 握手期间指定网站的主机名或域名，而不是在握手之后打开 HTTP 连接时指定。

### SNI 是怎么工作的

开启 SNI 后，允许客户端在发起 SSL 握手请求时就提交请求的域名信息，负载均衡收到 SSL 请求后，会根据域名去查找证书，如果找到域名对应的证书，则返回该证书；如果没有找到域名对应的证书，则返回缺省证书。负载均衡在配置 HTTPS 监听器支持此功能，即支持绑定多个证书。

TLS 的做法，是在 TLS 握手第一阶段 ClientHello （客户端问候）的报文中就添加包含主机名。SNI 在 TLSv1.2 开始得到支持。从 OpenSSL 0.9.8 版本开始支持。

SNI 将域名添加到TLS握手过程，以便 TLS 程序到达正确的域名并接收正确的 SSL 证书，从而使其余 TLS 握手能够正常进行。

## Encrypted Server Name Indication (ESNI)

### 为什么需要 ESNI

虽然 TLS 能够加密整个通信过程，但是在协商的过程中依旧有很多隐私敏感的参数不得不以明文方式传输，其中最为重要且棘手的就是将要访问的域名，即 SNI。

加密 SNI (Encrypted Server Name Indication, ESNI) 通过加密客户端问候的 SNI 部分来添加到 SNI 扩展，这可以防止任何在客户端和服务器之间窥探的人看到客户端正在请求哪个证书，从而进一步保护客户端。Cloudflare 和 Mozilla Firefox 于 2018 年推出了对 ESNI 的支持。

ESNI 可以确保正在侦听的第三方无法监视 TLS 握手流程并以此确定用户正在访问哪些网站。

### ESNI 是如何工作的

ESNI 通过公钥加密客户端问候消息的 SNI 部分（仅此部分），来保护 SNI 的私密性。加密仅在通信双方（在此情况下为客户端和服务器）都有用于加密和解密信息的密钥时才起作用，就像两个人只有在都有储物柜密钥时才能使用同一储物柜一样。

由于客户端问候消息是在客户端和服务器协商 TLS 加密密钥之前发送的，因此 ESNI 加密密钥必须以其他方式进行传输。

Web 服务器可以在其 DNS 记录中添加一个公钥，这样，当客户端查找正确的服务器地址时，同时能找到该服务器的公钥。这有点像将房门钥匙放在屋外的密码箱中，以便访客可以安全地进入房屋。然后，客户端即可使用公钥来加密 SNI 记录，以便只有特定的服务器才能解密它。

![](/assets/in-post/2022-10-09-Secure-Your-Browsing-Experience-with-More-Encrypted-Tools-1.png )

## Encrypted Client Hello (ECH)

### 使用 ESNI 仍然存在的问题

ESNI 存在问题。首先是密钥的分发，Cloudflare 在部署时每个小时都会轮换密钥，这样可以降低密钥泄露带来的损失，但是 DNS 有缓存的机制，客户端很可能获得的是过时的密钥，此时客户端就无法用 ESNI 继续进行连接。其次是对网站的 DNS 请求可能返回有几个 IP 地址，每个地址分别代表了不同的 CDN 服务器，然而 ESNI 的 TXT 记录只有一个，可能会将该密钥发送给了错误的服务器导致握手失败。

自从 ESNI 规范草案在 IETF 上发布以来，分析表明仅仅加密 SNI 扩展提供的保护是不完整的。为了解决 ESNI 的问题，最近发布的规范不再只加密 SNI 扩展，而是对整个 Client Hello 信息进行加密，因此标准名称从 ESNI 也变成了 ECH。

### 什么是 ECH

**ECH（Encrypted Client Hello，也称加密客户端问候）**出现的目标就是就是为了克服 ESNI 的缺陷，同时也正如其名，ECH 有着更大的野心，不单单加密 SNI，而是要加密整个 Client Hello。

### ECH 的工作原理

ECH 同样采用 DoH （后文会进行详细介绍，此处可暂时理解成 DNS 安全层的一种实现）进行密钥的分发，但是在分发过程上进行了改进。如果解密失败，ESNI 服务器会中止连接，而 ECH 服务器会提供给客户端一个公钥供客户端重试连接，以期可以完成握手。

**ECH 协议实际上涉及两个 ClientHello 消息：ClientHelloOuter，它像往常一样以明文形式发送；ClientHelloInner，它被加密并作为 ClientHelloOuter 的扩展发送。**服务器仅使用其中一个 ClientHello 完成握手：如果解密成功，则继续使用 ClientHelloInner；否则，它只使用 ClientHelloOuter。

ClientHelloInner 由客户端想要用于连接的握手参数组成。这包括它想要访问的源服务器的 SNI、ALPN 列表等。ClientHelloOuter 虽然也是一个成熟的 ClientHello 消息，但不用于预期的连接。相反，握手是由 ECH 服务提供者完成，在无法完成解密的情况下，它会向客户端发出信号，表明由于解密失败而无法到达其预期的目的地。此时，服务提供商还会发送正确的 ECH 公钥，客户端可以使用该公钥重试握手，从而“更正”客户端的配置。

![](/assets/in-post/2022-10-09-Secure-Your-Browsing-Experience-with-More-Encrypted-Tools-2.png )

## DNS 安全层

### 为什么 DNS 需要额外的安全层

DNS 是互联网的电话簿；DNS 解析器将人类可读的域名转换为机器可读的 IP 地址。默认情况下，DNS 查询和响应以明文形式（通过 UDP）发送，这意味着它们可以被网络、ISP 或任何能够监视传输的人读取。即使网站使用 HTTPS，也会显示导航到该网站所需的 DNS 查询。 

这种隐私上的欠缺对安全有着巨大影响，如果 DNS 查询不是私密的，则攻击者可以轻松跟踪用户的Web 浏览行为。

### 基于 TLS 的 DNS 标准（DoT）

**基于 TLS 的 DNS（DNS over TLS，简称 DoT）**是加密 DNS 查询以确保其安全和私密的一项标准。DoT 使用安全协议 TLS，这与 HTTPS 网站用来加密和认证通信的协议相同。DoT 在用于 DNS 查询的用户数据报协议（TCP）的基础上添加了 TLS 加密，这可以确保 DNS 请求和响应不会被[在途攻击](https://www.cloudflare.com/learning/security/threats/on-path-attack/)篡改或伪造。

与 DoT 采用在 TCP 协议上处理稍有不同的是，还存在另一个在 UDP 协议上加密的标准，**DNS over DTLS，**即基于 UDP 的 DNS TLS 加密协议标准。

### 基于 HTTPS 的 DNS 标准（DoH）

基于 HTTPS 的 DNS 或 DoH 是 DoT 的替代标准。使用 DoH 时，DNS 查询和响应会得到加密，但它们是通过 HTTP 或 HTTP/2 协议发送，而不是直接通过 UDP 发送。与 DoT 一样，DoH 也能确保攻击者无法伪造或篡改 DNS 流量。从网络管理员角度来看，DoH 流量表现为与其他 HTTPS 流量一样，如普通用户与网站和 Web 应用进行的交互。

### DoT 与 DoH 的区别

这两项标准都是单独开发的，并且各有各的 RFC 文档，但 DoT 和 DoH 之间最重要的区别是它们使用的端口。DoT 仅使用端口 853，DoH 则使用端口 443，后者也是所有其他 HTTPS 流量使用的端口。

由于 DoT 具有专用端口，因此即使请求和响应本身都已加密，具有网络可见性的任何人都发现来回的 DoT 流量。DoH 则相反，DNS 查询和响应伪装在其他 HTTPS 流量中，因为它们都是从同一端口进出的。

### 其他加密 DNS 请求的方式

除了上文提到的几种标准外，想要达到 DNS 请求加密的目的，我们仍然有多种其他实现方式：

1. VPN：通过 VPN，你不仅可以加密 DNS 请求，甚至可以将所有网络流量进行加密传输；
2. DNSCurve：DNSCurve 使用 Curve25519 椭圆曲线加密算法创建 Salsa20 使用的密钥，配以 MAC 函数 Poly1305，用来加密和验证解析器与身份验证服务器之间的 DNS 网络数据包。它的提出者希望用 DNSCurve 替代 DNSSEC；
3. DNSCrypt：DNSCrypt 是由 Frank Denis 及付业成（Yecheng Fu）主导设计的网络协议，用于用户计算机与递归域名服务器之间的域名系统（DNS）通信的身份验证。DNSCrypt 将未修改的 DNS 查询与响应以密码学结构打包来检测是否被伪造；
4. IPsec：IPsec（Internet Protocol Security）是为 IP 网络提供安全性的协议和服务的集合，它是VPN（Virtual Private Network，虚拟专用网）中常用的一种技术。 由于 IP 报文本身没有集成任何安全特性，IP 数据包在公用网络如 Internet 中传输可能会面临被伪造、窃取或篡改的风险。通信双方通过 IPsec 建立一条 IPsec 隧道，IP数据包通过 IPsec 隧道进行加密传输，有效保证了数据在不安全的网络环境如 Internet 中传输的安全性；

## TLS 握手指纹

TLS 握手指纹又叫 SSL 指纹，或者 JA3 指纹，是根据客户端向服务端发送的 Client Hello 信息中部分字段计算得出的 hash 值信息。

此外，在 TLS 握手中还有服务端响应的 Server Hello，这类信息也有特征，根据类似的思路可以得到 JA3S 指纹。又由于服务端会根据不同的 Client Hello 响应不同的 Server Hello，根据这个又可以得到 JARM 指纹。

![](/assets/in-post/2022-10-09-Secure-Your-Browsing-Experience-with-More-Encrypted-Tools-3.png )

### 什么是 JA3/JA3S

由于 TLS/SSL 协商以明文形式传输，因此可以使用 SSL Client Hello 数据包中的详细信息对客户端应用程序进行指纹识别。JA3 从 Client Hello 数据包中的以下字段收集十进制字节值：

```jsx
SSLVersion,Cipher,SSLExtension,EllipticCurve,EllipticCurvePointFormat
// 分别代表 TLS/SSL 版本，可接受的密码，扩展列表，椭圆曲线，椭圆曲线格式
```

然后按顺序将这些值连接在一起，使用`,`分隔每个字段，使用`-`分隔每个字段中的每个值，如果没有 TLS/SSL 扩展则留空，最后对这些字符串进行 MD5 散列以生成易于使用和共享的32个字符指纹，这就是 JA3 客户端指纹。

对于服务端来说，同一台服务器会根据`Client Hello`消息及其内容以不同的方式创建其`Server Hello`消息。因此，这里不能像客户端和JA3那样，仅仅根据服务器的Hello消息来对其进行指纹识别。

JA3S是用于 SSL/TLS 通信的服务器端的JA3, 服务器对特定客户机响应的指纹。

JA3S 使用以下字段生成指纹：`SSLVersion,Cipher,SSLExtension`，在应用中，需要通过结合`JA3 + JA3S`对客户端与其服务器之间的整个加密协商进行指纹识别。因为服务器会对不同的客户端做出不同的响应，但对同一个客户端的响应总是相同的。

通过以上两类指纹可以来标记SSL握手中客户端、服务端特征。关于 JA3/JA3S 的详细定义可参见 [https://github.com/salesforce/ja3](https://github.com/salesforce/ja3)

### 什么是 JARM

TLS Server 根据 TLS Client Hello 中参数的不同，返回不同的 Server Hello 数据包。而 Client Hello 的参数可以人为指定修改，因此通过发送多个精心构造（比如指定不同的TLS版本、支持套件等来试探服务端响应情况）的 Client Hello 获取其对应的特殊 Server Hello（包含服务器返回的加密套件、服务器返回选择使用的 TLS 协议版本、TLS 扩展 ALPN 协议信息、TLS 扩展列表等信息），最终形成 JARM 指纹信息，来标记服务器的特征。具体能够产生影响的参数包括但不限于：

- 操作系统及其版本
- OpenSSL等第三方库及其版本
- 第三方库的调用顺序
- 用户自定义配置

与 JA3/JA3S 是在流量被动监听中得到的方式不同的是，JARM 是通过主动探测的方式得到。

详细定义可参见 [https://github.com/salesforce/jarm](https://github.com/salesforce/jarm)

### TLS 握手指纹的用途

两者均是 TLS 握手信息（版本、支持套件）的简化表现形式。所以 JA3/JA3S 可以用来标记特质的客户端、服务端所产生的流量。

JA3S 指纹则根据客户端的不同环境（系统版本等）有变化。JARM 则可以用来威胁狩猎。

## 总结

TLS 协议已经成为互联网上最流行的协议，以确保网络通信免受干扰和窃听。但在握手阶段，由于 SNI 信息是明文传输，这导致了客户端的访问网址等信息容易被窃听。

ESNI 是保护网络隐秘性和安全性的重要步骤，但其他新协议和功能也很重要。设计 Internet 时并未考虑安全性和隐私性，因此，在访问网站的过程中有很多步骤都是非私密的。但是，有各种新协议都有助于对每个步骤进行加密，使之免受恶意攻击者的攻击。

域名系统或 DNS 将人类可读的网站地址（如 www.example.com）与字母数字 IP 地址进行匹配。这就像在所有人都使用的大型地址簿中查找某人的地址一样。但是，普通的 DNS 未加密，这意味着任何人都可以看到某人正在查找哪个地址，并且任何人都可以伪装成地址簿。即使安装了 ESNI，攻击者仍然可以查看用户正在查询的 DNS 记录，并确定他们正在访问哪些网站。

其他三个附加协议旨在弥补这些空白：

1. 基于 TLS 的 DNS
2. 基于 HTTPS 的 DNS
3. DNSSEC

基于 TLS 的 DNS 和基于 HTTPS 的 DNS 都在做同样的事情：使用 TLS 加密来加密 DNS 查询。它们之间的主要区别在于使用网络的哪个层以及使用哪个网络端口。DNSSEC 确认 DNS 记录真实并来自合法的 DNS 服务器，而非来自冒充 DNS 服务器的攻击者（例如，发生 [DNS 缓存中毒攻击](https://www.cloudflare.com/learning/dns/dns-cache-poisoning/)时）。

说完浏览私密性保证，我们再来看看对恶意流量的分析检测。由于网络管理人员可以识别和阻止自定义协议，很多恶意工具已经转向使用现有协议，TLS的流行为这些恶意工具提供了一个很好的选择，使用TLS协议的恶意工具可以将其流量隐藏在大量web浏览器和其他TLS的合法覆盖流量中以逃避检测。

从 TLS 连接（Client hello 阶段）中提取特定的一些字段生成指纹，通过分析恶意工具和常规工具在协议信息上的区别，可以进一步分析或者研究，通过连接模式或时间特征来检测恶意流量。

## 概念释义与其他

1. **服务器名称**：服务器名称就是计算机的名称。对于Web服务器，此名称通常对最终用户不可见，除非该服务器仅托管一个域并且该服务器名称与该域名等同。
2. **主机名**：主机名是连接到网络的设备的名称。在互联网背景中，域名或网站名称是一种主机名。两者都与与域名关联的 IP 地址分开。
3. **虚拟主机名**：虚拟主机名是没有自己的IP地址的主机名，它与其他主机名一起托管在服务器上。它是"虚拟的" ，因为它没有专用的物理服务器，就像虚拟现实仅以数字形式存在，而不是在物理世界中一样。
4. **AdGuard 进展**：AdGuard 是一款跨平台内容过滤的广告拦截软件。其对 DoH、ESNI 等的支持仍在筹划中 [https://github.com/AdguardTeam/CoreLibs/issues/722](https://github.com/AdguardTeam/CoreLibs/issues/722)
5. **浏览器对 ESNI 的支持情况**：当前只有 Firefox 支持 ESNI。
6. **浏览器对 DoH/DoT 的支持情况**：所有主流浏览器均支持。

## 参考

1. [https://www.infoblox.com/dns-security-resource-center/dns-security-faq/are-dns-requests-encrypted/](https://www.infoblox.com/dns-security-resource-center/dns-security-faq/are-dns-requests-encrypted/)
2. [https://zhufan.net/2022/06/18/tls%E6%8F%A1%E6%89%8B%E6%8C%87%E7%BA%B9%E6%A3%80%E6%B5%8B%E6%81%B6%E6%84%8F%E8%BD%AF%E4%BB%B6%E6%B5%81%E9%87%8F/](https://zhufan.net/2022/06/18/tls%E6%8F%A1%E6%89%8B%E6%8C%87%E7%BA%B9%E6%A3%80%E6%B5%8B%E6%81%B6%E6%84%8F%E8%BD%AF%E4%BB%B6%E6%B5%81%E9%87%8F/)
3. [https://blog.mozilla.org/security/2018/10/18/encrypted-sni-comes-to-firefox-nightly/](https://blog.mozilla.org/security/2018/10/18/encrypted-sni-comes-to-firefox-nightly/) 
4. [https://www.cloudflare.com/zh-cn/learning/dns/dns-over-tls/](https://www.cloudflare.com/zh-cn/learning/dns/dns-over-tls/)
5. [https://zinglix.xyz/2021/04/03/esni-ech/](https://zinglix.xyz/2021/04/03/esni-ech/)
6. [https://blog.cloudflare.com/encrypted-client-hello/](https://blog.cloudflare.com/encrypted-client-hello/)
7. [https://zinglix.xyz/2019/05/07/tls-handshake/](https://zinglix.xyz/2019/05/07/tls-handshake/)
8. [https://engineering.salesforce.com/tls-fingerprinting-with-ja3-and-ja3s-247362855967/](https://engineering.salesforce.com/tls-fingerprinting-with-ja3-and-ja3s-247362855967/)