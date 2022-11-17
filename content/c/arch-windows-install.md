---
title: Arch Linux and Windows 10 (UEFI + Encrypted) Install Guide
weight: 9987
description: How I setup my personal/work machines with Linux + Windows using UEFI and fully encrypting both partitions.
date: 2020-02-16
images:
- https://octetz.s3.us-east-2.amazonaws.com/title-card-arch-windows-install.png
---

# Arch Linux and Windows 10 (UEFI + Encrypted) Install Guide

This post details the installation process for my work and personal computers.
At a high-level, my setup is a dualboot system running Windows 10 and Arch
Linux. The Windows partition is encrypted with
[VeraCrypt](https://www.veracrypt.fr/en/Home.html) and the Linux partition with
[LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup). The post will
detail the step-by-step. The video link below providers more context on how all
the pieces fit together.

{{< yblink ybvwikNlx9I >}}

## Installation Media

This section covers creating installation media for Windows and Arch Linux. You'll need 2 USB 
drives sized to >= 8GB. These steps cover media creation from Windows (for the Windows 10 
ISO) and Linux (for the Arch Linux ISO)  workstations. There are many alternative ways to create
installation media. If you choose to go with an alternative, skip this section.

### Windows Installation Media

As of Windows 10, Microsoft requires you to download a tool to create windows installation media. 
This `.exe` requires a Windows host to create the installation media. If you do not have a Windows
host to run this installer, Microsoft offers a USB for purchase.

Windows did not historically have this restriction. For example, 
[Windows 8](https://www.microsoft.com/en-us/software-download/windows8ISO). You could follow this
guide using Window 8. To create installation media directly from an ISO, consider
[WoeUSB](https://github.com/slacka/WoeUSB).

### Arch Linux Installation Media

1. Download the Arch Linux ISO.

    https://www.archlinux.org/download

1. Insert a USB drive.

1. List block devices and determine the device name.

    ```
    lsblk

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

    > In the above example, the USB drive is `sda`.

1. Write the ISO to the device using dd.

    ```
    dd bs=4M if=path/to/archlinux.iso of=/dev/sdx status=progress oflag=sync
    ```

    * `dd`: copies and converts a file based on arguments.
    * `bs`: amount of bytes to write at a time.
    * `if`: specify a file to read rather than stdin.
    * `of`: specify a file to write to rather than stdout.
    * `status`: level to log to stderr; progress shows periodic transfer stats.
    * `oflag`: set to sync synchronizes I/O for data and metadata.


## BIOS Settings

1. Boot into BIOS.

    > Often accomplished by hitting F2 on start-up.

1. Verify UEFI booting is enabled.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/uefionly.png" width="600" >}}

1. Verify Secure Boot is disabled.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/secure-boot.png" width="600" >}}

    > Arch Linux can be installed with Secure Boot. See 
      https://wiki.archlinux.org/index.php/Secure_Boot


## Installing Windows

This section covers installing Windows. Installing it first allows reuse of the Windows-created
EFI partition. Using VeraCrypt, the Windows partition will be encrypted.

1. Insert the USB containing Windows.

1. Power on.

1. While booting, open the device boot menu.

    > Often achieved by hitting F12 during boot.

1. Select the USB device in UEFI mode.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/select-windows-usb.png" width="600" >}}

    > If you boot in legacy mode, the Arch UEFI installation will **not** work.

1. Select the language to install and click Next.

1. Click Install now.

1. Enter your product key and click Next.

1. Accept the license terms and click Next.

1. Click Custom: Install Windows only (advanced).

1. Delete all existing partitions.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/deleted-windows-partitions.png" width="600" >}}

1. Create a new partition of the size you'd like Windows to occupy.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/click-new-windows.png" width="250" >}}

    > Windows creates additoinal partitions including the 100.0MB System partition that will act as the EFI partition.  1. Click Next and wait for Windows to install.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/windows-made-partitions.png" width="250" >}}

    > After the installation completes, the machine will reboot.

1. After reboot, go through the Windows setup procedure.

   {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/windows-setup-proceedure.png" width="400" >}}

1. Open Control Panel.

1. In the top right search, enter `power`.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/control-panel.png" width="600" >}}

1. Click `Change what the power buttons do`.

1. Clickk `Change settings that are unavailable`.

1. Uncheck `Turn on fast startup (recommended)`.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/disable-fast-startup.png" width="600" >}}
    

    > To understand why fast startup is not recommended, see 
      [https://wiki.archlinux.org/index.php/Dual_boot_with_Windows#Fast_Start-Up](https://wiki.archlinux.org/index.php/Dual_boot_with_Windows#Fast_Start-Up)

1. Open Start > Settings > Update & Security and Check for updates.

1. Allow all Windows updates to download and install before proceeding.

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

## Installing Arch Linux

This section covers installing Arch Linux. Using Linux Unified Key Setup (LUKS), the root partition 
will be encrypted.

1. Insert the USB containing Arch Linux.

1. Boot the machine.

1. While booting, open the device boot menu.

    > Often a key like F12 launches the boot menu.

1. Select the USB device.

    > If legacy boot is enabled on your system, assure you're choosing to boot the USB via UEFI.

1. At the Arch Boot Menu, hit `e` at the menu to edit parameters.

1. Add `nomodeset video=1280x760` to the list of commands.

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/nodemodeset.png" width="600" >}}

    > This boots the installer in lower resolution making the console easier to see.

1. Run `wifi-connect` and select a wireless network.

    > If plugged into ethernet, this step can be skipped.

1. Validate connectivity.

    ```
    ping google.com   

    PING google.com (216.58.193.206) 56(84) bytes of data.
    64 bytes from lax02s23-in-f14.1e100.net time=809 ms
    64 bytes from lax02s23-in-f14.1e100.net time=753 ms
    ```

**After the steps above, I always start sshd (included in the archiso) and
finish the installation process from another computer. This enables me to have
access to copy and paste, editors, and browsers rather than the restricted
terminal on my target machine. This is optional, but the steps below may
make your experience better.**

1. Set a root passwd for archiso.

    ```
    passwd
    ```

1. Enable `sshd`.

    ```
    systemctl start sshd
    ```

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/ssh-install.png" width="600" >}}

1. Determine your local address using `ip a`.

1. From another machine, ssh in.

    ```
    ssh root@${TARGET_MACHINE_IP}
    ```

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/in-other-machine.png" width="600" >}}

    > From this point forward, I'm completing the installation from another
    > Linux desktop. You can also use Windows (putty) or Mac.

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
configuring grub. In the screenshots above, it is partition 2.

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

### Mounting and Installing

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

This section enters the new Arch Linux system and configures the system.

1. Enter the system root via `arch-chroot`.

    ```
    arch-chroot /mnt
    ```

1. Set the timezone.

    ```
    ln -sf /usr/share/zoneinfo/MST /etc/localtime
    ```

    > `MST` is my zone, yours may vary.

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

1. Determine the UUID of your root partition and EFI parition.

    ```
    blkid
    ```

    {{< img src="https://octetz.s3.us-east-2.amazonaws.com/linux-windows-install/uuid.png" width="600" >}}

2. Edit the GRUB boot loader configuration.

    ```
    vim /etc/default/grub
    ```

3. Update the `GRUB_CMDLINE_LINUX` to match the format 
`cryptdevice=UUID=${ROOT_UUID}:cryptroot root=/dev/mapper/cryptroot` where `${ROOT_UUID}` is the UUID
captured above.

    ```
    GRUB_CMDLINE_LINUX="cryptdevice=UUID=4f7301bf-a44f-4b90-ad6d-5ec10a0c2f2a:cryptroot root=/dev/mapper/cryptroot"
    ```

5. Add grub menu item for Windows 10 by editing `/etc/grub.d/40_custom`.

    ```
    #!/bin/sh
    exec tail -n +3 $0
    # This file provides an easy way to add custom menu entries.  Simply type the
    # menu entries you want to add after this comment.  Be careful not to change
    # the 'exec tail' line above.
    if [ "${grub_platform}" == "efi" ]; then
      menuentry "Windows 10" {
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

6. Replace `$FS_UUID` with the EFI partition's UUID, found in step 1 of this
   section.

    ```
    #!/bin/sh
    exec tail -n +3 $0
    # This file provides an easy way to add custom menu entries.  Simply type the
    # menu entries you want to add after this comment.  Be careful not to change
    # the 'exec tail' line above.
    if [ "${grub_platform}" == "efi" ]; then
      menuentry "Windows 10" {
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
        search --fs-uuid --set=root 8E12-69DD
        chainloader /EFI/VeraCrypt/DcsBoot.efi
      }
    fi
    ```

6. Install grub.

    ```
    grub-install
    ```

    > This assumes your efi is located in `/boot/efi`; additional flags are
    > available if you used an alternative location.

7. Generate the grub configuration.

    ```
    grub-mkconfig -o /boot/grub/grub.cfg
    ```

### User Administration

1. Set the root password.

    ```
    passwd
    ```

2. Add a user.

    ```
    useradd -m -G wheel josh
    ```

    * `-G` adds the user to a group.
    * `-m` creates a home directory.

3. Set the user's password.

    ```
    passwd josh 
    ```

4. Enter visudo.

    ```
    visudo
    ```

    `visudo` edits the sudoers files at /etc/sudoers. It does this safely by acquiring a lock.

5. Uncomment the lines that allow users of group `wheel` to sudo.

    ```
    ## Uncomment to allow members of group wheel to execute any command
    %wheel ALL=(ALL) ALL
    ``` 

### Enable Networking

1. Enable NetworkManager to ensure it starts after boot.

    ```
    systemctl enable NetworkManager
    ```

### Rebooting

1. Exit the `arch-chroot`

    ```
    exit
    ```

2. Unmount the partitions.

    ```
    umount -R /mnt
    ```

3. Reboot.

    ```
    reboot
    ```

4. Using grub, login to Arch linux.

5. Use `nmtui-connect` to establish internet and begin installing packages.

    > From here you can install any window manager such as:

      * [gnome-desktop](https://www.archlinux.org/packages/extra/x86_64/gnome-desktop/)
      * [i3-wm](https://www.archlinux.org/packages/?name=i3-wm)
      * [xfce](https://www.archlinux.org/groups/x86_64/xfce4)
