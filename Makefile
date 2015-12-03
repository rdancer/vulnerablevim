# NOTE: Reusing the TEMP_FILE after removing it is insecure (multiple
# foo.tar.bz2 targets, i.e. ``make all'').  The ``-u'' option is even worse. --
# But do we really care?
TEMP_FILE := $(shell mktemp -u ./XXXXXXXXX)
TARCAT = ./util/tarcat
SUBDIRS = gzip_vim filetype.vim filetype.vim.updated tarplugin tarplugin.updated tarplugin.v2 zipplugin zipplugin.v2 netrw netrw.v2 netrw.v3 netrw.v4 netrw.v5 xpm.vim shellescape
# Lame name!
BACKUPDIR = backups
VIM_VERSION = $(shell vim --version | sed -n '1s/[^0-9]*\([^ ]*\).*/Vim version \1/p;2s/Included/, included/p' | tr -d '\n'; echo )
ZIPVIM_VERSION = $(shell make -sC zipplugin zipvim_version_print )
FILETYPEVIM_VERSION = $(shell make -sC filetype.vim.updated filetypevim_version_print )
NETRW_VERSION = $(shell make -sC netrw.v5 plugin_version_print )

# Author's email address
MY_EMAIL = rdancer@rdancer.org

.PHONY: dist
dist: vulnerablevim.tar.bz2


# test_vim_version -- Print vim version
.PHONY: test_vim_version
test_vim_version:
	printf '%s\n' "$(VIM_VERSION)"

# Send a hash of the distributed files to be signed by the stamper service -- thereby proving we are indeed the authors of said
.PHONY: stamper
stamper: dist
	mkdir -p $(BACKUPDIR)
	timestamped="vulnerablevim-`date -Iseconds|tr -d :`.tar.bz2"; \
	: XXX We should really create the file in a safe manner; \
	test -e $(BACKUPDIR)/"$$timestamped" && exit 1; \
	cp vulnerablevim.tar.bz2 $(BACKUPDIR)/"$$timestamped"; \
	( cd $(BACKUPDIR); openssl sha1 "$$timestamped" ) \
		| mail -r $(MY_EMAIL) -s "$$timestamped hash" -c $(MY_EMAIL) \
				clear@stamper.itconsult.co.uk

