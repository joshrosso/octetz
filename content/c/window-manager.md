---
title: Why I Don't Care About My Window Manager
weight: 9979
description: What I have learned trying to optimize my window management experience over the years!
date: 2020-09-03
images:
- https://octetz.s3.us-east-2.amazonaws.com/why-i-dont-care-about-my-window-manager/title-card.png
aliases:
---

# Why I Don't Care About My Linux Window Manager

Conversations around window managers can be a little contentious...but for some of us, it makes very little difference. I'm one of those humans. As much as I adore nerding out around some ultra-minimal window manager that requires you change settings by compiling its c code, at the end of the day I gain little benefit from any specific approach.

{{< youtube AK2UKUfsV3g >}}

That said, I do love and prefer Linux. The fact that we're afforded these choices around window managers is what draws many of us in initially. Your computer, whether running Ubuntu or Arch, can flip a switch to run a very capable, heavy-weight manager such as [KDE](https://kde.org/) or a manager with a binary size of ~1mb, such as [dwm](https://dwm.suckless.org/). Before diving too deep into my day-to-day workflow, let's set some primer around window managers.

## Window Managers

Window managers come in two, primary, varieties. These include stacked and tiled. Tiled are commonly composed of several "workspaces", which can be switched through and host one or many windows, tiled side-by-side. They (typically, by default) do not allow windows to stack or overlap. The following screenshot, from Wikipedia, demonstrates this for i3.

