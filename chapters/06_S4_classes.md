# S4 classes

The S3 class system is the wild west of object-oriented programming. Class hierarchies only exist implicitly through the `class` attributes, generic methods can be implemented or not by any class whatsoever, with no check that interfaces and class hierarchy designs are implemented correctly. Everything depends on conventions and it is entirely up to the programmer to ensure any resemblance of consistency.

The S3 system is popular because it is very easy to use and to write new classes. In most cases, we would prefer simplicity over elaborate design, and in those cases, S3 is perfect for our needs. When we implement a new statistical model, we rarely need a complex class hierarchy. Most abstract data structures have only a few associated operations, and we have no problem remembering to implement them all when we write concrete versions of them. Once software reaches a certain level of complexity, however, more structure is needed. Rather than having the design exist only implicitly in programming conventions we want it explicitly stated in the code.

The S4 system provides a more structured object-oriented system. Here classes and class hierarchies are explicitly created; they are not merely strings in a `class` attribute. To obtain the added structure that S4 gives a little more code is needed when creating classes and methods, but overall the system works very similar to S3 so if you are comfortable with S3 then learning S4 should not pose a problem.

## Defining S4 classes

In S4, classes are explicitly created. To create a new class, we use the function `setClass` from the `methods` package. This function takes arguments that specify which attributes objects of the class should hold, what default values the attributes should have, how the class fits into a class hierarchy, and many other properties of the created class. All these properties have default values so we can create a new class just by specifying its name.

As an example, we consider the stack data structure we implemented in S3 earlier. To make an abstract stack class we can write:

```{r}
library(methods)
Stack <- setClass("Stack")
```

This creates a new class called `"Stack"`. We have not specified any attributes of the class, so S4 will assume that it is an abstract class that is not supposed to be instantiated and we will get an error if we try.

We can create the vector-based stack class like this:

```{r}
VectorStack <- setClass("VectorStack",
                        slots = c(
                          elements = "vector"
                        ),
                        contains = "Stack")
```

Here we use two arguments to `setClass`: `slots` and `contains`. The `slots` argument is a list of attributes that objects of the class should have. Here specify that it should contain a vector called `elements`. The `contains` argument specifies which superclasses the new class should have. We make `VectorStack` a subclass of `Stack`.

Since `VectorStack` has slots, it is not considered an abstract class (we can explicitly make it so by adding `"VIRTUAL"` to the `contains` argument, but we do want to be able to instantiate it). We can create objects of the class by calling `VectorStack'

```{r}
(vs <- VectorStack())
```

and we can specify the `elements` as a named argument to `VectorStack`

```{r}
(vs <- VectorStack(elements = 1:4))
```

Positional arguments will not work here; it has to be a named argument.

Once we have an object of class `VectorStack` we can access the elements with the notation

```{r}
vs@elements
```

In general, `@` is used to access slots of S4 objects.

Capturing the result of `setClass` and using it as a function to construct objects is my preferred way of creating S4 constructors, but strictly speaking, it isn't necessary. Once a class is built with `setClass` you can create objects just using the name of the class using the function `new`.

```{r}
new("VectorStack", elements = 1:4)
```

## Generic functions

In the S3 system, we create generic functions just as normal functions that call `UseMethod`. In S4 we have to define generic functions explicitly using the `setGeneric` function. The first argument of `setGeneric` is the name of the generic function. If you have an existing function that you want to make generic, calling `setGeneric` with its name will create a generic function with the existing function as the default implementation. Typically, though, we use `setGeneric` to create a brand new generic function, and in that case, we need to provide a definition of the function as well. This we do through the parameter `def`. This function plays the role the function definition in S3 has: it should simply call the function `standardGeneric`, which is S4's analogue to `UseMethod`.

We can define the interface of the stack abstract data structure like this:

```{r, message=FALSE, warning=FALSE, results="hide"}
setGeneric("top", 
           def = function(stack) standardGeneric("top"))
setGeneric("pop", 
           def = function(stack) standardGeneric("pop"))
setGeneric("push", 
           def = function(stack, element) standardGeneric("push"))
setGeneric("is_empty", 
           def = function(stack) standardGeneric("is_empty"))
