## Install SPP with ansible

This program is an ansible script for setup SPP on VM.

- DPDK v16.07 
- SPP v16.07


### 1. Installation

You have to install ansible on host to run ansible-playbook
which is a instruction for building DPDK and other tools.

#### (1) ansible

Install ansible  >= 2.0 by following this
[instruction](http://docs.ansible.com/ansible/intro_installation.html#installation).
I've only tested version 2.0.1.0 but other versions might work.

#### (2) ssh

Ansible uses ssh to install tools on remote server,
so you have to install ssh client into ansible-server in which ansible run.
If you use ssh password to login ansible-clients, you have to install `sshpass`.

You also have to install sshd into ansible-clients.


### 2. How to use

#### 2.1. Understand roles

First of all, edit "hosts" to register IP addresses of VMs under the roles.

There are three two roles in "hosts", common, qemu and pktgen.
Role is a kind of group of installation processes.
Each of processes are defined in "roles/[role_name]/tasks/main.yml".

Use common role if you want to install dpdk only.
On the other hand, use spp role.

##### (1) common role

`common` is a basic role and applied for all of roles.
If you run qemu's task, common's task is run before qemu's.

##### (2) dpdk role

Install DPDK.

##### (3) spp role

Install SPP.


#### 2.2. Add user

On each of ansible-clients, add user account as defined in hosts if you don't have
an account for spp on remote.
Then make it as sudoer.

[NOTE] Add http_proxy in .bashrc if you are in proxy environment.

```
$ sudo adduser dpdk

$ sudo gpasswd -a dpdk sudo
```

Delete account by userdel if it's no need. You should add -r option to delete home directory.

```
$ sudo userdel -r dpdk
```
  

#### 2.3. Assing network interfaces

After spp is installed, you find `${HOME}/dpdk-home/do_after_reboot.sh` which is setting up
DPDK's environments.
This script includes NIC binding with `dpdk-devbind.py`, so you have to check interfaces
used by DPDK inside VM.

Run `ifconfig -a` to find interfaces and update `dpdk_interfaces` in `group_vars/dpdk`.

#### 2.4. Run ansible-playbook.
```
$ ansible-playbook -i hosts site.yml
```
or use rake if you installed it.
```
$ rake
```


### Status
This program is under construction.


### License
This program is released under the MIT license:
- http://opensource.org/licenses/MIT
