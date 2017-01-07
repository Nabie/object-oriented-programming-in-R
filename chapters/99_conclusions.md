# Conclusions

This concludes this book on object-oriented programming in R. You now know the three different systems for object-oriented programming in R and how to use them to define class hierarchies and polymorphic functions.

Object-oriented programming in R, at least for the S3 and S4 system, differs from most other object-oriented programming languages. Most languages consider objects mutable, and most object-oriented software designs involve wiring up objects with references to each other such that their behaviour depend on the changing states of other objects. The R6 system is closer to this type of language design. Still, the S3 and S4 systems combine two powerful programming language paradigms: functional programming and object-oriented programming. The combination of dynamic function dispatch based on the argument types and high-level functional programming lets you construct flexible and extensible software.

It can be confusing with three very different systems for object-oriented programming in the same language, and I would recommend that you stick to one for any single project. Knowing all three, however, and knowing the pros and cons of using them lets you pick the right tool for any particular job. The S3 system is the simplest of the three and good for getting a small model up and running in very little time. The more formal classes of S4 makes it easier to structure more complex frameworks, and the reference semantics of R6 makes it easier to implement classical mutable data structures than you can otherwise easily do in R.

Getting familiar with these systems, of course, requires practise and you will not be an expert object-oriented programming just from reading this book. You know enough now, though, to get started.

This ends the book. I hope it has been useful in learning object-oriented programming as understood by the R programming language.
