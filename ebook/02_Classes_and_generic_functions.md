

# Classes and generic functions

R’s approach to object oriented programming is through *generic functions* and *classes*. As mentioned in the introduction, R actually has three systems for implementing this, called S3, S4, and RC. In this chapter I will only describe the S3 system, which is the simplest of the three, but I will return to the other two systems in later chapters.


## Generic functions

The term *generic functions* refers to functions that can be used on more than one data type. Since R is dynamically typed, which means that there is no check of type consistency before you run your programs, type checking is really only a question of whether you can manipulate data in the way your functions attempts to. This is also called “duck typing” from the phrase “if it walks like a duck…”. If you can do the operations you want to do on a data object, then it has the right type. Where generic functions come into play is when you want to do the same semantic operation on objects of different types, but where the implementation of how that operation is done depends on the concrete types. Generic functions are functions that work differently on different types of objects. They are therefore also known as *polymorphic functions*.

To take this down from the abstract discussion to something more concrete, let us consider an abstract data type, say a stack. A stack is defined by the operations we can do on it:

* get the top element
* pop the first element off a stack
* push a new element to the top of the stack

To have a base case for stacks we typically also want a way to

* create an empty stack
* check if a stack is empty

These five operations defines what a stack *is*, but we can implement a stack in many different ways. Defining a stack by the operations we can do on stacks makes it an abstract data type. To implement a stack we need a concrete implementation.

In a statically typed programming language we would define the type of a stack by these operations. How this would be done depends on the type of programming language and the concrete language, but generally in statically typed functional languages you would define a *signature* for a stack — the functions and their type for the five operations — while in an object oriented language you would define an abstract super-class.

In R, the types are implicitly defined, but for a stack we would also define the five functions. These functions would be generic and not actually have any implementation in them; the implementation goes into the concrete implementation of stacks.

Of the five functions defining a stack, one is special. Creating an empty stack does not work as a generic function. When we create a stack, we always need a concrete implementation. But the other four can be defined as generic functions. Defining a generic function is done using the `UseMethod` function, and the four functions can be defined as thus:


```r
top <- function(stack) UseMethod("top")
pop <- function(stack) UseMethod("pop")
push <- function(stack, element) UseMethod("push")
is_empty <- function(stack) UseMethod("is_empty")
```

What `UseMethod` does here is tying the functions in the the S3 object oriented programming system. When it is called, it will look for a concrete implementation of a function and call it with the parameters the generic function was called with. We will see how this lookup works shortly.

When defining generic functions you can specify “default” functions as well. These are called when `UseMethod` cannot find a concrete implementation. These are mostly useful when it is possible to actually have some default behaviour that works in most cases, so not all concrete classes need to implement them, but it is a good idea to always implement them, even if all they do is inform you that an actual implementation wasn’t found.


```r
top.default <- function(stack) .NotYetImplemented()
pop.default <- function(stack) .NotYetImplemented()
push.default <- function(stack, element) .NotYetImplemented()
is_empty.default <- function(stack) .NotYetImplemented()
```


## Classes

To make concrete implementations of abstract data types we need to use *classes*. In the S3 system you create a class, and assign a class to an object, just by setting an attribute on the object. The name of the class is all that defines it, so there is no real type checking involved. Any object can have an attribute called “class” and any string can be the name of a class.

We can make a concrete implementation of a stack using a vector.  To define the class we just need to pick a name for it. We can use `vector_stack`. We create such a stack using a function for creating an empty stack, and in this function we set the attribute “class” using the `class<-` modification function.


```r
empty_vector_stack <- function() {
  stack <- vector("numeric")
  class(stack) <- "vector_stack"
  stack
}

stack <- empty_vector_stack()
stack
```

```
## numeric(0)
## attr(,"class")
## [1] "vector_stack"
```

```r
attributes(stack)
```

```
## $class
## [1] "vector_stack"
```

```r
class(stack)
```

```
## [1] "vector_stack"
```

The empty stack is a numeric vector, just because we need some type to give the empty vector, but pushing other values onto it will just force a type conversion, so we can put other basic types into it. It is limited to basic data types since vectors cannot contain complex data; for that we would need a list. If we need complex data we could easily change the implementation to use a list instead of a vector.

