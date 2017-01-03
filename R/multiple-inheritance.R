
device <- function(name) {
  structure(list(name = name), class = "device")
}

format <- function(x) UseMethod("format")
format.device <- function(x) x$name

print.device <- function(x) {
  print(format(x))
}

printer <- function(name) {
  x <- device(name)
  class(x) <- c("printer", class(x))
  x
}

scanner <- function(name) {
  x <- device(name)
  class(x) <- c("scanner", class(x))
  x
}

format.printer <- function(x) paste("Printer:", NextMethod())
format.scanner <- function(x) paste("Scanner:", NextMethod())

printer("123-321")
scanner("456-654")

