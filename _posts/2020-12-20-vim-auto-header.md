---
title: vim文件头自动补全
description:
author: Sherlockedb
date: 2020-12-20 23:00:31 +0800
categories: [linux, vim]
tags: [linux, vim]
lang: zh
---


# 前言
由于本人从事服务端开发，经常用`vim`写代码或者写一些脚本，而对于一些编程语言，文件头都有固定的格式，比如

+ `python`一开头都会加`# -*- coding: utf8 -*-`
+ `c/c++`头文件固定带一些条件宏
+ 类似一些`IDE`功能，新建文件即可记录创建文件的作者、邮箱、日期等等

`vim`也提供了自动生成文件头的一些函数，需要我们在`.vimrc`里面自己编写函数生成。

---

## Python

在`.vimrc`加入以下函数，并在识别到`.py`后缀时调用这个函数。
```vim
function HeaderPython()
    call setline(1, "#!/usr/bin/env python")
    call append(1, "# -*- coding: utf8 -*-")
    call append(2, "#Filename:    " . expand("%"))
    call append(3, "#Author:      author")
    call append(4, "#Email:       xx.yy.zz@aa.bb")
    call append(5, "#Date:        " . strftime("%Y-%m-%d %T"))
    call append(6, "")
    call append(7, "import sys")
    call append(8, "")
    call append(9, "def main():")
    call append(10, "    print 'run %s' % (sys.argv[0])")
    call append(11, "")
    call append(12, "if __name__ == '__main__':")
    call append(13, "    main()")
    normal G
endf

autocmd bufnewfile *.py call HeaderPython()
```
效果：

![](https://blogs.dns.army/imgbed/blog/20201220230335.png)

--- 

## Shell脚本
```vim
function HeaderShell()
    call setline(1, "#!/bin/sh")
    call append(1, "# -*- coding: utf8 -*-")
    call append(2, "#Filename:    " . expand("%"))
    call append(3, "#Author:      author")
    call append(4, "#Email:       xx.yy.zz@aa.bb")
    call append(5, "#Date:        " . strftime("%Y-%m-%d %T"))
    call append(6, "")
    call append(7, "set -e")
    call append(8, "set -u")
    call append(9, "set -x")
    call append(10, "")
    call append(11, "cd `dirname $0`")
    call append(12, "")
    normal G
endf

autocmd bufnewfile *.sh call HeaderShell()
```

效果：

![](https://blogs.dns.army/imgbed/blog/20201220230408.png)

--- 

## MarkDown
这个是我用`Jekyll`主题写博客，该主题要求的`MarkDown`格式，开头指明标题、作者、发布时间、分类和标签等。所以我也写了个自动生成文件头的函数，当然，正文还是在`VS Code`写的。

```vim
function HeaderMarkDown()
    call setline(1, "---")
    call append(1, "title: " . expand("%"))
    call append(2, "author: author")
    call append(3, "date: " . strftime("%Y-%m-%d %T") . " +0800")
    call append(4, "categories: []")
    call append(5, "tags: []")
    call append(6, "lang: zh")
    call append(7, "---")
    call append(8, "")
    call append(9, "")
    normal G
endf

autocmd bufnewfile *.md call HeaderMarkDown()
```
效果：

![](https://blogs.dns.army/imgbed/blog/20201220230446.png)

--- 

## C/C++

```vim
func HeaderCPP()
    if expand("%:e") == 'h'
        call setline(1, "\#ifndef __".toupper(expand("%:t:r"))."_H__")
        call append(1, "\#define __".toupper(expand("%:t:r"))."_H__")
        call append(2, "")
        call append(3, "")
        call append(4, "")
        call append(5, "\#endif /* __".toupper(expand("%:t:r"))."_H__ */")
    elseif expand("%:e") == 'c'
        call setline(1, "#include \"".expand("%:t:r").".h\"")
        call append(1, "")
    elseif expand("%:e") == 'cc'
        call setline(1, "#include \"".expand("%:t:r").".h\"")
        call append(1, "")
    elseif expand("%:e") == 'cpp'
        call setline(1, "#include \"".expand("%:t:r").".h\"")
        call append(1, "")
    endif
    normal G
endfunc

autocmd BufNewFile *.c,*.cc,*.cpp,*.h, exec ":call HeaderCPP()"
```

效果：

![](https://blogs.dns.army/imgbed/blog/20201220230943.png)

![](https://blogs.dns.army/imgbed/blog/20201220231009.png)

---

### 参考
- [Automatic insertion of C/C++ header gates](https://vim.fandom.com/wiki/Automatic_insertion_of_C/C%2B%2B_header_gates)