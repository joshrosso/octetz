---
title: "The Go Programming Language"
date: 2022-11-16T10:41:11-07:00
draft: false
meta:
  theme: reference
  series: Go
---

# The Go Programming Language failed at <isset>: wrong numb

The Go programming language is a compiled,
[statically-typed](https://en.wikipedia.org/wiki/Type_system#Static_type_checking),
language. It achieves memory management (garbage collection) while compiling
programs to a [statically-linked
binary](https://en.wikipedia.org/wiki/Static_build) that don't require a
separate runtime to execute. Here I will cover a **small** subset the language's
characteristics, which programmers coming from other languages may find helpful
in understanding "why go".

For an exhaustive overview of Go's history, I recommend reading [the
FAQ](https://go.dev/doc/faq).

## History

Go was introduced in 2007 and aiming at a sweet spot in the current language
landscape where may wish to benefit from the productivity fostered in modern
languages while still offering a general purpose language that could be as
viable for systems-level programming and business logic.

In my eyes the inflection point for Go, like many languages was when it got a
use-case that saw large adoption. This tends to be the catalyst for building an
ecosystem around a project and thus a language. For Go, this was likely
[Docker](https://en.wikipedia.org/wiki/Docker_(software))[^1]. Then this
expanded over time as containers gained larger adoption and folks needed a way
to orchestrate them. Thus, queue in
[Kubernetes](https://en.wikipedia.org/wiki/Kubernetes) and its massive
surrounding ecosystem.

[^1]: I don't mean to claim Go would not have been successful without Docker.
  However, there's no doubt in my mind that this use-case significantly grew the
  Go ecosystem.

## Consistency and brevity

In my mind, this is Go's most compelling characteristic. I shy away from using
"simplicity" as it's hard to quantify and largely an opinion. In languages like
Java, applications are often quite verbose. The benefit is this feels very
explicit, where the downside is there is a lot to read thus inducing cognitive
overhead. Then we can examine languages like Javascript or Ruby. These languages
are framework heavy and as such, code bases can look (and read) drastically
different depending on the framework chosen by the author.

Throughout your usage of Go, hopefully you'll see these consistency and brevity
characteristics surface, but for now, here are a few supporting examples.

1. Go has [25 keywords (reserved identifiers)](https://go.dev/ref/spec#Keywords). 
 
   Compared to other languages:
      1. C++: 95 keywords
      1. Java: 67 keywords
      1. Javascript: 49 keywords

1. Formatting is determined.

    Go code uses tabs, has rules around breaks, and spacing. Ends many bike-shedding
    debates around stylization while invoking a level of consistency in the code
    base. Formatting conventions are built into the go tool, `go fmt`, which is
    used by popular IDEs to format code on save.[^2]

    [^2]: Some feel this doesn't go far enough and I agree. The biggest missing
      piece is standardization on line length, which the Rust project has
      [standardized into their
      conventions](https://rustc-dev-guide.rust-lang.org/conventions.html#:~:text=Lines%20should%20be%20at%20most,can%20keep%20things%20to%2080.).

1. There is one style of loop, `for`:

    ```go
    // conventional index-based
    for (i := 0; i < 5; i++) {
      // prints 1 2 3 4 5
      fmt.Printf("%d ", i)
    }

    // for-each over an array
    for index, value := range myArray {
      // do something
    }

    // infinite until break
    for {
      // do something
      if shouldEnd {
        break
      }
    }
    ```

    Thus there is no `while`, `do-while`, etc.

1. Functions and variables are public (exported) simply by using a capital
   letter in their name.

    ```go
    // GetData is exported (public) and 
    // available outside its package
    func GetData() []byte {
      // retrieves data
    }

    // getData is not exported (private) 
    // and cannot be called outside its package
    func getData() []byte {
      // retrieves data
    }
    ```

1. Types implement interfaces implicitly.

    There is no need to declare what a type (struct) implements. If it has the
    methods with the correct arguments and return values of an interface, it is
    considered to be an implementation of that interface.

    ```go
    type Runner interface {
      Run(config []byte) bool
    }

    // Due to the method defined below,
    // Service implements Runner. 
    type Service struct {
    }

    func (s *Service) Run(config []byte) bool {
      // do something
    }
    ```

While not always true, Go strives to have one way to do a thing. The primary
benefit of all this is readability, and sometimes with a trade-off of
convenience. So far in my programming career, Go has enabled me to dig into
different code-bases with the least amount of overhead and adjusting to
frameworks, stylization and more. This is been a huge part of developer
productivity.

## Performance

## Concurrency

## Binary artifacts

By default, Go produces statically-linked binaries. Meaning it does **not** rely
on shared-objects or other libraries on a host that it would "link" in to get
functionality. For example, non-statically compiled programs can experience
different behavior based on the [libc
variant](https://en.wikipedia.org/wiki/C_standard_library) running on the host.
Two common variants are glibc and musl, which [musl has a good comparison page
available](https://wiki.musl-libc.org/functional-differences-from-glibc.html)
describing differences such as how name resolvers work when doing DNS lookups.
Along with consistency on hosts, this also makes cross compilation simpler as we
don't need to rely on which library is available on BSD, Linux, Windows, [and
more](https://github.com/golang/go/blob/master/src/go/build/syslist.go). From a
programmer's perspective, you simply need to specify the OS and Architecture:

```sh
GOOS=windows GOARCH=arm64 go build main.go
```

This would produce a MS Windows binary for the ARM64 architecture, which
[file](https://en.wikipedia.org/wiki/File_(command)) can verify:

```sh
file main.exe
main.exe: PE32+ executable (console) Aarch64 (stripped to external PDB), for MS Windows
```

The downside (albeit for many trivial) is that the entire Go runtime along with
information to support the runtime is packaged in every binary. [A comparison in
the FAQ is](https://go.dev/doc/faq#Why_is_my_trivial_program_such_a_large_binary):

> A simple C "hello, world" program compiled and linked statically using gcc on Linux is around 750 kB, including an implementation of printf. An equivalent Go program using fmt.Printf weighs a couple of megabytes, but that includes more powerful run-time support and type and debugging information.

On the flip-side, compare this model to Java and the JVM where there is a
independent runtime where apps need to be run atop of, often necessitating a
dedicated application server. Aside from some specified use-cases like embedded
software on very-limited hardware, this makes Go a valid option.

## Is Go right for you?

I have no idea.

The most concrete summary I can give is that for many applications you may write I
believe Go achieves an excellent balance in versatility, productivity, and
performance. 

My opinionated take is that, I'd love to see the spectrum of business logic
(traditionally Java) down to lower-level constructs like container runtimes to
be written in Go. This would then blend into Rust, which would also be excellent
for system services like container runtimes but also can go deeper with kernels
and services for embedded systems. Then, we'd just see how this whole Web
Assembly (WASM) thing plays out to see if it can ever replace aspects of
Javascript in the stack. A simplistic pancake-view of the stack may look as
follows:

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="100%" viewBox="-0.5 -0.5 981 421" content="<mxfile host=&quot;app.diagrams.net&quot; modified=&quot;2022-11-27T15:44:42.880Z&quot; agent=&quot;5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36&quot; version=&quot;20.6.0&quot; etag=&quot;lqQKttx50TiRIiyngN8G&quot; type=&quot;device&quot;><diagram id=&quot;i3L_Wq0f4fInR3AETcPD&quot;>1ZdRk5sgEMc/jY+dURElj216d53O3EvzcM8Ia2RCxEESk376kgSTeJi5Tstl7p6E/+4i/FhYjdB8vXvStK2fFQcZpTHfReh7lKYJwpl9HJT9SSFFcRKWWnDndBEW4jc4MXbqRnDoRo5GKWlEOxaZahpgZqRRrVU/dquUHL+1pUvwhAWj0ldfBDe1WwWOL/oPEMt6eHMSO8uaDs5O6GrKVX8loYcIzbVS5tRa7+YgD/AGLqe4xxvW88Q0NOZvAtJTwJbKjVubm5fZD4vVatNwOPjHEfrW18LAoqXsYO3t9lqtNmtpe4ltVkLKuZJKH2NRVVUpY1bvjFYruLLwvMxxbi1uAqAN7G4uIjmjsTkFag1G762LC5g5mC6bzv3+sjcz4rT6al+yYReoy4fleegLMttw1KYJIo9gpZWddxpDw/8Tph1n4WKTAJyyGI9AocIHhfAEKByAU+ZxKilbHRnFHeitYPZEf2hcWXZHXNjDVavOfJGwPd6ln4MYTu5ILPeIrUA3R1qHMWy10cKu7qMjI3dEVnjInlTQ+59TINXk/Z8zAmX1DkCL/O1TS7DPMwlRDIgH9NemM4FLKuQ3SmoxK+M4TElF6bimTp3k4r0ozjyKP+mWdkyLNjBLwmCaZUlwhgOxfJ2RU2V3KiNDnPBh265YvnxdPIc95BgIz6YokrREeaCPvNcZOUVxKiP/gaLtXr7Aj7ar/xj08Ac=</diagram></mxfile>"><defs></defs><g><rect x="0" y="0" width="980" height="420" fill="#fff2cc" stroke="#d6b656" pointer-events="all"></rect><rect x="315" y="80" width="350" height="50" fill="rgb(255, 255, 255)" stroke="rgb(0, 0, 0)" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 348px; height: 1px; padding-top: 105px; margin-left: 316px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; font-weight: bold; white-space: normal; overflow-wrap: normal;">front end</div></div></div></foreignObject><text x="490" y="109" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle" font-weight="bold">front end</text></switch></g><rect x="315" y="150" width="350" height="50" fill="rgb(255, 255, 255)" stroke="rgb(0, 0, 0)" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 348px; height: 1px; padding-top: 175px; margin-left: 316px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; font-weight: bold; white-space: normal; overflow-wrap: normal;">backend services</div></div></div></foreignObject><text x="490" y="179" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle" font-weight="bold">backend services</text></switch></g><rect x="315" y="220" width="350" height="50" fill="rgb(255, 255, 255)" stroke="rgb(0, 0, 0)" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 348px; height: 1px; padding-top: 245px; margin-left: 316px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; font-weight: bold; white-space: normal; overflow-wrap: normal;">host-level services</div></div></div></foreignObject><text x="490" y="249" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle" font-weight="bold">host-level services</text></switch></g><rect x="315" y="290" width="350" height="50" fill="rgb(255, 255, 255)" stroke="rgb(0, 0, 0)" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 348px; height: 1px; padding-top: 315px; margin-left: 316px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; font-weight: bold; white-space: normal; overflow-wrap: normal;">kernel / drivers</div></div></div></foreignObject><text x="490" y="319" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle" font-weight="bold">kernel / drivers</text></switch></g><rect x="675" y="150" width="85" height="120" fill="#dae8fc" stroke="#6c8ebf" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 83px; height: 1px; padding-top: 210px; margin-left: 676px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; font-weight: bold; white-space: normal; overflow-wrap: normal;">Go</div></div></div></foreignObject><text x="718" y="214" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle" font-weight="bold">Go</text></switch></g><rect x="230" y="220" width="75" height="120" fill="#ffe6cc" stroke="#d79b00" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 73px; height: 1px; padding-top: 280px; margin-left: 231px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">Rust</div></div></div></foreignObject><text x="268" y="284" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">Rust</text></switch></g><rect x="675" y="80" width="85" height="50" fill="#f8cecc" stroke="#b85450" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 83px; height: 1px; padding-top: 105px; margin-left: 676px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">Javascript</div></div></div></foreignObject><text x="718" y="109" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">Javascript</text></switch></g><rect x="230" y="80" width="75" height="50" fill="#d5e8d4" stroke="#82b366" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 73px; height: 1px; padding-top: 105px; margin-left: 231px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">WASM</div></div></div></foreignObject><text x="268" y="109" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">WASM</text></switch></g></g><switch><g requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"></g><a transform="translate(0,-5)" xlink:href="https://www.diagrams.net/doc/faq/svg-export-text-problems" target="_blank"><text text-anchor="middle" font-size="10px" x="50%" y="100%">Text is not SVG - cannot display</text></a></switch></svg>

However, like anything, you have to see what works for you. And often, the
ecosystem and prior art will make the decision obvious for you. For example,
doing machine learning? Python. Doing game audio processing? C++.

Regardless, I hope you give Go a shot and with whatever time you spend using it,
have fun.
