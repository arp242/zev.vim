fun! Test_Go() abort
	let l:tests = {
		\ 'return err': ['errctx', 'return fmt.Errorf(": %w", err)'],
		\ 'return foo, err': ['errctx', 'return foo, fmt.Errorf(": %w", err)'],
		\ 'return errors.Wrap(err, "context")': ['unwrap', 'return fmt.Errorf("context: %w", err)'],
	\ }

	for [l:in, l:want] in items(l:tests)
		let l:name = l:want[0]
		let l:want = l:want[1]

		new
		set ft=go
		call setline('.', l:in)
		exe ':Zev ' . l:name

		let l:got = getline('.')
		if l:got isnot# l:want
			call Errorf("%s:\ngot:  %s\nwant: %s\n", l:name, l:got, l:want)
		endif
	endfor
endfun
