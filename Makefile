all:
	@sbcl --noinform --noprint --non-interactive --no-sysinit --no-userinit \
		--load make-website.lisp --eval '(make-website)'

clean:
	@rm docs/*.html docs/articles/*html
