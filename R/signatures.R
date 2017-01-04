
setGeneric("f", def = function(x, y) standardGeneric("f"))
setMethod("f", signature = c("numeric", "numeric"),
          definition = function(x, y) x + y)
setMethod("f", signature = c("logical", "logical"),
          definition = function(x, y) x & y)

f(2, 3)
f(TRUE, FALSE)

setMethod("f", signature = "character",
          definition = function(x, y) x)

f("foo", "bar")
