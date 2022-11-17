---
title: Linux Hypervisor Setup (libvirt/qemu/kvm)
weight: 9986
description: Let's explore how you can setup a hypervisor on any Linux host! We'll dig into the libvirt/qemu/kvm stack with a focus on how these pieces interact with each other.
date: 2020-05-06
images:
- https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/title-card.png
aliases:
---

# Linux Hypervisor Setup (libvirt/qemu/kvm)

One of the best things about Linux is how easily you can throw together a few
tools and end up with a great system. This is especially true for
provisioning VMs. Arguably, this is one of the key things that keeps me on a
Linux desktop for my day-to-day work! However, these tools can also be used
to turn an old laptop or desktop into a screaming hypervisor. This way you can
laugh at all your friends with their $10,000 homelab investment while
you're getting all the same goodness on commodity hardware :).

{{< youtube HfNKpT2jo7U >}}

This setup is what I use day-to-day to create Kubernetes environments in a
simple, manageable way without too many abstractions getting in my way. If
understanding and running VMs on Linuxs hosts interests you, this post is for
you!

## Tools

KVM, ESXi, Hyper-V, qemu, xen....what's the deal? You're not short of options in
this space. My stack, I like to think, is fairly minimal and let's me get
everything I need done. The tools are as follows.

**key system tools:**

These are the key tools/services/features that enable vitalization.

