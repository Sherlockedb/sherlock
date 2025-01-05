---
title: 私有云搭建（一）树莓派4安装ubuntu server
description:
author: Sherlockedb
date: 2025-01-05 15:46:00 +0800
categories: [raspberry pi4, 私有云搭建, ubuntu]
tags: [raspberry pi4, 私有云搭建, ubuntu]
lang: zh
---

---
## 硬件准备
&emsp;&emsp;硬件列表如下：
+ 树莓派4一个，我的是4g版本
+ 两个硬盘：一个系统盘(500G)、一个数据盘(1TB)
+ 一个USB-Hub：带供电(5V2A)，这个比较重要，直接把两个硬盘连到树莓派4的USB接口上会导致电压不稳定，从而异常重启。

    ![](https://blogs.dns.army/imgbed/blog/private_cloud_architecture-backup-scheme.drawio.svg)

&emsp;&emsp;两个硬盘作用是为了备份，系统盘安装系统用，然后也用来备份一些重要数据，另外一个数据盘就是平时提供服务使用。我在[私有云搭建（零）架构：服务和拓扑图](https://blogs.dns.army/posts/private-cloud/)里面也讲过我的备份方案，不仅系统盘有备份，时不时也会手动备份到PC机上，冷热双重保险。

---
## 系统下载

#### 1. Raspberry Pi Imager下载
`Raspberry Pi Imager`是树莓派官方一个下载树莓派系统镜像和将镜像写到硬盘或SD卡的工具。先到这个网址：[Install Raspberry Pi OS using Raspberry Pi Imager](https://www.raspberrypi.com/software/)，按自己操作系统平台下载对应的软件。

![](https://blogs.dns.army/imgbed/blog/202501051601240.png)

#### 2. ubuntu server镜像下载
ubuntu官网就有支持树莓派设备的ubunt-server镜像，进去这个网址：[Install Ubuntu on a Raspberry Pi](https://ubuntu.com/download/raspberry-pi)，如果这个网址失效了，直接`google`关键词：`ubuntu raspberry pi`，一般就能搜到ubuntu官网对应的树莓派镜像下载地址。

![](https://blogs.dns.army/imgbed/blog/202501051603649.png)

一般选最新的长期支持版本，目前长期支持版本是`Ubuntu 24.04.1 LTS`，可以下载桌面版，也可以下载服务器版。但更建议服务器版本，毕竟咱们是搭建云服务器。

---
## 安装前准备
把两个硬盘都格式化为ext4，`Windows`用`disk geninus`，`Mac`用自带磁盘工具，`Linux`用命令行。以上不懂的移步`Baidu`、`Google`、`ChatGPT`，不详细讲了。

---
## 安装ubuntu server
参考ubuntu官方教程：[How to install Ubuntu Server on your Raspberry Pi](bhttps://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview)总结下安装流程如下。

打开`Raspberry Pi Imager`
![](https://blogs.dns.army/imgbed/blog/20250105161851174.png)

选择对应的设备，我这里是树莓派4
![](https://blogs.dns.army/imgbed/blog/20250105162003425.png)

选择操作系统，其实可以直接在这里下载，对应入口：`Other general-purpose OS`->`Ubuntu`->`Ubuntu Server 24.04.1 LTS(64-bit)`，但我是先下了系统镜像的，所以直接拉到最下面：`Use custom`，然后选择对应的镜像，我下载的镜像是`ubuntu-24.04.1-preinstalled-server-arm64+raspi.img.xz`
![](https://blogs.dns.army/imgbed/blog/20250105162108736.png)

选择好镜像后就是选择存储卡，把硬盘插到电脑，选择对应的硬盘就可以了。
![](https://blogs.dns.army/imgbed/blog/20250105162409815.png)

全部选择完毕后点击`next`会弹出这个界面，选择`编辑设置`
![](https://blogs.dns.army/imgbed/blog/20250105163233673.png)

把`用户名`和`密码`，还有`语言设置`两个设置一下，这样就不会有时差问题
![](https://blogs.dns.army/imgbed/blog/20250105163329504.png)

然后选择开启一下`ssh服务`，方便直接在电脑ssh过去，而不用插个线连到屏幕上去设置，先使用密码登录，后面要关闭再去关闭。
![](https://blogs.dns.army/imgbed/blog/20250105163411280.png)

点击保存，然后`Next`，选择是，就可以把镜像写到硬盘了，注意不要选错硬盘了，这里会格式化。然后等待写盘完成就可以拔出硬盘，插到连在树莓派的`USB-Hub`上，然后开机，等待个几分钟系统初始化完成。

---
## 安装后配置

&emsp;&emsp;系统安装好后，怎么找到树莓派ip地址登录到ubuntu呢，有两种方法：

+ 用micro hdmi线将树莓派连到电脑屏幕上，然后登录ubuntu，用命令

    ```shell
    # 一般eth0对应的ip地址就是树莓派内网的ip地址
    ip -4 addr
    ```

+ 登录路由器的管理页面，查看是否有新设备联网，对应的ip地址应该就是树莓派的

&emsp;&emsp;这里建议用路由器将树莓派的物理地址和ip地址绑定，以后连树莓派或者重装也都是这个ip了，免去找ip的烦恼，而且平时登录树莓派也不用每次都去路由器看。

&emsp;&emsp;好了，咱们的ubuntu系统就安装完成了，后面就可以开始来安装我们需要的服务了。
