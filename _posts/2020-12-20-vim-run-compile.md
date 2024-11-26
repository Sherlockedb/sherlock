---
title: vim设置快捷键编译运行
description:
author: Sherlockedb
date: 2020-12-20 23:30:11 +0800
categories: [linux, vim]
tags: [linux, vim]
lang: zh
---


# 前言
用`vim`在服务器上写脚本，然后直接跑。比如`python`脚本，我一般都是`ctrl+z`，将`vim`进程挂起，然后用命令`python3 xx.py`跑起来，跑完再`fg`将后台进程重新跑起来。后面看到这个视频([vim编写python实战](https://www.bilibili.com/video/BV13Z4y1u7PK?from=search&seid=5355085804717238417))，才发现原来可以设置快捷键直接跑，看来我工具用得还是不深入。。。

---
## 设置快捷键编译运行

不说那么多，直接上配置，跑起来。这里我是将`F5`设置为快捷键，然后根据不同文件类型，判断要用哪个命令编译。还加了`time`命令，可以查看执行程序耗了多少时间。配置完后一个`F5`就可以查看运行结果，然后一个`enter`就回来，继续编写代码，舒服！！！

```vim
map <F5> :call CompileRun()<CR>

func CompileRun()
    exec "w"
    if &filetype == 'c'
        exec "!g++ % -o %< && time ./%<"
    elseif &filetype == 'cpp'
        exec "!g++ % -o %< && time ./%<"
    elseif &filetype == 'java'
        exec "!javac %"
        exec "!time java %<"
    elseif &filetype == 'sh'
        :!time bash %
    elseif &filetype == 'python'
        exec "!time python3 %"
    elseif &filetype == 'html'
        exec "!firefox % &"
    elseif &filetype == 'go'
        exec "!go build %<"
        exec "!time go run %"
    elseif &filetype == 'mkd'
        exec "!~/.vim/markdown.pl % > %.html &"
        exec "!firefox %.html &"
    endif
endfunc
```

要是写的是项目代码，比如`C/C++`用的`makefile`编译的，也可以换成`make`命令，甚至换用另外一个专有的快捷键，完全没问题。

---

## 参考
- [vim编写python实战](https://www.bilibili.com/video/BV13Z4y1u7PK?from=search&seid=5355085804717238417)