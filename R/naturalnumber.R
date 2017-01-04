
NaturalNumber <- setClass("NaturalNumber",
                          slots = c(
                            n = "integer"
                          ))

(n <- NaturalNumber())

NaturalNumber <- setClass("NaturalNumber",
                          slots = c(
                            n = "integer"
                          ),
                          prototype = list(
                            n = as.integer(0)
                          ))

(n <- NaturalNumber())

n@n <- 1.2
n@n <- as.integer(-1)

NaturalNumber <- setClass("NaturalNumber",
                          slots = c(
                            n = "integer"
                          ),
                          prototype = list(
                            n = as.integer(0)
                          ),
                          validity = function(object) {
                            object@n >= 0
                          })
n <- NaturalNumber(n = -1)

n <- NaturalNumber()
n@n <- as.integer(-1)
validObject(n)
