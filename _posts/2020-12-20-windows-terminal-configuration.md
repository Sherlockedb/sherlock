---
title: WindowsTerminal配置
description:
author: Sherlockedb
date: 2020-12-20 16:47:06 +0800
categories: [Windows, WindowsTerminal]
tags: [windows]
lang: zh
---


# 前言
之前`Windows`一直用的`X-shell`，然而由于版权问题，商业版得付费用了。现在`Windows`有了`Windows-Terminal`，于是就着手配置`Windows-Terminal`。不得不说`Windows`到现在，命令行也越来越好用了，`power-shell`还有`wsl`，然后后面又出了个`Windows-Terminal`，这对于我这种习惯用命令行的人来说，体验是越来越好了。这篇文章主要介绍以下几点：
1. `Windows-Terminal`的一些简单配置
2. 把`Windows-Terminal`加入到右键菜单里面

---

## SSH配置
* 在用户目录下的`.ssh`文件夹下，创建`config`文件，按如下格式填写，`host`是标签，写个你知道的，`hostname`就是服务器的ip或者域名，其它的顾名思义。比如我这样配置后，就可以在`powershell`用命令`ssh dev`连上服务器。

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/20201218162246.png)

---
            
## Windows Terminal 配置
在微软应用商店下载`Windows Terminal`，下载完成后打开，用`ctrl+,`打开配置文件`settings.json`进行如下配置：

### session管理配置

如图，模仿`cmd`和`powershell`填写配置，我添加了开发机(`ssh dev`)配置。

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/20201218162348.png)

若需要修改默认终端，则把`defaultProfile`配置成对于的`guid`即可。

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/20201218162409.png)

在命令行里面用`wt -p {session_name}`可以在新窗口打开对应session.(下面右键打开`powershell`用到了这个命令)

### 主题配置

主题配置是在`profiles->schemes`下，可从[Windows Terminal Themes](https://windowsterminalthemes.dev)获取对应配置

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/20201218162501.png)

### 快捷键配置

快捷键绑定也可以自己配置，我主要添加了一些常用命令输入的快捷键，用`sendInput`可以绑定快捷键输入固定字符，比如`ctrl+5`就是打印`/sbin/ifconfig | grep inet\u000D`到终端，`\u000D`是回车。

![](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/20201218162525.png)

---

## 修改注册表添加右键菜单

把`Windows Terminal`加入到右键是为了在任何目录下直接打开终端，类似`Git Bash Here`，方法是添加一个注册表，我加了两个：
1. 默认的`Windows Terminal`
2. 直接打开`PowerShell`

### 用法
新建一个文件，然后加入以下语句，保存为`wt.reg`，然后双击运行，即可添加注册表项。

```reg
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\Background\shell\powsh]
@="PowerShell Here"
"Icon"="C:\\Users\\[user_name]\\AppData\\Local\\WindowsTerminal\\powershell.ico"

[HKEY_CLASSES_ROOT\Directory\Background\shell\powsh\command]
@="C:\\Users\\[user_name]\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe -p Windows PowerShell"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt]
@="Windows Terminal Here"
"Icon"="C:\\Users\\[user_name]\\AppData\\Local\\WindowsTerminal\\terminal.ico"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\command]
@="C:\\Users\\[user_name]\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe"
```

### 说明：
1. 把`user_name`换成你的用户名
2. `HKEY_CLASSES_ROOT\Directory\Background\shell\powsh`是注册表的值，下面是设置右键显示的文本和`icon`，注册表的值加上`\command`是值点击时触发的命令。
3. 需要在对应的`session`配置里面加上 `startingDirectory: "."` 配置。

### 注意：
1. 如果注册失败，检查一下路径，会不会多了一个斜杆啥的。(我一开始就是复制了用户名，然后多了个斜杆，一直打不开程序。。。)
2. 格式要严格按照上面写的，块与快之间的空行数都是一行，别多也别少了，别加注释，这个坑一样踩过。。。

### 最终效果如下
![image](https://raw.githubusercontent.com/Sherlockedb/github.page/gh-pages/blog/20201218162721.png)

### 删除右键菜单
若后面想从右键删除，也很简单，在新的文本文件加入以下文本，把`key`改成你要删的注册表项就可以了，减号`-`意味着删除注册值。
```reg
Windows Registry Editor Version 5.00
 
[-HKEY_CLASSES_ROOT\Directory\Background\shell\powsh]
```