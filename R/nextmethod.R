
A <- function() {
  structure(list(), class = "A")
}

B <- function() {
  this <- A()
  class(this) <- c("B", class(this))
  this
}

C <- function() {
  this <- B()
  class(this) <- c("C", class(this))
  this
}

x <- A()
y <- B()
z <- C()

class(x)
class(y)

f <- function(x) UseMethod("f")
f.default <- function(x) print("f.default")

f(x)
f(y)
f(z)

g <- function(x) UseMethod("g")
g.default <- function(x) print("g.default")
g.A <- function(x) print("g.A")

g(x)
g(y)
g(z)

h <- function(x) UseMethod("h")
h.default <- function(x) print("h.default")
h.A <- function(x) print("h.A")
h.B <- function(x) print("h.B")

h(x)
h(y)
h(z)

i <- function(x) UseMethod("i")
i.default <- function(x) print("i.default")
i.A <- function(x) print("i.A")
i.B <- function(x) print("i.B")
i.C <- function(x) print("i.C")

i(x)
i(y)
i(z)


g <- function(x) UseMethod("g")
g.default <- function(x) print("g.default")
g.A <- function(x) {
  print("g.A")
  NextMethod()
}

g(x)
g(y)
g(z)

i <- function(x) UseMethod("i")
i.default <- function(x) print("i.default")
i.A <- function(x) {
  print("i.A")
  NextMethod()
}
i.B <- function(x) {
  print("i.B")
  NextMethod()
}
i.C <- function(x) {
  print("i.C")
  NextMethod()
}

i(x)
i(y)
i(z)

j <- function(x) UseMethod("j")
j.default <- function(x) print("j.default")
j.A <- function(x) {
  print("j.A")
  NextMethod()
}
j.C <- function(x) {
  print("j.C")
  NextMethod()
}

j(x)
j(y)
j(z)

class(z) <- rev(class(z))
i(z)
