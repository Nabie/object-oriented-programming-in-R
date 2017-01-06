# R6 classes

The last object system we will look at is the R6 system. This system is very unlike S3 and S4, and unusual in R in general. Data is usually immutable in R and any semblance of object modification is really implemented by copying data and constructing new objects. The only thing you can modify in R is environments; you cannot modify data. The R6 system, however, uses environments to give us objects we can modify. Unusual in R, but the semantics is then similar to how object-orientation is implemented in most other languages, where methods modify objects rather than create new objects.

The R6 system is a better implementation of this semantics than the built in reference class (RC) system, also known as R5, the natural name for the next object system, implemented in R, after the object systems S3 and S4, originally from the S language. Because R6 has the same semantics as R5, and is considered a better implementation of it, I will not cover R5 further.

## Defining classes

Classes are defined using the `R6Class` function from the package `R6`. Similar to `setClass` from S4, we need to give the class a name, and we have a number of optional arguments for defining how objects of the class should look like and behave. Unlike S4, we need to capture the result from the call to `R6Class` in order to create objects of the class. In S4 this is a convention, but we can create objects as long as we know the name of a class. In R6, the name is mainly used to set the `class` attribute so the objects can interact with S3 polymorphism. It is the return value of `R6Class` we use to create objects.

As an example we, once again, implement a stack. This time I will not bother with an abstract super-class but just implement a `VectorStack` directly. One implementation can look like this:

```{r}
library(R6)

VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         top = function() {
                           private$elements[1]
                         },
                         pop = function() {
                           private$elements <- private$elements[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements <- c(e, private$elements)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements) == 0
                         }
                       ))
```

Here, besides the class name, we use two arguments to `R6Class`: `private` and `public`. These are used to define attributes of the class, either values stored in objects or methods we can call on the objects. For both, the arguments are lists. The names used for the list elements become the names of the attributes and the values, naturally, the attribute values.

The difference between the two arguments is that attributes in the `public` list can be accessed on objects of the class anywhere you have such objects while attributes in the `private` list can only be accessed in methods you define for the class. In methods, you can access elements in the `public` list using the variable `self` and you can access attributes in the `private` list using the variable `private`. In this `VectorStack` implementation we have made the vector used for storing the stack private and we have implemented the stack interface as public methods. Inside the methods we access the elements as `private$elements`, and in `push` and `pop` we return the object itself using the variable `self`. We return this object wrapped in `invisible` so it isn't automatically printed when we call these methods, but we didn't have to. We didn't have to return an object at all for these methods, but doing so allows us to chain together method calls, as we will see below, so it is good practise.

Notice that the `self` and `private` objects are not arguments to the methods. They just exist in the namespace of the functions as part of the magic R6 uses to implement its mutable object semantics.

The `VectorStack` object we create this way is not a constructor function itself, as it was for S4. It is a so-called object generator. To create an object we use the attribute `new` of this generator thus:

```{r}
(stack <- VectorStack$new())
```

Printing this object is rather verbose, but if we define the method `print` for the class we can modify how it is displayed.

```{r, echo=FALSE}
VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         top = function() {
                           private$elements[1]
                         },
                         pop = function() {
                           private$elements <- private$elements[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements <- c(e, private$elements)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements) == 0
                         },
                         print = function() {
                           cat("Stack elements:\\n")
                           print(private$elements)
                         }
                       ))
```

```r
VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         # ... rest of the methods
                         print = function() {
                           cat("Stack elements:\\n")
                           print(private$elements)
                         }
                       ))
```

This doesn't modify the existing object

```{r}
stack
```

but it has an effect if we create a new one

```{r}
(stack <- VectorStack$new())
```

We can access the (public) attributes of the stack object, and call methods if the attributes are functions, using `$` indexing:

```{r}
stack$push(1)$push(2)$push(3)
stack

while (!stack$is_empty()) stack$pop()
stack
```

The chained call to `push` here is possible because the `push` method returns the object itself. Unlike the previous implementations where `push` returns a new object, for the R6 object, the existing object is modified. We do not need to assign the result of the three `push` calls back to `stack` and we do not need to assign the calls to `pop` back to `stack` either. Returning the object itself in these functions allows us to chain method calls, but that is all this does. The R6 object is not immutable.

### Object initialisation

If we want to set attributes of objects when constructing them, we need to do a little more work than in S4. We cannot simply use named arguments in the constructor; this call would give us an error:

```r
stack <- VectorStack$new(elements = 1:4)
```

To be able to initialise objects this way, we need to explicitly write a function for it. This function must be a `public` method called `initialise`. If you want the constructor to take arguments, you must specify the arguments in this function. You cannot make this function `private`; it is an error to put a function named `initialise` in the `private` list.

To initialise `VectorStack` objects with a sequence of elements we can implement its `initialize` function like this:

