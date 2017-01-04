# class hierarchy...
A <- setClass("A", contains = "NULL")
B <- setClass("B", contains = "A")
C <- setClass("C", contains = "B")

x <- A()
y <- B()
z <- C()

setGeneric("f", def = function(x) standardGeneric("f"))
setMethod("f", signature = "A", 
          definition = function(x) print("A::f"))

f(x)
f(y)
f(z)

setGeneric("g", def = function(x) standardGeneric("g"))
setMethod("g", signature = "A", definition = function(x) print("A::g"))
setMethod("g", signature = "B", definition = function(x) print("B::g"))

g(x)
g(y)
g(z)

setGeneric("h", def = function(x) standardGeneric("h"))
setMethod("h", signature = "A", definition = function(x) print("A::h"))
setMethod("h", signature = "B", definition = function(x) print("B::h"))
setMethod("h", signature = "C", definition = function(x) print("C::h"))

h(x)
h(y)
h(z)


setMethod("h", signature = "A", 
          definition = function(x) {
            print("A::h")
          })
setMethod("h", signature = "B", 
          definition = function(x) {
            print("B::h")
            callNextMethod()
          })
setMethod("h", signature = "C", 
          definition = function(x) {
            print("C::h")
            callNextMethod()
          })

h(x)
h(y)
h(z)

h <- function(x) print("default::h")
setGeneric("h")
setMethod("h", signature = "A", 
          definition = function(x) {
            print("A::h")
            callNextMethod()
          })
setMethod("h", signature = "B", 
          definition = function(x) {
            print("B::h")
            callNextMethod()
          })
setMethod("h", signature = "C", 
          definition = function(x) {
            print("C::h")
            callNextMethod()
          })

h(x)
h(y)
h(z)


# prototypes...

# validity...

# method signatures
