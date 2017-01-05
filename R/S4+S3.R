
A <- function(x) {
  structure(list(x = x), class = "A")
}

setOldClass("A")
B <- setClass("B", contains = "A")
B <- setClass("B", contains = "A", slots = c(x = "ANY")) # error

setOldClass("A")
B <- setClass("B", contains = "A", slots = c(x = "ANY")) # fine

C <- setClass("C", contains = "A", slots = c(x = "ANY")) # error

setOldClass("A")
C <- setClass("C", contains = "A", slots = c(x = "ANY")) # error
