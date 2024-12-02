---
title: 从零开始阅读nginx源码系列(二)
description:
author: Sherlockedb
date: 2020-11-20 23:50:34 +0800
categories: [Program, Nginx]
tags: [nginx, c]
lang: zh
---

# 日志系统
&emsp;&emsp;首先，我们跑起来后，就尝试着改代码，最简单的就是打印一行日志。会打日志后，有什么流程上不清楚的地方就可以打印日志看看。

---
## Hello, nginx!
&emsp;&emsp;那我们看看nginx日志怎么打印出来，因为我们刚看这个代码，去找到日志函数就太麻烦了(虽然可以搜log关键字)，不过因为还有日志级别这些的，你找到的函数打印，不一定能打印到文件里面。所以最简单的，就是从`error.log`找到一行关键字，然后在源码里面搜索这个关键字，看看人家用的什么函数，模仿着写，就可以了。

![](https://blogs.dns.army/imgbed/blog/20201129234133.png)

&emsp;&emsp;我们先看看启动后`error.log`里面的内容，然后就看到`start worker processes`这一行关键字(别问我怎么这么快定位到，其它目测都是变量生成的，关键字不一定搜得到)。

![](https://blogs.dns.army/imgbed/blog/20201129234212.png)

&emsp;&emsp;果不其然，就可以看到人家用的是`ngx_log_error`这个函数打印的，那我们一样用这个函数照猫画虎写一行打印就可以了。
我们先找到`main`函数

![](https://blogs.dns.army/imgbed/blog/20201129234237.png)

&emsp;&emsp;一开始是想在`main`函数开头写的，但是想想，不行啊，因为人家`ngx_log_error`有用参数`cycle->log`，所以肯定要这个初始化后，才能用这个函数打日志。然后我们就看到`main`开头有个`log`变量，一猜应该就是那个`log`，所以我们继续往下找初始化地方，然后在初始化后面加上`ngx_log_error`打印`Hello, nginx!`，除了`log`参数，其它参数都跟上面的一样。

![](https://blogs.dns.army/imgbed/blog/20201129234313.png)

&emsp;&emsp;然后我们`make && make install`看一下日志，`Hello, nginx!`赫然出现在我们眼前。

![](https://blogs.dns.army/imgbed/blog/20201129234346.png)

---
## 修改日志格式

&emsp;&emsp;我们回头来看一下日志格式：

- 日志头：有日期、时间点、日志级别，还有目测是进程号和线程号
- 日志信息

&emsp;&emsp;想一下是不是还缺少了些什么？刚刚`start worker processes`这一行是不是还要我们去`grep`源码才知道这一行是在哪个文件、哪一行么，那我们是不是也可以把这些信息加到日志头里面呢？
&emsp;&emsp;`C`里面提供了一些宏定义:`__FILE__`,`__LINE__`和`__func__`，可以打印出文件名、行号和函数名。
&emsp;&emsp;那我们就要去找一下`ngx_log_error`这个函数的定义了，看看怎么把我们想要的信息加进去。

![](https://blogs.dns.army/imgbed/blog/20201129234411.png)

&emsp;&emsp;我们看到`ngx_log_error`的声明在`core/ngx_log.h`里面，可以看到`ngx_log_error`是一个宏，这样最好，我们才方便我们把上面说到的宏加进去。要是不是宏，就得自己加一个宏，然后调用这个函数了。
&emsp;&emsp;可以看到，`ngx_log_error`的声明还跟一些宏有关系，那么我们就要去找`NGX_HAVE_C99_VARIADIC_MACROS`这个宏的值了，去哪找呢，这就要看我们上一篇说到的，`configure`后生成的两个头文件：`objs/ngx_auto_headers.h`和`objs/ngx_auto_config.h`，里面都是根据系统生成的宏定义，不同系统不一样，自己看一下自己系统生成的是哪一个。下面是我这个系统生成的宏定义，在`objs/ngx_auto_config.h`这个头文件找到的。

![](https://blogs.dns.army/imgbed/blog/20201129234441.png)

&emsp;&emsp;`NGX_HAVE_C99_VARIADIC_MACROS`定义为1，说明编译时用的是第一个分支，所以我就改第一个分支的定义就可以了。我们继续看第一个分支，`ngx_log_error`最终调用的是`ngx_log_error_core`这个函数，我们就找这个函数的定义，最终在`core/ngx_log.c`找到了。

![](https://blogs.dns.army/imgbed/blog/20201129234510.png)

&emsp;&emsp;我们看到函数的定义跟刚刚是一样的，看宏的值，相信不用我说大伙知道怎么看了吧。然后我们继续看下去，找到文件头的格式，发现有一行非常可疑(其实注释已经说明了)，就是打印进程号和线程号的，那么我们就可以在后面加上自己想要的参数。

![](https://blogs.dns.army/imgbed/blog/20201129234538.png)


&emsp;&emsp;我们先直接在该地方加上前面的宏，看看能不能修改成功。修改如下，然后重新编译，跑起来。

![](https://blogs.dns.army/imgbed/blog/20201129234600.png)

&emsp;&emsp;然后我们就看到，日志打印已经有文件名、行号和函数名了，只不过都是`ngx_log_error_core`这个函数的，接下来我们稍微改一下这个函数定义，然后在宏定义那里把这三个参数传进来，就可以在日志看到你打印日志那里的文件名、行号和函数名了。修改如下：

![](https://blogs.dns.army/imgbed/blog/20201129234825.png)

![](https://blogs.dns.army/imgbed/blog/20201129235012.png)

&emsp;&emsp;细节大家自己看看，应该就知道了。最终日志结果如下：

![](https://blogs.dns.army/imgbed/blog/20201129235107.png)

&emsp;&emsp;这样我们看日志就非常方便了。
