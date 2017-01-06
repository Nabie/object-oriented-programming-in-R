
A <- R6Class("A", public = list(x = 1:5))

B <- R6Class("B", public = list(a = A$new()))

x <- B$new()
y <- B$new()

x$a$x
x$a$x <- 1:3
x$a$x
y$a$x

B <- R6Class("B", 
             public = list(
               a = NULL,
               initialize = function() {
                 self$a <- A$new()
               }))

x <- B$new()
y <- B$new()

x$a$x
x$a$x <- 1:3
x$a$x
y$a$x

z <- x$clone()
z$a$x <- 1:5
x$a$x

x <- B$new()
y <- x$clone(deep = TRUE)

x$a$x
y$a$x
y$a$x <- NULL
y$a$x
x$a$x