.PHONY: test
test:
	# TODO: Should be split amongst the individual Makefiles in the individual
	# subdirectories
	: Magic numbers in the inline comments are corresponding advisory
	: sections.
	\
	results=-------------------------------------------; \
	results="`printf '%s\n%s' "$$results" "-------- Test results below ---------------"`"; \
	results="`printf '%s\n%s' "$$results" "-------------------------------------------"`"; \
	: Version info; \
	results="`printf '%s\n%s' "$$results" "$(VIM_VERSION)"`"; \
	results="`printf '%s\n%s' "$$results" "filetype.vim revision date: $(FILETYPEVIM_VERSION)"`"; \
	results="`printf '%s\n%s' "$$results" "zip.vim version: $(ZIPVIM_VERSION)"`"; \
	results="`printf '%s\n%s' "$$results" "netrw.vim version: $(NETRW_VERSION)"`"; \
	\
	results="`printf '%s\n%s' "$$results" "-------------------------------------------"`"; \
	\
	: 3.4.2.2. filetype.vim; \
	dir=filetype.vim; \
	results="`printf '%s\n%s' "$$results" "$$dir"`"; \
	for EXPLOIT_FLAVOUR in strong weak; do \
	        make -sC $$dir test; \
		test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
		make -sC $$dir clean; \
		results="`printf '%s\n  %-8s: %s' "$$results" "$$EXPLOIT_FLAVOUR" "$$status"`"; \
	done; \
	\
	: 3.4.2.2. filetype.vim "updated"; \
	dir=filetype.vim.updated; \
	results="`printf '%s\n%s' "$$results" "$$dir"`"; \
	for EXPLOIT_FLAVOUR in strong weak; do \
	        make -sC $$dir test; \
		test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
		make -sC $$dir clean; \
		results="`printf '%s\n  %-8s: %s' "$$results" "$$EXPLOIT_FLAVOUR" "$$status"`"; \
	done; \
	: Note: the remote exploit does not test reliably -- disabling; \
	: make -sC $$dir test-remote; \
	: test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	: make -sC $$dir clean; \
	: results="`printf '%s\n  %-8s: %s' "$$results" "remote" "$$status"`"; \
	\
	: 3.4.2.3. tar.vim; \
	dir=tarplugin; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY tar.vim "updated"; \
	dir=tarplugin.updated; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY tar.vim version 2; \
	dir=tarplugin.v2; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: 3.4.2.4. zip.vim; \
	dir=zipplugin; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY zip.vim version 2; \
	dir=zipplugin.v2; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: 3.4.2.5. xpm.vim and xpm2.vim; \
	dir=xpm.vim; \
	results="`printf '%s\n%s' "$$results" "$$dir"`"; \
	for EXPLOIT_FLAVOUR in xpm xpm2; do \
	        make -sC $$dir test; \
		test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
		make -sC $$dir clean; \
		results="`printf '%s\n  %-8s: %s' "$$results" "$$EXPLOIT_FLAVOUR" "$$status"`"; \
	done; \
	\
	: 3.4.2.5.3. Remote exploit; \
	make -sC $$dir test-remote; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n  %-8s: %s' "$$results" "remote" "$$status"`"; \
	\
	: 3.4.2.6. gzip.vim; \
	dir=gzip_vim; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: 3.4.2.7. Netrw; \
	dir=netrw; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY Netrw version 2; \
	dir=netrw.v2; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY Netrw version 3; \
	dir=netrw.v3; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY Netrw version 4; \
	dir=netrw.v4; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY Netrw version 5; \
	dir=netrw.v5; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	: NOT IN ORIGINAL ADVISORY shellescape; \
	dir=shellescape; \
	make -sC $$dir test; \
	test -e $$dir/pwned && status=VULNERABLE || status='EXPLOIT FAILED'; \
	make -sC $$dir clean; \
	results="`printf '%s\n%-10s: %s' "$$results" "$$dir" "$$status"`"; \
	\
	echo "$$results"


.PHONY: all
all:
	for target in $(SUBDIRS); do \
		make $$target; \
	done

.PHONY: cleanlocal
cleanlocal:
	for a in $(SUBDIRS); do \
		for timestamped in $$a-*.tar.bz2; do \
			if test -e $$timestamped; then \
				mv -f $$timestamped old; \
			fi; \
		done; \
		if test -e $$a.tar.bz2 || test -L $$a.tar.bz2; then \
			rm -f $$a.tar.bz2; \
		fi; \
	done

.PHONY: clean
clean:
	for a in $(SUBDIRS); do \
		make -C $$a clean; \
	done

vulnerablevim.tar.bz2: all advisory
	# bits_and_pieces are not a separate target, because we'll unlink it
	# before this target is finished
	tar cjf bits_and_pieces.tar.bz2 Makefile advisory README licenses \
			util Changelog patch
	$(TARCAT) bits_and_pieces.tar.bz2 \
			`for a in $(SUBDIRS); do echo $$a.tar.bz2; done`\
			> vulnerablevim.tar.bz2
	rm -f bits_and_pieces.tar.bz2

.PHONY: filetype.vim.updated.tar.bz2
.PHONY: filetype.vim.updated
filetype.vim.updated: filetype.vim.updated.tar.bz2
filetype.vim.updated.tar.bz2:
	make -C filetype.vim.updated clean
	ln -sf "filetype.vim.updated-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) filetype.vim.updated
	if diff filetype.vim.updated.tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) filetype.vim.updated.tar.bz2 ;\
	fi

.PHONY: filetype.vim.tar.bz2
.PHONY: filetype.vim
filetype.vim: filetype.vim.tar.bz2
filetype.vim.tar.bz2:
	make -C filetype.vim clean
	ln -sf "filetype.vim-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) filetype.vim
	if diff filetype.vim.tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) filetype.vim.tar.bz2 ;\
	fi

