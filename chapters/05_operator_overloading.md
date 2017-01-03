# Operator overloading

Overloading operators, that is, giving operators such as plus or minus new or additional functionality, is not inherently object-oriented, but since it can be thought of as adding polymorphism to functions it fits in naturally here, after we have gone through polymorphism through generic functions.

Opinions vary in whether overloading operators is good or bad practise. Some languages allow it, others do not; some languages allow you to make your own infix operators but not change existing once, and some languages are just inconsistent in allowing some operator overloading for built-in objects but not for user-defined. One argument against overloading is the expected behaviour of operators. It is so ingrained in us to expect `+` to mean addition that we cannot handle if it also means string concatenation. This argument, of course, ignores that we have no problem with using `+` for both integer and floating point addition. Another, and in my opinion more valid, argument is that it is harder to remember what an operator does than what a function does, since the function name at least gives us some hint as to the function's function. The truth is that infix operators, when used carefully, can give us a more convenient syntax than simple function calls. You probably find `2 * x + 5` easier to read than `plus(times(2, x), 5)`, and most programming languages, with Lisp dialects a noticeable except, prefer the former to the latter. The same goes for user-defined or user-overloaded operators. Using `magrittr`'s pipe operator, `%>%`, makes analysis workflows much easier to read, and `ggplot2`'s overloading of `+` makes plotting code much easier to read.

Since, in R, you can both overload existing operators and create your own, you have to choose which is most appropriate for any given situation. My rule of thumb is to prefer creating new infix operators unless it feels natural to use an existing one. That is, of course, a terribly subjective evaluating, but some operations just feels like "addition" — I would say combining operations in `ggplot2` can be justified as such — while others don't — like pipeline operations in `magritte`. It is a judgment call, and you can always experiment with your code to see what comes naturally.

In this chapter we will see how we can overload operators. I will not cover how you create infix operators. If you are interested, I cover it in my *Functional Programming in R* book.

## Functions and operators

Every operation in R involves a function call. Control structures, subscripting, even parenthesis involve functions, and, naturally, operators involve function calls as well. This means that operators can be overridden. You can replace one implementation of `+` with another just by defining a new version of `+`. But you really shouldn't. Replacing the built-in operators with user-defined will affect all your code, seriously slow it down, and is very likely to introduce hard-to-find bugs. You don't have to do this to define operators for your own classes, though. The operators are generic and you can define specialised version of them, defining how operators should handle new classes you define.

To illustrate how this is done, we define a class for arithmetic modulus some number `n`. Here I assume that `value` is some numeric type -- in production code we would write tests for this, but in the example we just implicitly assume this -- and we use an attribute to store the number `n`. We then compute the value modulus `n`, set the class, and return the result.

```{r}
modulus <- function(value, n) {
  result <- value %% n
  attr(result, "modulus") <- n
  class(result) <- c("modulus", class(value))
  result
}
```

To pretty-print values of the class we define the `print` method. We want to print values, `x`, using the underlying type but with a line above giving us `n`. If we just call `print(x)` we would recurse back to `print.modulus` since that is the type of `x`, but we can use the function `unclass` to get rid of the type of `x`. It doesn't completely get rid of the type, though. If `x` is a numeric type, `unclass` just reduce `x` to that. When we print primitive values with attributes the attributes are printed as well, so we get rid of all attributes before we print the reduced `x`. Here we could directly call `print(x)` but `NextMethod()` works as well, so that is what I have used here.

```{r}
print.modulus <- function(x, ...) {
  cat("Modulus", attr(x, "modulus"), "values:\\n")
  # remove attributes to get plain numeric printing
  x <- unclass(x)
  attributes(x) <- NULL
  NextMethod()
}

(x <- modulus(1:6, 3))
```

### Defining single operators 

We can define what addition means for this type by defining the function `` `+.modulus` ``:

```{r}
`+.modulus` <- function(x, y) {
  n <- attr(x, "modulus")
  x <- unclass(x)
  y <- unclass(y)
  modulus(x + y, n)
}
```

We first get `n` from `x`. Then we remove the class information from the two operands so we can call the primitive `+` to calculate their sum -- if we didn't do this we would again recurse when we tried to add `x` to `y` -- and we then simply calculate the result and use the `modulus` constructor to return it with the right type.

Dispatch of such operator functions work a little different from the generic functions we have seen earlier. There, the dispatch is based on the type of the first argument, at least unless you explicitly state otherwise, but for operators the dispatch is based on the type of both operands. If both have a class that implements an operator they must have the same class. If only one of them have a class, and here primitive classes such as `"numeric"` or `"integer"` do not count, then the dispatch is based on that. So if `x` is of type `"modulus"` then both `x + 1:6` and `1:6 + x` will call `` `+.modulus` ``.

```{r}
x + 1:6
1:6 + x
```

