### 1. Ansible目录结构介绍
>* /etc/ansible         #配置文件目录 
>* /usr/bin         #执行文件目录  
>* /usr/lib/python2.7/site-packages/ansible        #Ansible所有lib库文件和模块文件均存放于该目录下
>* /usr/share/doc/ansible-2.8.1         #Help文档目录
>* /usr/share/man/man1/          #Man文档目录


### 2. Ansible配置文件解析
#### 2.1 ansible.cfg配置文件
>* ansible自身有ansible.cfg这一个配置文件，安装好后默认存放/etc/ansible目录下
>* ansible.cfg配置文件可存放于多个地方，Ansible读取配置文件的顺序依次是当前命令执行目录，然后是用户家目录下的.ansible.cfg,再然后是/etc/ansible.cfg,先找到哪个使用哪个配置
>* ansible.cfg配置的所有内容均可在命令行通过参数的形式传递或者定义再playbook中
#### 2.2 ansible.cfg 遵循INI格式，主要有以下几块内容
```
[defaults]                 #定义ansible基本设置
#inventory = /etc/ansible/hosts
library = /usr/share/ansible/
#module_utils = /usr/share/my_module_utils/
#remote_tmp = ~/.ansible/tmp
#local_tmp = ~/.ansible/tmp
#plugin_filters_cfg = /etc/ansible/plugin_filters.yml
#forks = 5
#poll_interval = 15
#sudo_user = root
#ask_sudo_pass = True
#ask_pass = True
#transport = smart
#remote_port = 22
[inventory]             #enable inventory plugins
[privilege_escalation]
[paramiko_connection]  
[ssh_connection]
[persistent_connection]
[accelerate]  #加速模式
[selinux]
[colors]          #颜色定义
[diff]
```

### 3. Ansible系列命令用法详解与使用场景介绍
#### 3.1 ansible 认证方式
由于ansible采用ssh通信的，在使用ansible之前我们要设置好ssh认证方式，ansible认证方式主要有密码认证和密钥认证
##### 3.1.1 密码认证
```
修改/etc/ansible/hosts 文件，例如:
[db]
192.168.30.153  ansible_ssh_user='root' ansible_ssh_pass='yunwei'
```
##### 3.1.2 密钥认证（建议使用）
```
1. ssh-keygen命令生成密钥文件
2.ssh-copy-id -i [identity_file]  [user]@[ip]
ssh-copy-id -i  /root/.ssh/id_rsa.pub  root@192.168.30.153
```
### 3.2 Ansible Ad-Hoc
#### 3.2.1 运用场景
Ansible Ad-Hoc主要运用在非固化需求的临时性操作
#### 3.2.2 ansible命令格式
```
ansible <host-pattern> [options] 
<host-pattern> (必须项，不可忽略)，其包括: ip,hostname, Inventory中的group组名,具有"."或"*"或":" 等特殊字符的匹配型字符串
 [options](可选项):
-m   指定使用模块
-u    指定远程运行命令的用户
-s   sudo 命令
-U  --sudo-user=sudo_username
-v  输出更详细的执行过程信息 -vvv输出全部执行过程
-i 指定inventory文件
-f 指定并发线程数，默认为5
--private-key   指定密钥文件
-k 指定用户密码
-K sudo 用户密码
-t DIRECTORY   输出信息至DIRECTORY目录下
-T 远程连接主机最大超时
-B 后台运行
-P   定期返回后台任务进度
-c CONNECTIONS      指定连接方式
--list-hosts/--list    列出符合条件的主机列表，不执行命令
--limit     对特定主机进行变更
```
#### 3.2.3 ansible 执行过程
>* 执行命令---建立连接---获取被控机器家目录---在被控主机上创建临时文件目录---生成本地临时文件，并将脚本拷贝临时目录---将临时文件上传到远程被控机器---给远程被控空机器临时文件添加执行权限---执行命令---返回结果，删除临时文件
#### 3.2.4 验证ansible是否执行成功
>* 绿色，橘黄色均表示正常执行
>* 橘黄色表示命令执行结束后目标有状态的变化
#### 3.2.5 ansible使用实例
```
查看系统设置
ansible -i /data/inventory nodes -a "df -lh"     #ansible默认使用command模块执行命令
ansible -i /data/inventory nodes -m shell -a "free -m"
软件安装
ansible -i /data/inventory nodes -m yum -a "name=redhat-lsb state=present"
ansible -i /data/inventory node -m user -a "name=lee shell=/bin/bash home=/home/lee state=present"
用户管理
ansible -i /data/inventory node -m user -a "name=lee shell=/bin/bash home=/home/lee state=present"
ansible -i /data/inventory node -m user -a "name=lee groups=docker,lee state=present"
ansible -i /data/inventory node -m user -a "name=lee state=absent remove=yes"
ansible -i /data/inventory node -m user -a "name=lee password=always"
```
#### 3.2.6 Ansible并发特性
>* 输出结果不是Inventory定义的主机顺序输出
>* 同样命令多次执行，每次输出结果不一定一样
>* 每次结果输出遵循 -f设置的大小(进程数)
>* -f 指定并发线程，建议设置为cpu核数的偶数倍
>* ansilbe使用multiprocessing管理多进程

### 4. ansible-playbook 
#### 4.1 什么是playbook
可以理解为Ad-Hoc的集合，通过一定规则编排在一起
#### 4.2 工作机制
通过读取预先编写好的playbook文件实现批量管理
#### 4.3 命令格式
```
ansible-playbook playboo.yml
功能参数:
--ask-valut-pass   #加密playbook文件时提示输入密码
-D         #更新文件数或者内容较少时，该选项可以显示这些文件不同的地方，与-C结合使用
--list-tags    #列出所有可用的tags
--list-tasks  #列出即将被执行的任务
--skip-tags  #跳过指定tags的任务
--start-at-task  #指定从哪个任务开始执行
--syntax-check  #语法检查
--extra-vars    #变量赋值
```

