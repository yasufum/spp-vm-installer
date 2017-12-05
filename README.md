# Install SPP on a VM

## Table of contents
- [What is this](#what-is-this)
- [Installation](#installation)
  - [(1) ansible](#1-ansible)
  - [(2) ssh](#2-ssh)
  - [(3) rake](#3-rake)
- [Usage and settings](#usage-and-settings)
  - [How to use](#how-to-use)
  - [Understand roles](#understand-roles)
  - [Add user](#add-user)
  - [(Optional) Using Proxy](#optional-using-proxy)
  - [Configuration for DPDK](#configuration-for-dpdk)
  - [Run rake](#run-rake)
  - [(Optional) Run ansible-playbook](#optional-run-ansible-playbook)
- [License](#license)


## What is this
This is an ansible script for install
[DPDK](http://dpdk.org/browse/dpdk/) and
[SPP](http://dpdk.org/browse/apps/spp/)
on a VM for running SPP secondary process on it.
SPP is a patch panel like 
switching function for Inter-VM communication.

Supported versions:
- DPDK v17.08
- SPP v17.08


## Installation

You have to install ansible on host machine to run ansible-playbook
for building DPDK and other tools.

### (1) ansible

Install ansible  >= 2.0 by following this
[instruction](http://docs.ansible.com/ansible/intro_installation.html#installation).
I've only tested version 2.0.0.2 but other versions might work.

### (2) ssh

Ansible uses ssh to install tools on remote server,
so you have to ssh client into ansible server in which ansible is installed.

You also have to install sshd on ansible clients and to be able to ssh-key login
from the server before install DPDK and other applications.

In order to ssh-key login, you generate with `ssh-keygen` on the server and
copy content of it to 
`$HOME/.ssh/authorized_keys` on the clients.

[NOTE] You can skip it if you have a public key "$HOME/.ssh/id_rsa.pub" and use `rake`.
If you don't have the key, generate it as following.

```sh
$ ssh-keygen -t rsa
```

### (3) rake

Install rake for running setup script, or you can setup it manually.


## Usage and settings

### How to use

First of all, setup roles defined in `hosts` and run `rake` to start installation.
Refer to following sections for roles and details of settings.

```sh
$ rake
...
```


### Understand roles

There are several roles defined in `hosts` file.
Role is a kind of group of installation tasks.
Each of tasks of the role is listed in "roles/[role_name]/tasks/main.yml".

Target machines are specified as a list of IP address or hostname in `hosts`.
Empty list means the role is not effective.
For example, if you only use dpdk, empty the entries of pktgen and spp.

#### (1) common role

Applied for all of roles as common tasks.

This role installs following applications as defined in YAML files under
"roles/common/tasks/".
All of entries are listed in "roles/common/tasks/main.yml" and comment out
entries if you don't need to install from it.

- base.yml
  - git
  - curl
  - wget

- vim.yml
  - vim + .vimrc
  - dein (vim plugin manager)

- emacs.yml
  - emacs

- tmux.yml
  - tmux + .tmux.conf

- nmon.yml
  - nmon (sophisticated resource monitor)

- python-yaml.py
  - python-yaml

- ruby.yml
  - ruby

- rbenv.yml
  - rbenv

- dpdk.yml
  - dpdk
  - libarchive-dev
  - build-essential
  - linux-headers

- hugepages-setup.yml
  - hugepage setup

- spp.yml
  - spp

- sshkey-setup.yml
- sudo-without-pw.yml

Configuration files which are also installed on target machines with the application 
are included in "roles/common/templates.
Change the configuration before run ansible if you need to.


#### (2) vhost role

Install and setup SPP for running secondary process with
[vhost](http://dpdk.org/doc/guides-17.08/prog_guide/vhost_lib.html)
interface.


### Add user

For remote login to ansible-clients, create an account as following steps
and add following account info in `group_vars/all`.

  - remote_user: your account name
  - ansible_ssh_pass: password for ssh login
  - ansible_sudo_pass: password for doing sudo
  - http_proxy: proxy for ansible-client.

You can also setup this params by running rake command as detailed in later.

Create an account and add it as sudoer.

```
$ sudo adduser dpdk1708

$ sudo gpasswd -a dpdk1708 sudo
```

Delete account by userdel if it's no need. You should add -r option to delete
home directory.

```
$ sudo userdel -r dpdk1708
```

### (Optional) Using Proxy

[NOTE] You can skip it if you use `rake`.

If you are in proxy environment, set http_proxy while running rake or define
it directly in `group_vars/all` and use `site_proxy.yml` instead of `site.yml`
at running ansible playbook.
Rake script selects which of them by checking your proxy environment, so you
don't need to specify it manually if you use rake.


### Configuration for DPDK

For DPDK, You might have to change params for your environment.
DPDK params are defined in group_vars/{dpdk spp pktgen}. 

  - hugepage_size: Size of each of hugepage.
  - nr_hugepages: Number of hugepages.
  - dpdk_interfaces: List of names of network interface assign to DPDK.
  - dpdk_target: Set "x86_64-ivshmem-ivshmem-gcc" for using ivshmem, or
                 "x86_64-native-linuxapp-gcc".

This script supports 2MB or 1GB of hugepage size.
Please refer "Using Hugepages with the DPDK" section
in [Getting Started Guide](http://dpdk.org/doc/guides/linux_gsg/sys_reqs.html)
for detals of hugepages.

This configuration to be effective from DPDK is installed, but cleared by
shutting down.
Run `$HOME/dpdk-home/do_after_reboot.sh` on the client for config.
It also setups modprobe and assignment of interfaces.

Template of `do_after_reboot.sh` is included as
`roles/dpdk/templates/do_after_reboot.sh.j2`,
so edit it if you need to.

#### (Optional) Assing network interfaces

After SPP is installed, you find `${HOME}/dpdk-home/do_after_reboot.sh` in vhost VMs.
`do_after_reboot.sh` is a setup script for DPDK's environments.
It runs `dpdk-devbind.py` with intarfaces described in it.

Default value for vhost interface `dpdk_interfaces: "04:00.0"` is defined in `group_vars/all`.
If you need to change this value, edit `group_vars/all` before installation or `do_after_reboot.sh` inside VMs after installation.


### Run rake

You can setup and install DPDK by running rake which is a `make` like build tool.

Type simply `rake` to run default task for setup and install at once.
At first time you run rake, it asks you some questions for configuration. 

```sh
$ rake
> input new remote_user.
[type your account]
> update 'remote_user' to 'dpdk1708' in 'group_vars/all'.
> input new ansible_ssh_pass.
[type your passwd]
> update 'ansible_ssh_pass' to 'your_passwd' in 'group_vars/all'.
> input new ansible_sudo_pass.
[type your passwd]
> update 'ansible_sudo_pass' to 'your_passwd' in 'group_vars/all'.
SSH key configuration.
> './roles/common/templates/id_rsa.pub' doesn't exist.
> Please put your public key as './roles/common/templates/id_rsa.pub' for login spp VMs.
> copy '/home/local-user/.ssh/id_rsa.pub' to './roles/common/templates/id_rsa.pub'? [y/N]
[type y or n]
Check proxy (Type enter with no input if you are not in proxy env).
> 'http_proxy' is set as ''.
> Use proxy env ? () [Y/n]: 
[type y or n]
```

To list all of tasks, run `rake -T`.
The default task includes "confirm_*" and "install" tasks.
You can run each of tasks explicitly by specifying task name.
"install" task runs "ansible-playbook".

```sh
$ rake -T
rake check_hosts         # Check hosts file is configured
rake clean               # Clean variables and files depend on user env
rake clean_hosts         # Clean hosts file
rake clean_vars          # Clean variables
rake config              # Configure params
rake confirm_account     # Update remote_user, ansible_ssh_pass and ansible_sudo_pass
rake confirm_dpdk        # Setup DPDK params (hugepages and network interfaces)
rake confirm_http_proxy  # Check http_proxy setting
rake confirm_sshkey      # Check if sshkey exists and copy from your $HOME/.ssh/id_rsa.pub
rake default             # Run tasks for install
rake install             # Run ansible playbook
rake remove_sshkey       # Remove sshkey file
rake restore_conf        # Restore config
rake save_conf           # Save config
```

If you need to remove account and proxy configuration from config files,
run "clean" task.
It is useful if you share the repo in public.

```sh
$ rake clean
```


### (Optional) Run ansible-playbook

You don't do this section if you use `rake` previous section.

If you setup config and run ansible-playbook manually,
run ansible-playbook with inventory file `hosts` and `site.yml`.

```
$ ansible-playbook -i hosts site.yml
```


## License
This program is released under the BSD license.
