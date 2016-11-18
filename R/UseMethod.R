


foo <- function(object) UseMethod("foo")
foo.numeric <- function(object) object
foo(4)

bar <- function(object) {
  x <- 2
  UseMethod("bar")
}
bar.numeric <- function(object) x + object
bar(4)

baz <- function(object) 2 + UseMethod("baz")
baz.numeric <- function(object) object
baz(4)
