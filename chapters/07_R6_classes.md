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

In general, it is considered good practise to keep data private and methods that are part of a class interface public. There are several reasons for this: If data is only modified through a class' methods then you have more control over the state of objects and can ensure that an object is always in a valid state before and after all method calls, but, perhaps more importantly, keeping the representation of objects hidden away limits the dependency between a class and code that uses the class. If any code can access the inner workings of objects there is a good chance that eventually a lot of code will. This means that you will have to modify all the uses of a class if you change how objects of the class are represented. If, on the other hand, code only accesses objects through a public interface, then you can modify all the private attributes as much as you want as long as you keep the public interface unchanged. You will of course have to modify some of the class' methods, but changes will be limited to that.

In the R6 system, private attributes can be accessed only by methods you define for the class or in methods defined in sub-classes. If you are used to languages such as C++ or Java, this might surprise you, but the private attributes in R6 are similar to the protected attributes in those languages and not the private attributes.

### Active bindings

There is a way of getting the syntax of accessing data attributes without actually doing so. If you have code that already uses a public attribute and you want to change that into a function to hide or modify implementation details you can use this, or if you just like the syntax for data better than method calls.

This is achieved through the `active` argument to `R6Class`. Here you can provide a list of attributes, as for `private` and `public`, but these attributes should be functions and they will define a value-like syntax for calling the functions.

As an example we can take the elements in the vector stack. We want to be able to write `stack$elements` but we do not want to make the elements public. So we write a function for `elements` and add it to `active`. We cannot have the same name used both in `private` and `active` (or in `public` for that matter), so we have to change the name for the private data attribute first, and of course update all the existing methods. After doing that, we can add the `active` function like this:

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

Functions in the `active` list should take one argument, `value`. This value will be missing when we read the attribute and contain data when we assign to the attribute. In this implementation we consider assigning to the elements an error and we return the private `elements_` when we read the attribute.

This will give us the elements:

```{r}
stack <- VectorStack$new(elements = 1:4)
stack$elements
```

while this will raise an error:

```{r}
stack$elements <- rev(1:3)
```

You can use these `active` functions to modify values you assign, to ensure object consistency, or to fake an attribute that isn't directly stored but exists implicitly by being computable from other data. It all depends on how you choose to use them.

## Inheritance

The way we specify class hierarchies, and the way method-calls are dispatched to the most specialised implementation of a method, is fairly straightforward. We can take the example with three classes we have seen two times earlier and implement it in R6. To specify that one class inherits from another we use the `inherit` argument to `R6Class` and to write more specialised version of a method we simply add the method to the `public` or `private` lists. Overall, writing methods and class hierarchies is done with much simpler code in R6 than in both S3 and S4.

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
```

There are no surprises in how we instantiate objects of the classes; we have to use the `new` method in the object generators:

```{r}
x <- A$new()
y <- B$new()
z <- C$new()
```

For method `f` we only have an implementation for class `A`, so calling `f` on all three objects will call that version. Except that the method call has a different syntax from the implementations for S3 and S4, there are no surprises here.

```{r}
x$f()
y$f()
z$f()
```

For `g`, we have implementations in both `A` and `B`, and the `C` object will call the `B` implementation since this is the most specialised for that class.

```{r}
x$g()
y$g()
z$g()
```

Finally, for `h` we have implementations in all three classes, so we call different methods for the three objects.

```{r}
x$h()
y$h()
z$h()
```

There should not be any surprises in how inheritance and method dispatching works in R6.

## References to objects and object sharing

One important thing is different from R6 objects and all other R objects: the R6 objects have a state that can be modified. If you are used to other object-oriented programming languages this might not sound like much of a deal, but in general we can assume that calling functions do not have side-effects in R except for changing values that variables point to. When objects can suddenly change state, we need to worry about when two references are to the same object or merely references to two objects that represent the same values.

The first thing you need to know is that values set in the definition of `private` and `public` lists are shared between objects of a class. To see this in action we can define these two classes:

```{r}
A <- R6Class("A", public = list(x = 1:5))
B <- R6Class("B", 
             public = list(
               x = 1:5,
               a = A$new()
             ))
