# Makefile for rdancer's exploit of the Vim 7.2b shellescape vulnerability

#
# Usage {{{1
#
# Some interesting targets:
#
#	(1) make sploit
#
#	    Compiles the exploit.
#
#	(2) make demo
#
#	    This is the default target.  Runs ``make sploit'', adds contents to
#	    the exploit tarball, and opens it in vim (thereby running the
#	    exploit)
#
#	(3) make test
#	
#	    Compile and run exploit non-interactively.

#
# Variables {{{1
#

# Be very verbose -- use for debugging
#VIM_OPTIONS := -V16

# This is the name of the file created by the exploit
PWN_FILE = "pwned"
EXPLOIT_NAME = exploit


#
# Targets {{{1
#

# test -- Run the exploit and report success (or absence thereof) upon exit {{{2
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +:'so kodkod.vim' +:'call Kodkod()' +:q
test: clean
	vim $(VIM_OPTIONS) -- $(EXPLOIT_NAME)
	if test -f $(PWN_FILE); then \
		echo "Exploit worked: we're pwned"; \
	else \
		echo "Exploit didn't work"; \
	fi

# clean -- Remove files we can make {{{2
.PHONY: clean
clean:
	rm -f  -- $(PWN_FILE)


#
# Modeline {{{1
#
# vim: foldmethod=marker :