```

To provide implementations of generic functions we use the function `setMethod`. We need to provide the name of the generic function, the signature of the method (which is the type(s) used for dispatching the method), and the definition of the function.

When a generic function is called, the concrete implementation is chosen based on the type of the arguments to the function. This is what we call dynamic dispatch, and in S3 it is based on a single argument---typically the first---but in S4 we can dispatch based on more complex type information. To get behaviour similar to S3 we just provide a signature that is a class name. This, then, makes S4 choose a given implementation based on the class of the first argument to the generic function.

We can implement the vector stack thus:

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("top", signature = "VectorStack",
          definition = function(stack) stack@elements[1])
setMethod("pop", signature = "VectorStack",
          definition = function(stack) {
            VectorStack(elements = stack@elements[-1])
          })
setMethod("push", signature = "VectorStack",
          definition = function(stack, element) {
            VectorStack(elements = c(element, stack@elements))
          })
setMethod("is_empty", signature = "VectorStack",
          definition = function(stack) length(stack@elements) == 0)
```

The implementations are just variations of the functions we defined in the S3 implementation, and we can use the class just as before.

```{r}
stack <- VectorStack()
stack <- push(stack, 1)
stack <- push(stack, 2)
stack <- push(stack, 3)
stack

while (!is_empty(stack)) {
  stack <- pop(stack)
}
stack
```

### Slot prototypes

When you create an object, and you don't provide values for the slots, you will get default values, which are often empty vectors or empty lists. For example, if we create a class for representing natural numbers we can write the class like this:

```{r, message=FALSE, warning=FALSE, results="hide"}
NaturalNumber <- setClass("NaturalNumber",
                          slots = c(
                            n = "integer"
                          ))
```

and if we instantiate it without arguments the object will contain an empty vector for the natural number it is supposed to represent.

```{r}
(n <- NaturalNumber())
```

If, instead, we want other default values we can use the `prototype` argument to `setClass`. For example, we can state that the default natural number is zero.

```{r, message=FALSE, warning=FALSE, results="hide"}
NaturalNumber <- setClass("NaturalNumber",
                          slots = c(
                            n = "integer"
                          ),
                          prototype = list(
                            n = as.integer(0)
                          ))
```

Now, when we create an object, it will get the default value from the prototype

```{r}
(n <- NaturalNumber())
```

which, of course, doesn't prevent us from specifying other values as arguments when we create an object

```{r}
(n <- NaturalNumber(n = as.integer(1)))
```

### Object validity

The type we give slots when we specify them puts type constraints on objects. When we declared that the `n` slot in `NaturalNumber` should be an integer we constrained the values we can assign to that slot. If we try to assign a `numeric` instead, we will get an error.

```{r}
n@n <- 1.2
```

For natural numbers, we do not want negative integers to be included, but since negative integers are still integers, there is no constraint to assigning such a value.

```{r}
n@n <- as.integer(-1)
```

We can put further constraints on objects via the `validity` argument to `setClass`. This argument should be a function that tests if an object is valid. If it is, it should return `TRUE`. Otherwise, it should return `FALSE`.

```{r, message=FALSE, warning=FALSE, results="hide"}
NaturalNumber <- setClass("NaturalNumber",
                          slots = c(
                            n = "integer"
                          ),
                          prototype = list(
                            n = as.integer(0)
                          ),
                          validity = function(object) {
                            object@n >= 0
                          })
```                          

```{r}
n <- NaturalNumber(n = as.integer(-1))
```

The validity test is only done when creating objects, though. We can modify objects and put them in an invalid state.

```{r}
n@n <- as.integer(-1)
```

This behaviour is necessary since, when modifying an object, it is likely to be in an invalid state until we are done modifying it. At any point when you are done modifying an object, though, you can call the `validObject` function to check the validity again.

```{r}
validObject(n)
```

## Generic functions and class hierarchies

To see how S4 handles class hierarchies and generic functions we return to the `A`, `B`, `C` example from earlier. We can construct the classes and three objects thus:

```{r}
A <- setClass("A", contains = "NULL")
B <- setClass("B", contains = "A")
C <- setClass("C", contains = "B")

x <- A()
y <- B()
z <- C()
```

Here I let `A` inherit from the pseudo-class `"NULL"` to make it non-abstract so I can instantiate it even though it doesn't have any slots.

If we define a generic function `f` and only implement it for class `A`

```{r, message=FALSE, warning=FALSE, results="hide"}
setGeneric("f", def = function(x) standardGeneric("f"))
setMethod("f", signature = "A", 
          definition = function(x) print("A::f"))
```

then this version will be called when we call it on all three objects.

```{r}
f(x)
f(y)
f(z)
```

If we define another function, `g`, that we implement for both `A` and `B`, then calling it on `x` will call the `A` version. Calling it on `y` and `z` will invoke the `B` version since this is the most specialised form of the function for those two classes.