```

Here, I am breaking the rule about not having public data to simplify the example. In any case, what we have is one class, `A`, that contains a vector and another, `B`, that contains another vector and a reference to an `A` object. Let's create two objects of class `B`.

```{r}
x <- B$new()
y <- B$new()
```

We can first check the behaviour of the vector in the objects. It is initialled to the first five natural numbers so that is what both objects contain initially.

```{r}
x$x
y$x
```

If we then modify the vector in `x` we see that this vector changes but the vector in `y` does not. This is how vectors behave in R and generally what we would expect.

```{r}
x$x <- 1:3
x$x
y$x
```

If we modify the vector in the nested `A` object, however, we get a different behaviour. Here, changing the value through `x` *also* changes the value in `y`.

```{r}
x$a$x
y$a$x
x$a$x <- 1:3
x$a$x
y$a$x
```

Even creating a new object from the class will give us an object that contains the modified value.

```{r}
z <- B$new()
z$a$x
```

All three objects are referring to the same `A` object and modifications to this object are reflected in all of them. This is generally how R6 classes behave. The copy-on-modification semantics of other R objects is not how R6 objects behave. When you have two references to the same object then modifying one of them will also modify the other.

Modifying `x$x` didn't change `y$x` because `x` and `y` are different objects, but if we make another reference to the object pointed to by `x` then changes to `x` will be reflected in the other.

```{r}
w <- x
w$x
x$x <- 1:5
w$x
```

If you want objects of a class to contain distinct objects of an R6 class then you can create the objects in the `initialise` function instead of in the `public` or `private` lists. This function is called whenever you create a new object and contained objects that are created in the initialisation function will be distinct and thus not shared.

We can modify `B` like this:

```{r}
B <- R6Class("B", 
             public = list(
               x = 1:5,
               a = NULL,
               initialize = function() {
                 self$a <- A$new()
               }))
```

We need to re-create `x` and `y` to have them refer to this new class

```{r}
x <- B$new()
y <- B$new()
```

but now we can modify one without modifying the other.

```{r}
x$a$x
x$a$x <- 1:3
x$a$x
y$a$x
```

Since assigning from one variable to another just create another reference to the same object, we need another way of creating an effective copy. This is done with the `clone` method that all `R6` objects automatically implement.

If we clone object `x` we get a new copy of the object, which contains the same state as `x` does at the time of cloning, but which can be modified without changing `x`.

```{r}
z <- x$clone()
z$x
z$x <- 1:2
x$x
```

The default cloning is shallow, however. It makes a copy of the object, but if the object contains a references to an R6 class then the clone will contain a reference to the same object. If we modify the `a` attribute of `z` we will also modify the `a` attribute of `x`.

```{r}
x$a$x
z$a$x <- 1:5
x$a$x
```

If we call `clone` with the option `deep = TRUE` we will instead get a deep copy; here we get a transitive closure of cloned references, so here we can modify the `a` attribute safe in the knowledge that they are distinct between an object and its clone.

```{r}
y <- x$clone(deep = TRUE)

x$a$x
y$a$x <- NULL
x$a$x
```

## Interaction with S3 and operator overloading

We don't have a mechanism for defining new operators for R6 objects, but we can use the S3 system for this. Objects create from R6 object generators are assigned a `class` attribute, a list of the name we give the class when creating the generator and `"R6"`, so we can define generic function specialisations for them.

We can implement the `modulus` class in R6 like this:

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
                       cat("Modulus", private$n_, "values:\\n")
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
```

There are a few things going on in this class definition. We define the attributes for holding the data in the `private` list, define an initialisation function and a print function, and then we define two `action` attributes for accessing the data. We allow users of the class to modify `values` but not `n` (for no good reason other than it gives us an example of two different behaviour), and for the `values` attribute we make sure that we modify the data before we store it in the private `values_` variable.

The `class` attribute of objects of this class contains

```{r}
class(x)
```

This means that we can define arithmetic operations on the class using the S3 system like this:

```{r}
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
```

The implementation is slightly different from the S3 version, because the data in the objects are represented differently, but the general control-flow is the same, and with this definition we have modulus arithmetic.

```{r}
x + 1:6
1:6 + x
2 * x
```

If you make sub-classes of an R6 class like `modulus` you will get a `class` attribute that also reflects this, so the S3 dispatch mechanism will also work for sub-classes in the R6 system.

```{r}
modulus2 <- R6Class("modulus2", inherit = modulus)
y <- modulus2$new(value = 1:2, n = 3)
class(y)
x + y
```

That being said, don't go crazy with combing R6 and S3 either; it will only confuse the maintainers of your code (which are likely to include yourself somewhere in the future).


