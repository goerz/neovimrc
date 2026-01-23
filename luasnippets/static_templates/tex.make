.PHONY: help all update clean distclean

.DEFAULT_GOAL := all

FILE = main

help:   ## Show this help
	@grep -E '^([a-zA-Z_-]+):.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "%-20s %s\n", $$1, $$2}'

all: ${FILE}.pdf  ## Compile all files

${FILE}.pdf: ${FILE}.tex
	pdflatex $(PDFLATEXOPTS) ${FILE}.tex

update: ## Run a single compilation pass
	pdflatex $(PDFLATEXOPTS) ${FILE}.tex


clean:  ## Remove generated files
	@echo "Cleaning up files from LaTeX compilation ..."
	@rm -f *.aux
	@rm -f *.log
	@rm -f *.toc
	@rm -f *.bbl
	@rm -f *.blg
	@rm -f *.nav
	@rm -f *.snm
	@rm -rf *.out
	@rm -rf .cache
	@rm -f *.bak
	@rm -f *.ilg
	@rm -f *.synctex.gz
	@rm -f *.preview.pdf
	@rm -f *.gnuplot
	@rm -f *.table
	@rm -f a0header.ps
	@rm -f *.fls
	@rm -f *~
	@rm -f *Notes.bib
	@rm -f *-eps-converted-to.pdf
	@rm -f *.fdb_latexmk
	@rm -f *.synctex.gz*
	@rm -f .latexrun.db*
	@echo "Done"

distclean: clean  ## Restore clean repository state
	@rm -f $(FILE).pdf