```{r, message=FALSE, warning=FALSE, results="hide"}
setGeneric("g", def = function(x) standardGeneric("g"))
setMethod("g", signature = "A", 
          definition = function(x) print("A::g"))
setMethod("g", signature = "B", 
          definition = function(x) print("B::g"))
```

```{r}
g(x)
g(y)
g(z)
```

If we define a function that we implement for all three classes, then calling it on `x`, `y`, and `z` will invoke the most specialised version in all three cases.

```{r, message=FALSE, warning=FALSE, results="hide"}
setGeneric("h", def = function(x) standardGeneric("h"))
setMethod("h", signature = "A", 
          definition = function(x) print("A::h"))
setMethod("h", signature = "B", 
          definition = function(x) print("B::h"))
setMethod("h", signature = "C", 
          definition = function(x) print("C::h"))
```

```{r}
h(x)
h(y)
h(z)
```

The analogue of `NextMethod` in S4 is called `callNextMethod` and it works very similar:

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("h", signature = "A", 
          definition = function(x) {
            print("A::h")
          })
setMethod("h", signature = "B", 
          definition = function(x) {
            print("B::h")
            callNextMethod()
          })
setMethod("h", signature = "C", 
          definition = function(x) {
            print("C::h")
            callNextMethod()
          })
```

```{r}
h(x)
h(y)
h(z)
```

There is no `.default` version of methods as such, but we can use the `setGeneric` function to create one. If we define a plain old function and call `setGeneric` just with its name, that function will become the default function called when we do not have a more specialised version.

```{r, message=FALSE, warning=FALSE, results="hide"}
d <- function(x) print("default::d")
setGeneric("d")
```

```{r}
d(x)
d(y)
d(z)
```

This, of course, also work when we specialise and use `callNextMethod`

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("d", signature = "A", 
          definition = function(x) {
            print("A::d")
            callNextMethod()
          })
setMethod("d", signature = "B", 
          definition = function(x) {
            print("B::d")
            callNextMethod()
          })
setMethod("d", signature = "C", 
          definition = function(x) {
            print("C::d")
            callNextMethod()
          })
```

```{r}
d(x)
d(y)
d(z)
```

### Requiring methods

The abstract class `Stack` we defined earlier didn't serve any purpose. It is an abstract class with no associated data or functions. All functions in the stack interface were implemented in `VectorStack`, and we didn't gain anything from inheriting from `Stack`. In S4, however, we can formalise interfaces such as stacks and ensure that implementations of an interface actually implements all the functions in the interface.

It's not much. There is very little type checking in R, and you won't get much assistance from S4 either, but there is a way of at least making the error messages more informative when you invoke a generic function that hasn't been implemented.

Let's implement a non-functioning stack. We can make this class for the list-based stack. It inherits from `Stack`, but it doesn't add any slots or any functionality.

```{r, message=FALSE, warning=FALSE, results="hide"}
ListStack <- setClass("ListStack", contains = "Stack")
```

Even without an implementation, we can create an object of type `ListStack`. The `Stack` class is abstract because we didn't add any slots to it, but the `ListStack` is not interpreted as abstract, even though it doesn't add any slots either because it `contains` a superclass. If we call `pop` on a `ListStack`, however, we get an error, and rightly so.

```{r}
stack <- ListStack()
pop(stack)
```

We would expect to get an error here, and it probably isn't hard to figure out, from the error message, what is wrong. But if either `Stack` implemented a version of `pop`, or we had set a default function, we would instead be calling that, which would be an error but might not invoke an error message.

We can specify that all sub-classes of `Stack` must implement the stack interface using the function `requireMethods`:

```{r, message=FALSE, warning=FALSE, results="hide"}
requireMethods(functions = c("top", "pop", "push", "is_empty"), 
               signature = "Stack")
```

By doing this we ensure that calling any of these methods on `ListStack` will give us an error message.

```{r}
pop(stack)
```

It is not much of a safety check for the correct implementation of an interface, and I usually don't see much use for it, but it is there if you want it.


## Constructors

You can provide values for slots when you create objects by providing them as named arguments, but you can also get more control over object initialisation through the method `initialize`. This method works as a constructor, except that it doesn't create an object, it just is responsible for setting attributes to leave it in a consistent state. If you define this function, it replaces the default constructor, and you are in charge of which arguments the constructor should take, how it should set slots, and whether it should call the constructor of its superclass.

A very simple example, where we have one superclass and one subclass, is shown below:

```{r}
A <- setClass("A", slots = list(x = "numeric", y = "numeric"))
B <- setClass("B", contains = "A", slots = list(z = "numeric"))

setMethod("initialize", signature = "A",
          definition = function(.Object, x, y) {
            print("A initialize")
            .Object@x <- x
            .Object@y <- y
            .Object
          })

setMethod("initialize", signature = "B",
          definition = function(.Object, z) {
            .Object <- callNextMethod(.Object, x = z, y = z)
            .Object@z <- z
            .Object
          })

(a <- A(x = 1:3, y = 4:6))
(b <- B(z = 6:9))
```


## Dispatching on type-signatures

The signatures we have used so far when defining specialised methods consisted of just a class name. If we use them this way, S4 methods work just as S3 generic functions, but the dispatch mechanism for S4 methods is more general than this and it is possible to dispatch based on the type of all a function's arguments.

For example, we can define a function `f` of two arguments and refine it in different ways based on the type of the two arguments. Say, have one version when the arguments are numeric and another when they are logical.

```{r, message=FALSE, warning=FALSE, results="hide"}
setGeneric("f", def = function(x, y) standardGeneric("f"))
setMethod("f", signature = c("numeric", "numeric"),
          definition = function(x, y) x + y)
setMethod("f", signature = c("logical", "logical"),
          definition = function(x, y) x & y)
```

When calling `f`, the appropriate function is then selected based on the type of the arguments.

```{r}
f(2, 3)
f(TRUE, FALSE)
```

The type matching goes from most specific to most abstract, following class hierarchies for classes and would match integer over numeric over complex for numerical values. So, if we define a version of `f` that matches integers for the first value, it will call that one when we give it an integer and the version defined above when we call it with `numeric` values.

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("f", signature = c("integer", "complex"),
          definition = function(x, y) x - y)
```

```{r}
f(2, 2)
f(as.integer(2), 2)
```

Here, the second argument would catch any complex number, but we can specialise it to match integers and numeric instead:

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("f", signature = c("integer", "numeric"),
          definition = function(x, y) 2*x + y)
```

```{r}
f(as.integer(2), 2)
```

If we just give the signature a single string, as we did in the cases with classes earlier, it just dispatches on the type of the first argument

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("f", signature = "character",
          definition = function(x, y) x)
```

```{r}
f("foo", "bar")
```

In general, the signature list just matches types for a prefix of parameters if you do not provide types for all of them.

```{r, message=FALSE, warning=FALSE, results="hide"}
setGeneric("g", def = function(x, y, z) standardGeneric("g"))
setMethod("g", signature = "character",
          definition = function(x, y, z) "g(character)")
setMethod("g", signature = c("numeric", "character"),
          definition = function(x, y, z) "g(numeric, character)")
```
```{r}
g("foo", NA, NA)
g(12, "bar", NA)
```

If you want to match any type whatsoever, you can use the type `"ANY"`.

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("f", signature = "ANY",
          definition = function(x, y) "any")
```
```{r}
f(list(), NULL)
```

This can be used to define a catch-all default implementation for when no more specific implementation matches the arguments.

You can even match for cases when some arguments are not provided using the type `"missing"`. 

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("f", signature = c("ANY", "missing"),
          definition = function(x, y) "missing")
```
```{r}
f(list(), NULL)
f(list())
```

Here, the first call matches the version that take any arguments because the second argument is not missing, it is just `NULL`, while the other matches the more specific signature where the second argument is missing.

## Operator overloading

S4 also supports operator overloading and in much the same way as S3 does, just using the method mechanism for generic methods. We can try implementing the modulus class as an S4 class like this:

```{r, message=FALSE, warning=FALSE, results="hide"}
modulus <- setClass("modulus", 
                    slots = c(
                      value = "numeric",
                      n = "numeric"
                    ))
                    
setMethod("show", signature = "modulus",
          definition = function(object) {
            cat("Modulus", object@n, "values:\\n")
            print(object@value)
          })
```

```{r}
(x <- modulus(value = 1:6, n = 3))
```

The `show` method we implemented here is the S4 equivalent of `print` and we use it to pretty-print `modulus` objects.

If we then want to implement a single operator we can specialise the method for it, just as we did with generic functions for S3, but we can use the signature type matching to capture different combinations of arguments instead of writing type-checking code at the beginning of the generic function as we had to for S3.

Below we handle the three cases we want for modulus arithmetic: the case where both operands are `modulus` objects and the two cases where one of them is a `modulus` object and the other is `numeric`.

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("+", signature = c("modulus", "modulus"),
          definition = function(e1, e2) {
            if (e1@n != e2@n) stop("Incompatible modulus")
            modulus(value = e1@value + e2@value,
                    n = e1@n)
          })
setMethod("+", signature = c("modulus", "numeric"),
          definition = function(e1, e2) {
            modulus(value = e1@value + e2,
                    n = e1@n)
          })
setMethod("+", signature = c("numeric", "modulus"),
          definition = function(e1, e2) {
            modulus(value = e1 + e2@value,
                    n = e2@n)
          })
```

