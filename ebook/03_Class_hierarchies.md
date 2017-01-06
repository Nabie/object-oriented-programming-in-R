

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



```r
methods(class = "vector_stack")
```

```
## [1] is_empty pop      push     top     
## see '?methods' for accessing help and source code
```

and check if you have everything implemented. You can also use this function to get a list of all classes that implement a given generic function



```r
methods("top")
```

```
## [1] top.default      top.list_stack  
## [3] top.vector_stack
## see '?methods' for accessing help and source code
```

### Another example: graphical objects

The “is-a” relationship underlying a class hierarchy is more flexible than just having abstract classes and implementations of such. It provides us with both a way of modelling that some objects really are of different but related classes and it provides us with a mechanism for thinking about interfaces as specialisations of other interfaces.

Let us consider, for an example, an application where we operate on some graphical object -- perhaps as part of a new visualisation package. The most basic class of this application is the *GraphicalObject* whose objects you can `draw`. Being able to draw objects is the most basic operation we need for graphical objects. Graphical objects also have a “bounding box” — a rectangle that tells us how large the shape is; something we might need when drawing objects.

This class is abstract, not just because we are defining and interface so we can have different implementations, like with did with the stack, but because it doesn’t really make sense to *have* a graphical interface at this abstract level. A concrete class that does make sense to have objects of is *Point* which is a graphical object representing a single point. Other classes could be *Circle* and *Rectangle*. 

For dealing with more than one graphical object, in an interface that makes that easy, we also have a class, *Composite*, that captures a collection of graphical objects. 