We will push elements by putting them at the front of the vector, pop elements by getting everything except the first element of the vector, and of course get the top of a vector by just indexing the first element. Such an implementation can look like this:


```r
top.vector_stack <- function(stack) stack[1]
pop.vector_stack <- function(stack) {
  new_stack <- stack[-1]
  class(new_stack) <- "vector_stack"
  new_stack
}
push.vector_stack <- function(element, stack) {
  new_stack <- c(element, stack)
  class(new_stack) <- "vector_stack"
  new_stack
}
is_empty.vector_stack <- function(stack) length(stack) == 0
```

You will notice that the names of the functions are composed of two parts. Before the “.” you have the names of the generic functions that define a stack, and after the “.” you have the class name. This name format has semantic meaning; it is how generic functions figure out which concrete functions should be called based on the data provided to them.

When the generic functions call `UseMethod`, this function will check if the first value the generic function was called with has a class. If so, it will get the name of that class and see if it can find a function with the name of the generic function (the name parameter given to `UseMethod`, not necessarily the name of the function that calls `UseMethod`) before a “.” and the name of the class after the “.”. If so, it will call that function. If not, it will look for a `.default` suffix instead and call that function if it exists.

This lookup mechanism gives semantic meaning to function names, and you really shouldn’t use “.”s in function names unless you want R to interpret the names in this way. The built in functions in R are not careful about this — R has a long history and is not terribly consistent in how functions are named — but if you want to accidentally implement a function that works as a concrete implementation of a generic function, you shouldn’t do it.

If we call `push` on a vector stack, it will therefore be `push.vector_stack` that will be called instead of `push.default`.


```r
stack <- push(stack, 1)
stack <- push(stack, 2)
stack <- push(stack, 3)
stack
```

```
## [1] 1 2 3
## attr(,"class")
## [1] "vector_stack"
```

In the `push.vector_stack` we explicitly set the class of the concatenated new vector. If we didn’t do this, we would just be creating a vector — the stack-ness of the second argument to `c` does not carry on to the concatenated vector — and we wouldn’t return a stack. By setting the class of the new vector we make sure that we return a stack.

The class isn’t preserved when we remove the first element of the vector either, which is why we also have to explicitly set the class in the `pop.vector_stack` function. Otherwise we would only have a stack the first time we pop an element and after that it would just be a plain vector. By explicitly setting the class we make sure that the function returns a stack that we can use with the generic functions again.


```r
while (!is_empty(stack)) {
  stack <- pop(stack)
}
```

The remaining two functions, `top` and `is_empty` do not return a stack object, and they are not supposed to, so we don’t set the class attribute there.

We can avoid having to explicitly set the class attribute whenever we update it — that is, whenever we return a new value; we never actually modify an object here — by wrapping the class creation code in another function. Such a version could look like this:


```r
make_vector_stack <- function(elements) {
  structure(elements, class = "vector_stack")
}
empty_vector_stack <- function() {
  make_vector_stack(vector("numeric"))
}
top.vector_stack <- function(stack) stack[1]
pop.vector_stack <- function(stack) make_vector_stack(stack[-1])
push.vector_stack <- function(stack, element) make_vector_stack(c(element, stack))
is_empty.vector_stack <- function(stack) length(stack) == 0
```

We are of course still setting the class attribute when we create an updated stack, we are just doing so implicitly by translating a vector into a stack using `make_vector_stack`. That function uses the `structure` function to set the class attribute, but otherwise just represent the stack as a vector just like before.

## Polymorphism in action

The point of having generic functions is, of course, that we can have different implementations of the abstract operations. For the stack, we can try a different implementation. The vector version has the drawback that each time we return a modified stack we need to create a new vector, which means copying all the elements in the new vector from the old. This makes the operations linear time in the vector size. Using a linked list we can make them constant time operations. Such an implementation can look like this:


