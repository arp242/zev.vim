let s:patterns = {}

fun! zev#cmd(bang, line1, line2, ...) abort
	if a:0 is# 0
		return zev#list(a:bang)
	endif
	
	return zev#apply(a:bang, a:line1, a:line2, a:1)
endfun

" List all patterns.
fun! zev#list(bang) abort
	if a:bang
		let l:pats = {}
		for l:ft in keys(s:patterns)
			call extend(l:pats, get(s:patterns, l:ft, {}))
		endfor
	else
		let l:pats = get(s:patterns, '', {})
		call extend(l:pats, get(s:patterns, &filetype, {}))
	endif

	let l:align = 0
	for l:name in keys(l:pats)
		let l:align = max([l:align, len(l:name)])
	endfor

	let l:i = 0
	for [l:name, l:cmd] in items(l:pats)
		echo printf('%s   %s%s', l:name, repeat(' ', l:align-len(l:name)), l:cmd[0])
		echo printf("%s %s", repeat(' ', l:align+2), l:cmd[1])
		if l:i < len(l:pats) - 1
			echo "\n"
		endif
		let l:i += 1
	endfor
endfun

" Apply a pattern.
fun! zev#apply(bang, line1, line2, name) abort
	let l:s = split(a:name, '/')
	let l:name = l:s[0]
	let l:flags = ''
	if len(l:s) > 1
		let l:flags = l:s[1]
	endif

	let l:cmd = get(get(s:patterns, &filetype, {}), l:name, '')
	if l:cmd is# ''
		let l:cmd = get(get(s:patterns, '', {}), l:name, '')
		if l:cmd is# ''
			echohl Error
			echom printf('Not defined: "%s"', l:name)
			echohl None
			return
		endif
	endif

	" TODO: ideally I'd like to replace the original motion, '%Zev! ..' gets
	" replaced with ':1,508:s/...' which looks a bit weird.
	let l:cmd = printf(':%d,%d%s%s', a:line1, a:line2, l:cmd[1], l:flags)

	if a:bang
		return feedkeys(l:cmd)
	end

	try
		exe l:cmd
	catch /^Vim\%((\a\+)\)\=:E486:/
		" Don't show full trace in pager, just the error message.
		echohl Error
		echom substitute(v:exception, '^Vim(substitute):', '', '')
		echohl None
	endtry

	" TODO: this is rather ugly, but not sure how to do this better.
	keepjumps normal! f█
	let l:s = winsaveview()
	silent s/█//e
	call winrestview(l:s)
endfun

" Register a new pattern; this is 'compiled' in to a :substitute command.
fun! zev#register(filetype, name, desc, search, replace) abort
	let l:filetypes = map(split(a:filetype, ','), { _, v -> trim(v)})

	for l:ft in l:filetypes
		if get(s:patterns, l:ft, '') is# ''
			let s:patterns[l:ft] = {}
		endif

		" Delimiters in order of preference.
		for l:d in split('/!|,@#$', '\zs')
			if a:search !~# l:d && a:replace !~# l:d
				break
			endif
		endfor

		let s:patterns[l:ft][a:name] = [a:desc, printf(':s%s%s%s%s%s',
			\ l:d, a:search, l:d, a:replace, l:d)]
	endfor
endfun

let s:s_flags = ['&', 'c', 'e', 'g', 'i', 'I', 'n', 'p', '#', 'l', 'r']

" Commandline completion.
" TODO: Complete flags after `:Zev name/<Tab>
fun! zev#complete(lead, cmdline, cursor) abort
	let l:pats = get(s:patterns, '', {})
	call extend(l:pats, get(s:patterns, &filetype, {}))
	return filter(keys(l:pats), {_, v -> strpart(l:v, 0, len(a:lead)) is# a:lead})
endfun
