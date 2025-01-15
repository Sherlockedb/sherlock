---
title: 私有云搭建（二）ubuntu安装docker和v2rayA
description:
author: Sherlockedb
date: 2025-01-15 16:46:20 +0800
categories: [raspberry pi4, 私有云搭建, ubuntu, docker, v2rayA]
tags: [raspberry pi4, 私有云搭建, ubuntu, docker, v2rayA]
lang: zh
---

# 前言
---
&emsp;&emsp;我们[前面](https://blogs.dns.army/posts/private-cloud/)讲过，私有云部署的服务尽量用`docker`来部署，所以我们要先安装`docker`，然后由于众所周知的网络问题，`docker`拉取镜像需要科学上网，所以我们还需要安装`v2rayA`。

## 安装`docker`

&emsp;&emsp;安装`docker`比较简单，直接问`ChatGPT`，照着做就行了，以下命令都来自`ChatGPT`，我简单整理了一下，建议读者们也问问`GPT`来安装，以下命令不一定是最新的。
```shell
#  更新系统并安装依赖
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
# 添加 Docker 的官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# 添加 Docker 的软件源
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# 安装 Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
# 验证docker是否安装成功
docker --version
```

&emsp;&emsp;安装后设置开机启动，并把当前用户加入到`docker`组里面，以便可以直接运行`docker`命令。

```shell
# 设置开机自启
sudo systemctl enable docker
# 添加当前用户到 Docker 组
sudo usermod -aG docker $USER
```

&emsp;&emsp;注意：修改用户组后需要注销并重新登录才能生效。

## 安装`v2rayA`

&emsp;&emsp;`v2rayA`是一个易用而强大的，跨平台的`V2Ray`客户端，主页是这个：[v2rayA](https://v2raya.org/)。这个客户端的界面是网页，用这个的好处是对于无界面的服务器，也可以直接用ip登录到对应服务器上的`v2rayA`后台去配置。

&emsp;&emsp;本来安装`v2rayA`也挺简单的，直接几个命令就可以了，但我也想用`docker`来部署`v2rayA`，看了下官方安装教程，也是有[`docker`安装](https://v2raya.org/docs/prologue/installation/docker/)的，但现在问题出现了，`docker`拉取镜像要先安装`v2rayA`，而用`docker`来安装`v2rayA`要先用`docker`拉取镜像，死锁了。所以这里就有两种方案：

+ 先直接安装`v2rayA`，然后用`docker`拉取`v2rayA`镜像，配置好后再删掉非`docker`安装的`v2rayA`
+ 从其它可以科学上网的电脑下载`arm`版的`v2rayA`镜像，打包复制到树莓派上来安装

&emsp;&emsp;我选择了后者，原因如下：用`docker`安装是为了方便部署和迁移，用第一种方案不如直接安装就好了，因为你再一次部署到新机器一样是这么麻烦，没利用到`docker`安装的好处，有点舍本逐末，为了用`docker`而用`docker`。而第二种方案，我们只需要把这个打包的镜像保存好，下次部署一也可以用。那我们就开始安装。

### 在其它电脑将镜像保存到文件
&emsp;&emsp;我在`MacBook`上安装`docker`，由于我的`MacBook`是M芯片的，跟树莓派一样是`arm`架构，所以拉取镜像时可以不用指定平台，如果你是用`windows`或者是`intel`芯片的`Mac`，可以加个参数`--platform`来指定平台，具体咨询`ChatGPT`。
```shell
docker pull mzz2017/v2raya
docker save -o v2raya.tar mzz2017/v2raya
```

### 在树莓派加载镜像文件
&emsp;&emsp;然后把我们打包的文件`scp`到树莓派，运行如下命令加载镜像：
```shell
docker load -i v2raya.tar
```
&emsp;&emsp;查看本地的`docker`镜像是否有`mzz2017/v2raya`：
```shell
docker image ls
```

### 启动配置`v2rayA`
&emsp;&emsp;[官方教程：`docker`安装`v2rayA`](https://v2raya.org/docs/prologue/installation/docker/)里面给出了运行`v2rayA`的示例：
```shell
docker run -d \
  --restart=always \
  --privileged \
  --network=host \
  --name v2raya \
  -e V2RAYA_LOG_FILE=/tmp/v2raya.log \
  -e V2RAYA_V2RAY_BIN=/usr/local/bin/v2ray \
  -e V2RAYA_NFTABLES_SUPPORT=off \
  -e IPTABLES_MODE=legacy \
  -v /lib/modules:/lib/modules:ro \
  -v /etc/resolv.conf:/etc/resolv.conf \
  -v /etc/v2raya:/etc/v2raya \
  mzz2017/v2raya
```
&emsp;&emsp;为了部署迁移方便，我希望用`docker compose`来部署，也方便备份配置文件和数据，于是我就把这个示例仍给了`ChatGPT`，叫他帮忙改成`docker compose`的配置文件：
```yml
version: '3.8'
services:
  v2raya:
    image: mzz2017/v2raya
    container_name: v2raya
    restart: always
    privileged: true
    network_mode: "host"
    environment:
      - V2RAYA_LOG_FILE=/tmp/v2raya.log
      - V2RAYA_V2RAY_BIN=/usr/local/bin/v2ray
      - V2RAYA_NFTABLES_SUPPORT=off
      - IPTABLES_MODE=legacy
    volumes:
      - /lib/modules:/lib/modules:ro
      - /etc/resolv.conf:/etc/resolv.conf
      - /etc/v2raya:/etc/v2raya
```

&emsp;&emsp;我加了个时区环境变量，以及配置的路径不同，稍微修改了一下，最终配置文件如下，文件名为`v2rayA.yml`：

```yml
name: v2rayA

services:
  v2raya:
    container_name: v2raya
    image: mzz2017/v2raya:latest
    restart: always
    privileged: true
    network_mode: "host"
    environment:
      V2RAYA_LOG_FILE: /tmp/v2raya.log
      V2RAYA_V2RAY_BIN: /usr/local/bin/v2ray
      V2RAYA_NFTABLES_SUPPORT: off
      IPTABLES_MODE: legacy
      TZ: Asia/Shanghai
    volumes:
      - /lib/modules:/lib/modules:ro
      - /etc/resolv.conf:/etc/resolv.conf
      - ./config:/etc/v2raya
```
&emsp;&emsp;专门创建一个`v2rayA`文件夹来存放镜像、yml配置和本身的程序配置，方便备份和迁移：

![](https://blogs.dns.army/imgbed/blog/202501151758463.png)

&emsp;&emsp;运行`v2rayA`：
```shell
# 运行
docker compose -f v2rayA.yml up -d
# 查看进程
docker compose -f v2rayA.yml ps
```

&emsp;&emsp;接下来就是配置`v2rayA`，打开`http://ip:2017`，访问网页界面即可开始配置`v2rayA`，具体配置详见[官方教程](https://v2raya.org/docs/prologue/quick-start/)。

&emsp;&emsp;最后记得验证下代理配置是否成功：
```shell
curl -i www.google.com -x http://192.168.199.222:20171
```

## `docker`配置代理
&emsp;&emsp;这个一样问下`ChatGPT`，这里记录下。添加或者修改`docker`的配置文件`/etc/docker/daemon.json`：
```json
{
  "proxies": {
    "http-proxy": "http://127.0.0.1:20171",
    "https-proxy": "http://127.0.0.1:20171",
    "no-proxy": "localhost,127.0.0.0/8"
  }
}
```

&emsp;&emsp;重新加载并重启`docker`：
```shell
sudo systemctl daemon-reload
sudo systemctl restart docker
```

&emsp;&emsp;验证下能否用`docker search`搜索镜像：
```shell
docker search nginx
```
&emsp;&emsp;如果没报错然后就可以愉快地用`docker`拉取和搜索镜像啦，有报错请咨询`ChatGPT`，如果是网络问题，大概率是代理不稳定，可以多试几次。