```r
make_list_node <- function(head, tail) {
  list(head = head, tail = tail)
}
make_list_stack <- function(elements) {
  structure(list(elements = elements), class = "list_stack")
}
empty_list_stack <- function() make_list_stack(NULL)
top.list_stack <- function(stack) stack$elements$head
pop.list_stack <- function(stack) make_list_stack(stack$elements$tail)
push.list_stack <- function(stack, element) {
  make_list_stack(make_list_node(element, stack$elements))
}
is_empty.list_stack <- function(stack) is.null(stack$elements)

stack <- empty_list_stack()
stack <- push(stack, 1)
stack <- push(stack, 2)
stack <- push(stack, 3)
stack
```

```
## $elements
## $elements$head
## [1] 3
## 
## $elements$tail
## $elements$tail$head
## [1] 2
## 
## $elements$tail$tail
## $elements$tail$tail$head
## [1] 1
## 
## $elements$tail$tail$tail
## NULL
## 
## 
## 
## 
## attr(,"class")
## [1] "list_stack"
```

Normally, when working with lists, we would use `NULL` as the base case to terminate a list. We cannot just wrap a list and use `NULL` this way when we need to associate a class with the element. You cannot set the class of `NULL`. So instead we wrap the actual list inside another list where we set the class attribute. The real data is in the `elements` of this list, but except for having to use this list element of the object we just work with the list representation as we normally would with linked lists.

We now have two different implementations of the stack interface, but — and this is the whole point of having generic functions — code that uses a stack does not need to know which implementation it is operating on, as long as it only access stacks through the generic interface.

We can see this in action in the small function below that reverses a sequence of elements by first pushing them all onto a stack and then pop’ing them off again.


```r
stack_reverse <- function(empty, elements) {
  stack <- empty
  for (element in elements) {
    stack <- push(stack, element)
  }
  result <- vector(class(top(stack)), length(elements))
  for (i in seq_along(result)) {
    result[i] <- top(stack)
    stack <- pop(stack)
  }
  result
}

stack_reverse(empty_vector_stack(), 1:5)
```

```
## [1] 5 4 3 2 1
```

```r
stack_reverse(empty_list_stack(), 1:5)
```

```
## [1] 5 4 3 2 1
```

Since the `stack_reverse` function only refers to the concrete stacks through the abstract interface we can give it either a vector stack or a list stack and it can do the same operations on both. As long as the concrete data structures all implement the abstract interface correctly then code that only uses the generic functions will be able to work on any implementation.

One single concrete implementation is rarely superior in all cases, so it makes sense that we are able to combine algorithms working on abstract data types with concrete implementations depending on the concrete problem we need to solve. For the two stack implementations they generally work equally well, but as discussed above, the stack implementation has a worst-case quadratic running time while the list implementation has a linear running time. For large stacks, we would thus expect the list implementation to be the best choice, but for small stacks there is more overhead in manipulating the list implementation the way we do — having to do with looking up variable names and linking lists and such — so for short stacks the vector implementation is faster.


```r
library(microbenchmark)
microbenchmark(stack_reverse(empty_vector_stack(), 1:10),
               stack_reverse(empty_list_stack(), 1:10))
```

```
## Unit: microseconds
##                                       expr
##  stack_reverse(empty_vector_stack(), 1:10)
##    stack_reverse(empty_list_stack(), 1:10)
##      min       lq     mean   median       uq
##  203.807 220.3595 249.1687 234.4750 258.8270
##  235.304 253.1885 279.5662 264.8585 279.7165
##       max neval cld
##   977.800   100  a 
##  1020.264   100   b
```

```r
microbenchmark(stack_reverse(empty_vector_stack(), 1:1000),
               stack_reverse(empty_list_stack(), 1:1000))
```

```
## Unit: milliseconds
##                                         expr
##  stack_reverse(empty_vector_stack(), 1:1000)
##    stack_reverse(empty_list_stack(), 1:1000)
##       min       lq     mean   median       uq
##  29.14557 32.76035 37.67371 34.30566 36.65295
##  23.94298 24.75708 26.74601 25.57205 26.72429
##        max neval cld
##  117.37179   100   b
##   93.35432   100  a
```

Plotting the time usage for various length of stacks makes it even more evident that, as the stack gets longer, the list implementation gets relatively faster.



