.PHONY: all
all: zipPlugin.vim.ready zip.vim.ready

zipPlugin.vim.ready: zipPlugin.vim clean
	./zipPlugin.vim.filter < zipPlugin.vim > zipPlugin.vim.ready

zip.vim.ready: zip.vim clean
	./zip.vim.filter < zip.vim > zip.vim.ready

.PHONY: clean
clean:
	rm -f zipPlugin.vim.ready zip.vim.ready
