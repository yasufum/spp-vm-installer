## Install SPP with ansible

This program is an ansible script for setup SPP on VM.

- DPDK v16.07 
- SPP v16.07


### 1. Installation

You have to install ansible on host machine to run ansible-playbook
for building DPDK and other tools.

#### (1) ansible

Install ansible  >= 2.0 by following this
[instruction](http://docs.ansible.com/ansible/intro_installation.html#installation).
I've only tested version 2.0.1.0 but other versions might work.

#### (2) ssh

Ansible uses ssh to install packages on remote machines,
so you have to install ssh client into ansible-server in which ansible run.
If you use ssh password to login ansible-clients, you have to install `sshpass`.

You also have to install sshd into ansible-clients.


### 2. How to use

Run `rake` or `ansible-playbook` directly after [Setup](#3. Setup) in section 3.
If you use `ansible-playbook`, you have to setup sshkey and http_proxy by yourself.

```
$ rake

or

$ ansible-playbook -i hosts site.yml
```


### 3. Setup

#### 3.1. Understand roles

First of all, edit `hosts` to register IP addresses or hostname of VMs
under the roles.

There are three two roles in `hosts`, `common`, `ring` and `vhost`.
Role is a kind of group of installation processes.
Each of processes are defined in `roles/[role_name]/tasks/main.yml`.

##### (1) common role

`common` is the default role which is applied before other roles.
In this tool, you don't need to include any of VMs in the role
explicitly because VMs must be setup with ring or vhost role, which means
`common` is applied all of VMs implicitly.

##### (2) ring role

Setup VMs for running SPP with ring.

##### (3) vhost role

Setup VMs for running SPP with vhost.


#### 3.2. Add user

This playbook assumes that user account defined in `group_vars/all` is already exists
in each of ansible-clients.
If you don't have, add user account as sudoer. 

```
$ sudo adduser dpdk

$ sudo gpasswd -a dpdk sudo
```

You can delete account by userdel if it's no need. You should add -r option to delete home directory.

```
$ sudo userdel -r dpdk
```

#### 3.3. SSH key

[NOTE] You can skip it if you use `rake`.

Put ssh key as `roles/common/templates/id_rsa.pub` for login VMs.

If you don't have the key, generate it as following.

```sh
$ ssh-keygen -t rsa
$ cp $HOME/.ssh/id_rsa.pub ./roles/common/templates/id_rsa.pub
```

#### 3.4. (Optional) Proxy setting

[NOTE] You can skip it if you use `rake`.

You need to set http_proxy in you are in proxy environment for downloading packages
while installation.

Proxy setting is described in `group_vars/all`.


#### 3.5. (Optional) Assing network interfaces

After SPP is installed, you find `${HOME}/dpdk-home/do_after_reboot.sh` in vhost VMs.
`do_after_reboot.sh` is a setup script for DPDK's environments.
It runs `dpdk-devbind.py` with intarfaces described in it.

Default value for vhost interface `dpdk_interfaces: "04:00.0"` is defined in `group_vars/all`.
If you need to change this value, edit `group_vars/all` before installation or `do_after_reboot.sh` inside VMs after installation.


### Status
This program is under construction.


### License
This program is released under the MIT license:
- http://opensource.org/licenses/MIT
