# Creating classes

Stack <- setClass("Stack")

# error, Stack is virtual 
#s <- Stack()

VectorStack <- setClass("VectorStack",
                        slots = c(
                          elements = "vector"
                        ),
                        contains = "Stack")

(vs <- VectorStack())
(vs <- VectorStack(elements = 1:4))
vs@elements

new("VectorStack", elements = 1:4)

# Make methods
setGeneric("top", def = function(stack) standardGeneric("top"))
setGeneric("pop", def = function(stack) standardGeneric("pop"))
setGeneric("push", def = function(stack, element) standardGeneric("push"))
setGeneric("is_empty", def = function(stack) standardGeneric("is_empty"))

# Define methods for subclass
setMethod("top", signature = "VectorStack",
          definition = function(stack) stack@elements[1])
setMethod("pop", signature = "VectorStack",
          definition = function(stack) {
            VectorStack(elements = stack@elements[-1])
          })
setMethod("push", signature = "VectorStack",
          definition = function(stack, element) {
            VectorStack(elements = c(element, stack@elements))
          })
setMethod("is_empty", signature = "VectorStack",
          definition = function(stack) length(stack@elements) == 0)

stack <- VectorStack()
stack <- push(stack, 1)
stack <- push(stack, 2)
stack <- push(stack, 3)
stack

while (!is_empty(stack)) {
  stack <- pop(stack)
}
stack


# requireMethods

ListStack <- setClass("ListStack", contains = "Stack")
stack <- ListStack()
pop(stack)

requireMethods(functions = c("top", "pop", "push", "is_empty"), 
               signature = "Stack")
stack <- ListStack()
pop(stack)




ListNode <- setClass("ListNode",
                     slots = c(
                       head = "NULL",
                       tail = "list"
                     ))

ListStack <- setClass("ListStack",
                      slots = c(
                        stack = "ListNode"
                      ),
                      contains = "Stack")

stack <- ListStack()
pop(stack)

requireMethods(functions = c("top", "pop", "push", "is_empty"), 
               signature = "Stack")

setMethod("top", signature = "VectorStack",
          definition = function(stack) stack@elements[1])
setMethod("pop", signature = "VectorStack",
          definition = function(stack) {
            VectorStack(elements = stack@elements[-1])
          })
setMethod("push", signature = "VectorStack",
          definition = function(stack, element) {
            VectorStack(elements = c(element, stack@elements))
          })
setMethod("is_empty", signature = "VectorStack",
          definition = function(stack) length(stack@elements) == 0)
