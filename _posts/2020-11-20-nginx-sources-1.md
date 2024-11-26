---
title: 从零开始阅读nginx源码系列(一)
description:
author: Sherlockedb
date: 2020-11-20 22:43:06 +0800
categories: [Program, Nginx]
tags: [nginx, c]
media_subpath: '/posts/20201120'
lang: zh-CN
---
---

# 前言
---
&emsp;&emsp;看了<<深入理解Nginx>>的一些章节后，发现看完还是云里雾里，于是想重新看源码整理一遍。然后就想，要是我是一个从头看源码的人，我会怎么开始看，所以就想着记录一下自己整理源码的过程。

&emsp;&emsp;首先，我们把源码下载下来，然后编译跑起来。为什么要跑起来呢，因为看代码其实很枯燥，所以跑起来，一边实践一边看代码，是比较好的方式。我们在哪看不懂或者有疑问，也可以加上日志，跑起来看看。

---
## 获得源码
&emsp;&emsp;从[GitHub nginx](https://github.com/nginx/nginx)获取源码
```shell
git clone https://github.com/nginx/nginx.git
# checkout到当前最新稳定版
git checkout -b stable-1.18 origin/branches/stable-1.18
```
---

## 编译源码
```shell
# 进入nginx源码目录
cd nginx
# 创建$HOME/local,放我们编译好的二进制,可以跑起来测试
mkdir $HOME/local
auto/configure --prefix=$HOME/local/nginx
```
&emsp;&emsp;`auto/configure`这个脚本是检查一些环境变量，然后生成宏变量，如果跑这个脚本过程报错的话，在`auto`里面搜索对应的关键字，一般可以找到原因。比如有些系统没装`pcre`库，就可以下载`pcre`的源码，然后指定`pcre`源码路径，再重新`configure`一下就可以了。
跑完这个脚本，我们来看看生成了什么东西，先`git status`一下

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/cee9c6b9c1a30ff7b820f924e0aecc59.png)

&emsp;&emsp;生成了`Makefile`和一个`objs`文件夹，仔细看这个`Makefile`就知道，其实最终是调`objs`里面的`Makefile`，我们继续看一下`objs(tree objs)`里面的内容

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/f5c1e4d418ed0e717fce1fc0e8e34122.png)

&emsp;&emsp;我们主要看里面两个头文件和一个源文件，两个头文件是生成的一些宏定义，`nginx`源码里面用到很多宏，到时可以回到这里看，`ngx_modules.c`则是所有模块的数组，这个我们后面再说，`objs/src`里面只是一些空文件，目录结构跟源码目录`src`结构一样，是为了放编译过程生成的目标文件。现在我们来编译一下。
```shell
make -j 4
make install
```
&emsp;&emsp;编译安装完就会看到`bin`下面有二进制和配置文件等

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/5fb7e19c1d41c8056200002c.png)

---
## 跑起来
&emsp;&emsp;我们先改一下配置文件，主要改三个地方，日志级别、监听端口和单进程模式，如图:

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/5fb7e57e1d41c80562000032.png)

```shell
# nginx默认的配置文件是conf/nginx.conf,可以用-c指定配置文件路径
cd $HOME/local/nginx
sbin/nginx -c conf/nginx.conf
```
&emsp;&emsp;若有报错可以看`logs/error.log`文件。然后用浏览器访问我们的服务器和端口，若出现`welcom to nginx`页面则成功跑起来。
