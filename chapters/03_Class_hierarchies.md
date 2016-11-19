# Class hierarchies

There is more to polymorphism than simply abstract data types that can have different concrete implementations. A key concept found in most object-oriented programming languages is classes and class hierarchies. Class hierarchies serve two conceptually different purposes: refinement of object interfaces and code reuse. Neither concept, strictly speaking, requires class hierarchies in R, since R is dynamically typed, unlike programming languages such as C++ or Java where class hierarchies and the static type system are intertwined. Nevertheless, class hierarchies provide a framework for thinking about software design that is immensely useful, also in dynamically typed languages.

We will go into details of the two concepts in the two following sections, but in short, interfaces describe which (generic) functions objects of a given class must implement, and hierarchies chain together interfaces in “more-abstract/more-refined” relationships based on these functions, while code-reuse, in this context, refers simply to writing functions that can operate on more than one class of objects — essentially just the type of polymorphic functions we saw in the previous chapter — and fitting such functions into class hierarchies as generic functions themselves.

## Interfaces and implementations

We can think of the *interface* of a class as the kinds of operations, or methods, we can apply to objects of the class. In R, this means which functions we can call with such objects as arguments in a meaningful way.

If we think in terms of abstract data structures, such as the stack from last chapter, these are defined by which operations they support. You can *push* and *pop* from a stack, check if it is *empty*, and you can get the *top* element; those functions, together with a way of creating a stack, define what “stack-ness” *is*. At least as long as those four functions also have the semantics we associate with a stack.

At an abstract level, we can describe the interface of a function by its formal arguments and its semantics. We can, for example, associate with a function *push* its two formal parameters, a stack and an element, and the semantics that it should return the stack but with the element added to the top. If we associate the *push* operation with these two attributes, the formal parameters and the semantics, we have what we could call an *abstract function*. As we saw, we can implement such abstract functions in different concrete ways, but a caller of these concrete functions need only worry about the abstract description to ensure correctness of functionality (although performance can of course also be a concern and not something we associated with the interface of an abstract function here).

With this definition of abstract functions, we can say that an abstract data type is defined by a set of abstract functions. If we call a set of abstract functions an *interface*, then an abstract data type is defined by an interface. We can implement an abstract data structure by writing an implementation for all the abstract functions in the interface. This we might call a (concrete) *implementation* of the interface, or something along those lines. We can reason about algorithms and design software just from knowing the interface of an abstract data type, and if we have different implementations of the interface to choose from, any of them could in theory be used.

Concepts such as interfaces and implementations are not just useful when it comes to abstract data structures. For any type of data you want to manipulate in a program, you could think up a set of meaningful operations you could do on that data, thus creating an interface for the type of data, and you could write functions for those operations in different ways to create different implementations.

### Polymorphism and interfaces

If we go back to thinking about interfaces, we can say that a class implements an interface if it implements all the abstract functions that make up the interface. This simply means that, if we take objects of this class, we have concrete functions we can call for each of the abstract functions in the interface. Without generic/polymorphic functions, however, we would need to know which concrete function maps to which abstract function for each class that implements a given interface. Exchanging one implementation of an interface with another would require a rewrite of the code that uses the implementation. So naturally, we would also require that the names of the concrete functions matches the names of the abstract functions.

This obviously maps directly to generic functions. If, whenever we think *abstract function*, we map that to a *generic function* — one that simply calls `UseMethod` — and whenever we think *concrete function* we think implementation of a generic function — a function with a “.” in its name — then we have an almost automatic way of mapping the concepts of interfaces and implementations into code.

Since R doesn’t do any static type checking, there is very little you can do to guarantee that a class you write this way actually implements a given interface. There is nothing in generic functions that explicitly binds them together as an interface, so for any class you decide to implement you can implement an arbitrary subset of generic functions. Interfaces and implementations are design concepts and you can map the design into R code very easily, but R does not enforce that your code matches your design.

### Abstract and concrete classes

We often unify interfaces and implementations as just classes, at least when designing software. The object-oriented way to think about software is this: every piece of data you manipulate is an *object* and all objects have a *class* that determine their behaviour. By behaviour we just mean which functions we can call on an object. This way of thinking makes a little more sense in languages where you can modify data and where objects thus have a state. Regardless, you can think of all data as objects with associated classes that determine what you can do with them.

A *class* thus encapsulates both what you can do with objects — the interface you have for them — but also how it is done — how the interface is implemented.

Objects have classes, and classes determine what you can do with objects, but classes live in hierarchies of more abstract or more derived classes. A vector-based implementation of a stack is a stack. It is a special *kind* of stack, sure, but it is still a stack. The general concept of what a stack *is* is more general than vector-based implementations, so the vector implementation can be thought of as a specialisation of a stack; one that is implemented using a vector.

We generally think about class hierarchies as part of “is-a” relationships. A vector implementation of a stack “is-a” stack. So is a list-based implementation. If you have an object of a more specialised class you should also be able to treat it as an object of a more abstract class. If you have a vector-stack you can treat it as a stack because its class is a vector stack class and that is a special case of the stack class.

The closest we get to interfaces and implementations is *abstract classes* and *concrete classes*. An abstract class is essentially exactly an interface. It is nothing more than a description of what you can do with objects of this class; there is no implementation associated with it. Concrete classes, on the other hand, have implementations for all the functions you can call on objects of the given class. Quite often, though, classes implement some but not all the functions their interface describes, so the distinction is not that clean in practise.