* **[kvm](https://www.linux-kvm.org/page/Main_Page)**: 
    * Kernel-based Virtual Machine
    * Kernel module that handles CPU and memory communication
* **[qemu](https://www.qemu.org)**:
    * Quick EMUlator
    * Emulates many hardware resources such as disk, network, and USB. While it can
    emulate CPU, you'll be exposed to qemu/kvm, which delegates concerns like
    that to the KVM (which is [HVM](https://en.wikipedia.org/wiki/Hardware-assisted_virtualization)).
    * Memory relationship between qemu/kvm is a little more complicated but can
    be [read about here](https://www.linux-kvm.org/page/Memory).
* **[libvirt](https://libvirt.org)**:
    * Exposes a consistent API atop many virtualization technologies. APIs are
    consumed by client tools for provisioning and managing VMs.

**user/client tools:**

These tools can be interacted with by users / services.

* **[virsh](https://libvirt.org/manpages/virsh.html)**
    * Command-line tools for communicating with libvirt
* **[virt-manager](https://virt-manager.org)**
    * GUI to manage KVM, qemu/kvm, xen, and lxc.
    * Contains a [VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing)
    and
    [SPICE](https://en.wikipedia.org/wiki/Simple_Protocol_for_Independent_Computing_Environments)
    client for direct graphical access to VMs.
    * GUI alternative to `virsh`, albeit less capable.
* **[virt-install](https://linux.die.net/man/1/virt-install)**
    * Helper tools for creating new VM guests.
    * Part of the `virt-manager` project.
* **[virt-viewer](https://linux.die.net/man/1/virt-viewer)**
    * UI for interacting with VMs via VNC/SPICE.
    * Part of the `virt-manager` project.

**ancillary system tools:**

These tools are used to support the system tools listed above.

* `dnsmasq`: light-weight DNS/DHCP server. Primarily used for allocating IPs to
VMs.
* `dhclient`: used for DHCP resolution; probably on your distro already
* `dmidecode`: prints computers SMBIOS table in readable format. Optional
dependency, depending on your package manager.
* `ebtables`: used for setting up NAT networking the host
* `bridge-utils`: used to create bridge interfaces easily. (tool has been
[deprecated since 2016}(https://lwn.net/Articles/703776), but still used)
* `openbsd-netcat`: enables remote management over SSH

The above _may_ feel overwhelming. But remember it is a look into the guts of
all the pieces facilitating the virtualization stack. At a high-level, this
diagram demonstrates the key relationships to understand:

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/kvm-stack.png"
width="1000" >}}

How you install these tools depends on your package manager. My hypervisor OS is
usually Arch, the following would install the above.

```
pacman -Sy --needed \
  qemu \
  dhclient \
  openbsd-netcat \
  virt-viewer \
  libvirt \
  dnsmasq \
  dmidecode \
  ebtables \
  virt-install \
  virt-manager \
  bridge-utils
```

## Permissions

The primary tricky bit is getting permissions correct. There are a few key
pieces to configure so your using can interact with `qemu:///system`. This
enables VMs to run as root, which is _generally_ what you'll want. This is also
the default used by virt-manager. [Checkout
this blog post from Colin Robinson, which calls out the
differences](https://blog.wikichoon.com/2016/01/qemusystem-vs-qemusession.html).

`virsh`, will use `qemu:///session` by default, which means CLI calls not run as
`sudo` will be looking at a different user. To ensure **all** client utilities
default to `qemu:///system`, add the following configuration to your `.config`
directory.

```
sudo cp -rv /etc/libvirt/libvirt.conf ~/.config/libvirt/ &&\
sudo chown ${YOURUSER}:${YOURGROUP} ~/.config/libvirt/libvirt.conf
```

> Replace `${YOURUSER}` and `${YOURGROUP}` above.

When using `qemu:///system`, access is dictated by `polkit`. Here you have many
options. Since commit
[e94979e9015](https://libvirt.org/git/?p=libvirt.git;a=commit;h=e94979e901517af9fdde358d7b7c92cc055dd50c)
a libvirt group is included, which will have access to libvirtd. With this in
place, you have the following options.

* Add your user to the `polkit` group.
* Be part of an `administrator` group. In Arch Linux, `wheel` is one of these
groups, in being part of `wheel`, you'll be prompted for a `sudo` password to
interact with `virt-manager` or `virsh`.
* Add your group explicitly to the polkit config. The following example
demonstrates adding wheel to `polkit`. You will not be prompted for a password
when interacting with `virt-manager` or `virsh`.

    * edit `/etc/polkit-1/rules.d/50-libvirt.rules`

        ```
        /* Allow users in wheel group to manage the libvirt
        daemon without authentication */
        polkit.addRule(function(action, subject) {
            if (action.id == "org.libvirt.unix.manage" &&
                subject.isInGroup("wheel")) {
                    return polkit.Result.YES;
            }
        });
        ```

    > This is the approach I use.

Depending on the option you go with, you may need to re-login or at least
restart `libvirtd` (see below).

## Configure and Start libvirtd

To begin interacting with qemu/kvm you need to start the libvirt daemon.

```
sudo systemctl start libvirtd
```

If you want `libvirtd` to be on at start-up, you can enable it.

```
sudo systemctl enable libvirtd
```
> This is what I do on dedicated "servers". I don't enable `libvirtd` on my
desktop machines.

libvirt keeps its files at `/var/lib/libvirt/`. There are multiple directories
within.

```
drwxr-xr-x  2 root   root 4096 Apr  4 05:05 boot
drwxr-xr-x  2 root   root 4096 May  6 16:16 dnsmasq
drwxr-xr-x  2 root   root 4096 Apr  4 05:05 filesystems
drwxr-xr-x  2 root   root 4096 May  6 10:52 images
drwxr-xr-x  3 root   root 4096 May  6 09:55 lockd
drwxr-xr-x  2 root   root 4096 Apr  4 05:05 lxc
drwxr-xr-x  2 root   root 4096 Apr  4 05:05 network
drwxr-xr-x 11 nobody kvm  4096 May  6 16:16 qemu
drwxr-xr-x  2 root   root 4096 Apr  4 05:05 swtpm
```

The `images` directory is the default location a VM's disk image will be stored
(e.g. [qcow2](https://en.wikipedia.org/wiki/Qcow)).

I typically keep ISOs locally, unless I've got a PXE flow setup in my network.
To store ISOs, you can create an `isos` directory in `/var/lib/libvirtd`.

```
mkdir /var/lib/libvirt/isos
```

## Create a VM using virt-manager

`virt-manager` provides an easier way to create a new VM. In this section,
you'll create a new VM from an installation ISO.

1. Download an installation iso to your preferred directory.
    ```
    sudo wget -P /var/lib/libvirt/isos \
    https://mirrors.mit.edu/ubuntu-releases/18.04.4/ubuntu-18.04.4-live-server-amd64.iso
    ```
    > This is the directory created in the last section.

1. Launch `virt-manager`.

1. Create a new virtual machine.

    {{< img
    src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/create-vm-vm-mgr.png"
    width="650" >}}

1. Choose Local install media.

    {{< img
    src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/local-install-media.png"
    width="650" >}}

1. Browse for ISO.

1. Add a new pool.

    {{< img
    src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/add-pool.png"
    width="650" >}}

1. Name the pool `isos`.

1. Set the Target Path to `/var/lib/libvirt/isos`.

    {{< img
    src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/target-path.png"
    width="650" >}}

1. Click Finish.

1. Select the iso and click Choose Volume.

    {{< img
    src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/choose-volume.png"
    width="650" >}}

1. Go through prompts selecting desired system resources.

1. You'll either be prompted to create a default network or choose the default
   network (NAT).

    {{< img
    src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/network-selection.png"
    width="650" >}}

    > There are many ways to approach the network. A common approach is to setup
    a bridge on the host that can act as a virtual switch. However, this is a
    deeper topic, maybe for another post.

1. Click Finish.

1. Wait for `virt-viewer` to popup and go through the installation process.

    {{< img
    src="https://octetz.s3.us-east-2.amazonaws.com/running-a-minimal-hypervisor/ubuntu-install.png"
    width="600" >}}

1. Once installed, you can `ssh` to the guest based on its assigned IP address.

## Create a VM using CLI

Following the setup in the previous section, you may wish to trigger the same
install procedure via the command line. This could be done directly with qemu, but to keep interaction like-for-like with virt-manager, I'll show the `virt-install` CLI.

The equivalent to the above would be:

```
virt-install \
  --name ubuntu1804 \
  --ram 2048 \
  --disk path=/var/lib/libvirt/images/u19.qcow2,size=8 \
  --vcpus 2 \
  --os-type linux \
  --os-variant generic \
  --console pty,target_type=serial \
  --cdrom /var/lib/libvirt/isos/ubuntu-18.04.4-live-server-amd64.iso
```

## Clone a VM

Cloning a VM could be a simple as replicating the filesystem. Similar to `virt-install` there is a tool focused on cloning VMs called `virt-clone`. This tool performs the clone via libvirt ensuring the disk image is copied and the new guest is setup with the same virtual hardware. Often I'll create a "base image" and use `virt-clone` to stamp out many instances of it. You can run a clone as follows.

```
virt-clone \
  --original ubuntu18.04 \
  --name cloned-ubuntu \
  --file /var/lib/libvirt/images/cu.qcow2
```

The value for `--original` can be found by looking at the existing VM names in virt-manager or running `virsh list --all`.
