
top <- function(stack) UseMethod("top")
pop <- function(stack) UseMethod("pop")
push <- function(stack, element) UseMethod("push")
is_empty <- function(stack) UseMethod("is_empty")

top.default <- function(stack) .NotYetImplemented()
pop.default <- function(stack) .NotYetImplemented()
push.default <- function(stack, element) .NotYetImplemented()
is_empty.default <- function(stack) .NotYetImplemented()


make_vector_stack <- function(elements) {
  structure(elements, class = "vector_stack")
}
empty_vector_stack <- function() {
  make_vector_stack(vector("numeric"))
}
top.vector_stack <- function(stack) stack[1]
pop.vector_stack <- function(stack) make_vector_stack(stack[-1])
push.vector_stack <- function(stack, element) make_vector_stack(c(element, stack))
is_empty.vector_stack <- function(stack) length(stack) == 0

stack <- empty_vector_stack()
stack <- push(stack, 1)
stack <- push(stack, 2)
stack <- push(stack, 3)
stack

while (!is_empty(stack)) {
  stack <- pop(stack)
}


make_list_node <- function(head, tail) {
  structure(list(head = head, tail = tail))
}
make_list_stack <- function(elements) {
  structure(list(elements = elements), class = "list_stack")
}
empty_list_stack <- function() make_list_stack(NULL)
top.list_stack <- function(stack) stack$elements$head
pop.list_stack <- function(stack) make_list_stack(stack$elements$tail)
push.list_stack <- function(stack, element) {
  make_list_stack(make_list_node(element, stack$elements))
}
is_empty.list_stack <- function(stack) is.null(stack$elements)


stack <- empty_list_stack()
stack <- push(stack, 1)
stack <- push(stack, 2)
stack <- push(stack, 3)
stack

while (!is_empty(stack)) {
  stack <- pop(stack)
}

stack_reverse <- function(empty, elements) {
  stack <- empty
  for (element in elements) {
    stack <- push(stack, element)
  }
  result <- vector(class(top(stack)), length(elements))
  for (i in seq_along(result)) {
    result[i] <- top(stack)
    stack <- pop(stack)
  }
  result
}

#stack_reverse(empty_vector_stack(), 1:5)
#stack_reverse(empty_list_stack(), 1:5)

library(microbenchmark)

library(tibble)
get_time <- function(empty, n) 
  microbenchmark(stack_reverse(empty, 1:n))$time
#time_stacks <- function(n) {
#  rbind(tibble(Implementation = "Vector", n = n, 
#               Time = get_time(empty_vector_stack(), n)),
#        tibble(Implementation = "List", n = n, 
#               Time = get_time(empty_list_stack(), n)))
  
#}
#times <- do.call(rbind, 
#                 lapply(seq(100, 5000, length.out = 10), 
#                        time_stacks))

#library(ggplot2)
#ggplot(times) + 
#  geom_boxplot(aes(x = as.factor(n), y = Time, fill = Implementation))



pop_until <- function(stack, element) {
  if (element %in% stack) {
    while (top(stack) != element) stack <- pop(stack)
  }
  stack
}

library(magrittr)
vector_stack <- empty_vector_stack() %>% push(1) %>% push(2) %>% push(3) %T>% print
pop_until(vector_stack, 1)
pop_until(vector_stack, 5)

list_stack <- empty_list_stack() %>% push(1) %>% push(2) %>% push(3) %T>% print
pop_until(list_stack, 1)

pop_until <- function(stack, element) {
  s <- stack
  while (!is_empty(s) && top(s) != element) s <- pop(s)
  if (is_empty(s)) stack else s
}
vector_stack <- empty_vector_stack() %>% push(1) %>% push(2) %>% push(3) %T>% print
pop_until(vector_stack, 1)
pop_until(vector_stack, 5)

list_stack <- empty_list_stack() %>% push(1) %>% push(2) %>% push(3) %T>% print
pop_until(list_stack, 1)

contains <- function(stack, element) UseMethod("contains")
contains.default <- function(stack, element) .NotYetImplemented()
contains.vector_stack <- function(stack, element) element %in% stack

pop_until <- function(stack, element) {
  if (contains(stack, element)) {
    while (top(stack) != element) stack <- pop(stack)
  }
  stack
}


vector_stack <- empty_vector_stack() %>% push(1) %>% push(2) %>% push(3) %T>% print
pop_until(vector_stack, 1)
pop_until(vector_stack, 5)
