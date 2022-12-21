---
title: "Variables"
date: 2022-11-16T10:41:11-07:00
draft: false
meta:
  theme: reference
  series: Go
---

# Variables

Variables can be assigned values for types such as
[primitives](https://en.wikipedia.org/wiki/Primitive_data_type),
[composites](https://en.wikipedia.org/wiki/Composite_data_type), and
[pointers](https://en.wikipedia.org/wiki/Pointer_(computer_programming)).

## Creating Variables

Variables may be **declared**, **initialized**, or **assigned** in one
statement. Consider these methods for creating variables where the value is a
string.

```go
// initialization
var dog string
// assignment
dog = "woof"

// initialization and assigment
var cat = "meow"

// shorthand
cow := "moo"
```

[Go playground example](https://go.dev/play/p/o2YhdJdbtqZ)

Each style of variable creation is effectively doing the same thing. However, Go
supports implying things such as the type and even the `var` keyword:

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="100%" viewBox="-0.5 -0.5 777 362" content="<mxfile host=&quot;app.diagrams.net&quot; modified=&quot;2022-11-24T16:08:18.820Z&quot; agent=&quot;5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36&quot; version=&quot;20.6.0&quot; etag=&quot;simw4FXKi_zZouTY_qtc&quot; type=&quot;device&quot;><diagram id=&quot;rg2y1ckoOcp6EOL9t3j-&quot;>5ZjLctsgFIafRntJ6IKXsZu2i3amM1l0jcTRpcE6Kkax3acvipBlCeUyE9vJOCvDz0HAB/yAHbJa775JVhc/kYNwfJfvHPLF8X3Po6H+aZV9p8QR7YRcltwEDcJd+Q+M6Bq1KTlsRoEKUaiyHospVhWkaqQxKXE7DstQjFutWQ6WcJcyYau/S66KTqWhO+jfocyLvmXPNSVr1gcbYVMwjtsjidw6ZCURVZda71YgWng9l67e1ydKDx2TUKnXVPC7Cg9MNGZspl9q3w9WYlNxaONdhyy3RangrmZpW7rV06u1Qq2Fznk6mZVCrFCgfKxLsizz01TrGyXxHo5KeJREYaRLTAdAKtg9OQjvgEavKcA1KLnXIaaCHxmaZjkd6G6HyYljs+aKo4khfUVmFkR++PbATCcMtnmExEL4wOTbKDJR5pVOpxoASBsrZ0CzWaxRSiHJToOV0AlWamP1iGtjDU5ANbCocszPSzWjKcwv1oSGQeiehmpI3pFqaFHVYy2rM4PlIVAezIGlfkKiE7lA9J7LNfosJkAuSTX+LCZwUarUPvPNyX82quBpD4jnqC6imLAzOcBFqS4sgsD1pdFkUaoCc6yYuB3U5ZjxEPMDsTZk/4BSe3MDZo3CMfeuzbahEbINNjKd3JkVkzmo0THwCrISBFPlw/jzc5geq95IyfZHATWWldocfflXKwwTRhfheMLCyW11Eh8Hz8brRNeDYcIOQ3nVHPasRtfh6G/T3saXW8RsyJ13v6QcEprM7RcSkQXhp9kv9D1dyPOu1dynR2awuCRW+wH3QXyI2D4UfRAfCic+FLzgQ0HwbPzbfch+Uzrk5kpO6end57Lbw35XXrPDT29El2VtvzbLdS1KjfBNaAVLQCxZep8/VuvRcchYI9QhACUH2RdWWLVGl2GljIl58YkOUX9yiJIZxP4MYnIKxPa78woRhxPEQXA+xDo7/PvaWffwHza5/Q8=</diagram></mxfile>"><defs></defs><g><rect x="0" y="0" width="775" height="360" fill="#fff2cc" stroke="#d6b656" pointer-events="all"></rect><rect x="120" y="60" width="130" height="40" fill="#dae8fc" stroke="#6c8ebf" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 80px; margin-left: 121px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">var</div></div></div></foreignObject><text x="185" y="84" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">var</text></switch></g><rect x="270" y="60" width="130" height="40" fill="#f8cecc" stroke="#b85450" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 80px; margin-left: 271px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">dog</div></div></div></foreignObject><text x="335" y="84" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">dog</text></switch></g><rect x="420" y="60" width="130" height="40" fill="#d5e8d4" stroke="#82b366" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 80px; margin-left: 421px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">string</div></div></div></foreignObject><text x="485" y="84" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">string</text></switch></g><rect x="120" y="160" width="130" height="40" fill="#dae8fc" stroke="#6c8ebf" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 180px; margin-left: 121px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">var</div></div></div></foreignObject><text x="185" y="184" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">var</text></switch></g><rect x="270" y="160" width="130" height="40" fill="#f8cecc" stroke="#b85450" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 180px; margin-left: 271px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">dog</div></div></div></foreignObject><text x="335" y="184" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">dog</text></switch></g><rect x="420" y="160" width="130" height="40" fill="#e1d5e7" stroke="#9673a6" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 180px; margin-left: 421px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">=</div></div></div></foreignObject><text x="485" y="184" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">=</text></switch></g><path d="M 635 160 L 635 130 L 485 130 L 485 106.37" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 485 101.12 L 488.5 108.12 L 485 106.37 L 481.5 108.12 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><rect x="570" y="160" width="130" height="40" fill="#cdeb8b" stroke="#36393d" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 180px; margin-left: 571px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">"woof"</div></div></div></foreignObject><text x="635" y="184" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">"woof"</text></switch></g><rect x="120" y="270" width="130" height="40" fill="#f8cecc" stroke="#b85450" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 290px; margin-left: 121px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">dog</div></div></div></foreignObject><text x="185" y="294" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">dog</text></switch></g><path d="M 335 270 L 335 230 L 185 230 L 185 206.37" fill="none" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 185 201.12 L 188.5 208.12 L 185 206.37 L 181.5 208.12 Z" fill="rgb(0, 0, 0)" stroke="rgb(0, 0, 0)" stroke-miterlimit="10" pointer-events="all"></path><rect x="270" y="270" width="130" height="40" fill="#e1d5e7" stroke="#9673a6" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 290px; margin-left: 271px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">:=</div></div></div></foreignObject><text x="335" y="294" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">:=</text></switch></g><rect x="420" y="270" width="130" height="40" fill="#cdeb8b" stroke="#36393d" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 128px; height: 1px; padding-top: 290px; margin-left: 421px;"><div data-drawio-colors="color: rgb(0, 0, 0); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 12px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; white-space: normal; overflow-wrap: normal;">"woof"</div></div></div></foreignObject><text x="485" y="294" fill="rgb(0, 0, 0)" font-family="jbm" font-size="12px" text-anchor="middle">"woof"</text></switch></g><rect x="560" y="110" width="120" height="30" fill="rgb(255, 255, 255)" stroke="rgb(0, 0, 0)" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 118px; height: 1px; padding-top: 125px; margin-left: 561px;"><div data-drawio-colors="color: rgb(0, 0, 0); background-color: rgb(255, 255, 255); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 17px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; background-color: rgb(255, 255, 255); white-space: normal; overflow-wrap: normal;">implied</div></div></div></foreignObject><text x="620" y="130" fill="rgb(0, 0, 0)" font-family="jbm" font-size="17px" text-anchor="middle">implied</text></switch></g><rect x="260" y="220" width="120" height="30" fill="rgb(255, 255, 255)" stroke="rgb(0, 0, 0)" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility" style="overflow: visible; text-align: left;"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe center; justify-content: unsafe center; width: 118px; height: 1px; padding-top: 235px; margin-left: 261px;"><div data-drawio-colors="color: rgb(0, 0, 0); background-color: rgb(255, 255, 255); " style="display: flex; box-sizing: border=box font-size: 0px; text-align: center;"><div style="display: inline-block; font-size: 17px; font-family: jbm; color: rgb(0, 0, 0); line-height: 1.2; pointer-events: all; background-color: rgb(255, 255, 255); white-space: normal; overflow-wrap: normal;">implied</div></div></div></foreignObject><text x="320" y="240" fill="rgb(0, 0, 0)" font-family="jbm" font-size="17px" text-anchor="middle">implied</text></switch></g></g><switch><g requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"></g><a transform="translate(0,-5)" xlink:href="https://www.diagrams.net/doc/faq/svg-export-text-problems" target="_blank"><text text-anchor="middle" font-size="10px" x="50%" y="100%">Text is not SVG - cannot display</text></a></switch></svg>

The shorthand `<var-name> := <value>` is the most common way to introduce a
variable. This includes when setting **new** variables to the return value(s) of
a function.

```go
func main() {
	hi, bye := HelloGoodbye()
	fmt.Println(hi + " then " + bye)
}

func HelloGoodbye() (string, string) {
	return "hello", "goodbye"
}
```

[Go Playground Example](https://go.dev/play/p/pcimSfp45GX)

More on functions in a different section, but at a high-level, HelloGoodbye() is
returning 2 strings, which are being assigned to the new variables `hi` and
`bye`.

While `:=` is most common for creating variables, there are times where using
the verbose `var <var-name> <type>` syntax is justified. For example, consider a
function where the assignment of the value happens in a conditional:

```go
func main() {
	fmt.Println("dog")
}

func GetSound(animal string) string {
	var sound string
	if animal == "dog" {
		sound = "woof"
	}
	if animal == "cat" {
		sound = "meow"
	}
	return sound
}
```

[Go playground example](https://go.dev/play/p/2gABZTNpm28)

Here, the variable is declared ahead of time with the intent to assign it a
proper value based on the argument `animal`. But what if `dog` or `cat` is not
passed as the argument to `GetSound`? To answer this, see the [Zero
values](#zero-values) section below.

## Zero values

When a new variable is created, the type's zero value is automatically set. This
applies to all non-pointer values. Below is an example of a few Go primitive
types and their zero values:

| type | zero value |
|---|---|
| int | 0 |
| string | "" (empty string) |
| bool | false |

Thus, the following variable declarations result in their corresponding values:

```go
var dog string
var isBlue bool
var age int

fmt.Printf("dogVal: \"%s\" | isBlueVal: %t | ageVal: %d", dog, isBlue, age)
```

The resulting output would be:

```txt
dogVal: "" | isBlueVal: false | ageVal: 0
```

[Go playground example](https://go.dev/play/p/_21p_5Wfrc1)

This idea extends to composite types, or structs (covered in a different
section) since these types are made up of primitives. Consider a struct that
contains all the variables above.

```go
type animal struct {
	dog    string
	isBlue bool
	age    int
}

func main() {
	var a animal
	fmt.Printf("%+v", a)
}
```

The output of this would be:

```txt
{dog: isBlue:false age:0}
```

[Go playground example](https://go.dev/play/p/sOC0SSNHh8z)

A common way to initialize structs and data structures with non-default values
is to define values within a `{ }` block. The animal example can be expanded to
be:

```go
type animal struct {
	dog    string
	isBlue bool
	age    int
}

func main() {
	a := animal{
		dog:    "henry",
		isBlue: true,
		age:    3,
	}
	fmt.Printf("%+v", a)
}
```

This would create the output:

```txt
{dog:henry isBlue:true age:3}
```

Slices ([dynamic arrays](https://en.wikipedia.org/wiki/Dynamic_array)) and maps
(covered in a different section) can use the same model:

```go
// a slice (list) of names
names := []string{"henry", "stelly", "paws"}
fmt.Printf("%+v\n", names)

// a map with the name as key and age (int) as value
cats := map[string]int{"henry": 3, "stelly": 22, "paws": 8}
fmt.Printf("%+v", cats)
```

This would output:

```txt
[henry stelly paws]
map[henry:3 paws:8 stelly:22]
```

[Go playground example](https://go.dev/play/p/KigWaThffza)

## Pointer values

Variables may also contain pointers. These do not go through the same zero-value
mechanics as values do. Pointers are covered in a different section, but an
example will be demonstrated here for those familiar with the concept.

Variables containing a pointer will initialize to [nil] when no memory address is
otherwise provided. 

```go
// aPointer holder a pointer to a string values
// until it is assigned, its value is nil.
var aPointer *string
```

Similar to other languages, the `&` symbol is used to
represent the address of a value. Thus, assigning a pointer-value using the
shorthand syntax can be easily done by:

```go
a := &animal{
  dog:    "henry",
  isBlue: true,
  age:    1,
}
fmt.Printf("%+v", a)
```

The output will now denote `&{<values>}` representing we printed a variable
containing a pointer, since `a`'s value is a pointer to animal, rather than a
value of animal.

```txt
&{dog:henry isBlue:true age:1}
```

[Go playground example](https://go.dev/play/p/KywG-XJiXVy)

## Globals and Constants

Packages may contain global variables and constants. Variables are able to
changed throughout the execution of the program, while constants are set and
never changed.

```go
const (
	defaultUrl     = "https://some-service.io"
	defaultTimeout = 20
)

var (
	user string
	pass string
)

func main() {
	user = "john"
	pass = "doe"

	login()
}

func login() {
	connString := fmt.Sprintf("%s:%s@%s", user, pass, defaultUrl)
	fmt.Printf("logging in to: %s", connString)
}
```

[Go playground example](https://go.dev/play/p/l-SCo6tAgBU)

As you can see, the `login` and `main` functions can access the global variables and
constants without the need to pass them around. The constant examples show a
common pattern where defaults are set since they should be referenced in many
places and will not change over time.

To make these variables accessible outside of the package, you can capitalize
the first letter in the name, thus and adjustment like:

```go
package db

const DefaultUrl = "https://some-service.io"
```

Would mean importers of this package could access the value with the statement:

```go
db.DefaultUrl
```

Global variables (non constant), like the `user` and `pass` above are generally
considered bad practice if you're working on a code based with even a minor
amount of complexity. The problem is global variables can mutate anywhere in the
package, which can easily produce unexpected and hard to debug errors.

