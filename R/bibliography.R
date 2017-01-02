
# publication interface
publication <- function(name, authors, citations) {
  structure(list(name = name, authors = authors, citations = citations),
            class = "publication")
}
name <- function(pub) pub$name
authors <- function(pub) pub$authors

# articles
article <- function(name, authors, citations, journal, pages) {
  structure(list(name = name, authors = authors, citations = citations,
                 journal = journal, pages = pages),
            class = c("article", "publication"))
}
journal <- function(pub) pub$journal
pages <- function(pub) pub$pages

# book
book <- function(name, authors, citations, publisher, ISBN) {
  structure(list(name = name, authors = authors, citations = citations,
                 publisher = publisher, ISBN = ISBN),
            class = c("book", "publication"))
}
publisher <- function(pub) pub$publisher
ISBN <- function(pub) pub$ISBN

format <- function(publ) UseMethod("format")

format.article <- function(publ) {
  paste(name(publ), authors(publ), journal(publ), pages(publ), sep = ", ")
}

format.book <- function(publ) {
  paste(name(publ), authors(publ), publisher(publ), ISBN(publ), sep = ", ")
}

print.publication <- function(publ) print(format(publ))

this_book <- book("Object-oriented Programming in R", "Thomas Mailund", NULL,
                  "Thomas Mailund", "NONE")

print(this_book)