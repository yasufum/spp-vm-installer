## Install SPP with ansible

This program setup following tools with ansible.

- DPDK 16.04 
- SPP


### 1. Installation

You have to install ansible on host to run ansible-playbook which is a instruction for building DPDK and other tools.

#### (1) ansible

Install ansible  >= 2.0 by following this [instruction](http://docs.ansible.com/ansible/intro_installation.html#installation).
I only tested version 2.0.1.0 but other versions might work.

#### (2) ssh

Ansible uses ssh to install tools on remote server,
so you have to ssh client into ansible-server in which ansible is installed.

You also have to install sshd into ansible-clients to install DPDK or
other tools.


### 2. How to use

#### 2.1. Understand roles

First of all, edit "hosts" to register IP addresses under the roles.

There are three two roles in "hosts", common, qemu and pktgen.
Role is a kind of group of installation processes.
Each of processes are defined in "roles/[role_name]/tasks/main.yml".

##### (1) common role

common is a basic role and applied for all of roles.
If you run qemu's task, common's task is run before qemu's.

##### (2) spp role

First, install DPDK and other tools with common role.
Then nstall spp.


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
  

#### 2.3. Run ansible-playbook.
```
$ ansible-playbook -i hosts site.yml
```
or use rake if you installed it.
```
$ rake
```

#### 2.4. Run DPDK applications.

Login as dpdk, then compile and run applications as following.
```
$ ssh dpdk@localhost
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.2.0-35-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
Last login: Sun May  8 01:38:50 2016 from 192.168.33.1
vagrant@vagrant:~$ cd dpdk/examples/helloworld/
vagrant@vagrant:~/dpdk/examples/helloworld$
vagrant@vagrant:~/dpdk/examples/helloworld$ make
  CC main.o
  LD helloworld
  INSTALL-APP helloworld
  INSTALL-MAP helloworld.map
vagrant@vagrant:~/dpdk/examples/helloworld$ sudo ./build/helloworld -c f -n 4
EAL: Detected 4 lcore(s)
EAL: Probing VFIO support...
EAL: VFIO support initialized
EAL: PCI device 0000:00:03.0 on NUMA socket -1
EAL:   probe driver: 8086:100e rte_em_pmd
EAL: PCI device 0000:00:08.0 on NUMA socket -1
EAL:   probe driver: 8086:100e rte_em_pmd
EAL: PCI device 0000:00:09.0 on NUMA socket -1
EAL:   probe driver: 8086:100e rte_em_pmd
EAL: PCI device 0000:00:0a.0 on NUMA socket -1
EAL:   probe driver: 8086:100e rte_em_pmd
EAL: PCI device 0000:00:10.0 on NUMA socket -1
EAL:   probe driver: 8086:100e rte_em_pmd
EAL: PCI device 0000:00:11.0 on NUMA socket -1
EAL:   probe driver: 8086:100e rte_em_pmd
hello from core 1
hello from core 2
hello from core 3
hello from core 0
```


### Status
This program is under construction.

### License
This program is released under the MIT license:
- http://opensource.org/licenses/MIT