We often show classes and their relationships in diagrams as that shown in +@fig:stack-hierarchy. Here *Stack* is shown in cursive to indicate that it is an abstract class, below the class name is listed the methods you can call on the class, and errors from one class to another indicates that one class is derived from another. Here we see that vector and list stacks, here called *VectorStack* and *ListStack* are derived from *Stack*.

![Class hierarchy for stacks.](figures/Stack-class-hierarchy){#fig:stack-hierarchy}

The two concrete classes only implement the methods also listed in the abstract class, and because of this we won’t always list the methods again in the derived classes. It is to be understood that any method implemented in a more abstract class will also be implemented in more derived classes.

### Implementing abstract and concrete classes in R

We already saw, in the previous chapter, how the attribute `class` is used to determine which version of a generic function is called for a given object. This approach for dispatching generic functions is the S3 system’s way of implementing classes, but in some sense only handles concrete implementations of abstract functions. Having a generic method `foo`

```r
foo <- function(object) UseMethod("foo")
```

that we implement for a class `bar`

```r
foo.bar <- function(object) ...
```

only tells R how class `bar` implements the `foo` function. If `foo` is part of an interface that consists of several functions, it is not explicitly stated in the R code.

If we think of interfaces as a set of abstract functions, then considering these part of a whole is something we only do informally in R. Since abstract classes are nothing more than interfaces, we can do the same for abstract classes. When we implemented the vector-based stack in the previous chapter, we did so by setting the `class` attribute of the objects we returned from the constructor function `empty_vector_stack` to `vector_stack` and by implementing the four functions we considered part of the stack interface: `push`, `pop`, `top`, and `is_empty`. At no point did we specify that there existed some abstract stack class and that `vector_stack` is a specialisation of it.

Since the class mechanism implemented this way is essentially working on a per-function level — we have generic functions and implementations of these that are dispatched based on their name — classes and their relationships can be a very messy affair in R. You can alleviate this by thinking about your software design in a more structured way than the language requires. Design your software with classes in mind, implement abstract classes by defining a set of generic functions — you can use comments to group them together and to document that these constitute an interface — and make sure that when you define a concrete class implementing an interface that you don’t forget about any of the functions in the interface. You might not implement them all, sometimes there are good reasons to and sometimes you are just being pragmatic and not implementing something that might be difficult to implement but that you don’t need yet, but make sure that this is a conscious choice and that you haven’t simply forgotten a function.

You can use the function `methods` to get a list of all the methods implemented by a class

```{r, echo=FALSE}
top <- function(stack) UseMethod("top")
pop <- function(stack) UseMethod("pop")
push <- function(stack, element) UseMethod("push")
is_empty <- function(stack) UseMethod("is_empty")

top.default <- function(stack) .NotYetImplemented()
pop.default <- function(stack) .NotYetImplemented()
push.default <- function(stack, element) .NotYetImplemented()
is_empty.default <- function(stack) .NotYetImplemented()

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
```{r}
methods(class = "vector_stack")
```

and check if you have everything implemented. You can also use this function to get a list of all classes that implement a given generic function

```{r, echo=FALSE}
top.vector_stack <- function(stack) stack[1]
top.list_stack <- function(stack) stack$elements$head
```
```{r}
methods("top")
```

### Another example: graphical objects

The “is-a” relationship underlying a class hierarchy is more flexible than just having abstract classes and implementations of such. It provides us with both a way of modelling that some objects really are of different but related classes and it provides us with a mechanism for thinking about interfaces as specialisations of other interfaces.

Let us consider, for an example, an application where we operate on some graphical object -- perhaps as part of a new visualisation package. The most basic class of this application is the *GraphicalObject* whose objects you can `draw`. Being able to draw objects is the most basic operation we need for graphical objects. Graphical objects also have a “bounding box” — a rectangle that tells us how large the shape is; something we might need when drawing objects.

This class is abstract, not just because we are defining and interface so we can have different implementations, like with did with the stack, but because it doesn’t really make sense to *have* a graphical interface at this abstract level. A concrete class that does make sense to have objects of is *Point* which is a graphical object representing a single point. Other classes could be *Circle* and *Rectangle*. 

For dealing with more than one graphical object, in an interface that makes that easy, we also have a class, *Composite*, that captures a collection of graphical objects. 

**FIXME: PUT FIGURE HERE**

Treating a collection of objects as an object of the same class as its components is a so-called *design pattern* and it makes it easier to deal with complex figures in this application. We can group together graphical objects in a hierarchy — similar to how you would group objects in a drawing tool — and we would not need to explicitly check in our code if we are working on a single object or a collection of objects. A collection of objects is also a graphical object and we can just treat it as such.

Implementing this class hierarchy is fairly straight-forward. The abstract class *GraphicalObject* is not explicitly represented, but we need its methods as generic functions.

```{r}
draw <- function(object) UseMethod("draw")
bounding_box <- function(object) UseMethod("bounding_box")
```

When constructing graphical objects we need to set their class, and these could be the constructors for the concrete classes:

FIXME

For the `draw` methods we can just use basic graphics functions:

FIXME

with the collection objects just calling `draw` on its components.



### Classes as interfaces with refinements




## Hierarchies and implementation reuse