The first expression does what we expect, but the second does not. This is not because the dispatch is not working but because we got `n` from the first operand only. Since we are only guaranteed that *one* of the two operands have type `"modulus"` we need to check both. We can do this simply by checking if the attribute `"modulus"` is `NULL` or not:

```{r}
`+.modulus` <- function(x, y) {
  n <- ifelse(!is.null(attr(x, "modulus")),
              attr(x, "modulus"), attr(y, "modulus"))
  x <- unclass(x)
  y <- unclass(y)
  modulus(x + y, n)
}

x + 1:6
1:6 + x
```

Depending on which semantic we want addition of these types to have, we might not want to allow addition of types with different `n`. If we add such types now, the `n` is taken from the first operand.

```{r}
y <- modulus(1:6, 2)
x + y
```

With a little more check we ensure that the two operands are compatible:

```{r}
`+.modulus` <- function(x, y) {
  nx <- attr(x, "modulus")
  ny <- attr(y, "modulus")
  if (!is.null(nx) && !is.null(ny) && nx != ny)
    stop("Incompatible types")
  n <- ifelse(!is.null(nx), nx, ny)

  x <- unclass(x)
  y <- unclass(y)
  modulus(x + y, n)
}

x + y
y <- modulus(rev(1:6), 3)
x + y
```

### Group operators

Using generic functions, we can define all relevant operators for a user-defined type, but it is also possible to handle all operators in a single function, `Ops`. This function is called a "group generic method" because it handles a group of generic functions; other group methods are `Math`, `Complex`, and `Summary`, which we will not cover here.

If we define the function `Ops.modulus` it will be called for all operators of `modulus` objects where the operator function is not defined. That is, if we have defined `` `+.modulus` `` as above, that function will be preferred over `Ops.modulus`, but otherwise, if one or both of the operands are of type `modulus`, then `Ops.modulus` will be called.

We can define it like this:

```{r}
Ops.modulus <- function(e1, e2) {
  nx <- attr(e1, "modulus")
  ny <- attr(e2, "modulus")
  if (!is.null(nx) && !is.null(ny) && nx != ny)
    stop("Incompatible types")
  n <- ifelse(!is.null(nx), nx, ny)
  
  result <- unclass(NextMethod()) %% n
  modulus(result, n)
}
```

The testing at the beginning of the function is the same as for `` `+.modulus` ``. After the testing we use `NextMethod` to call the operation using the underlying type. This strips the `modulus` class from the operands and evaluate whatever operation we are currently handling. We unclass the result, necessary because the result will inherit the attributes of the operands of `Ops` so if we don't the result will have class `modulus`, and we then compute modulus `n`. If we didn't `unclass`, this would be a recursive call, but since we do remove the class we just do modulus in the underlying type. We finally create a `modulus` object of the result.

With this function defined we get all binary operators in one go.

```{r}
y <- modulus(rev(1:6), 3)
x - y
x * y
```

This includes comparison operators as well:

```{r}
x == y
x == x
x != y
x != x
```

It even includes unary operators. If we use a unary minus, however, the argument `e2` will be missing in the function call, which we do not handle correctly right now.

```{r}
- x
```

We can easily fix this, however, byt checking if `e2` is missing. Otherwise, the function will work as it is.

```{r}
Ops.modulus <- function(e1, e2) {
  nx <- attr(e1, "modulus")
  ny <- if (!missing(e2)) attr(e2, "modulus") else NULL
  if (!is.null(nx) && !is.null(ny) && nx != ny)
    stop("Incompatible types")
  n <- ifelse(!is.null(nx), nx, ny)
  
  result <- unclass(NextMethod()) %% n
  modulus(result, n)
}

- x
```


## Units example

