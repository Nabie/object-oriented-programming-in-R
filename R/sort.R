
merge_lists <- function(x, y) {
  if (length(x) == 0) return(y)
  if (length(y) == 0) return(x)
  
  if (x[[1]] < y[[1]]) {
    c(x[1], merge_lists(x[-1], y))
  } else {
    c(y[1], merge_lists(x, y[-1]))
  }
}

sort_list <- function(x) {
  if (length(x) <= 1) return(x)
  
  start <- 1
  end <- length(x)
  middle <- end %/% 2
  
  merge_lists(sort_list(x[start:middle]), sort_list(x[(middle+1):end]))
}

unlist(sort_list(as.list(1)))
unlist(sort_list(as.list(sample(1:2))))
unlist(sort_list(as.list(sample(1:3))))
unlist(sort_list(as.list(sample(1:4))))
unlist(sort_list(as.list(sample(1:5))))

merge_lists <- function(x, y) {
  if (length(x) == 0) return(y)
  if (length(y) == 0) return(x)

  i <- j <- k <- 1
  n <- length(x) + length(y)
  result <- vector("list", length = n)  

  while (i <= length(x) && j <= length(y)) {
    if (x[[i]] < y[[j]]) {
      result[[k]] <- x[[i]]
      i <- i + 1
    } else {
      result[[k]] <- y[[j]]
      j <- j + 1
    }
    k <- k + 1
  }
  
  if (i > length(x)) {
    result[k:n] <- y[j:length(y)]
  } else {
    result[k:n] <- x[i:length(x)]
  }
  
  result
}

unlist(sort_list(as.list(1)))
unlist(sort_list(as.list(sample(1:2))))
unlist(sort_list(as.list(sample(1:3))))
unlist(sort_list(as.list(sample(1:4))))
unlist(sort_list(as.list(sample(1:5))))

sort_list <- function(x) {

  if (length(x) <= 1) return(x)
  
  result <- vector("list", length = length(x))
  
  start <- 1
  end <- length(x)
  middle <- end %/% 2
  
  merge_lists(sort_list(x[start:middle]), sort_list(x[(middle+1):end]))
}


make_tuple <- function(x, y) {
  result <- c(x,y)
  class(result) <- "tuple"
  result
}

x <- list(make_tuple(1,2), make_tuple(1,1), make_tuple(2,0))
sort_list(x)


merge_lists <- function(x, y) {
  if (length(x) == 0) return(y)
  if (length(y) == 0) return(x)
  
  i <- j <- k <- 1
  n <- length(x) + length(y)
  result <- vector("list", length = n)  
  
  while (i <= length(x) && j <= length(y)) {
    if (less(x[[i]], y[[j]])) {
      result[[k]] <- x[[i]]
      i <- i + 1
    } else {
      result[[k]] <- y[[j]]
      j <- j + 1
    }
    k <- k + 1
  }
  
  if (i > length(x)) {
    result[k:n] <- y[j:length(y)]
  } else {
    result[k:n] <- x[i:length(x)]
  }
  
  result
}

less <- function(x, y) UseMethod("less")
less.numeric <- function(x, y) x < y
less.tuple <- function(x, y) x[1] < y[1] || x[2] < y[2]

sort_list(x)


merge_lists <- function(x, y, less) {
  if (length(x) == 0) return(y)
  if (length(y) == 0) return(x)
  
  i <- j <- k <- 1
  n <- length(x) + length(y)
  result <- vector("list", length = n)  
  
  while (i <= length(x) && j <= length(y)) {
    if (less(x[[i]], y[[j]])) {
      result[[k]] <- x[[i]]
      i <- i + 1
    } else {
      result[[k]] <- y[[j]]
      j <- j + 1
    }
    k <- k + 1
  }
  
  if (i > length(x)) {
    result[k:n] <- y[j:length(y)]
  } else {
    result[k:n] <- x[i:length(x)]
  }
  
  result
}

sort_list <- function(x, less = `<`) {
  
  if (length(x) <= 1) return(x)
  
  result <- vector("list", length = length(x))
  
  start <- 1
  end <- length(x)
  middle <- end %/% 2
  
  merge_lists(sort_list(x[start:middle], less), 
              sort_list(x[(middle+1):end], less), 
              less)
}

unlist(sort_list(as.list(sample(1:5))))

tuple_less <- function(x, y) x[1] < y[1] || x[2] < y[2]
sort_list(x, tuple_less)