![Time usage of reversal with two different stacks.](figure/performance_plot-1.png){#fig:performance_plot}

Only for very short stacks would the vector implementation be preferable — the quadratic versus linear running time kicks in for very small $n$ — but in general different implementations will be preferable for different usages, and by writing code that is polymorphic we make sure that we can change the implementation of a data structure without having to change the algorithms using it.

## Designing interfaces

It is not just generic functions that are polymorphic. Any function that manipulate data only through generic functions is also polymorphic. The reversal function we implemented using a stack takes the empty stack as an argument, and this empty stack determines which actual stack implementation we use. Nowhere in the function do we refer to any details of an actual implementation. If we had, instead, created an empty stack inside this function then, despite otherwise only accessing the implementation through the generic functions interface, the function would be bound to a single implementation.

To get the most out of polymorphism you will want to design your functions to be as polymorphic as possible. This requires two things:

1. Don’t refer to concrete implementations unless you really have to.
2. Any time you *do* have to refer to implementation details of a concrete type, do so through a generic function.

The reversal function is polymorphic because it doesn’t refer to any concrete implementation. The choice of which concrete stack to use is determined by a parameter, and the operations it does on the concrete stack all goes through generic functions.

It can be very tempting to break these rules in the heat of programming. Using a parameter to determine data structures in an algorithm isn’t that difficult to do, but if you are writing an algorithm that uses several different data structures you might not want to have all the different concrete implementations as parameters. You really aught to do it, though. Just write a function that wraps the algorithm and provides implementations if you don’t want to remember all the concrete data structures where the algorithm is needed. That way you get the best of both worlds.

More often, you will want to access the details of a concrete implementation. Imagine, for example, that you want to pop elements until you see a specific one, but *only* if that element is on the stack. If we are used to working with the vector implementation of the stack, then it would be natural to write a function like this:


```r
pop_until <- function(stack, element) {
  if (element %in% stack) {
    while (top(stack) != element) stack <- pop(stack)
  }
  stack
}

library(magrittr)
vector_stack <- empty_vector_stack() %>%
  push(1) %>%
  push(2) %>%
  push(3) %T>% print
```

```
## [1] 3 2 1
## attr(,"class")
## [1] "vector_stack"
```

```r
pop_until(vector_stack, 1)
```

```
## [1] 1
## attr(,"class")
## [1] "vector_stack"
```

```r
pop_until(vector_stack, 5)
```

```
## [1] 3 2 1
## attr(,"class")
## [1] "vector_stack"
```

Here we use the `%in%` function to test if the element is on the stack (and we use the `magrittr` pipe operator to create a stack for our test). This works fine, as long as the stack is a vector stack, but it will *not* work if the stack is implemented as a list. You won’t get an error message, the `%in%` test will just always return `FALSE`, so if you replace the stack implementation you have incorrect code that doesn’t even inform you that it isn’t working.

Relying on implementation details is the worst breakage of the interface to polymorphic objects that you can do. Not only do you tie yourself in to a single implementation, but you also tie yourself into exactly how that concrete data is implemented. If that implementation changes, your algorithm using it will break. So now you either can’t change the implementation or you will have to change the algorithm that uses when it does. If you are lucky, you might get an error message if you break the interface, but as in the case we just saw (and you can try it yourself if you don’t believe me), you won’t even get that. The function will just always return the original stack, even when the element you want to pop to is on it.

```r
list_stack <- empty_list_stack() %>%
  push(1) %>%
  push(2) %>%
  push(3)
pop_until(list_stack, 1)
```

If you write an algorithm that operates on a polymorphic object, stick to the interface it has if at all possible. For the `pop_until` function we can easily implement it using just the stack interface.


```r
pop_until <- function(stack, element) {
  s <- stack
  while (!is_empty(s) && top(s) != element) s <- pop(s)
  if (is_empty(s)) stack else s
}
```

If you cannot achieve what you need using the interface, you should instead extend it. You can always write new generic functions that work on a class.


```r
contains <- function(stack, element) UseMethod("contains")
contains.default <- function(stack, element) .NotYetImplemented()
contains.vector_stack <- function(stack, element) element %in% stack
```

You do not need to implement concrete functions for all implementations of an abstract data type to add a generic function. If you have a default implementation that gives you an error — and you have proper unit tests for any code you use — you will get an error if your algorithm attempts to use the function if it isn’t implemented yet, and you can add it at that point.

Adding new generic functions is not as ideal as using the original interface in the first place if the abstract data type is from another package, because that package might change the details of the implementation at which point your new generic function might break — and might break silently. Still, combined with proper unit tests, it is a much better solution than simply accessing the detailed implementation in your other functions.

Designing interfaces is a bit of an art. When you create your own abstract types you want to think carefully about which operations the type should have. You don’t want to have too many operations. That would make it harder for people implementing other versions of type; they would need to implement all the operations, and depending on what those operations are, this could involve a lot of work. On the other hand, you can’t have too few operations, because then algorithms using the type will often have to break the interface to get to implementation details, which will break the polymorphism of those algorithms.

The abstract data types you learn about in an algorithms class are good examples of minimal yet powerful interfaces. They define the minimal number of operations necessary to get useful work done, yet still make implementations of concrete stacks, queues, dictionaries, etc. possible with minimal work.

When designing your own types, try to achieve the same kind of minimal interfaces.

## The usefulness of polymorphism

Polymorphism isn’t only useful for what we would traditionally call abstract data structures. Polymorphism gives you the means to implement abstract data structures so algorithms work on the abstract interface and never need to know which concrete implementation they are operating on, but generic functions are useful for many cases that we do not traditionally think of as data structures.

In R, you often fit statistical models to data. Such models are not really data structures, but there is an abstract interface to them. You fit a concrete model, for example a linear model, but once you have a fitted model there are many common operations that are useful for all models. You might want to predict response variables for new data or you might want to get the residuals of your fitted values. These operations are the same for all models — although how different models implement the operations will be different — and so they can benefit from being generic. Indeed they are. The functions `predict` and `residuals`, which implements those two operations, are generic functions, and each model can implement its own version of them.

There is a long list of common functions that are frequently used on fitted models, and all of these are implemented as generics. If you write analysis code that operate on fitted models using only those generic functions, you can change the model at any time and reuse all the code without modifying it.

The same goes for printing and plotting functions. Both `print` and `plot` are generic functions and they have concrete implementations for different data types (and usually also for different fitted models). It is not something we think much about from day to day, but if we didn’t have generic functions like these we would need to use different functions for displaying vectors and for displaying matrices, for example.

Converting between different data types is also a common operation, and again polymorphism is highly useful (and frequently used in R). To translate a data structure into a vector, you use the `as.vector` function — an unfortunate name since it looks like a generic function `as` with a specialisation for `vector`, but actually is a generic function named `as.vector`. To translate a factor into a vector, it is the concrete implementation `as.vector.factor` that gets called.

An algorithm that needs to translate some input data into a vector can use the `as.vector` function and then doesn’t have to worry about what the actual data is implemented as. As long as the data type has an implementation of the `as.vector` function.

## Polymorphism and algorithmic programming

Polymorphism as a component of designing algorithms, and especially implementing algorithms, is not often covered in classes and text books, but can be an important aspect of writing reusable software. Take something as simple as a sorting function. For many sorting algorithms, all you need to be able to for sorting elements is to determine whether one element is smaller than another. If you hardwire in an implementation of such an algorithm that the comparison used is interfering or floating point comparison, then you can only sort objects of these types. In general, if you hardwire comparisons, you need a different implementation for each type of elements you want to sort.

Because of this, most languages provide you with a generic sorting function as part of their runtime library where you can provide the comparison functionality it should use, typically either as a function provided to the function or by allowing you to specify a comparison function for new types. Unfortunately, the `sort` function in R is not of this kind — it does allow you to define sorting for new types but it wants its input to be in atomic form, so you cannot give it sequences of complex data types. Usually, you can change your data to a matrix or such and sort it this way, but if you actually have a list of complex data, you cannot use it.

We can easily implement our own function for doing this, however, and we can call it `sort_list` — not to be confused with the builtin function `sort.list` that actually does something else than sort lists…

### Sorting lists

A straightforward implementation of merge sort could look like this:


```r
merge_lists <- function(x, y) {
  if (length(x) == 0) return(y)
  if (length(y) == 0) return(x)
  
  if (x[[1]] < y[[1]]) {
    c(x[1], merge_lists(x[-1], y))
  } else {
    c(y[1], merge_lists(x, y[-1]))
  }
}

sort_list <- function(x) {
  if (length(x) <= 1) return(x)
  
  start <- 1
  end <- length(x)
  middle <- end %/% 2
  
  merge_lists(sort_list(x[start:middle]), sort_list(x[(middle+1):end]))
}
```

It gets the job done, but the merge function is quadratic in running time since it copies lists when it subscripts like `x[-1]` and `y[-1]` and when it combines the results in the recursive calls. We can make a slightly more complicated function that does the merging in linear time using a iterative approach rather than a recursive:


```r
merge_lists <- function(x, y) {
  if (length(x) == 0) return(y)
  if (length(y) == 0) return(x)

  i <- j <- k <- 1
  n <- length(x) + length(y)
  result <- vector("list", length = n)  

  while (i <= length(x) && j <= length(y)) {
    if (x[[i]] < y[[j]]) {
      result[[k]] <- x[[i]]
      i <- i + 1
    } else {
      result[[k]] <- y[[j]]
      j <- j + 1
    }
    k <- k + 1
  }
  
  if (i > length(x)) {
    result[k:n] <- y[j:length(y)]
  } else {
    result[k:n] <- x[i:length(x)]
  }
  
  result
}
```

We are still copying in the recursive calls of the sorting function, but we are not copying more than we will merge later, so the asymptotic running time is okay at least.

With this function we can sort lists of elements where `` `<` `` can be used to determine if one element is less than another. The builtin `` `<` `` function, however, doesn’t necessarily work on your own classes.


```r
make_tuple <- function(x, y) {
  result <- c(x,y)
  class(result) <- "tuple"
  result
}

x <- list(make_tuple(1,2),
          make_tuple(1,1),
          make_tuple(2,0))
sort_list(x)
```

```
## Warning in if (x[[i]] < y[[j]]) {: the condition
## has length > 1 and only the first element will be
## used

## Warning in if (x[[i]] < y[[j]]) {: the condition
## has length > 1 and only the first element will be
## used

## Warning in if (x[[i]] < y[[j]]) {: the condition
## has length > 1 and only the first element will be
## used
```

```
## [[1]]
## [1] 1 1
## attr(,"class")
## [1] "tuple"
## 
## [[2]]
## [1] 1 2
## attr(,"class")
## [1] "tuple"
## 
## [[3]]
## [1] 2 0
## attr(,"class")
## [1] "tuple"
```

There are several ways we can fix this. One option is to define a generic function for comparison, we could call it `less`, and then use that in the merge function.


```r
merge_lists <- function(x, y) {
  if (length(x) == 0) return(y)
  if (length(y) == 0) return(x)
  
  i <- j <- k <- 1
  n <- length(x) + length(y)
  result <- vector("list", length = n)  
  
  while (i <= length(x) && j <= length(y)) {
    if (less(x[[i]], y[[j]])) {
      result[[k]] <- x[[i]]
      i <- i + 1
    } else {
      result[[k]] <- y[[j]]
      j <- j + 1
    }
    k <- k + 1
  }
  
  if (i > length(x)) {
    result[k:n] <- y[j:length(y)]
  } else {
    result[k:n] <- x[i:length(x)]
  }
  
  result
}

less <- function(x, y) UseMethod("less")
less.numeric <- function(x, y) x < y
less.tuple <- function(x, y) x[1] < y[1] || x[2] < y[2]

sort_list(x)
```

```
## [[1]]
## [1] 1 1
## attr(,"class")
## [1] "tuple"
## 
## [[2]]
## [1] 1 2
## attr(,"class")
## [1] "tuple"
## 
## [[3]]
## [1] 2 0
## attr(,"class")
## [1] "tuple"
```

We would need to define concrete implementations of `less` for all types we wish to short, though. Alternatively, we can tell R how to handle `` `<` `` for our own types, and we will see how to in a later chapter. With that approach, we will get sorting functionality for all objects that can be compared this way. A third possibility is to make `less` a parameter of the sorting function:


```r
merge_lists <- function(x, y, less) {
  # Same function body as before
}
```

```r
sort_list <- function(x, less = `<`) {
  
  if (length(x) <= 1) return(x)
  
  result <- vector("list", length = length(x))
  
  start <- 1
  end <- length(x)
  middle <- end %/% 2
  
  merge_lists(sort_list(x[start:middle], less), 
              sort_list(x[(middle+1):end], less), 
              less)
}

unlist(sort_list(as.list(sample(1:5))))
```

```
## [1] 1 2 3 4 5
```

```r
tuple_less <- function(x, y) x[1] < y[1] || x[2] < y[2]
sort_list(x, tuple_less)
```

```
## [[1]]
## [1] 1 1
## attr(,"class")
## [1] "tuple"
## 
## [[2]]
## [1] 1 2
## attr(,"class")
## [1] "tuple"
## 
## [[3]]
## [1] 2 0
## attr(,"class")
## [1] "tuple"
```

We make the default `less` function `` `<` `` but can provide another for types where this comparison function doesn’t work.

### General comments on flexible implementations of algorithms

As a general rule, you want to make your algorithm implementations adaptable by providing handles for polymorphism. Either by providing options for certain functions, like we did with `less` above, or by using generic functions for abstract data types.

You might be able to experiment to optimal data structures and implementation of operations when you implement an algorithm for a given use, but by providing handles for modifying your function you make the code more reusable. Even in cases where the algorithm will function correctly for different uses, you might still want to provide flexibility; the performance of algorithms often depend on on the usage. In asymptotic analysis we generally prefer implementations that have theoretical better running times, but in practise we want the fastest code and that is not necessarily the asymptotically fastest algorithms. We hide away constants when we use “big-O” analysis, but those constants matter, so you want users of your implementations to be able to replace data structures and operations used in your algorithm implementations.

Figuring out how to best provide this flexibility in your implementations often require some experimentation. For abstract data structures, generic functions are usually the best approach. For something like comparison in the sorting example above, all three solutions (generic functions, operator overloading, or providing a function with a good default) are probably equally good. But just like experimentation and some thinking is involved in designing good software interfaces, the same is needed in algorithmic programming.

## More on `UseMethod`

The `UseMethod` function is what we use to define a generic function, and it takes care of finding the appropriate concrete implementation using the name lookup we saw earlier. There are some details about `UseMethod` I left out before, though.

First of all, it doesn’t actually work as a function normally does. It looks like a function, and to a large degree it is a function, but if you treat it just as any other function you might get effects you didn’t expect.

First of all, you can pass local variables along to concrete implementations if you assign them before you call `UseMethod`. Let’s consider a simple case:


```r
foo <- function(object) UseMethod("foo")
foo.numeric <- function(object) object
foo(4)
```

```
## [1] 4
```

```r
bar <- function(object) {
  x <- 2
  UseMethod("bar")
}
bar.numeric <- function(object) x + object
bar(4)
```

```
## [1] 6
```

Here the `foo` function uses the pattern we saw earlier. It just calls `UseMethod`. We then define a concrete function to be called if `foo` is invoked on a number. Numbers have classes, and that class is `numeric`. (Technically, there is more to numbers than this class, but for now we don’t need to worry about that). Nothing strange is going on with `foo`.

With `bar`, however, we assign a local variable before we invoke `UseMethod`. This variable, `x`, is visible when `bar.numeric` is called. With a normal function call, you have to take steps to get access to the calling scope, so here `UseMethod` does not behave as a normal function.

In the call to `UseMethod` it doesn’t behave like a normal function either. You cannot use `UseMethod` as part of an expression.


```r
baz <- function(object) UseMethod("baz") + 2
baz.numeric <- function(object) object
baz(4)
```

```
## [1] 4
```

When `UseMethod` is invoked, the concrete function takes over completely, and the call to `UseMethod` never returns. Any expression you put `UseMethod` in is not evaluated because of this, and any code you might put after the `UseMethod` call is never evaluated.

`UseMethod` takes a second argument, besides the name of the generic function. This is the object that is used to dispatch the generic function on — the object whose type determines the concrete function that will be called — and this argument can be used if you do not want to dispatch based on the first argument of the function that calls `UseMethod`. Since dispatching on the type of the first function argument is such a common pattern, using another object in the call to `UseMethod` can cause confusion, and I recommend that you do not do this unless you have very good reasons for it.