### 5.ansbile-galaxy 
#### 5.1 ansbile-galaxy 功能
上传和下载roles
#### 5.2 命令格式
````
ansible-galaxy [init|info|install|list|remove] [--help] [options] ...
实例:
ansible-galaxy init --help
ansible--galaxy init [options] role_name
```
### 6. ansible-pull 
#### 6.1 场景
ansible默认使用push模式，pull模式正好与其相反，其适用于以下场景：你有数量巨大的机器需要配置，即使使用非常高的线程还是要花费很多时间；你要在一个没有网络连接的机器上运行Anisble，比如在启动之后安装。
#### 6.2 工作方式
通过ansible-pull结合git和crontab一并实现，其原理是通过crontab 定期拉取指定的git版本到本地，并以指定模式自动运行预先定制好的指令
#### 6.3 命令格式
```
ansible-pull [options] [playbook.yml]
```
### 7. ansible-doc
#### 7.1 作用
Ansible模块说明文档
#### 7.2  命令格式
```
ansible-doc [options] [modules...]
ansible-doc 模块名   #查看模块文档
ansible-doc -l   #列出可用模块
ansible-doc -h
ansible-doc -v/--version
```
### 8. Ansible Inventory 配置及详解
#### 8.1 Inventory介绍
>* Inventory 是管理主机信息的配置文件，相当于系统的HOSTS文件的功能，默认存放于/etc/ansible/hosts
>* 只有一个Inventory 可以不用指定路径，默认读取/etc/ansible/hosts，Inventory可以同时存在很多个，而且支持动态生成，如AWS EC2, Cobbler等均支持
>* Ansible 通过Inventory来定义主机和组，以便于批量管理主机和使用主机分组，使用时通过-i或者--inventory-file指定读取
#### 8.2  Inventory配置
##### 8.2.1定义主机和组 
```
使用IP 
192.168.30.141
主机名
ntp.lee.com:2222
nfs.lee.com
主机组
[webserver]
web1.lee.com
web[10:20].lee.com     #表示10~20之间的所有数字
db-[b:f].lee.com          #表示b到f之前的所有数字
```
##### 8.2.2 定义主机变量
```
定义主机变量（使用"变量"="值" 定义）
[webserver]
web1.lee.com ansible_ssh_port=2222    #ansible_ssh_port=2222 即为定义的端口变量
```
##### 8.2.3 定义组变量
```
[groupserver]
web1.lee.com
web2.lee.com

[groupservers:vars]
ntp_server=ntp.lee.com   #groupserver组中所有主机的ntp_server都为ntp.lee.com
```
##### 8.2.4 定义组嵌套和组变量
```
[apache]
httpd1.lee.com
httpd2.lee.com

[nginx]
ngx1.lee.com
ngx2.lee.com

[webservers:children]   #webserver组中嵌套子组apache,gninx
apache
nginx

[webservers:vars]              #向webserver组中注入变量
ntp_server=ntp.lee.com
```
##### 8.2.5 多重变量定义
变量除了可以在Inventory中定义，也可以独立于Inventory文件单独存储到YAML格式的配置文件中，这些文件通常以.yml .yaml .json为后缀或者无后缀。
变量的检索位置如下：
>* 1.Inventory配置文件(默认在/etc/ansible/hosts)
>* 2.Playbook中vars定义的区域
>* 3.Roles中vars目录下的文件
>* 4.Roles同级目录groups_vars和hosts_vars目录下的文件，名字需要和主机名和主机组名字相同

Ansible遵循如上优先级顺序，设置变量时尽量沿用同一种方式，便于管理

####8.3 Inventory常用参数
```
ansible_ssh_port  
ansible_ssh_user
ansible_ssh_pass
ansible_sudo_pass
ansible_ssh_private_key_file
```

### 9 Ansible与正则
Ansible支持正则表达式，其Patterns功能等同于正则表达式，语法使用和正则类似。该功能主要针对于Inventory的主机列表使用，适用于ansible 和ansible-playbook
#### 9.1 命令格式
```
ansible <pattern_goes_here> -m <module_name> -a <arguments>
```
#### 9.2 all / * (全量）匹配
```
ansible all -m ping
ansible "*" -m ping
ansible 192.168.1.* -m ping
```
#### 9.3 逻辑或(or)匹配 （使用冒号分隔）
```
ansible "web1:web2" -m ping
```
#### 9.4 逻辑非(!)匹配 （使用:! 分隔）
```
#所有在webserver组中但不在phoenix组的主机
webservers:!phoenix
ansible -i inventory  'webservers:!phoenix' -m ping
```

#### 9.5 逻辑与(&)匹配（使用:&分割）
```
#webservers组和staging组中同时存在的主机
webservers:&staging
ansible -i inventory 'webservers:&staging' -m ping
```

#### 9.5 多条件组合
```
#webservers和dbservers两个组中所有主机在staging组中存在且在phoenix组中不存在的主机
webservers:dbservers:&staging:!phoenix
ansible -i inventory 'webservers:dbservers:&staging:!phoenix'  -m ping
```
#### 9.6 * 表示0个或者多个任意字符
```
#所有以lee.com结尾的主机
*.lee.com
#以one 开头以.com结尾的主机和dbservers中所有主机
one*.com:dbservers
```
#### 9.6 域切割
```
[webservers]
cobweb
webbing
weber
webservers[0]   # == cobweb
```

#### 9.7 正则匹配
```
从~开始表示正则匹配
~(web|db).*\.example\.com
ansible "~(beta|web|green)\.example\.(com|org) -m ping
```






