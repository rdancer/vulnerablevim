" This is an example usage of the shellescape() function

" ``The IUCN Red List has the kodkod as Vulnerable.''
" 	-- http://www.catsurvivaltrust.org/kodkod.htm
"
" Kodkod -- a poor man's cat(1)
fun! Kodkod()
	let i = 1
	while i <= line("$")
		let message =  getline(i)
		"silent exe "!echo ".shellescape(message,1)
		silent exe "!printf '\\\%s\\n' ".shellescape(message,1)
		let i = i+1
	endwhile
endfun
