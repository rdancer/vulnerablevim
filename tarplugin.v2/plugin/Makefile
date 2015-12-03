.PHONY: all
all: tarPlugin.vim.ready tar.vim.ready

tarPlugin.vim.ready: tarPlugin.vim clean
	./tarPlugin.vim.filter < tarPlugin.vim > tarPlugin.vim.ready

tar.vim.ready: tar.vim clean
	./tar.vim.filter < tar.vim > tar.vim.ready

.PHONY: clean
clean:
	rm -f tarPlugin.vim.ready tar.vim.ready
