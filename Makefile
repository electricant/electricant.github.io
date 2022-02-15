#
# Makefile for http://www.autistici.org/electricant/
#

all: index.html ultimatema.html OS.html humans.txt niceness

all-pdf:
	##############################
	# FIXME: This does not work! #
	##############################
	@pdflatex index

%.html: tex/%.tex
	@htlatex $<
	@# Use the same css for all the webpages (upload just index.css)
	# NOTE: not unix friendly but on Linux works
	sed -i -e 's/href=".\+.css"/href="index.css"/g' $@

niceness:
	@echo Adding Niceness...
	@cat fonts_css.conf >> index.css

humans.txt:
	@echo Generating humans.txt...
	@echo "/* TEAM */" >humans.txt
	@echo Author: The Electric Ant >>humans.txt
	@echo Contact: electricant@anche.no >>humans.txt
	@echo From: the World >>humans.txt
	@echo "\n" >>humans.txt
	@echo "/* SITE */" >>humans.txt
	@echo Last update: $$(date -u --iso-8601) >>humans.txt
	@echo Software: LaTex, htlatex, vim, make >>humans.txt
	
clean:
	@rm -f *.html *.css *.out *.tmp *.aux *.lg *.log *.4ct *.4tc *.xref *.dvi *.idv *.toc humans.txt

prepare_upload:
	@mv index.css index
	@rm -f *.css *.out *.tmp *.aux *.lg *.log *.4ct *.4tc *.xref *.dvi *.idv *.toc
	@mv index index.css
