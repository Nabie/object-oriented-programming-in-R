
PANDOC := pandoc

PANDOC_OPTS_ALL :=  -S --toc \
					--chapters \
					--filter pandoc-fignos
PANDOC_PDF_OPTS := $(PANDOC_OPTS_ALL) \
					--default-image-extension=pdf \
					--variable links-as-notes \
					--template=../templates/latex-template.tex

PDF_CHAPTERS := $(foreach chapter,$(CHAPTERS),$(chapter))

book.pdf: $(PDF_CHAPTERS)
	$(PANDOC) $(PANDOC_PDF_OPTS) -o $@ $(PDF_CHAPTERS)

%.md: %.Rmd
	../runknitr.sh $<

%.Rmd :: ../chapters/%.md
	cat ../chapters/000_knitr_header.Rmd > $@
	cat $< | gpp -DPDF >> $@
