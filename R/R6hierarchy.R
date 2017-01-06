
A <- R6Class("A",
             public = list(
               f = function() print("A::f"),
               g = function() print("A::g"),
               h = function() print("A::h")
             ))
B <- R6Class("B", inherit = A,
             public = list(
               g = function() print("B::g"),
               h = function() print("B::h")
             ))
C <- R6Class("C", inherit = B,
             public = list(
               h = function() print("C::h")
             ))

x <- A$new()
y <- B$new()
z <- C$new()

x$f()
y$f()
z$f()

x$g()
y$g()
z$g()

x$h()
y$h()
z$h()
