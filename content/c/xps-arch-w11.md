---
title: "Linux (Dual Boot) Workstation - Arch, Windows 11, Encrypted"
weight: 9910
description: Setup a Laptop that can dual boot Arch Linux and Windows 11. Fully encrypt both partitions.
date: 2022-04-18
images:
- https://octetz.s3.us-east-2.amazonaws.com/xps-thumb.png
aliases:
- /latest
---

# Linux Workstation Setup: XPS, Arch, Windows, Encrypted

{{< youtube Q4XfaJY2TZo >}}

## Laptop

My workstation is a Dell XPS. The specs are:

- Processor: 11th Gen i7-11800H
- Memory: 64 GB, 2 x 32 GB, DDR4, 3200 MHz
- Hard Drive: 2 TB, M.2, PCIe NVMe, SSD
- Dedicated Graphics: RTX 3050
- Display: FHD+ (1920x1200) Non-touch

I choose XPS as it is a familiar laptop with a keyboard and trackpad I like. I
choose one with an 11th Gen Intel chip even though the Intel 12th gen CPUs are
available. These feature the performance (p) and efficiency (e) cores. While I
am excited about this architecture, [Intel’s thread director is not planned to
be available in the Linux kernel until
5.18](https://www.phoronix.com/scan.php?page=news_item&px=Intel-HFI-For-Linux-5.18).
The memory size is largely unnecessary, but I do use `qemu` to spin up and down
multiple VMs, so the extra headroom is nice. With 2TB of disk space, I can have
Windows and Linux installed with ~1TB available to each. The dedicated graphics
are leveraged to offload video rendering. Otherwise, I try to use integrated
graphics (for the sake of battery). Lastly, the display is the less-nice
non-OLED (FHD+) option. While a lesser display, it has significantly less power
draw and removes the touch feature set. Lastly, being Dell, the BIOS-level
settings on this workstation can be a pain for Linux. If you’re looking for a
purely Linux workstation, I recommend [System 76](https://system76.com/laptops).

## Installation Preparation

For installation media, use 2 USB flash drives, one for Linux and one for
Windows.

### Linux Install Media

For Arch Linux, you can download the ISO at
[archlinux.org/download](https://archlinux.org/download/). From here, choose 
mirror. For my location, I find the [mit.edu
mirror](https://mirrors.mit.edu/archlinux/iso/) to be good. To setup the
downloaded ISO:

1. Insert the USB drive to your machine.
1. List block devices to determine the device name.
    
    ```bash
    $ lsblk
    NAME                    MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
    sda                       8:0    1  29.2G  0 disk
    |-sda1                    8:1    1   602M  0 part
    `-sda2                    8:2    1    64M  0 part
    nvme0n1                 259:0    0   477G  0 disk
    |-nvme0n1p1             259:1    0   512M  0 part  /boot
    `-nvme0n1p2             259:2    0 476.4G  0 part
      `-cryptroot\x5cx2callow-discards\x5cx2cheader
                            254:0    0 476.4G  0 crypt
        `-vg0-root          254:1    0 476.4G  0 lvm   /
    ```
    
    > Based on the above, the drive is located at `dev/sda`.

1. Write the ISO contents to the USB drive.
    
    ```bash cat ~/Downloads/${ARCH_ISO_FILE_NAME}.iso > /dev/sda```
    
    > cat points at the disk, `/dev/sda`. It should **not** point at a partition
      (e.g. `/dev/sda1`).

1. Remove the USB drive.

### Windows Install Media

For Windows, [Ventoy](http://ventoy.net) is used to create the installation
media. Its primary use is to disable hardware checks in Windows, namely [secure
boot](https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-secure-boot).
To get setup for the installation media, you should:

1. [Download and install Ventoy](https://www.ventoy.net/en/download.html).
2. [Download the Windows 11 **ISO**
image](https://www.microsoft.com/software-download/windows11).
    
    ![Install Windows 11](https://octetz.s3.us-east-2.amazonaws.com/w11-download.png)

With the above in place, you can setup the installation media by:

1. Launch `ventoygui`.
1. Choose your USB stick from the drop-down.
1. Click Install.
1. Close `ventoygui`.
1. Mount the partition made by `ventoygui`.
    
    ```bash
    # mount /dev/sda1 /run/media/josh/ventoy
    ```
    
    > Assumes `ventoy` exists in your path.

1. Run `ventoyplugson` against this mount.

    ```bash
    ventoyplugson /dev/sda1
    ```

1. Open the address provided by `ventoyplugson`.
1. In `Global Control Plugin` set `VTOY_WIN11_BYPASS_CHECK` to `1` (on).

    ![ventoy gui](https://octetz.s3.us-east-2.amazonaws.com/vtoy.png)

    > This will ensure we can install Windows 11 with secure boot disabled
    > (required for the Linux install). It will also allow you to install
    > Windows on a machine that does not meet Microsft's hardware requirements.

1. Exit `ventoyplugson`.
1. Remove the USB drive.

### BIOS Setup

On most modern motherboards, you'll need to disable secure boot in the BIOS.
This is primarily to support the Linux install, however [there are ways to do a
Linux install with secure boot
enabled](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Implementing_Secure_Boot).
On modern Dell laptops, Intel Rapid Storage (via RAID) is turned on by default.
The primary use of this feature is to emulate RAID storage, however, it really
doesn't serve much purpose on this single SSD laptop. Thus, I recommend setting
the SATA mode to AHCI/NVMe. To setup the BIOS:

1. Boot into the one-time-boot menu by holding F12 during boot.

1. Select the BIOS option.

1. In `Boot Configuration` > `Secure Boot`, disable secure boot.

    ![BIOS secure boot](https://octetz.s3.us-east-2.amazonaws.com/secure-boot.png)

1. From `Storage` > `SATA/NVMe Operation`, set the mode to `AHCI/NVMe`.

    ![BIOS AHCI/NVMe operation](https://octetz.s3.us-east-2.amazonaws.com/nvme.png)

1. Apply Changes and power down.

### Disk (Partition) Layout

This laptop will run Windows 11 and Arch Linux. Both operating systems will be
fully encrypted. The partition layout will be as follows:

![Partition Scheme](https://octetz.s3.us-east-2.amazonaws.com/part.png)

> I've intentionally left out some partitions that will be created by Linux.

It's worth noting that I do **not** reserve space for swap in Linux. For many
Linux-laptop users, swap is highly preferred as it enables their computer to
Hibernate. You may want to look into the benefits of Hibernate to determine if
you'd like an extra partition for swap.

## Windows Install

Windows installation comes first as it will layout the disk in a way that Linux
can add to. Once Windows is installed, Veracrypt will be used to encrypt its
volume.

1. Insert the USB drive containing the (Ventoy) Windows ISO.

1. Boot into the one-time-boot menu by holding F12 during boot.

1. Select USB from the left navigation.

1. Select the language to install and click Next.

1. Click Install now.

1. Accept the license terms and click Next.

1. Click Custom: Install Windows only (advanced).

1. Delete all existing partitions.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/deleted-windows-partitions.png" width="600" >}}

1. Create a new partition of the size you'd like Windows to occupy.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/click-new-windows.png" width="250" >}}

    > Windows creates additoinal partitions including the 100.0MB System partition that will act as the EFI partition.  

1. Click Next and wait for Windows to install.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/windows-made-partitions.png" width="250" >}}

    > After the installation completes, the machine will reboot.

1. After reboot, go through the Windows setup procedure.

### Disable Fast Boot

Once Windows has been installed and configured you're able to boot into it. The
next step is to turn off the fast boot feature. This feature can cause issues
with partitions shared between Windows and Linux. To disable fast boot:

1. Open Control Panel.

1. In the top right search, enter `power`.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/control-panel.png" width="600" >}}

1. Click `Change what the power buttons do`.

1. Click `Change settings that are unavailable`.

1. Uncheck `Turn on fast startup (recommended)`.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/disable-fast-startup.png" width="600" >}}
    

    > To understand why fast startup is not recommended, see 
      [https://wiki.archlinux.org/index.php/Dual_boot_with_Windows#Fast_Start-Up](https://wiki.archlinux.org/index.php/Dual_boot_with_Windows#Fast_Start-Up)

1. Open Start > Settings > Update & Security and Check for updates.

1. Allow all Windows updates to download and install before proceeding.

### Encrypt the Windows Volume

With Window fully configured, you can now encrypt its volume. VeraCrypt provides
a free and open source way to encrypt the volume. After setting this up, the
bootloader will boot to VeraCrypt, which will then prompt the user to decrypt
the drive. If the user providers the correct password, the drive is decrypted
and Windows is booted. To encrypt the Window volume:

1. Download and install VeraCrypt.

    https://www.veracrypt.fr/en/Downloads.html

1. Launch VeraCrypt.

1. From the menu bar, open System > Encrypt System Partition/Drive

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/veracrypt-encrypt-system.png" width="600" >}}

1. Choose Normal.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/veracrypt-normal.png" width="600" >}}

1. Choose Encrypt the Windows system partition.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/encrypt-system-part.png" width="600" >}}

1. Choose Single-boot.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/single-boot.png" width="600" >}}

    > While you will have a multi-boot system eventually. This installation will have grub point
      to veracrypt that will then decrypt and point to windows. Thus, vercrypt needs to know 
      nothing about Linux.  

1. Choose your preferred encryption algorithm and click Next.

1. Create a strong password.

1. Allow VeraCrypt to collect random data.

1. If desired, create a rescue disk.

    > This will require a USB drive to save to.

1. Choose your preferred Wipe Mode.

1. Run the System Encryption Pretest.

    > This will require your machine to be restarted.

1. Upon restart, enter your encryption password when prompted.

1. Log back in to your Windows system.

1. VeraCrypt will pop back up to tell you the Pretest Completed.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/encrypt.png" width="600" >}}

1. Click Encrypt and run the encryption.

    > This will encrypt the file system and take several minutes.

1. Allow the encryption to complete.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/encrypting.png" width="600" >}}

1. Power off the machine.

## Linux Install

Arch Linux will be installed using the disk space left over from Windows. We'll
use the installer to setup the partitions, encrypt root, and finally bootstrap
the initial system. To start installing Arch Linux:

1. Insert the USB containing the Arch Linux ISO.

1. Boot into the one-time-boot menu by holding F12 during boot.

1. Select the USB device and allow the Arch installer to boot.

The default Arch install requires internet connection to discover and install
packages. Wired connections should work by default. If using a wireless
connection:

1. Run `iwctl` to managed wireless networks.

    ```sh
    $ iwctl
    ```

1. Locate the name of your wireless device.

    ```sh
    $ device list
    ```

1. Connect to the wireless network by its name.

    ```sh
    $ station ${DEVICE_NAME} connect ${NETWORK_NAME}
    ```

1. Validate connectivity.

    ```
    ping google.com   

    PING google.com (216.58.193.206) 56(84) bytes of data.
    64 bytes from lax02s23-in-f14.1e100.net time=809 ms
    64 bytes from lax02s23-in-f14.1e100.net time=753 ms
    ```

### SSH into Installer

Once network is setup, I prefer to complete the installation on a second
computer. This providers greater flexibility to use a browser, copy/paste, and
more. To setup `ssh` and finish the install from another host:

1. Set a root passwd for `root`.

    ```
    passwd
    ```

1. Enable `sshd`.

    ```
    systemctl start sshd
    ```

    > This may be enabled by default.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/ssh-install.png" width="600" >}}

1. Determine your local address using `ip a`.

1. From another computer, ssh in.

    ```
    ssh root@${TARGET_MACHINE_IP}
    ```

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/in-other-machine.png" width="600" >}}

### Disk Partitioning

1. List block devices to determine the name of the drive.

    ```
    lsblk

    NAME                                            MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
    nvme0n1                                         259:0    0   477G  0 disk  
    |-nvme0n1p1                                     259:1    0   512M  0 part  /boot
    `-nvme0n1p2                                     259:2    0 476.4G  0 part  
      `-cryptroot\x5cx2callow-discards\x5cx2cheader 254:0    0 476.4G  0 crypt 
        `-vg0-root                                  254:1    0 476.4G  0 lvm   /
    ```

    In the above, the drive is mapped to `/dev/nvme0n1`.

1. Launch cgdisk for the drive above.

    ```
    cgdisk /dev/nvme0n1
    ```

    > `cgdisk` is an ncurses-based GUID partition table manipulator. Unlike the command-only `fdisk`
    approach, `cgdisk` provides a text-menu for writing partitions.

1. Select the free space.

1. Choose `[  New  ]`.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/cgdisk1.png" width="600" >}}

1. Enter no value for First sector (chooses default).

    > This means the Linux partition starts directly at the end of the Windows partition. Some
      believe it is best to leave a small amount of free space between partitions. However, I have
      not had issues with this.

1. Enter 512Mib for size in sectors.

    > This is the end size of the partition.

1. Enter no value for Hex code or GUID (chooses default).

    > Default is 8300, Linux filesystem. A list can be found at 
      https://gist.github.com/gotbletu/a05afe8a76d0d0e8ec6659e9194110d2

1. Name the partition `boot`.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/cgdisk2.png" width="600" >}}

1. Note the partition number of the EFI System partition. This will be referenced later when
configuring grub. In the screenshots above, it is partition 2. On **Windows
11** installs I've done, I have found this can be partition 1.

1. Select the free space.

1. Choose `[  New  ]`.

1. Enter no value for First sector (chooses default).

1. Enter no value for size in sectors (chooses default).

   > This will fill the remaining disk.

1. Enter no value for Hex code or GUID (chooses default).

1. Name the partition `root`.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/cgdisk3.png" width="600" >}}

1. Choose `[   Write   ]` and say yes.

1. Choose `[   Quit    ]`.

### Encrypting and Configuring the Root Partition

With the partitions setup, the root partition can be encrypted. Once encrypted,
a device mapper `/dev/mapper/*` will be used to interact with the partition. To
perform the encryption:

1. Encrypt the root partition.

    ```
    cryptsetup -y --use-random luksFormat /dev/nvme0n1p6
    ```

    > At the confirmation prompt, be sure to type `YES` in uppercase.

    * `-y`: interactively requests the passphrase twice.
    * `--use-random`: uses /dev/random to produce keys.
    * `luksFormat`: initializes a LUKS partition.


1. Open the LUKS device

    ```
    cryptsetup luksOpen /dev/nvme0n1p6 cryptroot
    ```

    * `luksOpen`: Opens the LUKS device and creates a mapping in `/dev/mapper`.

1. Run lsblk to view the new volume relationship.

1. Format the boot partitions as an `ext4` file system.

    ```
    mkfs.ext4 /dev/nvme0n1p5
    ```

1. Format the cryptroot as a `ext4` file system.

    ```
    mkfs.ext4 /dev/mapper/cryptroot
    ```

### Mounting and Installing Linux

With the filesystems in place, we need to mount the partitions to the local
files system (in `/mtn`) to begin writing to them. Once mounted, we'll be able
to use `pacstrap` which is like a version of `pacman` that installs packages
against a root filesystem you specify. To do perform these mounts and install:

1. Mount cryptroot at `/mnt`.

    ```
    mount /dev/mapper/cryptroot /mnt
    ```

1. Create a `boot` directory at root.

    ```
    mkdir /mnt/boot
    ```

1. Mount the boot directory to the boot partition.

    ```
    mount /dev/nvme0n1p5 /mnt/boot 
    ```

1. Create an `efi` directory in `/mnt/boot`.

    ```
    mkdir /mnt/boot
    ```

1. Mount the Window's created EFI partition to `/mnt/boot`.

    ```
    mount /dev/nvme0n1p2 /mnt/boot/efi
    ```

    > This is the partition you noted in the Disk Partitioning section.

1. Edit the mirrors file `/etc/pacman.d/mirrorlist` with preferred mirrors from
   [archlinux.org/mirrorlist](archlinux.org/mirrorlist).

   > Setting mirrors that are reliable and fast are key as these mirrors will be
   > used for your initial install and setup as the default mirrors for your
   > package installs going forward. I typically put `mit.edu` at the top and a
   > few more from the `America` section.

1. Install packages on the root file system.

    ```
    pacstrap /mnt linux linux-firmware base base-devel grub efibootmgr vim git intel-ucode networkmanager
    ```

    * `linux`: linux kernel ( https://www.archlinux.org/packages/core/x86_64/linux ).
    * `linux-firmware`: linux kernel ( https://www.archlinux.org/packages/core/any/linux-firmware ).
    * `base`: common packages for Linux ( https://www.archlinux.org/groups/x86_64/base ).
    * `base-devel`:common package for development in Linux ( https://www.archlinux.org/groups/x86_64/base-devel ).
    * `grub`: (GRand Unified Bootloader) is a multi-boot loader.
    * `vim`: text editor.
    * `git`: version control system.
    * `efibootmgr`: userspace application used to modify the Intel Extensible Firmware Interface (EFI) Boot Manager.
    * `intel-ucode`: processor microcode; assumes Intel x86 processor.
    * `networkmanager`: handles connecting to wireless and wired networks.

1. Generate file system table (fstab) for mounting partitions.

    ```
    genfstab -U /mnt >> /mnt/etc/fstab
    ```

    * `-u`: Use UUIDs for source identifiers.

### System Configuration

The system needs some configuration steps completed in order to support the
language, timezone, and expected character encodings. To configure these aspects, do:

1. Enter the system root via `arch-chroot`.

    ```
    arch-chroot /mnt
    ```

1. Set your timezone.

    ```
    ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime
    ```

1. Set the Hardware Clock from the System Clock, and update the timestamps in /etc/adjtime.

    ```
    hwclock --systohc
    ```

1. Uncomment `en_US.UTF-8 UTF-8` in `/etc/locale.gen`.

    ```
    #en_SG.UTF-8 UTF-8  
    #en_SG ISO-8859-1  
    en_US.UTF-8 UTF-8  
    #en_US ISO-8859-1  
    #en_ZA.UTF-8 UTF-8  
    ```

    > Modify for your [locale](https://wiki.archlinux.org/index.php/locale).

1. Generate [locale](https://wiki.archlinux.org/index.php/locale).

    ```
    locale-gen
    ```

1. Set the `LANG` variable to the same locale in `/etc/locale.conf`.

    ```
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    ```

1. Set your `hostname`.

    ```
    echo "taco" >> /etc/hostname
    ```

### Initial Ramdisk Configuration

The initial ramdisk is a root file system that will be booted into memory. It aids in startup. This
section covers setup and generation of an mkinitcpio configuration for generating 
[initramfs](https://wiki.archlinux.org/index.php/Arch_boot_process#initramfs).

1. Add `encrypt` to `HOOKS` in `/etc/mkinitcpio.conf` (order matters).

    ```
    HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)
    ```

    `HOOKS` are modules added to the initramfs image. Without `encrypt` and `lvm2`, systems won't
    contain modules necessary to decrypt LUKs.
1. Move `keyboard` before `modconf` in `HOOKS`.

    ```
    HOOKS=(base udev autodetect keyboard modconf block encrypt filesystems fsck)
    ```

1. Build initramfs with the `linux` preset.

    ```
    mkinitcpio -p linux
    ```

### GRUB Bootloader Setup

The bootloader will enable selection of and booting into Linux and Windows.
There are a variety of bootloaders out there, I prefer `grub` due to
familiarity. To setup `grub`:

1. Determine the UUID of your root partition and EFI parition.

    ```
    blkid
    ```

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/uuid.png" width="600" >}}

1. Edit the GRUB boot loader configuration.

    ```
    vim /etc/default/grub
    ```

1. Update the `GRUB_CMDLINE_LINUX` to match the format 
`cryptdevice=UUID=${ROOT_UUID}:cryptroot root=/dev/mapper/cryptroot` where `${ROOT_UUID}` is the UUID
captured above.

    ```
    GRUB_CMDLINE_LINUX="cryptdevice=UUID=4f7301bf-a44f-4b90-ad6d-5ec10a0c2f2a:cryptroot root=/dev/mapper/cryptroot"
    ```

1. Add grub menu item for Windows 10 by editing `/etc/grub.d/40_custom`.

    ```
    #!/bin/sh
    exec tail -n +3 $0
    # This file provides an easy way to add custom menu entries.  Simply type the
    # menu entries you want to add after this comment.  Be careful not to change
    # the 'exec tail' line above.
    if [ "${grub_platform}" == "efi" ]; then
      menuentry "Windows 11" {
        insmod part_gpt
        insmod fat
        insmod search_fs_uuid
        insmod chain
        # use:
        # after --set=root, add the EFI partition's UUID
        # this can be found with either:
        #
        # a. blkid
        # - or -
        # b. grub-probe --target=fs_uuid /boot/efi/EFI/VeraCrypt/DcsBoot.efi
        #
        search --fs-uuid --set=root $FS_UUID
        chainloader /EFI/VeraCrypt/DcsBoot.efi
      }
    fi
    ```

1. Replace `$FS_UUID` with the EFI partition's UUID, found in step 1 of this
   section. In this example:

    ```
    search --fs-uuid --set=root 8E12-69DD
    ```

1. Install grub.

    ```
    grub-install
    ```

    > This assumes your efi is located in `/boot/efi`; additional flags are
    > available if you used an alternative location.

1. Generate the grub configuration.

    ```
    grub-mkconfig -o /boot/grub/grub.cfg
    ```

### Final Setup

Lastly, you need to ensure your initial user is setup and a networking daemon is
good to go when you reboot. The final steps are:

1. Set the root password.

    ```
    passwd
    ```

1. Add a user.

    ```
    useradd -m -G wheel josh
    ```

    * `-G` adds the user to a group.
    * `-m` creates a home directory.

1. Set the user's password.

    ```
    passwd josh 
    ```

1. Enter visudo.

    ```
    visudo
    ```

    `visudo` edits the sudoers files at /etc/sudoers. It does this safely by acquiring a lock.

1. Uncomment the lines that allow users of group `wheel` to sudo.

    ```
    ## Uncomment to allow members of group wheel to execute any command
    %wheel ALL=(ALL) ALL
    ``` 

1. Enable NetworkManager to ensure it starts after boot.

    ```
    systemctl enable NetworkManager
    ```

1. Exit the `arch-chroot`

    ```
    exit
    ```

1. Unmount the partitions.

    ```
    umount -R /mnt
    ```

1. Reboot.

    ```
    reboot
    ```

1. Using grub, login to Arch Linux.

1. Use `nmtui-connect` to establish internet and begin installing packages.

Congrats! You have officially booted your new Linux desktop.

### Desktop Environment

For my desktop environment, I install all packages and configuration using a
Makefile found at [github.com/octetz/linux-desktop](https://github.com/octetz/linux-desktop).

I've detailed this process in my [Linux Desktop
Configuration](/docs/2020/2020-02-23-linux-desktop-configuration/) post.
