
PANDOC := pandoc

PANDOC_OPTS_ALL :=  -S --toc \
					--chapters \
					--filter pandoc-fignos
PANDOC_EPUB_OPTS := $(PANDOC_OPTS_ALL) \
					--default-image-extension=png \
					-t epub3 --toc-depth=1 \
					--epub-cover-image=../cover.png

EPUB_CHAPTERS := $(foreach chapter,$(CHAPTERS),$(chapter))

book.epub: $(EPUB_CHAPTERS)
	$(PANDOC) $(PANDOC_EPUB_OPTS) -o $@ $(EPUB_CHAPTERS)


%.md: %.Rmd
	../runknitr.sh $<

%.Rmd :: ../chapters/%.md
	cat ../chapters/000_knitr_header.Rmd | gpp -DEPUB > $@
	cat $< | gpp -DEPUB >> $@
