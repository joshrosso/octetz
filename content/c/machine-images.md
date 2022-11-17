---
title: Preparing Machine Images for qemu/KVM
weight: 9973
description: Exploring using tc (traffic control) to shape traffic in a Linux.
date: 2020-10-19
images:
- https://octetz.s3.us-east-2.amazonaws.com/machine-images/title-card.png
aliases:
---

# Preparing Machine Images for qemu/KVM

{{< youtube 6ccpDwT1qnw >}}

In a [previous post](https://octetz.com/docs/2020/2020-05-06-linux-hypervisor-setup), I covered using libvirt+qemu+kvm to manage virtual machines. Once you use these tools for a while, you get to a point of needing to setup images such that you can easily clone them. These can be thought of as 'base' images. A base image often contains the operating system, packages, and (possibly) configuration for each instance to build on. For example, let's assume you are setting up infrastructure to run Kubernetes clusters. In order to run Kubernetes, there are some key components expected on each machine. Thus, a viable base image might look like:

- Linux Operating System (e.g. Ubuntu)
- A container runtime (e.g. containerd)
- The Kubernetes agent (kubelet)
- Swap disabled ([required by Kubernetes](https://github.com/kubernetes/kubernetes/issues/53533))

Along with the above, there is some clean-up we may need to do before blessing something as a base image. Consider aspects of the host such as:

- **hostname**: Persisted in `/etc/hostname`, typically we want unique hostnames per VM instance.
- **DHCP lease**: Whether this is persisted or not may depend on your DHCP client. In the case of systemd-networkd, it is stored in `/run`, which is often not persisted since its underlying file system is [tmpfs](https://en.wikipedia.org/wiki/Tmpfs). Regardless, some operating systems, such as Ubuntu, default to use a [machine-id](http://manpages.ubuntu.com/manpages/bionic/man5/machine-id.5.html) for the lease. If the machine-id is duplicated in your clones, your VMs may end up with the same IP addresses!

In summary, work needs to be done to make an image viable for cloning. In this post, I am going to break down the manual approach to creating these images. In a future post, we'll explore achieving this with more robust automation.

## Manual Image Creation

While there is merit in the idea of "automating everything", sometimes I just want to run some experiments. In these cases, I'm not interested in fancy automation. I just want to hand craft a VM image the same way you might make a fancy cup of coffee ☕. On a more serious note, doing this manually is not only viable for experiments, but also as a learning tool.

I cover a variety of image creation methods in my [Linux Hypervisor Setup (libvirt/qemu/kvm)](https://octetz.com/docs/2020/2020-05-06-linux-hypervisor-setup/) post. Here I'm going to use some command line utilities to get it knocked out quick.

### Install the Operating System

1. Download the installation media.

    ```
    wget https://releases.ubuntu.com/20.04.1/ubuntu-20.04.1-live-server-amd64.iso \
      -O /var/lib/libvirtd/isos/ubuntu-20.04.1.iso
    ```

    `/var/lib/libvirtd/isos` is the arbitrary location I created for storing my install media.

2. Install the operating system.

    ```
    virt-install \
      --name u20 \
      --ram 2048 \
      --disk path=/var/lib/libvirt/images/u20.qcow2,size=16 \
      --vcpus 2 \
      --cdrom /var/lib/libvirt/isos/ubuntu-20.04.1.iso
    ```

    This will trigger the opening of [virt-viewer](https://linux.die.net/man/1/virt-viewer), if installed. virt-viewer will provide a graphical connection to interact with the installer.

3. Proceed with the install.

    ![https://octetz.s3.us-east-2.amazonaws.com/machine-images/u20-install.png](https://octetz.s3.us-east-2.amazonaws.com/machine-images/u20-install.png)

    Be sure to select the install SSH server option!

4. Let the machine reboot after install.

### Update the System and Install Packages

Now that the operating system is installed, we can SSH in and begin configuring the "base" system. This will include updating existing packages, installing new ones, and doing arbitrary configuration. In this case, we'll continue to configure under the assumption the base image will be used for Kubernetes clusters.

1. Find the server's IP.

    ```
    virsh net-dhcp-leases default

     Expiry Time           MAC address         Protocol   IP address           Hostname        Client ID or DUID
    -----------------------------------------------------------------------------------------------------------------------------------------------------
     2020-10-18 17:23:36   52:54:00:b2:a4:73   ipv4       192.168.122.123/24   u20             ff:56:50:4d:98:00:02:00:00:ab:11:c5:51:32:62:67:22:d8:d0
    ```

    This assumes you're using the default network, or one fully managed by libvirt. Alternatively, you can use a VNC connection to the host (e.g. virt-viewer) and get the IP by running `ip a s`.

2. `ssh` into the server.

    ```
    ssh josh@192.168.122.123
    ```

3. Run commands, or a script, that updates the system and installs your packages.

    ```
    #!/bin/bash
    # This script updates an Ubuntu system and installs relevant packages for k8s
    # Run this is root
    apt update
    apt upgrade -y

    # install and configure docker
    # instructions from:
    # https://kubernetes.io/docs/setup/production-environment/container-runtimes/
    apt install -y \
      apt-transport-https ca-certificates curl software-properties-common gnupg2
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
    sudo apt-get update && sudo apt-get install -y \
      containerd.io=1.2.13-2 \
      docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
      docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)
    cat <<EOF | sudo tee /etc/docker/daemon.json
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "100m"
      },
      "storage-driver": "overlay2"
    }
    EOF
    mkdir -p /etc/systemd/system/docker.service.d
    systemctl daemon-reload
    systemctl restart docker
    systemctl enable docker

    # Install kubelet, kubeadm, and kubectl
    sudo apt-get update && sudo apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    apt update
    apt  install -y kubelet kubeadm kubectl
    # mark these packages to ensure they don't upgrade without intervention
    apt-mark hold kubelet kubeadm kubectl
    ```

4. Do any system configuration desired. To support Kubernetes, we may wish to disable swap by entering the file system table at `/etc/fstab` and removing it.

    ```
    # / was on /dev/ubuntu-vg/ubuntu-lv during curtin installation
    /dev/disk/by-id/dm-uuid-LVM-xDSiqbDt3eDJGDXiX0NjBde4J9nd6YN9yDgEqxDIldxEIBVK96KuOISEhznBUD9l / ext4 defaults 0 0
    # /boot was on /dev/vda2 during curtin installation
    /dev/disk/by-uuid/dac500dc-5be1-4cd5-9ed8-f07b858cb1d6 /boot ext4 defaults 0 0

    # !! delete or comment this line !!
    #/swap.img      none    swap    sw      0       0
    ```

### Prepare the Image for Cloning

In order to clone this machine successfully, you need to ensure future replicas are unique in how they spin up. Take for example the IP address leased to this VM. The ID used to request a lease from the DHCP server is generated off the machine-id (`/etc/machine-id`). Here you can see the host's CLIENTID used in requesting that lease.

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/machine-images/duid.png" class="img-center" >}}

You don't want this to persist in future cloned instances or else they risk leasing the same IP. This could cause 2 routable hosts with the same IP to live on the network and cause all sorts of problems. It is key to understand how the machine-id got there. On start-up `systemd-machine-id-setup` is called. However, when `/etc/machine-id` is set, the code never fires to evaluate the client-id. When `/etc/machine-id` is missing, it detects that you are running on KVM and takes the UUID from `/sys/class/dmi/id/product_uuid`. This UUID could also be seen by running `virsh domuuid {name-of-domain/host}`. The following logic facilitates this, which can be found [in the systemd sourc](https://github.com/systemd/systemd/blob/90616bb962703d9d0d61e1988b302f2dae013cb5/src/core/machine-id-setup.c#L48-L78)e.

```
if (isempty(root) && running_in_chroot() <= 0) {
                /* If that didn't work, see if we are running in a container,
                 * and a machine ID was passed in via $container_uuid the way
                 * libvirt/LXC does it */

                if (detect_container() > 0) {
                        _cleanup_free_ char *e = NULL;

                        if (getenv_for_pid(1, "container_uuid", &e) > 0 &&
                            sd_id128_from_string(e, ret) >= 0) {
                                log_info("Initializing machine ID from container UUID.");
                                return 0;
                        }

                } else if (detect_vm() == VIRTUALIZATION_KVM) {

                        /* If we are not running in a container, see if we are
                         * running in qemu/kvm and a machine ID was passed in
                         * via -uuid on the qemu/kvm command line */

                        if (id128_read("/sys/class/dmi/id/product_uuid", ID128_UUID, ret) >= 0) {
                                log_info("Initializing machine ID from KVM UUID.");
                                return 0;
                        }
                        /* on POWER, it's exported here instead */
                        if (id128_read("/sys/firmware/devicetree/base/vm,uuid", ID128_UUID, ret) >= 0) {
                                log_info("Initializing machine ID from KVM UUID.");
                                return 0;
                        }
                }
        }
```

To ensure the above logic executes on a new clone, you must empty the file `/etc/machine-id`.

1. Flush the contents of `/etc/machine-id`.

    ```
    echo -n > /etc/machine-id 
    ```

Now that the machine-id is emptied, it will be set on every new clone. If you reboot this "base" image at some point, note that the machine-id **will be set again**, which may force you to go through the above. Some will take this a step further and ensure the base image is set to use the interface's mac address as the DUID for DHCP rather than the machine-id. This is perfectly acceptable and would achieve the same result of ensuring unique IPs. However, I recommend you still empty the machine-id as describe above to ensure clones are initialized properly.

Next you should consider the hostname. This value is stored in `/etc/hostname` and will be brought into all clones. This may or may not be an issue for you initially, but hostname can find its way to multiple places. For example, the hostname may be passed when leasing an IP from DHCP or, in Kubernetes, the hostname is used to identify each host in the cluster. Similar to IP, you may want these uniquely identifiable. Your choice of hostname is up to you. Some set the hostname to the IP of the machine. For my purposes, I like setting a random hostname that is set on boot and never changed. To do this, you can create a simple script as follows.

1. Add the following script to `/usr/local/bin`.

    ```
    #!/bin/sh
    SN="hostname-init"

    # do nothing if /etc/hostname exists
    if [ -f "/etc/hostname" ]; then
      echo "${SN}: /etc/hostname exists; noop"
      exit
    fi

    echo "${SN}: creating hostname"

    # set hostname
    HN=$(head -60 /dev/urandom | tr -dc 'a-z' | fold -w 3 | head -n 1)
    echo ${HN} > /etc/hostname
    echo "${SN}: hostname (${HN}) created"

    # sort of dangerous, but works.
    if [ -f "/etc/hostname" ]; then
      /sbin/reboot
    fi
    ```

2. Set the script to be executable.

    ```
    chmod +x /usr/local/bin/hostname-init.sh
    ```

3. Add the following systemd unit to `/etc/systemd/system/hostname-init.service`.

    ```
    [Unit]
    Description=Set a random hostname.
    ConditionPathExists=!/etc/hostname

    [Service]
    ExecStart=/usr/local/bin/hostname-init.sh

    [Install]
    WantedBy=multi-user.target
    ```

4. Ensure permission are set to `644`.

    ```
    chmod 644 /etc/systemd/system/hostname-init.service
    ```

5. Enable the unit to ensure it's evaluated on start up.

    ```
    systemctl enable hostname-init
    ```

6. Remove the host's hostname.

    ```
    rm -v /etc/hostname
    ```

You may notice that the script and the systemd unit check for the existence of `/etc/hostname`. While redundant, I prefer they both do this check so they are not making assumptions about each other. Similar to machine-id, if this host were to reboot, a hostname would be set. With this in mind, you need to delete `/etc/hostname` again should you reboot.

Before shutting down the base image and beginning cloning, you should do any final clean-up that is desirable. For example, the commands you've been running may be tracked in `~/.bash_history`. Once complete, shutdown the host.

1. Power off the host.

    ```
    poweroff
    ```

## Creating Clones

There are several ways to clone the new base image. I prefer to use [virt-clone](https://linux.die.net/man/1/virt-clone) to quickly create VMs.

1. Clone `u20` to `node0`.

    ```
    virt-clone --original u20 \
        --name node0 \
        --file /var/lib/libvirt/images/node0.qcow2
    ```

2. Power on the new clone.

    ```
    virsh start node0
    ```

3. Find the IP address given to the new node.

    ```
    virsh net-dhcp-leases default                                                                                                               taco: Mon Oct 19 07:58:12 2020

    IP address           Hostname   Client ID or DUID
    ------------------------------------------------------
    192.168.122.134/24   uym        01:52:54:00:cc:50:fa <== new host
    192.168.122.123/24   u20        01:52:54:00:cf:44:d7 <== old base image
    ```

    There are several ways to determine the IP address. This method assumes libvirt is managing the network and you can lookup the DHCP leases.

4. Optionally, you can ssh in and view the systemd unit that set the hostname.

    ```
    systemctl status hostname-init
    ```

    While `/etc/hostname` is set, this unit will **not** execute again!

## Summary

That is all for setting up machine images to use/clone in qemu/KVM. I hope you found this post helpful and educational. In a future post, we will explore automating this process to enable a more robust means of image creation.

