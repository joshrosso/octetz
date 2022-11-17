---
title: Recording and Repeating Commands in Vim
weight: 9991
description: Learn how to repeat sequences of Vim commands using macros.
date: 2020-01-05
images:
- https://octetz.s3.us-east-2.amazonaws.com/recording-vim-commands-title-card.png
---

# Recording and Repeating Commands in Vim

Have you ever found yourself in an editor, repeating some mundane string
manipulation task line after line? You're barely awake wondering if this is the
pinnacle of your software engineering career. If so, you're not alone. In this
post you'll explore my favorite feature of vim, macros. Macros save substantial
time on these kinds of tasks. It also helps remain efficient when your regex
powers are failing you.

{{< yblink Hd33Q0ZjZuk >}}

## Identify a Pattern

To start off, copy the following HTML into a file.

```
<html>
<head>
<link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
        

  <p>octetz.com by <a href="https://twitter.com/joshrosso">@joshrosso</a></p>
        <ul>
                <li><a href="posts/k8s-controllers-vs-operators">Operators and Controllers, What is the Difference?</a> [ October 13th, 2019 ]</li>
                <li><a href="posts/k8s-static-pods">Kubernetes Static Pods</a> [ October 12th, 2019 ]</li>
                <li><a href="posts/vim-as-go-ide">Vim as a Go (Golang) IDE using LSP and vim-go</a> [ April 24th, 2019 ]</li>
                <li><a href="posts/k8s-network-policy-apis">Kubernetes Network Policy APIs</a> [ April 22nd, 2019 ]</li>
                <li><a href="posts/contour-adv-ing-and-delegation">Contour: Advanced Ingress with Envoy</a> [ April 12th, 2019 ]</li>
                <li><a href="posts/ha-control-plane-k8s-kubeadm">Highly Available Control Plane with kubeadm 1.14+</a> [ March 26th, 2019 ]</li>
                <li><a href="posts/rr-setup">Configuring Route Reflectors in Calico</a> [ December 10th, 2018 ]</li>
                <li><a href="posts/setting-up-psps">Setting Up Pod Security Policies</a> [ December 7th, 2018 ]</li>
                <li><a href="posts/secure-port-k8s-cm-sched">Securing Communication to Controller Manager and Scheduler</a> [ December 5th, 2018 ]</li>
        </ul>
</p>
<p>stay updated: <a href="https://octetz.com/rss/feed.xml">rss</a></p>
<p><i><font color="#cccccc">Feel free to steal content; attribution discouraged.</font></i></p>
</body>
</html>
``` 

This snippet is an older version of this website’s index. Assume you want to
move the dates from the right to the left.

{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/vim-recording-website-image.png"
class="center" >}}

There are many ways to accomplish this. For me, it’s fastest to run a few
commands on each line to delete (and implicitly yank) the date and move it to
the front of each line. The key is to ensure the sequence of commands used **are
repeatable** on every line. Once you master this mindset, the efficiency gains
can be ridiculous!

Breaking down the html and image above, there are a few patterns you can
identify.

1. Each line item starts with `<li>`.
1. Each date starts with `[ `.
    1. The space is included.
1. Each date ends with ` ]`.
    1. The space is included.

## Record Commands

Now you’re ready to record commands using the identified pattern above to move
the dates. In this section, i’ll walk you through each command and its impact.

1. Set your cursor to the beginning of the first list element.
2. Press `q` to start recording {{< img
   src="https://octetz.s3.us-east-2.amazonaws.com/vim-recording-initial-q.png"
   class="center" >}}
1. Press `d` to assign the recording to your d key.  {{< img
   src="https://octetz.s3.us-east-2.amazonaws.com/vim-recording-save-to-d.png"
   class="center" >}}
1. Press a key sequence that moves the date to the front of the line. My
   sequence is as follows.
    1. `|`: go to begging of line
    2. `/[ `: move cursor to start of date
    3. `v`: enter visual selection mod
    4. `/ ]`: select to end of date
    5. `d`: delete (and yank) the date
    6. `|`: go to beginning of line
    7. `/><`: place cursor at end of list element
    8. `p`: paste date after list element
    9. `j`: go to next line
1. Press `q` to end the recording.  {{< img
   src="https://octetz.s3.us-east-2.amazonaws.com/vim-command-sequence.gif"
   class="center" >}}


You've recorded that entire sequence under `d`. Admittedly, 1-9 above are
**not** the most efficient ways to achieve the task at hand. Vim gurus around
the world are likely sick to their stomachs reading this. But the great thing
is, perfection in this sequence doesn't matter. It is recorded and repeatable!

## Replay Commands

With your sequence recorded in `d`, it's time to recall it across multiple
lines.

1. Move your cursor to the next line you'd like to manipulate.
    1. Note that you started your recording with `|`, so not matter where in the
       line your cursor is, recalling the recording will still work!
1. Recall the command with `@d`.
1. After recalling `@d`, you can instead hit `@@` to recall the last recalled
   recording.
1. Continue this until all the lines are modified.  {{< img
   src="https://octetz.s3.us-east-2.amazonaws.com/recording-vim-recall.gif"
   class="center" >}}

Just like that, you've run a repeatable, mundane, task across 9 lines of this
file! You can imagine how helpful this can be if there were thousands of lines.
Speaking of that, there is one more trick you can use to speed up the process
even more.

1. Undo all the date modifications done to this file.
1. Move your cursor to the first list element.
1. Press `9@d` and hit enter (full recording follows).
   {{< img
   src="https://octetz.s3.us-east-2.amazonaws.com/vim-recording-full.gif"
   class="center" >}}

Pretty rad, eh ;) ?

## Summary

I hope you've enjoyed using macros as much as I do. With a little practice, they
can save you a ton of time and perhaps a bit of your sanity.
