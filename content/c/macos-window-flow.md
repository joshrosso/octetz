---
title: "macOS Window Flow"
date: 2022-11-16T10:41:11-07:00
draft: false
---

Metadata is crucial for several I've changed my workstation setup to be an M1 Mac running a Linux VM for
development. Largely inspired by Mitchell Hashimoto's work at
[mitchellh/nixos-config](https://github.com/mitchellh/nixos-config). While I've
benefited deeply from Mac's [SoC] solid battery life, graphics, and audio, I find the
window management clunky and heavy with annoying animations.

[As always](https://joshrosso.com/c/window-manager), my goal is to get the
window manager out of the way as much as possible resulting in the ability to
switch between tasks with minimal context lost. In this post, I'm going to
describe the small things I've done to make this possible.

## Home row app switching and other things

My computer usage is pretty simple. When I'm writing software I use 4 things:

1. Terminal (IDE built in)
1. Web Browser
1. Diagramming
1. Chat

With the 4 above apps, I map each to a key on home row, attached to a super-key
combination of `cmd` + `shift`.

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="100%" viewBox="-0.5 -0.5 821 421" content="<mxfile host=&quot;app.diagrams.net&quot; modified=&quot;2022-11-16T14:49:37.201Z&quot; agent=&quot;5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36&quot; version=&quot;20.5.3&quot; etag=&quot;gwO0pKqIATifdvo65bLo&quot; type=&quot;device&quot;><diagram id=&quot;7ZYXt5zFVFgLNJ-U11xJ&quot;>7Vldk5owFP01PG4HCER4XF1tp90++dDuY4Tw0QKhMa7YX98giZAFZ5wVzLjTJ3NPwiU5J0duwACLvPpMUZl8JyHODNsMKwM8GbZt+xbkPzVyaBDLsgUS0zQUWAus079YgKZAd2mIt8pARkjG0lIFA1IUOGAKhigle3VYRDL1riWKcQ9YByjroz/SkCUN6rlmi3/BaZzIO1um6MmRHCyAbYJCsu9AYGmABSWENa28WuCsZk/y0ly3OtN7mhjFBbvkAru54BVlO7E2MS92kIulZFeEuB5vGmC+T1KG1yUK6t4915djCcszHlm8GZGCCb0sr47TLFuQjNBjLrDyVo/LJ45vGSW/cacHQOADfpO5mBCmDFdnF2WdqOKbDJMcM3rgQ8QFD3KfiP112jf7jlhSgaQjlCNBJDZIfMrdcsgbgsZhSkGPQRzy3SNCQllCYlKgbNmic5XjdswzIaVg9hdm7CCoRTtGVN45M/Tws77+kyvDF5HuGDxVSnQQ0Vu9cJWyThoevcg78HabpA5kjma99SIVvbZkRwMBOcKkiMb4ZIqLZaU4Qyx9VdNfI5EzsOthxgQfinjwz47IjoftkalHPsDyyuq4dNnPW3H9+1Vm4nNokjX4lbZSbRRFGAbBkI3Cmb8xzXFsZL+xEfD7NpoNuGg2goncezbRBYaAA4aw9RkCTmeIb7cwRIiwFw0aAgYe3kTjGAJoNMTsgxvCGzAE0GcIbzpDPN/EEC72QmfIEJ69ARCOYwhHoyH8ezbERGWWlENxkaPPRXI+U9ioaU5uJGxxK82GjOTDGUAjGcnVaCRZiE8hEsM0T7nBPk5R7KhCuaAvlOUOHS3HUGrotD6SUpv6rQimH6dYs4FOpcBZpbYlKq5SKkxRTFHOfRV31GrS3m8lYetU6/z7gKvVChLEbiHTbZ5T0NIp012/FJiq5PP7JZ/Oig/q0Ogd580h3qBG3rSc70fizdPIm/f/P+EijeQftxaR/Onq1iAPjbp2mNdZkjRitzlqBMHwUWPMz1jAVB+2Nuw/bG1znIctD9uPjse+zrdbsPwH</diagram></mxfile>" style="background-color: rgb(255, 255, 255);"><defs></defs><g><rect x="0" y="0" width="820" height="420" fill="#f8faed" stroke="#36393d" pointer-events="all"></rect><path d="M 255 250 L 255 285 L 125 285 L 125 313.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 125 318.88 L 121.5 311.88 L 125 313.63 L 128.5 311.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><rect x="220" y="180" width="70" height="70" fill="#ffe6cc" stroke="#d79b00" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 68px; height: 1px; padding-top: 215px; margin-left: 221px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><font style="font-size: 18px;">J</font></div></div></div></foreignObject><text x="255" y="219" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">J</text></switch></g><path d="M 355 250 L 355 285 L 315 285 L 315 313.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 315 318.88 L 311.5 311.88 L 315 313.63 L 318.5 311.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><rect x="320" y="180" width="70" height="70" fill="#dae8fc" stroke="#6c8ebf" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 68px; height: 1px; padding-top: 215px; margin-left: 321px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><font style="font-size: 18px;">K</font></div></div></div></foreignObject><text x="355" y="219" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">K</text></switch></g><path d="M 455 250 L 455 285 L 505 285 L 505 313.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 505 318.88 L 501.5 311.88 L 505 313.63 L 508.5 311.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><rect x="420" y="180" width="70" height="70" fill="#d5e8d4" stroke="#82b366" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 68px; height: 1px; padding-top: 215px; margin-left: 421px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><font style="font-size: 18px;">L</font></div></div></div></foreignObject><text x="455" y="219" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">L</text></switch></g><path d="M 555 250 L 555 285 L 695 285 L 695 313.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 695 318.88 L 691.5 311.88 L 695 313.63 L 698.5 311.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><rect x="520" y="180" width="70" height="70" fill="#e1d5e7" stroke="#9673a6" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 68px; height: 1px; padding-top: 215px; margin-left: 521px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><font style="font-size: 18px;">;</font></div></div></div></foreignObject><text x="555" y="219" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">;</text></switch></g><rect x="50" y="320" width="150" height="40" fill="#ffe6cc" stroke="#d79b00" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 148px; height: 1px; padding-top: 340px; margin-left: 51px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><font style="font-size: 18px;">terminal</font></div></div></div></foreignObject><text x="125" y="344" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">terminal</text></switch></g><rect x="240" y="320" width="150" height="40" fill="#dae8fc" stroke="#6c8ebf" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 148px; height: 1px; padding-top: 340px; margin-left: 241px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><font style="font-size: 18px;">browser</font></div></div></div></foreignObject><text x="315" y="344" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">browser</text></switch></g><rect x="430" y="320" width="150" height="40" fill="#d5e8d4" stroke="#82b366" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 148px; height: 1px; padding-top: 340px; margin-left: 431px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><span style="font-size: 18px;">diagramming</span></div></div></div></foreignObject><text x="505" y="344" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">diagramming</text></switch></g><rect x="620" y="320" width="150" height="40" fill="#e1d5e7" stroke="#9673a6" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 148px; height: 1px; padding-top: 340px; margin-left: 621px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><span style="font-size: 18px;">chat</span></div></div></div></foreignObject><text x="695" y="344" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">chat</text></switch></g><path d="M 410 90 L 410 135 L 255 135 L 255 173.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 255 178.88 L 251.5 171.88 L 255 173.63 L 258.5 171.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><path d="M 410 90 L 410 135 L 355 135 L 355 173.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 355 178.88 L 351.5 171.88 L 355 173.63 L 358.5 171.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><path d="M 410 90 L 410 135 L 455 135 L 455 173.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 455 178.88 L 451.5 171.88 L 455 173.63 L 458.5 171.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><path d="M 410 90 L 410 135 L 555 135 L 555 173.63" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 555 178.88 L 551.5 171.88 L 555 173.63 L 558.5 171.88 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><rect x="310" y="50" width="200" height="40" fill="#ffcccc" stroke="#36393d" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 198px; height: 1px; padding-top: 70px; margin-left: 311px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="box-sizing: border-box; font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;"><font style="font-size: 18px;">cmd + shift</font></div></div></div></foreignObject><text x="410" y="74" fill="rgb(0, 0, 0)" font-family="Helvetica" font-size="12px" text-anchor="middle">cmd + shift</text></switch></g></g><switch><g requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"></g><a transform="translate(0,-5)" xlink:href="https://www.diagrams.net/doc/faq/svg-export-text-problems" target="_blank"><text text-anchor="middle" font-size="10px" x="50%" y="100%">Text is not SVG - cannot display</text></a></switch></svg>

[skhd](https://github.com/koekeishiya/skhd) is the hotkey daemon I use. It has
a simple configuration file, supports hot reloading, and is even more snappy
than my [xbindkey](https://wiki.archlinux.org/title/Xbindkeys) mappings on
Linux. `skhd` can be [installed via brew and run as a
service](https://github.com/koekeishiya/skhd#install). Once installed, a
configuration file can be placed at `~/.config/skhd/skhdrc`. My configuration
contains:

```shell
# syntax: ${KEY MAPPING} : ${COMMAND}

# home row bindings
shift + cmd - j : open -a /Applications/Alacritty.app
shift + cmd - k : open -a /Applications/Visual\ Studio\ Code.app
shift + cmd - l : open -a /Applications/Brave\ Browser.app
shift + cmd - ; : open -a /Applications/Miro.app

# other bindings
shift + cmd - c : open -a /Applications/Fantastical.app
shift + cmd - n : open -a /Applications/Notion.app
shift + cmd - z : open -a /Applications/Zoom.app
shift + cmd - 1 : osascript /Users/josh/window-resize
```

The configuration syntax is fairly straight forward. I map bindings to `open`,
which is tool that _"... opens a file (or a directory or URL), just as if you
had double-clicked the file's icon."_. `open` will launch the application if
it's not already running or select the application if it is. I also use
`osascript`, which _"... executes the given OSA script, which may be plain text
or a compiled script (.scpt) ..."_. This enables calling uncompiled
[AppleScript](https://en.wikipedia.org/wiki/AppleScript). I use AppleScript
when I need to manage OS-level elements like windows. The script reference here
takes the currently selected application and sets its resolution to
`1920x1080`.

## OS-level changes

With the hotkeys setup, there are a few changes I make to help my brain focus.

* **Window snapping**: To snap windows around and manage their size, I use
  [rectangle](https://github.com/rxhanson/Rectangle).
* **Dim inactive windows**: I use [HazeOver](https://hazeover.com/) to dim
  windows I'm not actively working in. Since my workflow is largely keyboard
  based, this helps my brain register that hitting a hotkey has actually
  switched applications.
* **Remove workspace-sliding animation**: When using fullscreen, the sliding animation feels slow
  and distracting. You can disable this slide when switching between fullscreen
  apps by [Reducing Motion in the accessibility
  settings](https://support.apple.com/en-bn/guide/mac-help/mchlc03f57a1/mac).
* **Hide menu bar**: Instead of dealing with workspaces and setting them up
  with fullscreen apps, I typically just keep my apps in windowed mode and have
  them fill the screen. To maximize real estate, [I always hide the menu
  bar](https://www.macworld.com/article/233520/how-to-turn-onoff-automatic-hiding-menu-bar-macos-big-sur-11.html).

## Desires

Largely this configuration feels just like my native-Linux desktop and I can't
tell the difference in my day-to-day work. However, if I were to nitpick, there
are a few things I'd change.

1. Ability to remove window decorations from apps. I find them ugly and
   unnecessary on macOS.
1. Ability to drag windows from anywhere using a key combination. There are some
   apps that do this, but I don't want to run a daemon for this one piece of
   functionality. There are also ways to enable it using the `defaults write`
   command, but I've found its support to break between operating systems.
1. Disable all animations. This is my biggest gripe with macOS. While you can
   mitigate things (e.g. reduce motion), I'd prefer a snappier, less-animated,
   effect to my actions. This spans window minimizing to making an app
   fullscreen.
