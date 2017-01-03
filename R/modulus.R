
modulus <- function(value, n) {
  result <- value %% n
  attr(result, "modulus") <- n
  class(result) <- c("modulus", class(value))
  result
}

print.modulus <- function(x, ...) {
  cat("Modulus", attr(x, "modulus"), "values:\n")
  # remove attributes to get plain numeric printing
  x <- unclass(x)
  attributes(x) <- NULL
  NextMethod()
}

(x <- modulus(1:6, 3))

`+.modulus` <- function(x, y) {
  n <- attr(x, "modulus")
  x <- unclass(x)
  y <- unclass(y)
  modulus(x + y, n)
}

x + 1:6
1:6 + x

`+.modulus` <- function(x, y) {
  n <- ifelse(!is.null(attr(x, "modulus")),
              attr(x, "modulus"), attr(y, "modulus"))
  x <- unclass(x)
  y <- unclass(y)
  modulus(x + y, n)
}

x + 1:6
1:6 + x

y <- modulus(1:6, 2)
x + y

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

Ops.modulus <- function(e1, e2) {
  nx <- attr(e1, "modulus")
  ny <- attr(e2, "modulus")
  if (!is.null(nx) && !is.null(ny) && nx != ny)
    stop("Incompatible types")
  n <- ifelse(!is.null(nx), nx, ny)
  
  result <- NextMethod() %% n
  modulus(result, n)
}

y <- modulus(rev(1:6), 3)

x - y
x * y

- x

Ops.modulus <- function(e1, e2) {
  nx <- attr(e1, "modulus")
  ny <- if (!missing(e2)) attr(e2, "modulus") else NULL
  if (!is.null(nx) && !is.null(ny) && nx != ny)
    stop("Incompatible types")
  n <- ifelse(!is.null(nx), nx, ny)
  
  result <- NextMethod() %% n
  modulus(result, n)
}

- x



Ops.modulus <- function(e1, e2) {
  nx <- attr(e1, "modulus")
  ny <- attr(e2, "modulus")
  if (!is.null(nx) && !is.null(ny) && nx != ny)
    stop("Incompatible types")
  n <- ifelse(!is.null(nx), nx, ny)
  
  result <- NextMethod() %% n
  modulus(result, n)
}

y <- x <- modulus(1:6, 3)
x * 1:6
1:6 * x
