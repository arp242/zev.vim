command! -bang -range -nargs=? 
			\ -complete=customlist,zev#complete
			\ Zev call zev#cmd(<bang>0, <line1>, <line2>, <f-args>)

if get(g:, 'zev_no_default', 0)
	finish
end

" Go
call zev#register('go', 'unwrap',
			\ 'Replace errors.Wrap() with stdlib fmt.Errorf()',
			\ '\verrors\.Wrap\((\k+), (["`])(.{-})["`]\)',
			\ 'fmt.Errorf(\2\3: %w\2, \1)')

call zev#register('go', 'errctx',
			\ 'Add error context to the last variable in returns',
			\ '\vreturn (.{-}, )?\zs(\k+)',
			\ 'fmt.Errorf("█: %w", \2)')

" Markdown
call zev#register('markdown', 'html-link',
			\ 'Transform a HTML link to Markdown syntax',
			\ '<a .\{-}href=[''"]\(.\{-}\)[''"].\{-}>\(.\{-}\)</a>',
			\ '[\2](\1)')

" HTML
call zev#register('html', 'md-link',
			\ 'Transform a Markdown link to HTML syntax',
			\ '\[\(.\{-}\)\](\(.\{-}\))',
			\ '<a href="\2">\1</a>')
