# sbcl location and parameters
SBCL=sbcl --noinform --noprint --non-interactive --no-sysinit --no-userinit

all:
	$(SBCL) --load make-website.lisp --eval '(make-website)'

clean:
	@rm -f docs/*.html docs/articles/*html

demo:
	@$(SBCL) --load make-website.lisp --eval '(run-demo)'

