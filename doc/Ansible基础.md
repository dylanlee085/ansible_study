### 1.Ansible是什么
Ansible是近年来越来越火的一款自动化运维工具，其主要功能是帮助运维实现IT工作的自动化，降低认为操作失误，提高运维自动化效率，提升运维工作效率，常用于软件部署自动化，配置自动化，管理自动化，系统化系统任务，持续集成，零宕机平滑升级等。

### 2.Ansible发展史
>*  0.0.1 版本发布于2012.3.9,创始人Michael DeHaan
>* 目前已发布100多个版本,最新版本为ansible 2.8.1
>* 现已 被红帽收购，归属红帽公司
### 3.为什么选择Ansible
>* Ansible基于python开发,python可以很方便对ansible二次开发
>* Ansible丰富的内置模块
>* Ansible去中心化，便于迁移(只需要简单复制操作就可以完成配置中心的迁移)
>* Ansible无需安装客户端
### 3.Ansible是如何工作的
#### 3.1 角色
Ansible使用过程中的角色分为
>* 使用者
>* Ansible工具集
>* 作用对象
##### 3.1.1 使用者
>*  CMDB （通过CMDB直接发送指令调用Ansible工具集完成操作者需要达成的目标）
>* PUBLIC/PRIVATE (基于公有云和私有云，Ansible以api调用方式运行)
>* Ad-hoc（Ad-hoc临时命令集调用Ansible工具集完成任务目标）
>* playbooks（通过执行playbook中预先编排好的任务集按序完成任务执行）
##### 3.1.2 Ansible工具集
ansible命令是Ansible的核心工具，ansible命令并非自身完成所有的功能集，其只是Ansible执行任务的调用入口，属于"总指挥角色"， 所有命令的执行通过其"调兵遣将"最终完成。可供ansible调用的的对象有
>* Inventory （命令执行的目标对象配置文件)
>*  API（供第三方程序调用的应用程序编程接口）
>* MODULES（丰富的内置模块）
>* PLUGINS （内置和可自定义的插件）
##### 3.1.3 作用对象
ansible作用对象
>*  HOSTS(主机)
>* 公有云/私有云
>* 商业和非商业的网络设施

#### 3.2 Ansible的组成
 ![image]()

按Ansible工具集的组成来看，可以看出Ansible主要由6部分组成:ANSIBLE PLAYBOOKS,INVENTORY,MODULES,PLUGINS,API,ANSIBLE

>* ANSIBLE PLAYBOOKS :  任务剧本，编排定义Ansible任务集的配置文件 ,由ansible一次按顺序依次执行，通常是json给是的YML文件
>* INVENTORY:  Ansible管理主机的清单
>* MODULES:  Ansible执行命令的功能模块，多数为内置的核心模块，也可自定义
>* PLUGINS:  模块功能的补充，如连接类型插件，循环插件，变量插件，过滤插件等，该功能不常用
>* API:  供第三方程序调用的应用程序编程接口
>* ANSIBLE: Ansible命令工具，其为核心执行工具
#### 3.3 ansible组件的调用关系
在服务器终端输入ansible的Ad-hoc命令集或者playbook后，Ansible会遵循预先编排的规则将playbook逐条拆解为Play， 再将Play组织成可识别的task，随后调用task涉及的所有模块和插件，根据Inventory中定义的主机列表报通过SSH将任务集以临时文件或命令形式的传输到远程客户端执行并返回执行结果，如果是临时文件则执行完毕后自动删除。

### 4.Ansible通信发展史
#### 4.1 Ansible SSH工作机制
Ansible执行命令时，通过其底层传输模块，将一个或者数个文件，或者定义一个play/command命令传输到远程服务器/tmp目录的临时文件，并在远程执行这些play/command, 然后删除这些临时文件，同时回传整体命令执行结果.
#### 4.2 Ansible 通信发展历程
paramiko通信模块---openssh---加速模式---fast openssh
##### 4.2.1 paramiko通信模块
最初使用paramiko通信模块实现底层通信功能，paramiko发展速度远不及openssh，性能和安全较openssh稍差
##### 4.2.2 openssh
>* Ansible 0.5版本起支持openssh，1.3版本开始默认使用openssh实现各服务器间通信
>* 如果通过非默认22端口运行命令等操作，需要在Inventory文件中配置ansible_ssh_port的值
>* openssh 相比paramiko 更快,更可靠
>* 支持ControlPersist (持续管理)
##### 4.2.3 加速模式
>* 开启加速模式后Ansible通信速度有质的提升，是paramiko的10倍，是ssh持久模式的2~6倍
>* 对Ad-Hoc命令不友好，playbook通过加速模式会收到更高的性能
>* 抛弃SSH多次连接的方式，通过SSH初始化后，带着AES key的初始化连接信息通过特定的端口(默认5099，可配置)执行命令传输文件.
>* 使用加速模式额外需要安装python-keyczar
>* 使用sudoer 常规情况下无法再加速模式下运行，/etc/sudoers文件需要关闭requiretty功能, 设置sudo文件NOPASSWORD配置，禁用sudo后的PASSWORD交互认证过程.
##### 4.2.4 如何开启加速模式
```
方法一
在playbook中定义
---
- hosts: all
accelerate: true
accelerate_port: 5099
方法二
修改ansible.cfg
[accelerate]
accelerate_port = 5099
```
##### 4.2.5 fast openssh
>* ansible 1.5+才支持
>* 旧版本中实现方式是复制文件至远程服务器后台运行，然后删除这些临时文件，而新版本的替代方案是通过Openssh发送执行命令，将所有操作附带在SSH连接过程中同步实现.
>* 修改/etc/ansible/ansible.cfg的[ssh_connection]区域开启pipline=True功能

### 5.Ansible应用场景
#### 5.1 从运维操作角度可以分为
>* 文件传输
>* 命令执行
####5.2 自动化工作类型角度可以分为
>* 应用部署
>* 配置管理
>* 任务流编排
### 6.Ansible安装
```
pip安装
yum install python-pip python-devel  && pip install ansible
yum安装
yum install ansible
apt-get安装
apt-get install ansible
源码安装
git clone https://github.com/ansible/ansible.git
cd ansible 
python setup.py install
查看ansible版本
[root@ansible ~]# ansible --version
ansible 2.8.1
```




