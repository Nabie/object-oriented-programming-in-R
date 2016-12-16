
draw <- function(object) UseMethod("draw")
bounding_box <- function(object) UseMethod("bounding_box")

point <- function(x, y) {
  object <- c(x, y)
  class(object) <- "point"
  names(object) <- c("x", "y")
  object
}

rectangle <- function(x1, y1, x2, y2) {
  object <- c(x1, y1, x2, y2)
  class(object) <- "rectangle"
  names(object) <- c("x1", "y1", "x2", "y2")
  object
}

circle <- function(x, y, r) {
  object <- c(x, y, r)
  class(object) <- "circle"
  names(object) <- c("x", "y", "r")
  object
}

composite <- function(...) {
  object <- list(...)
  class(object) <- "composite"
  object
}

draw.point <- function(object) {
  points(object["x"], object["y"])
}

draw.rectangle <- function(object) {
  rect(object["x1"], object["y1"], object["x2"], object["y2"])
}

draw.circle <- function(object) {
  plotrix::draw.circle(object["x"], object["y"], object["r"])
}

draw.composite <- function(object) {
  invisible(Map(draw, object))
}

plot(c(0, 10), c(0, 10), type = 'n', axes = FALSE, xlab = '', ylab = '')
draw(point(5,5))
draw(rectangle(2.5, 2.5, 7.5, 7.5))
draw(circle(5, 5, 4))

corners <- composite(point(2.5, 2.5), point(2.5, 7.5),
                     point(7.5, 2.5), point(7.5, 7.5))
draw(corners)

bounding_box.point <- function(object) {
  c(object["x"], object["y"], object["x"], object["y"])
}

bounding_box.rectangle <- function(object) {
  c(object["x1"], object["y1"], object["x2"], object["y2"])
}

bounding_box.circle <- function(object) {
  c(object["x"] - object["r"], object["y"] - object["r"],
    object["x"] + object["r"], object["y"] + object["r"])
}

bounding_box.composite <- function(object) {
  if (length(object) == 0) return(c(NA, NA, NA, NA))
  
  bb <- bounding_box(object[[1]])
  x1 <- bb[1]
  y1 <- bb[2]
  x2 <- bb[3]
  y2 <- bb[4]
  
  for (element in object) {
    bb <- bounding_box(element)
    x1 <- min(x1, bb[1])
    y1 <- min(y1, bb[2])
    x2 <- max(x2, bb[3])
    y2 <- max(y2, bb[4])
  }
  
  c(x1, y1, x2, y2)
}


all <- composite(
  point(5,5),
  rectangle(2.5, 2.5, 7.5, 7.5),
  circle(5, 5, 4),
  composite(point(2.5, 2.5), point(2.5, 7.5),
            point(7.5, 2.5), point(7.5, 7.5))
)
bb <- bounding_box(all)
plot(c(bb[1], bb[3]), c(bb[2], bb[4]),
     type = 'n', axes = FALSE, xlab = '', ylab = '')
draw(all)
