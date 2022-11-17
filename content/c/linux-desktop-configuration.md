---
title: Linux Desktop Configuration
weight: 9986
description: How I configure my Linux desktop environment directly after an install.
date: 2020-02-23
images:
- https://octetz.s3.us-east-2.amazonaws.com/linux-desktop-config/title-card.png
---

# Linux Desktop Configuration

[In my previous post](../2020-2-16-arch-windows-install), I covered installation
of Linux, Windows, and encryption of the two operating systems. In this
post, I'll be building on the Linux installation by describing how I bootstrap
my desktop environment.  I fully wipe my machine approximately every 2 months. I
do this to keep things clean and also ensure I'm not putting myself in a
position where I cannot reproduce my desktop environment. It is easy, especially
with Arch Linux, to fall into a trap where you've tuned and customized
everything so much, the idea of reformatting is frightening. However, as you'll
see in this post, with some simple automation, you can ensure [fairly]
consistent desktop environments across installs.

{{< yblink Q_3vc-u01Bw >}}

## Setup

My entire configuration is sourced at https://github.com/octetz/linux-desktop.
As described in the README, each step is triggered via a `make` command. There
are a few key ones.

* install-packages
  * Installs all official + AUR packages.
  * This includes window managers.
* configure
  * Does all system and user-level configuration.
  * Enables select systemd units, creates configuration files, and symlinks.
* install-wm
  * Compiles and installs my fork of [dwm](https://dwm.suckless.org).
* install-terminal
  * Compiles and installs [st](https://st.suckless.org).

The rest of this post details how the automation works and what I install. I'm
sharing this process to help others create automation for their own
reproducible desktop installs. If
those details don't interest you, clone the repo and try the
Makefile for yourself.

## Packages

To install packages, there are two types to consider.

* Official Packages
* Arch User Repository (AUR) Packages

For official packages, the script calls a pacman install command as follows.

```
# requires sudo
pacman -Sy --needed $(<packages-official.txt)
```

The `needed` flag will check whether an up-to-date version of the package
pre-exists, which makes the command idempotent.

A simple list of all packages is maintained in `packages-official.txt`.

```
alsa-utils
ansible
arandr
base
base-devel
bash-completion
blueman
bluez
bluez-utils
chromium
cmake
ctags
dhclient
dmenu
dnsutils
docker
firefox
git
go
i3lock
i3status
imagemagick
intel-ucode
jdk10-openjdk
jq
libvncserver
mutt
nemo
neovim
net-tools
network-manager-applet
networkmanager
networkmanager-openconnect
obs-studio
openconnect
openssh
pavucontrol
picom
pulseaudio-bluetooth
remmina
ripgrep
signal-desktop
terraform
the_silver_searcher
ttf-hack
ttf-inconsolata
volumeicon
xf86-video-intel
xfce4
xorg
xorg-xinit
yarn
```

The above is my master list, which I've committed to retaining after every
re-install. I prefer to maintain this list over time, rather than trying to keep
it constantly updated with packages on my machine. The reason is, over time I
install many package I end up not using, so after each re-install, I lose (and
forget about) any packages not persisted in this list.

If you'd like to query pacman to get your current package list, run the
following.

```
pacman -Q | cut -f 1 -d " "
```

Installing AUR packages is accomplished with the following.

```
TEMP_DIR=$(mktemp -d)

while read AUR_PKG
do
  if ! pacman -Q ${AUR_PKG} > /dev/null; then 
    cd $TEMP_DIR
    git clone https://aur.archlinux.org/${AUR_PKG}.git
    cd ${AUR_PKG} && makepkg -si --noconfirm && cd $TEMP_DIR
  fi
done < packages-aur.txt
```

Similar to official packages, this will verify whether the package pre-exists
before attempting to install it. This method does not use an AUR-helper as I'm
not a huge fan of them and prefer to manually inspect `PKGBUILD`s before
installing a package.

The `packages-aur.txt` list is formatted the same as the official list.

```
cef-minimal
dropbox
gconf
golang-dep
kubectl-bin
obs-linuxbrowser-bin
slack-desktop
spotify
zoom
```

Due to the official and user repositories being so deep with packages, there are
only 2 "packages" I compile and install manually. Those are:

* [dwm](https://dwm.suckless.org): Window manager
* [st](https://st.suckless.org): Terminal

The reason I don't use pacman or AUR to install these packages is they require
changes to source (C code) to make configuration changes. This means every
change requires a recompilation and moving of binaries to the system's path. On
[octetz/linux-desktop](https://github.com/octetz/linux-desktop), you'll find
the source code for my dwm and st. Additionally the Makefile calls Makefiles in
the st and dwm directories to update each.

## Configuration

Configuration is a bunch of loose ends I tie up, this includes:

* Copying dotfiles
* Enabling certain systemd units
* Creating symlinks

This is primarily accomplished with some ugly, but functional, shell scripts.

* [configure-system](https://github.com/octetz/linux-desktop/blob/5d8f672b9ca75f9855841dfebd8ad5d0713e61c8/pkg/configure-system.sh#L1)
* [configure-user](https://github.com/octetz/linux-desktop/blob/5d8f672b9ca75f9855841dfebd8ad5d0713e61c8/pkg/configure-user.sh#L1)

## Window Manager and Desktop Initialization

For window management, I use `xfce` (floating) and `dwm` (tiling). Based on the
steps described above, everything is in place to start the desktop. One of the
key dotfiles copied over is the `.xinitrc`, which instructs what processes
(including window managers) to start when running `startx`.

The `.xinitrc` typically looks as follows.

```
exec xrdb ~/.Xresources &
xset r rate 150 60 &
exec picom &
eval $(ssh-agent) &
feh --bg-scale ~/photos/wallpapers/current.jpg &
exec startxfce4
```

In the above, there are 2 essential commands for my desktop.

* exec [picom](https://wiki.archlinux.org/index.php/Picom)
  * This is the next generation of the compton compositor.
  * Without a compositor, the X window system can have serious limitations when
    screen sharing. More trivially, you also need a compositor to allow for
    transparency of windows.
  * The configuration for the compositor is stored in
    `~/.config/picom/picom.conf`, which I also keep stored in my GitHub repo.

* exec startxfce4
  * This starts the window manager.
  * Depending on what I'm doing, I'll sometimes switch this to `dwm`, when I
    want to run a minimal tiling manager.

## Updating

Over time, it's helpful to copy a machine's local dotfiles over and commit them
via git for a future install. While you could also setup a process to update the
package list, I choose not to do this. The update command copies all local
dotfiles into the git repo, and allows the git history determine what has
changed and potentially committed.

## Summary

With that, you now have a desktop environment! I hope you found this post
interesting and [checkout the video](https://youtu.be/Q_3vc-u01Bw) to see it in action!