Now we can combine `numeric` and `modulus` in addition, and we didn't have to explicitly check the type in the functions since the type dispatch handled that for us.

```{r}
x + 1:6
1:6 + x
```

We also handle the case with two `modulus` object and check that their `n` slots are equal.

```{r}
y <- modulus(value = 1:6, n = 2)
x + y
y <- modulus(value = 1:6, n = 3)
x + y
```

We also have function group solutions in S4, and for defining arithmetic operations, we need the group `Arith`. This works much as the `Ops` generic function in S3 except that we, again, can use type matching instead of explicitly checking the type of the arguments inside the function(s).

```{r, message=FALSE, warning=FALSE, results="hide"}
setMethod("Arith", 
          signature = c("modulus", "modulus"),
          definition = function(e1, e2) {
            if (e1@n != e2@n) stop("Incompatible modulus")
            modulus(value = callGeneric(e1@value, e2@value),
                    n = e1@n)
          })
setMethod("Arith", 
          signature = c("modulus", "numeric"),
          definition = function(e1, e2) {
            modulus(value = callGeneric(e1@value, e2),
                    n = e1@n)
          })
setMethod("Arith", 
          signature = c("numeric", "modulus"),
          definition = function(e1, e2) {
            modulus(value = callGeneric(e1, e2@value),
                    n = e2@n)
          })
```

```{r}
x * y
2 * x
```

## Combining S3 and S4 classes

You can, to a limited degree, combine S3 and S4. The two systems are different and trying to write software that connects S3 and S4 class-hierarchies intimately is not something I will recommend. It only leads to weeping and gnashing of teeth. But if you have existing S3 code and you want to write an extension in S4 you can do this.

Let's say we have an S3 class, `X`, with generic functions `foo` and `bar`.

```{r}
X <- function(x) {
  structure(list(x = x), class = "X")
}

foo <- function(x) UseMethod("foo")
bar <- function(x) UseMethod("bar")
foo.X <- function(x) "foo"
bar.X <- function(x) x$x

x <- X(5)
foo(x)
bar(x)
```

If we want to write a subclass of `X`, let's call it `Y`, and we want to write `Y` in S4, we cannot use `X` in the `contains` option to `setClass`. Well, you can, but if you try to instantiate objects of the class you will get an error. The S4 system doesn't know about any class called `X` so we first have to make it aware of it. We can do that using the function `setOldClass`.

```{r}
setOldClass("X")
```

This does two things: it lets S4 know about the class so we can inherit from it and it makes any generic function defined for the class into functions we can specialise with `setMethod`. So after calling `setOldClass` we can make a sub-class of `A` as an S4 class.

```{r, message=FALSE, warning=FALSE, results="hide"}
Y <- setClass("Y", contains = "X")
```

Calling `foo` or `bar` on an object of type `Y` will also work with the dynamic dispatch system and will invoke `foo.Y` since there is no better matching `foo.Y`. 

```{r}
y <- Y()
foo(y)
```

If we want to, we could make a specialised version of `foo` for `Y` objects by implementing `foo.Y`

```{r}
foo.Y <- function(x) "Y::foo"
foo(y)
```

Of course, this would be the S3 of refining generic functions and since we are working with an S4 class now it is better to use `setMethod`.

Similar to `foo`, calling `bar` invokes `bar.X`. In this case resulting in an error because, even though S4 knows about the `X` class, it doesn't know about the constructor function or the representation of `X` objects it create.

```{r}
bar(y)
```

There is no formal definition of constructors or object representations in S3, only informal coding conventions, so no way for S4 to know about what the `bar` function expects to be able to get out of an `X` object. There is a limit to how well we can integrate S3 and S4 automatically and some coding is needed to get the functionality of the S3 version to also match the S4 class.

```{r, message=FALSE, warning=FALSE, results="hide"}
Y <- setClass("Y", contains = "X", slots = c(x = "ANY"))
setMethod("bar", signature = "Y",
          definition = function(x) x@x)
```

```{r}
y <- Y(x = 13)
bar(y)
```

I don't recommend mixing S3 and S4. If you have code written using the S3 system you are probably better off sticking with S3 rather than trying to combine the two systems, but if you are writing code using S4 and need to include a little functionality from S3 classes, this is the way to do it.