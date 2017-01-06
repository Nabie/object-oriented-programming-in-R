
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

y <- modulus$new(value = 1:2, n = 3)
x + y


modulus2 <- R6Class("modulus2", inherit = modulus)
y <- modulus2$new(value = 1:2, n = 3)

x + y

class(y)



setOldClass("modulus")
setGeneric("f", def = function(e1,e2) standardGeneric("f"))
setMethod("f", signature = c("modulus", "modulus"),
          definition = function(e1, e2) {
            return("foo?")
            if (e1@n != e2@n) stop("Incompatible modulus")
            modulus(value = e1@value + e2@value,
                    n = e1@n)
          })

setMethod("+", signature = c("modulus", "modulus"),
          definition = function(e1, e2) {
            return("foo?")
            if (e1@n != e2@n) stop("Incompatible modulus")
            modulus(value = e1@value + e2@value,
                    n = e1@n)
          })

f(x, y)
x + y
