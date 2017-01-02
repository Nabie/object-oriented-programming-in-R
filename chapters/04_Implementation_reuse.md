# Implementation reuse

The easiest code to write is the code that is already written. If you can reuse existing code it is always better than writing new code; you don't have to spend time writing the code and if the existing code has been around for a while there is a good chance that it is well tested and thus more likely to be correct than new code you introduce. So your aim as a programmer should be to write as little new code as possible, paradoxically as it sounds.

The way to reuse code, however, is not to copy chunks of existing code from one place in your program and paste it into another. You will be reusing the code this way, true, but you will end up with two copies of the same code. If at some point in the future you find that you have to modify this code, perhaps because there was a bug hidden in it despite the tests, you will have to remember to change it both places. It is hard to remember when you have such duplicated code and if the two copies start drifting apart it is a nightmare trying to maintain it.

The way to reuse code is to write functions that can be used in many different contexts. Write functions to deal with a single problem, and deal with it well, while assuming very little about the context in which they will be called. Constructing a program out of small, reusable building blocks makes your code easier to maintain and easier to extend.

In object-oriented programming we often add another aspect to code reuse, however. When a class defines a number of generic functions, all implementations of the class and its sub-classes must implement these generic functions. If each class implements all of the generic functions in unique ways, there is very little opportunity for reuse, but it is rarely the case that *everything* is unique. Oftentimes there are good default solutions to a given problem that will work for most classes while only a few classes need to implement special functions. In object-oriented programming you want to implement functions at the highest level in the class hierarchy where it is possible and let sub-classes reuse these implementations when possible by calling the more general functions instead of providing their own specialised functions. Any class in the hierarchy might have to specialise a subset of the generic functions, and any subclass of should use the most specialised function in the hierarchy above it, but in general it should only define its own version of generic functions if they are different from the ones defined in its superclasses. The remaining functions, it should just reuse. We say that it *inherits* such functions from its super-class and the look-up mechanism for generic functions automates this to a high degree.


## Method lookup in class hierarchies

As we saw earlier, for a generic function `f` calling `f(x)` will make R look for a function with a name derived from `class(x)`. If `class(x)` is a single string, say `"A"`, it will look for `f.A`. If R finds such a function it will call it, if it doesn't, it will look for `f.default` and call that, or it will give up and give you an error if there is no `f.default`. This is how R behaves if the class of an object is a single string. If it is a sequence of class names it instead goes through this sequence and attempts to find functions for each of the classes in the sequence in turn.

Consider the three classes `A`, `B`, and `C`, defined below.

```{r}
A <- function() {
  structure(list(), class = "A")
}

B <- function() {
  structure(list(), class = c("B", "A"))
}

C <- function() {
  structure(list(), class = c("C", "B", "A"))
}
```

We can create instances of these and check their classes

```{r}
x <- A()
y <- B()
z <- C()

class(x)
class(y)
class(z)
```

If we define a generic function that only has a default implementation

```{r}
f <- function(x) UseMethod("f")
f.default <- function(x) print("f.default")
```

calling it on all three objects will just give us the default behaviour.

```{r}
f(x)
f(y)
f(z)
```

If, on the other hand, we define a generic function that has a default implementation and an implementation for the class `A`, calling it on the three objects all results in the `A` function being called.

```{r}
g <- function(x) UseMethod("g")
g.default <- function(x) print("g.default")
g.A <- function(x) print("g.A")

g(x)
g(y)
g(z)
```

For `x` we know why this happens. R looks for `g.A` and finds it. For `y`, on the other hand, R looks for `g.B` and doesn't find it. If the class of `y` was only `"B"` that would be the end of the search and R would call `g.default`. But the class of `y` is both `"B"` and `"A"`, so when R doesn't find `g.B` it instead searches for `g.A`, which does exist, and invokes that. Similarly, when we call `g(z)`, R first searches for `g.C`, doesn't find it, so it then searches for `g.B`, which it also doesn't find, and then it finally finds that `g.A` exists and it calls that. So all three calls are to the same `g.A` function. Classes `B` and `C` inherited the implementation of `g` from class `A`.

We can now try adding a generic function with implementations for both class `A` and `B`.

```{r}
h <- function(x) UseMethod("h")
h.default <- function(x) print("h.default")
h.A <- function(x) print("h.A")
h.B <- function(x) print("h.B")

h(x)
h(y)
h(z)
```

