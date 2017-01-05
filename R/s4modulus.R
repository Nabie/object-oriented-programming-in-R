
modulus <- setClass("modulus", 
                    slots = c(
                      value = "numeric",
                      n = "numeric"
                    ))

setMethod("show", signature = "modulus",
          definition = function(object) {
            cat("Modulus", object@n, "values:\n")
            print(object@value)
          })

(x <- modulus(value = 1:6, n = 3))

setMethod("+", signature = c("modulus", "modulus"),
          definition = function(e1, e2) {
            if (e1@n != e2@n) stop("Incompatible modulus")
            modulus(value = e1@value + e2@value,
                    n = e1@n)
          })
setMethod("+", signature = c("modulus", "numeric"),
          definition = function(e1, e2) {
            modulus(value = e1@value + e2,
                    n = e1@n)
          })
setMethod("+", signature = c("numeric", "modulus"),
          definition = function(e1, e2) {
            modulus(value = e1 + e2@value,
                    n = e2@n)
          })

x + 1:6
1:6 + x

y <- modulus(value = 1:6, n = 2)
#x + y

y <- modulus(value = 1:6, n = 3)
x + y

setMethod("Arith", 
          signature = c("modulus", "modulus"),
          definition = function(e1, e2) {
            if (e1@n != e2@n) stop("Incompatible modulus")
            modulus(value = callGeneric(e1@value, e2@value),
                    n = e1@n)
          })
setMethod("Arith", 
          signature = c("modulus", "numeric"),
          definition = function(e1, e2) {
            modulus(value = callGeneric(e1@value, e2),
                    n = e1@n)
          })
setMethod("Arith", 
          signature = c("numeric", "modulus"),
          definition = function(e1, e2) {
            modulus(value = callGeneric(e1, e2@value),
                    n = e2@n)
          })

x * y
2 * x
