
library(R6)

VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         top = function() {
                           private$elements[1]
                         },
                         pop = function() {
                           private$elements <- private$elements[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements <- c(e, private$elements)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements) == 0
                         }
                       ))

(stack <- VectorStack$new())

VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         top = function() {
                           private$elements[1]
                         },
                         pop = function() {
                           private$elements <- private$elements[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements <- c(e, private$elements)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements) == 0
                         },
                         print = function() {
                           cat("Stack elements:\n")
                           print(private$elements)
                         }
                       ))

(stack <- VectorStack$new())
stack$push(1)$push(2)$push(3)
stack

while (!stack$is_empty()) stack$pop()
stack

#(stack <- VectorStack$new(elements = 1:4))

VectorStack <- R6Class("VectorStack",
                       private = list(elements = NULL),
                       public = list(
                         initialize = function(elements = NULL) {
                           private$elements <- elements
                         },
                         top = function() {
                           private$elements[1]
                         },
                         pop = function() {
                           private$elements <- private$elements[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements <- c(e, private$elements)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements) == 0
                         },
                         print = function() {
                           cat("Stack elements:\n")
                           print(private$elements)
                         }
                       ))


(stack <- VectorStack$new(elements = 1:4))

stack$elements
list()$elements

VectorStack <- R6Class("VectorStack",
                       private = list(elements_ = NULL),
                       public = list(
                         initialize = function(elements = NULL) {
                           private$elements_ <- elements
                         },
                         top = function() {
                           private$elements_[1]
                         },
                         pop = function() {
                           private$elements_ <- private$elements_[-1]
                           invisible(self)
                         },
                         push = function(e) {
                           private$elements_ <- c(e, private$elements_)
                           invisible(self)
                         },
                         is_empty = function() {
                           length(private$elements_) == 0
                         },
                         print = function() {
                           cat("Stack elements:\n")
                           print(private$elements_)
                         }
                       ),
                       active = list(
                         elements = function(value) {
                           if (!missing(value)) stop("elements are read-only")
                           private$elements_
                         }
                       ))

(stack <- VectorStack$new(elements = 1:4))
stack$elements

stack$elements <- rev(1:3)


B <- R6Class("A")
B$new()

A <- R6Class("A", public = list(x = 5), private = list(y = 13))

a <- A$new()
a$x
a$x <- 7
a$x

a$y
a$y <- 12
a$y

stack$pop <- function() "foo?"
stack$pop()