![https://octetz.s3.us-east-2.amazonaws.com/why-i-dont-care-about-my-window-manager/i3.png](https://octetz.s3.us-east-2.amazonaws.com/why-i-dont-care-about-my-window-manager/i3.png)

Stacked window managers, on the other hand, are what we conventionally think of. Especially those of us that have a history with OSX (mac) or Windows. These window managers give us floating windows that can overlap and be moved into any format on our screens. The following screenshot, from Wikipedia, demonstrates this for xfce.

![https://octetz.s3.us-east-2.amazonaws.com/why-i-dont-care-about-my-window-manager/xfce.png](https://octetz.s3.us-east-2.amazonaws.com/why-i-dont-care-about-my-window-manager/xfce.png)

From my experience, many have associated the move to tiling managers as a more hardcore approach to interacting with Linux. Or at least one we associate with focus, minimalism, and/or getting things done. Over the years, some using i3 and others using dwm, I have found my productivity remain relatively static. I did have some super cool layouts that I loved looking at. However, I am a habitual over-optimizer. This trait sends me down constant rabbit holes of thinking through what workspace I should assign to which tasks, how I should be setting up a tiling layout for optimal focus, and many more considerations. Eventually I realized this constant customization was causing me more loss in focus than the gain I'd hoped to have leaving stacked managers behind.

In short, this was a me problem, not a tiling window manager problem. Knowing myself better now, I have switched back to stacked managers, with optimizations and automation focused around my key priorities.

## Priorities

My priorities around workflow are fairly straight forward. Given I have the attention span of a small squirrel, my key priorities are:

1. Switch between key applications quickly
2. Switch between key applications with minimal context-switching

So switching between applications, this isn't too hard in any window manager, is it? Sure, it is not. However minimizing the thought required to jump from a to b is huge for my work. For example, at the most intense end of the spectrum, clicking around and moving windows to find firefox is less than ideal. Even using flows like alt+tab or a launcher requires me to think about where the thing is or how to find/focus it. Additionally, the applications I care about and need to switch between are fairly minimal in quantity. There are maybe 7 total with 4 key ones I constantly toggle. These are:

- Web Browser (firefox)
- Terminal (st)
- IDE (intellij)
- File browser (nemo)

For me, the question is, with a key or two, can I bring up the application I need to get the task done no matter where it preexisted. Additionally, if the app isn't running, can I transparently launch it without being concerned about another shortcut or workflow? This is where my most important trick comes in, a script named `lof` (launch or focus).

## Launch or Focus (lof)

`lof` is a simple script that does exactly what the name implies. If the app isn't running, it launches it. If the app is, it focuses it. `lof` is not a unique solution. For example there is [jumpapp](https://github.com/mkropat/jumpapp), which is a far more capable tool than `lof`. I have chosen to write `lof` because it is less than 20 lines of shell script (when comments are removed), easy to understand, and handles 97% of my use cases.

`lof` can be found in my [octetz/linux-desktop repository](https://github.com/octetz/linux-desktop/blob/master/s/lof). I have [another blog](https://octetz.com/docs/2020/2020-02-23-linux-desktop-configuration/) post on how I use this repo, if you're interested. At the time of this writing, the script looks something like this.

```bash
#!/bin/sh

# lof: launch or focus
# this script checks whether an app is running and
# if running, focuses the window
# if not running, launches the app

# this script is likely called from another command or script

# usage: lof [arg]
# [arg]: provide the full path, arguments, and flags representing the process
# The value of arg will be looked up literally in the process list by wrapping [arg] in ^ (start) and $ (end)
# for example, to ensure the correct firefox window is launched, lof would be used as follows:
# lof /usr/lib/firefox/firefox

# for web-based apps, nodejs-natifier can be used to generate a desktop binary
# https://aur.archlinux.org/packages/nodejs-nativefier

# this script assumes the app exists and wmctrl is installed
# checks do not occur to ensure optimal performance

APP_NAME="$1"

# find pid for app process
# -f includes the entire process details, including arguments and flags
APP_PID="$(pgrep -f "^${APP_NAME}$")"

# if app is not running, start it
# if app is running, focus it
if [ -z "$APP_PID" ]
then
  # launch app
  $APP_NAME
else
  # using the pid, find the window id, then focus it
  wid=$(wmctrl -lp | grep "$APP_PID" | awk '{print $1}')
  # -R moves the window to the current desktop AND brings it to focus
  wmctrl -iR "$wid"
fi
```

`lof`'s goal is to determine if an app is running and if it's not, launch it. If it is running, it stores the process id and correlates that to the window id. Once the window id is found, it focuses the window, using a tool called [wmctrl](https://en.wikipedia.org/wiki/Wmctrl). For example, my usage of `lof` for firefox is:

```bash
lof /usr/lib/firefox/firefox
```

`lof` expects to resolve the **exact** command when it runs `pgrep`, this enables `lof` to be very specific around what window it looks up. If you're interested in the gory details of how these pieces fit together, keep reading this section. Otherwise, you should skip to the next section.

To understand `lof`, it is important to understand how window ids and process ids are related. Technically, we can look up windows by their titles, however, many applications re-title their window based on the context of where the user is in the app. Thus, correlating process id to window id is preferable. Assuming firefox is running, you can lookup its window id with `wmctrl`.

```bash
wmctrl -lp

0x01800003 -1 899    taco xfce4-panel
0x01000028 -1 945    taco Desktop
0x02e00006  0 1139   taco tmux
0x0300004d  0 2804   taco linux-desktop – lof
0x03200003  0 5276   taco Arch Linux - Mozilla Firefox
0x06200006  0 7115   taco VLC media player
```

In the above desktop, *Arch Linux - Mozilla Firefox* is clearly the firefox window. The process id is `5276` and the window id is `0x03200003`. Since `lof` resolves based on the process's command, we should look that up using the process id.

```bash
ps 5276

PID TTY      STAT   TIME COMMAND
5276 pts/2    Sl    13:49 /usr/lib/firefox/firefox
```

And just like that, we know that `/usr/lib/firefox/firefox` is the correct argument to send to `lof`. When `lof /usr/lib/firefox/firefox` is run, `pgrep` is used to resolve a process with that **exact** command. If `pgrep` returns no result, `lof` executes the command it was fed as an argument. If `pgrep` did find a result, it can use the process id to run the above `wmctrl -lp` command and resolve the window id via `grep` and `awk`.

```bash
wmctrl -lp | grep 5276 | awk '{print $1}'

0x03200003
```

It then uses `wmctrl -iR` to focus the firefox window.

```bash
wmctrl -iR 0x03200003
```

And that end-to-end is `lof`! There are times where some apps, such as those requiring JRE, need more love than `lof` can handle. In those cases, rather than making `lof` smarter, I chose to write a slightly modified script. You can find an example with my [lof_intellij](https://github.com/octetz/linux-desktop/blob/master/s/lof_intellij) script in GitHub.

## Shortcuts

The glue that holds this all together is the shortcuts or key bindings. For key bindings, I use [xbindkeys](https://wiki.archlinux.org/index.php/Xbindkeys). The reason I prefer it over other tools, is its generic approach to capturing mouse or keyboard events. Captured events can execute scripts in **any window manager**. This means that when I randomly decide to switch back to dwm, all my keys bindings come with me.

xbindkeys, assuming it is installed, can be added to your `~/.xinitrc` file to launch when you start your window manager. An example of mine is:

```bash
exec xrdb ~/.Xresources &
xset r rate 150 60 &
# only required when wm does not have compositor
# exec picom &
feh --bg-scale ~/photos/wallpapers/current.jpg &
xbindkeys -p &
# options are dwm, i3, and startxfce4
exec startxfce4
```

The `-p` flag tells `xbindkeys` to poll the rc (configuration) file for changes. The last step is to setup this rc file to include the `lof` commands. The rc file is, by default, located at `~/.xbindkeysrc`. On my machine, a some of the configuration look as follows.

```bash
# launch demu
"dmenu_run -fn Hack-16:normal -l 5"
    m:0x40 + c:65
    Mod4 + space

# launch browser
"lof /usr/lib/firefox/firefox"
    m:0x40 + c:45
    Mod4 + k

# launch or focus terminal
"lof st\ \-e\ tmux"
    m:0x40 + c:44
    Mod4 + j

# launch or focus nemo
"lof nemo"
    m:0x40 + c:40
    Mod4 + d
```

You can see the many uses of `lof`. The quoted text is the script to be run when an event is detected for the key codes below it. `xbindkeys` offers a simple way to figure out these key strokes. You run `xbindkeys -k` and hit the key you want to resolve. For example, this is the result of `mod` (window key) + `e`:

```bash
xbindkeys -k

Press combination of keys or/and click under the window.
You can use one of the two lines after "NoCommand"
in $HOME/.xbindkeysrc to bind a key.
"(Scheme function)"
    m:0x4 + c:26
    Control + e
```

Now, assume you want to use that as a keyboard shortcut for the GUI app `blueman-manager` (a bluetooth utility). With the app running, you lookup the command.

```bash
ps aux | grep -i blueman-manager
josh       11874  2.1  0.1 625088 51320 tty1     Sl   16:54   0:00 /usr/bin/python /usr/bin/blueman-manager
```

Now you can see the command is `/usr/bin/python /usr/bin/blueman-manager`. Due to the space, you must delimit it so it is treated as a space character and **not** a second argument passed to `lof`. Taking the information from the preceding examples, you can add the following to `~/.xbindkeysrc`.

```bash
# launch blueman-manager
"lof /usr/bin/python\ /usr/bin/blueman-manager"
    m:0x40 + c:26
    Mod4 + e

# -- remainder of config redacted --
```

Now `mod4`+`e` will launch or focus `blueman-manager`.

## Summary

In short, over years of using many different window managers with different philosophies, I've found that the idea of easily triggering the app I need to get to is the real value add for any desktop experience. This is true for me and, at a minimum, hopefully this provided interesting perspective for your future Linux endeavors!josh @ taco (/tmp) []