.PHONY: tarplugin.updated.tar.bz2
.PHONY: tarplugin.updated
tarplugin.updated: tarplugin.updated.tar.bz2
tarplugin.updated.tar.bz2:
	make -C tarplugin.updated clean
	ln -sf "tarplugin.updated-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) tarplugin.updated
	if diff tarplugin.updated.tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) tarplugin.updated.tar.bz2 ;\
	fi

.PHONY: tarplugin.tar.bz2
.PHONY: tarplugin
tarplugin: tarplugin.tar.bz2
tarplugin.tar.bz2:
	make -C tarplugin clean
	ln -sf "tarplugin-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) tarplugin
	if diff tarplugin.tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) tarplugin.tar.bz2 ;\
	fi

.PHONY: tarplugin.v2.tar.bz2
.PHONY: tarplugin.v2
tarplugin.v2: tarplugin.v2.tar.bz2
tarplugin.v2.tar.bz2:
	make -C tarplugin.v2 clean
	ln -sf "tarplugin.v2-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) tarplugin.v2
	if diff tarplugin.v2.tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) tarplugin.v2.tar.bz2 ;\
	fi

.PHONY: zipplugin.tar.bz2
.PHONY: zipplugin
zipplugin: zipplugin.tar.bz2
zipplugin.tar.bz2:
	make -C zipplugin clean
	ln -sf "zipplugin-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) zipplugin
	if diff zipplugin.tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) zipplugin.tar.bz2 ;\
	fi

.PHONY: zipplugin.v2.tar.bz2
.PHONY: zipplugin.v2
zipplugin.v2: zipplugin.v2.tar.bz2
zipplugin.v2.tar.bz2:
	make -C zipplugin.v2 clean
	ln -sf "zipplugin.v2-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) zipplugin.v2
	if diff zipplugin.v2.tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) zipplugin.v2.tar.bz2 ;\
	fi

.PHONY: doit
doit:
	make -C $(BASE) clean
	ln -sf $(BASE)"-`date -Iseconds|tr -d :`.tar.bz2" $(TEMP_FILE)
	tar cjf $(TEMP_FILE) $(BASE)
	if diff $(BASE).tar.bz2 $(TEMP_FILE) >/dev/null 2>&1; then \
		rm -f "`readlink $(TEMP_FILE)`" $(TEMP_FILE) ;\
	else \
		mv $(TEMP_FILE) $(BASE).tar.bz2 ;\
	fi

.PHONY: xpm.vim.tar.bz2
.PHONY: xpm.vim
xpm.vim.tar.bz2: xpm.vim
xpm.vim: BASE = xpm.vim
xpm.vim:
	env BASE=$(BASE) make doit

.PHONY: gzip_vim.tar.bz2
.PHONY: gzip_vim
gzip_vim.tar.bz2: gzip_vim
gzip_vim: BASE = gzip_vim
gzip_vim: 
	env BASE=$(BASE) make doit

.PHONY: netrw.tar.bz2
.PHONY: netrw
netrw.tar.bz2: netrw
netrw: BASE = netrw
netrw: 
	env BASE=$(BASE) make doit

.PHONY: netrw.v2.tar.bz2
.PHONY: netrw.v2
netrw.v2.tar.bz2: netrw.v2
netrw.v2: BASE = netrw.v2
netrw.v2: 
	env BASE=$(BASE) make doit

.PHONY: netrw.v3.tar.bz2
.PHONY: netrw.v3
netrw.v3.tar.bz2: netrw.v3
netrw.v3: BASE = netrw.v3
netrw.v3: 
	env BASE=$(BASE) make doit

.PHONY: netrw.v4.tar.bz2
.PHONY: netrw.v4
netrw.v4.tar.bz2: netrw.v4
netrw.v4: BASE = netrw.v4
netrw.v4: 
	env BASE=$(BASE) make doit

.PHONY: netrw.v5.tar.bz2
.PHONY: netrw.v5
netrw.v5.tar.bz2: netrw.v5
netrw.v5: BASE = netrw.v5
netrw.v5: 
	env BASE=$(BASE) make doit

.PHONY: shellescape.tar.bz2
.PHONY: shellescape
shellescape.tar.bz2: shellescape
shellescape: BASE = shellescape
shellescape: 
	env BASE=$(BASE) make doit

.PHONY: advisory
advisory:
	make -C advisory