In this case, calling `h(x)` invokes `h.A` — naturally, the only class for `x` is `A` and `h.A` is implemented — while calling `h(y)` and `h(z)` both invokes `h.B`. In both cases, class `B` is found before class `A` in the class sequence and since `h.B` exists it is invoked and the search for matching functions stops. The `h.A` function exists, but we stop searching after the first match, so we never get to it.

For completeness, if we add a function that has implementations for all the three classes, the most specialised function will be called for each.

```{r}
i <- function(x) UseMethod("i")
i.default <- function(x) print("i.default")
i.A <- function(x) print("i.A")
i.B <- function(x) print("i.B")
i.C <- function(x) print("i.C")

i(x)
i(y)
i(z)
```


## Getting the hierarchy correct in the constructors

When we created the three classes `A`, `B`, and `C` above we explicitly created the class list representing the class hierarchy in each constructor. This is fine for a small hierarchy as the one we have here, where we define all three classes close together and know that they are supposed to work together, but it does introduce a potential source of errors if the code grows into something more complex. If, for example, we at some point want to put another class into the hierarchy between `A` and `B`. We might remember to update the class list for `B` but will we also remember to update it for `C`? If `C` is in a different file, perhaps, and we haven't modified it in years?

Since the class hierarchy is entirely represented in these class lists, there is no explicit hierarchy only these implicit lists, we must be extra careful to ensure that our code always matches our design. We should avoid explicitly representing the hierarchy in every constructor.

One way to ensure this is to always invoke the immediate super-class constructor when you define a new class. R doesn't know anything about class hierarchies and it doesn't know which super-class you have until after you have created the `class` list, so there is no automatic way of doing this, but you can simply call the constructor of the super-class, obtain an object this way, and then prepend the new class name to its `class` list.

```{r}
A <- function() {
  structure(list(), class = "A")
}

B <- function() {
  this <- A()
  class(this) <- c("B", class(this))
  this
}

C <- function() {
  this <- B()
  class(this) <- c("C", class(this))
  this
}
```

Using this programming idiom also saves you from another potential error source. The constructor of a class often creates an object with a number of attributes that it expects to be in a consistent state in its functions. If you do not call the constructor, but set up these attributes in the constructor of a sub-class, you might violate invariants the super-class depends upon. You will probably be careful not to do that when you write the sub-class constructor, but the super-class implementation could be changed in the future, perhaps by someone who doesn't know about the sub-class constructor (and let's face it, that someone could be you in six months), and when that happens the sub-class implementation could be broken. It is hell to try to debug an error that shows up because code has changed in a completely different location in the code.

You are generally better of if you always call the constructor of the super-class and then modify the resulting object before you return the object of the sub-class.

## `NextMethod`

When we specialise generic functions we do not always need to implement everything from scratch either. Sometimes we can reuse implementations from more abstract classes, we just need to tweak the results of them a little. We can always call the function of a super-class explicitly using the full name of the function, but this will only work if the class actually implements its own version — it will not work if it simply inherits it — and you have to be careful every time you modify the class hierarchy that you are not breaking assumptions underlying such direct calls.

A better solution is to use the `NextMethod` function. This function lets you call inherited functions in a way that resembles `UseMethod` and that uses the `class` sequence.

```r
format.publication <- function(publ) {
  paste(name(publ), authors(publ), sep = ", ")
}

format.article <- function(publ) {
  paste(NextMethod(), journal(publ), pages(publ), sep = ", ")
}

format.book <- function(publ) {
  paste(NextMethod(), publisher(publ), ISBN(publ), sep = ", ")
}
```



```{r}
i <- function(x) UseMethod("i")
i.default <- function(x) print("i.default")
i.A <- function(x) {
  print("i.A")
  NextMethod()
}
i.B <- function(x) {
  print("i.B")
  NextMethod()
}
i.C <- function(x) {
  print("i.C")
  NextMethod()
}

i(x)
i(y)
i(z)

j <- function(x) UseMethod("j")
j.default <- function(x) print("j.default")
j.A <- function(x) {
  print("j.A")
  NextMethod()
}
j.C <- function(x) {
  print("j.C")
  NextMethod()
}

j(x)
j(y)
j(z)
```

```{r}
class(z) <- rev(class(z))
i(z)
```

