A <- setClass("A", slots = list(x = "numeric", y = "numeric"))
B <- setClass("B", contains = "A", slots = list(z = "numeric"))

setMethod("initialize", signature = "A",
          definition = function(.Object, x, y) {
            print("A initialize")
            .Object@x <- x
            .Object@y <- y
            .Object
          })

setMethod("initialize", signature = "B",
          definition = function(.Object, z) {
            .Object <- callNextMethod(.Object, x = z, y = z)
            .Object@z <- z
            .Object
          })

(a <- A(x = 1:3, y = 4:6))
(b <- B(z = 6:9))