![Class hierarchy for graphical objects. The arrow from *Composite* to *GraphicalObject*, with a diamond starting point and an arrow endpoint, indicates that a *Composite* consists of a collection of *GraphicalObjects*.](figures/Shapes-class-hierarchy){#fig:shapes-hierarchy}

Treating a collection of objects as an object of the same class as its components is a so-called *design pattern* and it makes it easier to deal with complex figures in this application. We can group together graphical objects in a hierarchy — similar to how you would group objects in a drawing tool — and we would not need to explicitly check in our code if we are working on a single object or a collection of objects. A collection of objects is also a graphical object and we can just treat it as such.

Implementing this class hierarchy is fairly straight-forward. The abstract class *GraphicalObject* is not explicitly represented, but we need its methods as generic functions.


```r
draw <- function(object) UseMethod("draw")
bounding_box <- function(object) UseMethod("bounding_box")
```

When constructing graphical objects we need to set their class, and these could be the constructors for the concrete classes:


```r
point <- function(x, y) {
  object <- c(x, y)
  class(object) <- "point"
  names(object) <- c("x", "y")
  object
}

rectangle <- function(x1, y1, x2, y2) {
  object <- c(x1, y1, x2, y2)
  class(object) <- "rectangle"
  names(object) <- c("x1", "y1", "x2", "y2")
  object
}

circle <- function(x, y, r) {
  object <- c(x, y, r)
  class(object) <- "circle"
  names(object) <- c("x", "y", "r")
  object
}

composite <- function(...) {
  object <- list(...)
  class(object) <- "composite"
  object
}
```

We just represent the graphical objects as vectors, except for the composite that we represent as a list so it can contain different types of other graphical objects. The points are just vectors of coordinates, the rectangles are represented by two coordinates, the rectangle's lower left and upper right corners, and circles are represented by a center point and a radius.

For the `draw` methods we can just use basic graphics functions:


```r
draw.point <- function(object) {
  points(object["x"], object["y"])
}

draw.rectangle <- function(object) {
  rect(object["x1"], object["y1"], object["x2"], object["y2"])
}

draw.circle <- function(object) {
  plotrix::draw.circle(object["x"], object["y"], object["r"])
}

draw.composite <- function(object) {
  invisible(Map(draw, object))
}
```

except for the circles where we use the `draw.circle` function from the `plotrix` package for convenience. For the collection class we just call `draw` on all of a collection's components. We wrap the call to `Map` in `invisible` because we don't want the function call to print a list when we call it, but otherwise it is straightforward. 

With these functions we can construct plots of graphical elements, see +@fig:plotting-shapes-1.


```r
plot(c(0, 10), c(0, 10), 
     type = 'n', axes = FALSE, xlab = '', ylab = '')
draw(point(5,5))
draw(rectangle(2.5, 2.5, 7.5, 7.5))
draw(circle(5, 5, 4))

corners <- composite(point(2.5, 2.5), point(2.5, 7.5),
                     point(7.5, 2.5), point(7.5, 7.5))
draw(corners)
```

![Plot of graphical elements.](figure/plotting-shapes-1-1.png){#fig:plotting-shapes-1}

Here we have to set the size of the plot so it actually contains the elements we want to display there. Calculating what that area is, is what we have the `bounding_box` function for, and we can implement the different methods like this:


```r
bounding_box.point <- function(object) {
  c(object["x"], object["y"], object["x"], object["y"])
}

bounding_box.rectangle <- function(object) {
  c(object["x1"], object["y1"], object["x2"], object["y2"])
}

bounding_box.circle <- function(object) {
  c(object["x"] - object["r"], object["y"] - object["r"],
    object["x"] + object["r"], object["y"] + object["r"])
}

bounding_box.composite <- function(object) {
  if (length(object) == 0) return(c(NA, NA, NA, NA))
  
  bb <- bounding_box(object[[1]])
  x1 <- bb[1]
  y1 <- bb[2]
  x2 <- bb[3]
  y2 <- bb[4]
  
  for (element in object) {
    bb <- bounding_box(element)
    x1 <- min(x1, bb[1])
    y1 <- min(y1, bb[2])
    x2 <- max(x2, bb[3])
    y2 <- max(y2, bb[4])
  }
  
  c(x1, y1, x2, y2)
}
```

With that, we can collect all the graphical elements we wish to plot in a composite object and calculate the bounding box before we plot.

```r
all <- composite(
  point(5,5),
  rectangle(2.5, 2.5, 7.5, 7.5),
  circle(5, 5, 4),
  composite(point(2.5, 2.5), point(2.5, 7.5),
            point(7.5, 2.5), point(7.5, 7.5))
)
bb <- bounding_box(all)
plot(c(bb[1], bb[3]), c(bb[2], bb[4]),
     type = 'n', axes = FALSE, xlab = '', ylab = '')
draw(all)
```

## Class hierarchies as interfaces with refinements

In the examples so far, we have had an abstract class defining and interface and then different concrete classes implementing it. In the case of the stack, the different implementations gave us different time-complexity tradeoffs, but the different implementations were conceptually all just stacks; in the case of the graphical objects the different concrete classes were conceptually different objects, just objects that can all be treated as graphical objects and thus manipulated through the general interface. These are common patterns in software design, but when sub-classes, such as the different types of graphical objects, represent different conceptual classes, they often also extend the interface.

Take for instance statistical models. These are usually implemented as classes that implement a number of generic functions, such as `predict` or `coef`, that gives us a uniform interface to models and makes it possible to switch between different models in analysis without major rewrites of our analysis code. The generic functions implemented by all models gives us an interface for the most abstract kind of models — all models must implement `predict` and `coef`, for example, for us to be able to use them as drop-in replacements in our analysis code — but different types of models might add additional functionality to this interface that is not relevant for all models. We could, for example, imagine that decision trees add functionality for pruning trees, e.g. a function `prune`. If all decision tree implementations have a `prune` function, we can replace the implementation of decision trees and still reuse our code, but because `prune` is not implemented for all models we can only replace one implementation of a decision tree with another decision tree, not any kind of model. We would say that decision trees are specialisations of models. All decision trees are models but not all models are decision trees. In term of classes, we would have a super-class for models and a sub-class for decision trees that adds to the interface of models functions such as `prune`. If we have different implementations of decision trees, the decision tree class would typically also be abstract, and different implementations would inherit from this class rather than the more general model class, see +@fig:model-hierarchy.

![Hierarchy of models where decision trees are specialisations of the *Model* class that adds the `prune` function and gives us an additional abstract class that instances of decision trees must implement.](figures/Model-hierarchy){#fig:model-hierarchy}

As another example, we can consider a bibliography, which is essentially a list of publications. There are different kinds of publications but all have at least a name and one or more authors, so the most abstract way of representing publications would just have those two attributes. One thing we might want to do with a list of publications is to calculate bibliometrics such as how many citations a publication has. If each publication has a list of other works it cites, then we could calculate this from a database of all relevant publications. If we have a list of all publications a given author has created, we could also calculate how many citations this particular author has received or derived statistics such as the [h-index](https://en.wikipedia.org/wiki/H-index). 

There are different types of publications, so we can create sub-classes for e.g. books and articles. A book will have an associated publisher and an ISBN while journal articles will have associated a journal and (typically) the page-numbers in the journal where the article can be found. If we, for simplicity, only allow those two types of publications we can represent it as the class hierarchy shown in  +@fig:bibliography-hierarchy.

![Hierarchy of bibliography objects. The generic *Publication* class gives each publication a name and a list of authors and a list of other publications cited. Two concrete types of publications, *Article* and *Book*, adds extra attributes](figures/Bibliograph-hierarchy){#fig:bibliography-hierarchy}

In this hierarchy, all the functions simply access attributes of objects, that is, they just extract data that is stored in these. Accessing attributes via functions, as opposed to extracting them from lists or vectors or however objects are implemented, is generally a good idea. It allows you to change how you represent data without having to change any code besides the accessor function. If your code only accesses your objects through functions then you have encapsulated the implementation details and updating your code later will be much simpler than it would otherwise be.

Notice also that none of the accessor functions need to differ between the two concrete types of publications. The abstract *Publication* class accesses `name` and `authors` and the additional attributes provided in the other classes are disjunct. Because of this, there is no need to have generic functions for implementing this class hierarchy. We can do it using just plain old functions.

```r
# publication interface
publication <- function(name, authors, citations) {
  structure(list(name = name, authors = authors, 
                 citations = citations),
            class = "publication")
}
name <- function(pub) pub$name
authors <- function(pub) pub$authors

# articles
article <- function(name, authors, citations, journal, pages) {
  structure(list(name = name, authors = authors, 
                 citations = citations,
                 journal = journal, pages = pages),
            class = c("article", "publication"))
}
journal <- function(pub) pub$journal
pages <- function(pub) pub$pages

# book
book <- function(name, authors, citations, publisher, ISBN) {
  structure(list(name = name, authors = authors, 
                 citations = citations,
                 publisher = publisher, ISBN = ISBN),
            class = c("book", "publication"))
}
publisher <- function(pub) pub$publisher
ISBN <- function(pub) pub$ISBN
```

Generic functions are perfect for getting different behaviour for a given operation for different classes, but when we can get the behaviour we desire using plain old functions there is no reason to invoke the more complicated type of functions.

The implementation of publications is straightforward except when it comes to the `class` attributes set in the constructor functions. Here we set the classes to lists of class names instead of just the class names. This is how we specify that a `"book"` object or an `"article"` object is also a `"publication"` object. The design we have in mind requires that books and articles are publications, but since S3 classes are just names represented as strings, we cannot make this explicit in R. Instead we represent the class hierarchy by having the `class` attribute be lists of class names, going up the hierarchy from the most specialised to the most abstract object. How R interprets such a list of class names, and how it uses it to find the right implementations of generic functions, is the topic of the next chapter.

It is not uncommon to have a class hierarchy similar to the one we made here for publications, but there are some slight problems with it. To access book-specific attributes you need to know that the object you are working on is a book; treating publications in aggregates without having to write specialised code for dealing with books or articles is the purpose of using object-orientation and having the publication hierarchy to begin with. There is nothing wrong with having a class hierarchy where sub-classes add functions to the interface of their super-class, but if you find yourself writing such a hierarchy you should think carefully about how objects from the hierarchy should be accessed and manipulated.

It is generally best to put functions as high up in the hierarchy as it makes sense to do, thus insuring that as many classes from the hierarchy as possible will support them. With generic functions, the different sub-classes can implement the methods very differently, but all objects you manipulate will at least implement the methods you call them on. With the publication class hierarchy we have designed here, the only things we can really do if we want to write reusable code is to access names and authors and construct graphs of citations. The special attributes for books and articles are only available in a type-safe way if we explicitly check that we are accessing books and articles, respectively.

We would probably like code to format publications for making publication lists and such. Here we would need the information stored in books and articles, but since accessing these directly requires that we first test the class of the objects, the code would be a bit cumbersome and likely also error prone. Worse, if we added another publication type to the hierarchy, for example conference contributions, we would need to update all code that does this class checking and handle the different classes in different ways to handle this type as well. Avoiding this is exactly why we need generic functions, so the right design would be to have a generic function for formatting citations and specialise it for the sub-classes.

```r
format <- function(publ) UseMethod("format")

format.article <- function(publ) {
  paste(name(publ), authors(publ), 
        journal(publ), pages(publ), sep = ", ")
}

format.book <- function(publ) {
  paste(name(publ), authors(publ), 
        publisher(publ), ISBN(publ), sep = ", ")
}
```

and we could then use this `format` function in another generic function, `print`, for displaying publications:

```r
print.publication <- function(x, ...) print(format(x))
```

When we sub-class in order to extend an interface we add functions that only a subset of objects will support. Sometimes this is necessary, when there are operations that truly only make sense for some objects — like pruning decision trees, where pruning something like a linear model is not meaningful — but as a general rule, I would suggest that you keep specialisation like this to a minimum. It might feel like a good design to have a large hierarchy of more or less specialised classes, but when you have to work with objects from the hierarchy you want them to be as similar as you can get them so you can treat all of them using the same (generic) functions, so you will in general want to stick to the most abstract interface in any case. You might as well design your code with that in mind.

Being able to treat objects uniformly is also the reason we made a collection of graphical objects be a graphical object in itself. If we had not, then we would need to explicitly deal with collections of objects and write recursive functions to traverse them. By making the collection a class of graphical objects, we could hide this complexity in the generic functions. This is a very common trick and is called the [composite design pattern](https://en.wikipedia.org/wiki/Composite_pattern).
