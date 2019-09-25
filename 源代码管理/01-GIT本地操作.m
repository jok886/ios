01. GIT简介(PPT)
================================================================================

02. GIT命令行帮助
================================================================================
$ git help
查看git所有命令的帮助
$ git help 子命令

# 要退出帮助信息，按"q"
# 翻看下页，按"空格"
# 翻看上页，按"CTRL+B"
# 要搜索相关文字，按"/"然后输入"相关文字"

03. 创建代码库 & 配置个人信息
================================================================================
1>  创建代码仓库
$ git init

2>  配置用户名和邮箱
$ git config user.name manager
$ git config user.email manager@gmail.com

* 以上两个命令会将用户信息保存在当前代码仓库中

3>  如果要一次性配置完成可以使用一下命令
$ git config --global user.name manager
$ git config --global user.email manager@gmail.com

* 以上两个命令会将用户信息保存在用户目录下的 .gitconfig 文件中

4>  查看当前所有配置
$ git config -l

04. 实际开发
================================================================================
1>  创建代码，开始开发
$ touch main.c
$ open main.c

2>  将代码添加到代码库
# 查看当前代码库状态
$ git status
# 将文件添加到代码库
$ git add main.c
# 将修改提交到代码库
$ git commit -m "添加了main.c"

提示：
*   在此一定要使用 -m 参数指定修改的备注信息
*   否则会进入 vim 编辑器，如果对vim不熟悉，会是很糟糕的事情

# 将当前文件夹下的所有新建或修改的文件一次性添加到代码库
$ git add .

3>  添加多个文件
$ touch Person.h Person.m
$ git add .
$ git commit -m "添加了Person类"
$ open Person.h
$ git add .
$ git commit -m "增加Person类属性"

* 注意 使用git时，每一次修改都需要添加再提交，这一点是与svn不一样的

git 的重要概念及工作原理
--------------------------------------------------------------------------------
工作区
暂存区(staged)
分支(HEAD)

05. 别名 & 日志
================================================================================
$ git config alias.st status
$ git config alias.ci "commit -m"

除非特殊原因，最好不要设置别名，否则换一台机器就不会用了

# 查看所有版本库日志
$ git log
# 查看指定文件的版本库日志
$ git log 文件名

# 配置带颜色的log别名
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

提示：在git中，版本号是一个由SHA1生成的哈希值

06. 版本号，让我们在任意版本之间穿梭
================================================================================
# 回到当前版本，放弃所有没有提交的修改
$ git reset --hard HEAD
# 回到上一个版本
$ git reset --hard HEAD^
# 回到之前第3个修订版本
$ git reset --hard HEAD~3
# 回到指定版本号的版本
$ git reset --hard e695b67

# 查看分支引用记录
$ git reflog