For a slightly more involved example, we define a class for associating physical units with values. This will allow us to check that units we manipulate are compatible -- so we do not subtract meters from seconds and such -- and will do unit analysis as part of arithmetic operations. The example is a simplified version of the package [units](https://github.com/edzer/units). The `units` package also hands unit conversion and unit simplification. Here we just implement a simple arithmetic of symbolic units and simple equality check of them.

The idea is to have a representation of physical units and then associate these to numeric values. Physical units, here, refers to units like square kilometres, metres per second, etc. In general, these will be symbolic expressions, but we will only consider the slightly simpler situation where the units are a fraction of physical constants. In that case, we can represent these as a list of terms in the nominator and a list of terms in the denominator. If we always keep these lists sorted we have a canonical representation of them and we can check equality of two units by checking equality of the nominator and denominator lists. We can implement the constructor like this:

```{r}
symbolic_unit <- function(nominator, denominator = "") {
  non_empty <- function(x) x != ""
  nominator <- sort(Filter(non_empty, nominator))
  denominator <- sort(Filter(non_empty, denominator))
  structure(list(nominator = nominator, denominator = denominator),
            class = "symbolic_unit")
}
```

We can translate these units into a string representation of the fraction for pretty-printing.

```{r}
as.character.symbolic_unit <- function(x, ...) {
  format_terms <- function(terms, op) {
    if (length(terms) == 0) return("1")
    paste0(terms, collapse = op)
  }
  nominator <- format_terms(x$nominator, "*")
  denominator <- format_terms(x$denominator, "/")
  paste(nominator, "/", denominator)
}

print.symbolic_unit <- function(x, ...) {
  cat(as.character(x, ...), "\\n")
}

(x <- symbolic_unit("m"))
(y <- symbolic_unit("m", "s"))
```

Comparing two symbolic units involves checking that nominator and denominator are equal.

```{r}
`==.symbolic_unit` <- function(x, y) {
  if (!(inherits(x, "symbolic_unit") && inherits(y, "symbolic_unit")))
      stop("Comparison only defined when both x and y are both symbolic_units")
  return(identical(x$nominator, y$nominator) && 
           identical(x$denominator, y$denominator))
}

`!=.symbolic_unit` <- function(x, y) !(x == y)

x == y
x != y
```

Adding and subtracting physical quantities is only possible if they have the same units, but it is always possible to multiple and divide units. The resulting unit is then obtained by doing the same operation on the (symbolic) units as you do on the quantities. To be able to handle this, we define multiplication and division on symbolic units. 

```{r}
`*.symbolic_unit` <- function(x, y) {
  symbolic_unit(c(x$nominator, y$nominator), 
                c(x$denominator, y$denominator))
}

`/.symbolic_unit` <- function(x, y) {
  symbolic_unit(c(x$nominator, y$denominator), 
                c(x$denominator, y$nominator))
}

x * y
x / y
```

We now have everything in place to represent units. We just need to define the class for associating units with quantities. This class is very similar to the `modulus` class we wrote earlier. We take a (numeric) value, associate a symbolic unit in an attribute, and set the class.

```{r}
units <- function(value, nominator, denominator = "") {
  attr(value, "units") <- symbolic_unit(nominator, denominator)
  class(value) <- c("units", class(value))
  value
}
```

Pretty-printing follows the pattern we saw with `modulus`. We need to strip the class and attributes in order to use the underlying print method, called through `NextMethod`, but that is all there is to it.

```{r}
print.units <- function(x, ...) {
  cat("Units: ", as.character(attr(x, "units")), "\\n")
  # remove attributes to get plain numeric printing
  x <- unclass(x)
  attributes(x) <- NULL
  NextMethod()
}

(x <- units(1:6, "m"))
```

Handling operators for `units` is only slightly more involved than it was for `modulus`. We need to distinguish between operators where we require that the units match and those where we need to construct new units. The former are those are addition, subtraction, and comparisons, assuming we only want to consider numbers equal if they agree in both quantity and associated units, the latter are multiplication and division where the resulting units must be computed from the operands. It is not obvious how to handle logical operators on physical quantities, if that is something that even make sense, so for operators that do not fall into these two categories we should just default to what the underlying type does.

We implement the operators using the `Ops` group function. Inside this function we can get hold of the actual operator being evaluated using the variable `.Generic`. This is not a parameter of the function but it will be set to the operator being evaluated when the function is called and we can check the operator and handle it appropriately by switching on it.

```{r}
Ops.units <- function(e1, e2) {
  su1 <- attr(e1, "units")
  su2 <- if (!missing(e2)) attr(e2, "units") else NULL
  
  if (.Generic %in% c("+", "-", "==", "!=", "<", "<=", ">=", ">")) {
    if (!is.null(su1) && !is.null(su2) && su1 != su2)
      stop("Incompatible units")
    su <- ifelse(!is.null(su1), su1, su2)
    return(NextMethod())
  }

  if (.Generic == "*" || .Generic == "/") {
    if (is.null(su1))
      su1 <- symbolic_unit("")
    if (is.null(su2))
      su2 <- symbolic_unit("")
    su <- switch(.Generic, "*" = su1 * su2, "/" = su1 / su2)
    result <- NextMethod()
    attr(result, "units") <- su
    return(result)
  }
  
  # For the remaining operators we don't really have a good
  # way of treating the units so we strip that info and go back
  # to numeric values
  e1 <- unclass(e1)
  e2 <- unclass(e2)
  attributes(e1) <- attributes(e2) <- NULL
  NextMethod()
}
```

With this definition of the units operators we can combine units with scalars:

```{r}
2 * x
x + 2
x - 2
```

If we attempt to add two quantities with incompatible types we will be warned that this is incorrect

```{r}
(y <- units(1:6, "m", "s"))
x + y
```

but when the units are compatible we can add and subtract

```{r}
(z <- units(1:6, "m"))
x + z
x - z
```

Multiplication and division is always permissible and the resulting units are derived from the operands.

```{r}
2 * x
x * y
x / y
```

