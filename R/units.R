
symbolic_unit <- function(nominator, denominator = "") {
  non_empty <- function(x) x != ""
  nominator <- sort(Filter(non_empty, nominator))
  denominator <- sort(Filter(non_empty, denominator))
  structure(list(nominator = nominator, denominator = denominator),
            class = "symbolic_unit")
}

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
  cat(as.character(x, ...), "\n")
}

(x <- symbolic_unit("m"))
(y <- symbolic_unit("m", "s"))

`==.symbolic_unit` <- function(x, y) {
  if (!(inherits(x, "symbolic_unit") && inherits(y, "symbolic_unit")))
      stop("Comparison only defined when both x and y are both symbolic_units")
  return(identical(x$nominator, y$nominator) && 
           identical(x$denominator, y$denominator))
}

`!=.symbolic_unit` <- function(x, y) !(x == y)

#x == y
x != y

`*.symbolic_unit` <- function(x, y) {
  symbolic_unit(c(x$nominator, y$nominator), c(x$denominator, y$denominator))
}

`/.symbolic_unit` <- function(x, y) {
  symbolic_unit(c(x$nominator, y$denominator), c(x$denominator, y$nominator))
}

x * y
x / y


units <- function(value, nominator, denominator = "") {
  attr(value, "units") <- symbolic_unit(nominator, denominator)
  class(value) <- c("units", class(value))
  value
}

print.units <- function(x, ...) {
  cat("Units: ", as.character(attr(x, "units")), "\n")
  # remove attributes to get plain numeric printing
  x <- unclass(x)
  attributes(x) <- NULL
  NextMethod()
}

(x <- units(1:6, "m"))


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

x + 2
x - 2

(y <- units(1:6, "m", "s"))
#x + y

(z <- units(1:6, "m"))
x + z

2 * x
x * y
x / y

#x == y
x == z
x & y