```{r, echo=FALSE}
VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         initialize = function(elements = NULL) {
                           private$elements <- elements
                         },
                         top = function() {
                           private$elements[1]
                         },
                         pop = function() {
                           private$elements <- private$elements[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements <- c(e, private$elements)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements) == 0
                         },
                         print = function() {
                           cat("Stack elements:\\n")
                           print(private$elements)
                         }
                       ))
```
```r
VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         initialize = function(elements = NULL) {
                           private$elements <- elements
                         },
                         # ... rest of the methods
                       ))
```

With this initialisation function we can now construct objects with `elements` initialised.

```{r}
(stack <- VectorStack$new(elements = 1:4))
```

### Private and public attributes

The elements in the stack are private so we cannot access them the same way we can the public methods. You might hope that `stack$elements` would then give you an error, but unfortunately not.

```{r}
stack$elements
```

This is because accessing a list with a key it doesn't contain gives you `NULL` and it is this behaviour you are getting.

```{r}
list()$elements
```

We can see the difference between private and public attributes with this little example:

```{r}
A <- R6Class("A", public = list(x = 5), private = list(y = 13))
```

With this defintion of class `A` we should be able to access object's `x` attributes, and we can:

```{r}
a <- A$new()
a$x
a$x <- 7
a$x
```

We can also get `y`, but it has the behaviour we saw above for stacks, and we are not allowed to modify it since it isn't really an attribute of the object.

```{r}
a$y
a$y <- 12
a$y
```

In general, you cannot create new attributes to R6 objects just by assigning to `$` indexed values, as you can in S3. Attributes must be defined in the class definition.

```{r}
a$z <- "foo"
```

You can modify public data attributes, as we saw above for `x`, but don't try to be clever and modify methods. It is really bad practise to change methods for a single object to begin with, but luckily it is also "verboten" in R6 and you will get you an error.

```{r}
stack$pop <- NULL
```

In general, it is considered good practise to keep data private and methods that are part of a class interface public. There are several reasons for this: 

### Active bindings

```{r, echo=FALSE}
VectorStack <- R6Class("VectorStack",
                       private = list(elements_ = NULL),
                       public = list(
                         initialize = function(elements = NULL) {
                           private$elements_ <- elements
                         },
                         top = function() {
                           private$elements_[1]
                         },
                         pop = function() {
                           private$elements_ <- private$elements_[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements_ <- c(e, private$elements_)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements_) == 0
                         },
                         print = function() {
                           cat("Stack elements:\\n")
                           print(private$elements_)
                         }
                       ),
                       active = list(
                         elements = function(value) {
                           if (!missing(value))
                             stop("elements are read-only")
                           private$elements_
                         }
                       ))
```

```r
VectorStack <- R6Class("VectorStack",
                       private = list(elements_ = NULL),
                       public = list(
                         # ... methods
                       ),
                       active = list(
                         elements = function(value) {
                           if (!missing(value)) 
                             stop("elements are read-only")
                           private$elements_
                         }
                       ))
```

```{r}
(stack <- VectorStack$new(elements = 1:4))
stack$elements

stack$elements <- rev(1:3)
```

## Inheritance

```{r}

A <- R6Class("A",
             public = list(
               f = function() print("A::f"),
               g = function() print("A::g"),
               h = function() print("A::h")
             ))
B <- R6Class("B", inherit = A,
             public = list(
               g = function() print("B::g"),
               h = function() print("B::h")
             ))
C <- R6Class("C", inherit = B,
             public = list(
               h = function() print("C::h")
             ))

x <- A$new()
y <- B$new()
z <- C$new()

x$f()
y$f()
z$f()

x$g()
y$g()
z$g()

x$h()
y$h()
z$h()
```

## References to objects and object sharing



## Interaction with S3 and operator overloading

```{r}

modulus <- R6Class("modulus", 
                    private = list(
                      value_ = c(),
                      n_ = c()
                    ),
                   public = list(
                     initialize = function(value, n) {
                       private$value_ <- value
                       private$n_ <- n
                     },
                     print = function() {
                       cat("Modulus", private$n_, "values:\n")
                       print(private$value_)
                     }
                   ),
                   active = list(
                     value = function(value) {
                       if (missing(value)) private$value_
                       else private$value_ <- value %% private$n_
                     },
                     n = function(value) {
                       if (!missing(value)) stop("Cannot change n")
                       private$n_
                     }
                   ))

(x <- modulus$new(value = 1:6, n = 3))

Ops.modulus <- function(e1, e2) {
  nx <- ny <- NULL
  if (inherits(e1, "modulus")) nx <- e1$n
  if (inherits(e2, "modulus")) ny <- e2$n
  if (!is.null(nx) && !is.null(ny) && nx != ny)
    stop("Incompatible types")
  n <- ifelse(!is.null(nx), nx, ny)
  
  v1 <- e1
  v2 <- e2
  if (inherits(e1, "modulus")) v1 <- e1$value
  if (inherits(e2, "modulus")) v2 <- e2$value
  
  e1 <- v1 ; e2 <- v2
  result <- NextMethod() %% n
  modulus$new(result, n)
}

x + 1:6
1:6 + x
2 * x
```
