# LaTeX Makefile v1.0 -- LaTeX + PDF figures

##==============================================================================
# CONFIGURATION
##==============================================================================
.PHONY = clean help images set-version
MAKEFLAGS := --jobs=4
SHELL  = /bin/bash

##==============================================================================
# DIRECTORIES
##==============================================================================
SCRIPTS = ./org-doc-scripts
IMG     = img
MDPI    = Definitions

##==============================================================================
# FILES
##==============================================================================
DOC_SRC         = main.tex
TARGET          = sa-pap.pdf
ALL             = $(shell find . -type f -name "*.org")
FIGURES_TEX     = $(wildcard $(IMG)/*tex)
FIGURES_EPS     = $(wildcard $(MDPI)/*eps)
EPS_TO_PDF      = $(patsubst %.eps, %-eps-converted-to.pdf, $(FIGURES_EPS))
FIGURES_PDF     = $(patsubst %.tex, %.pdf, $(FIGURES_TEX))

##==============================================================================
# RECIPES
##==============================================================================

##------------------------------------------------------------------------------
#
all: precheck images ## Build full thesis (LaTeX + figures)
	@command -v emacs && make emacs || echo "Emacs not installed... skipping"
	@printf "Generating $(TARGET)...\n"
	@bash -e $(SCRIPTS)/relative-path-bibtex $(DOC_SRC)
	@bash -e $(SCRIPTS)/build-pdf $(basename $(DOC_SRC)) $(TARGET)

##------------------------------------------------------------------------------
#
pipeline: precheck images ## Recipe to be ran when executed from a pipeline
	@printf "Stamping the document...\n"
	@make set-version
	@printf "Generating $(TARGET)...\n"
	@bash -e $(SCRIPTS)/relative-path-bibtex $(DOC_SRC)
	@bash -e $(SCRIPTS)/build-pdf $(basename $(DOC_SRC)) $(TARGET) | \
	grep "^!" -A20 --color=always || true

##------------------------------------------------------------------------------
#
emacs: images $(ALL)
	@emacs $(basename $(DOC_SRC)).org --script $(SCRIPTS)/emacs-build-doc.el

##------------------------------------------------------------------------------
#
images: $(FIGURES_PDF) $(EPS_TO_PDF) ## Generate all the images for the project

##------------------------------------------------------------------------------
# Resources:
# - https://stackoverflow.com/questions/15559359/insert-line-after-match-using-sed
#
set-version: ## Stamp the document with date and git commit hash
	@$(eval VERSION=$(shell git describe --tags))
	@grep "$(VERSION)" $(DOC_SRC) > /dev/null || \
	sed -i 's/\\today/\\today : $(VERSION)/' $(DOC_SRC)

##------------------------------------------------------------------------------
#
clean:	## Clean LaTeX and output figure files
	@rm -f $(FIGURES_PDF)
	@rm -f $(EPS_TO_PDF)
	@rm -f $(patsubst %.pdf, %.aux, $(FIGURES_PDF))
	@rm -f $(patsubst %.pdf, %.log, $(FIGURES_PDF))
	@rm -f $(TARGET)
	@latexmk -silent -C $(DOC_SRC)


##------------------------------------------------------------------------------
#
watch:	## Recompile on any update of LaTeX or SVG sources
	@while [ 1 ]; do                                                                          \
		printf "=========================  WATCHING =========================\r";         \
		find . -mmin 0.10 -type f \( -name \*.org -o -name \*.tex \) -exec make -j1 emacs \;; \
		sleep 5;                                                                          \
	done

##------------------------------------------------------------------------------
# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:  ## Auto-generated help menu
	@grep -P '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	sort |                                                \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

##==============================================================================
# HELPER RECIPES
##==============================================================================

##------------------------------------------------------------------------------
#
%.pdf: %.tex  ## Figures for the manuscript
	@printf "Generating %s...\033[K\r" "$@"
	@pdflatex -shell-escape -interaction=nonstopmode -output-directory $(IMG) "$<" | \
	grep "^!" -A20 --color=always || true

##------------------------------------------------------------------------------
#
precheck: ## Ensures all the required software is installed
	@$(SHELL) -e $(SCRIPTS)/check-packages
	@epspdf -v>/dev/null 2>&1 || epstopdf -v>/dev/null 2>&1 && \
	echo "EPS converter installed!" ||                       \
	(echo "Warning: no EPS converter installed"; exit 1)

##------------------------------------------------------------------------------
#
%-eps-converted-to.pdf: %.eps ## Convert eps file to PDF
	@printf "Generating %s...\033[K\r" "$@"
	@epspdf -v>/dev/null 2>&1 && epspdf $< || epstopdf $<
	mv $(basename $<).pdf $(basename $<)-eps-converted-to.pdf
