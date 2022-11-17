---
title: Local JDK Docs in an IDE
weight: 9990
date: 2019-11-29
aliases:
  - /posts/loading-local-jdk-docs
  - /posts/loading-local-jdk-docs.html
---

# Loading Local JDK Docs in an IDE

Over the US's Thanksgiving break, I started playing around with "modern" Java.
Around 5 years ago it was my primary language for all development (I worked in
middle ware). Since then, I've pretty much only written Go. After setting up
Intellij as my Java IDE, I quickly ran into a problem.  I could not figure out
where download the JDK JavaDocs. I wanted this as I use the docs quite a bit to
traverse through various classes and functions. Instead, when I hit the
"external docs" shortcut, nothing happened. This post covers how to find the JDK
JavaDocs and set it up in Intellij.  While these examples focus on Intellij, you
may find this information useful for your own IDE.

{{< yblink FfnTR9Gv9Gc >}}

## Set Remote Documentation URL

First, I should acknowledge it is easy to point Intellij at the JDK JavaDocs
remotely. The URL Oracle uses consistent URL pathing. For example, to get the
Java 13 docs, you can visit
[https://docs.oracle.com/en/java/javase/13/docs/api](https://docs.oracle.com/en/java/javase/13/docs/api).
To load this into Intellij, you open `File > Project Structure`. From there you
select your SDK and add a remote documentation path, as shown below.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/intellij-java.png"
>}}

You'll then get an input box where you can put an API URL like the one above and
done! However, I am not a fan of remote documentation. I fly on planes and have
spotty connection all the time.  I want to quickly load the documentation
locally. 

## Downloading JDK JavaDocs

Given this download exists on Oracle's website, you can bet it'll be a pain. If
not egregious to find, they'll probably make you sell your first born and
register with their marketing department before you can even _think_ about
viewing the docs. *Sigh*. However, here is how you can fast track it. As far as
I can tell, Oracle only keeps LTS and current Java version docs linked on their
site.  I did find some StackOverflow posts with links to things like Java
12...but you may just want to choose the closest version. 

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/java-version-table.png"
>}}

In my case, I'm using Java 13. So I headed to the Java SE Development Kit
Downloads page at
[https://www.oracle.com/technetwork/java/javase/downloads/jdk13-downloads-5672538.html](https://www.oracle.com/technetwork/java/javase/downloads/jdk13-downloads-5672538.html). 

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/downloads.png"
>}}

Looking at the page, you'll notice a Documentation tab. But that would be too
easy. You won't find downloadable documentation there. Instead you'll find a
bunch of random things including but not limited to binary code licensing
information..._rolls eyes_.

**Ignore that page** and head to the "main" download page, which you can find at
[https://www.oracle.com/technetwork/java/javase/downloads/index.html](https://www.oracle.com/technetwork/java/javase/downloads/index.html).
From this page, if you scroll to the bottom, you'll see an **Additional
Resources** section.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/javadocs.png"
>}}

Click the download button for your version of Java. Of course, you're going to
have to accept a license agreement (goodbye first born), but then you should get
a zip of all the JavaDocs.

## Adding Documentation to Intellij

First, you'll want to find a good location to store the docs. I unzipped them in
my `$JAVA_HOME`, located at `/usr/lib/jvm/java-13-jdk`. Unzipping places files
in a `docs` directory, which is perfect for me.

```
unzip ~/Downloads/jdk-13.0.1_doc-all.zip -d /usr/lib/jvm/java-13-jdk
```

```
ls -l /usr/lib/jvm/java-13-jdk
```

```
4096 Nov 29 20:34 .
4096 Nov 29 17:57 ..
4096 Nov 29 17:59 bin
  26 Nov 29 17:56 conf -> ../../../../etc/java13-jre
4096 Oct  6 05:36 docs
4096 Nov 29 17:59 include
4096 Nov 29 17:59 jmods
  27 Nov 29 17:56 legal -> ../../../share/licenses/jre
4096 Nov 29 17:59 lib
1235 Nov 29 17:56 release
```

In Intellij, return to `File > Project Structure > SDKs > Documentation Paths`
and click the plus sign. You can then select the location of your new `docs`
folder as seen below.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/intellij-java-local.png"
>}}

Now, if you use something in the standard library, you should be able to call
for external documentation.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/external-docs.png"
>}}

Upon selecting this option, a browser window will open pointed to the JavaDocs
on your local machine.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/local-javadoc-browser.png"
>}}

## Downloading JavaDocs for Dependencies

One last thing I'll leave you with. If you're using Maven, it is really easy to
generate the JavaDocs for your dependencies/libraries so you can rely on the
same external documentation abilities. For example, I'm using the Spring
Framework in my current project. To download the documentation, open the maven
panel from the right side-bar. From there, click the download button and choose
to download documentation. There is also an option to download documentation and
sources, which I recommend as it'll prevent you from needing to decompile
bytecode in order to goto code in the libraries you are calling.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/maven-panel.png"
>}}

With this complete, you can now select code or annotations from a library you're
calling and produce the relevant JavaDoc. As seen below.

{{< img class="center"
src="https://octetz.s3.us-east-2.amazonaws.com/loading-local-jdk-docs/spring-javadoc.png"
width="800" >}}

I hope you found this post useful! Or at least educational as to how hard
setting up something as simple as local JDK docs can be. Good luck with your
Java adventures!
