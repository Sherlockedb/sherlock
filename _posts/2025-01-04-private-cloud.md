---
title: 私有云搭建（零）架构：服务和拓扑图
description:
author: Sherlockedb
date: 2025-01-04 15:31:00 +0800
categories: [raspberry pi4, 私有云搭建]
tags: [raspberry pi4, 私有云搭建]
lang: zh
---


# 前言
---
&emsp;&emsp;本篇文章是关于本人私有云搭建系列的概要篇，主要介绍我搭建私有云的初衷和演变，以及私有云的架构包括运行的服务和网络拓扑图。


---
## 私有云搭建的初衷和演变
&emsp;&emsp;初衷：本来我是想搭个云相册服务，方便我随时随地同步和查看图片，以及做一些备份，因为我本来是有一个树莓派4的，上面装的是`ubuntu-server`，所以找个开源的相册就可以了，最后找到了`immich`。

&emsp;&emsp;演变：
+ `ddns+ipv6`：一开始计划是把`immich`部署在树莓派上，然后看了下官方文档和一些部署教程，也有讲到备份方案等，看着看着发现还有外网部署方案：ddns(动态dns)+ipv6，看起来也不错。不过要网络支持ipv6，于是我看了下我宽带，也是支持ipv6，光猫也是默认配置了开启ipv6，去树莓派上看了下，也是有ipv6地址，于是这个方案可行，所以加了`ddns+ipv6`服务。
+ `ufw`：然后因为都有外网了，肯定要注意一下安全，于是要有防火墙，只对外开放80和443端口。
+ `nginx-certbot`：考虑到后面可能有服务扩展，所以要有反向代理服务，用域名访问服务，要有https证书申请和更新服务，选了`nginx-certbot`。
+ `wireguard`：后面又想着都有ipv6可以直接访问内网了，那平时在公司或者外面有需要连内网，是不是也得搞个vpn，选了`wireguard`。
+ `博客`：部署了这些后，突然想写个博客记录下，刚好也可以部署在这上面，我之前用的github-pages部署的，但考虑到国内网络访问GitHub不是很方便，所以部署个国内访问也比较方便。博客相关的服务如下：
    * `图床(SFTP+PicList)`：博客用到的图片上传到这里。
    * `github-webhook`：自动部署博客。
+ `docker`：为了部署以及迁移方便，大部分服务优先考虑用`docker`部署，所以装了`docker`服务。
+ `v2ray`：因为网络原因，得装个梯子才能拉取到docker镜像，所以还得装个科学上网工具`v2ray`。
+ `samba`：最后还有个`samba`服务，这是本来就装在上面的，可以用来内网文件共享，或者看视频图片等。

---
## 主要运行的服务

![](https://blogs.dns.army/imgbed/blog/private_cloud_architecture-rasraspberry-pi4-service.svg)

---
## 网络拓扑图

![](https://blogs.dns.army/imgbed/blog/private_cloud_architecture-network-top-graph.svg)

## 数据备份

&emsp;&emsp;数据备份是非常重要的，我这里方案是三份数据：
+ 原始数据
+ 热备份：定时自动备份到另外一个硬盘
+ 冷备份： 电脑开机手动备份到电脑的硬盘

备份的数据内容一般是部署服务的配置、服务对应的数据库等这些数据。

&emsp;&emsp;为了搞热备份我还专门用个`usb-hub`连两个硬盘，注意要`usb-hub`要有额外供电的，为两个硬盘供电，直接插树莓派4的`usb`口会电压不足，没发提供稳定电流，导致系统会异常重启。

![](https://blogs.dns.army/imgbed/blog/private_cloud_architecture-backup-scheme.drawio.svg)


---
## 思考

&emsp;&emsp;写这一系列文章主要目的一方面是为了记录搭建服务器的流程和注意点，另外一方面是记录当下对搭建这种类似NAS的低成本方案和想法。方便以后如果要重新搭建也可以基于此次搭建的基础上进行优化。比如架构上基本可以不变，把树莓派换成性能好点的其它服务器；服务器上的服务也可以换成对应的其它替代品，这个因人因时而异，还有数据备份方案可以用开源组件等等。最主要还是要在搭建的这个系统上一步步实践一步步迭代来将这些用于服务我们的生活和工作，让我们更便利。