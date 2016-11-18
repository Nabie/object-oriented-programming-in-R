
CHAPTERS := 000_header.md \
			01_Introduction.md \
			02_Classes_and_generic_functions.md \
			03_Class_hierarchies.md

SOURCE_CHAPTERS := $(foreach chapter,$(CHAPTERS),chapters/$(chapter))


book.pdf: $(SOURCE_CHAPTERS) Makefile
	(cd pdf_book && make CHAPTERS="$(CHAPTERS)")
	cp pdf_book/book.pdf book.pdf

book.epub:  $(SOURCE_CHAPTERS) Makefile
	(cd ebook && make CHAPTERS="$(CHAPTERS)")
	cp ebook/book.epub book.epub

book.mobi: book.epub
	./kindlegen book.epub -o book.mobi

all: book.pdf book.epub book.mobi

clean:
	rm book.pdf book.epub book.mobi

