if exists("g:did_ban_functions")
	finish
endif
let g:did_ban_functions = 1

function! Ban_Run(command)
	" Run an external command using internal or external terminal

	if !exists("g:ban_run_internal")
		if has("gui_running")
			let g:ban_run_internal = 1
		elseif has("nvim")
			let g:ban_run_internal = 1
		else
			let g:ban_run_internal = 0
		endif
	endif

	let quote = '"'
	if g:ban_run_internal == 1
		let prefix = 'tabnew | terminal '. &shell .' -c ' . quote
		let suffix = quote
	else
		let prefix = '!'
		let suffix = ''
	endif

	return prefix . a:command . suffix
endfunction

function! Ban_ExecNERDCommenterWithMotion(mode)
	let command = '<first>,<last>call NERDComment("n", "<type>")'
	let [firstline, lastline] = [line("'["), line("']")]
	if firstline > lastline
		let [firstline, lastline] = [lastline, firstline]
	endif
	let command = substitute(command, '<first>', firstline, '')
	let command = substitute(command, '<last>', lastline, '')
	let command = substitute(command, '<type>', g:nerd_comment_type, '')
	exec command
endfunction

function! Ban_AddDelimiterToSelectedText() range
	" It works only in one line by now.
	let counterchars = {'(': '()', ')': '()', '[': '[]', ']': '[]', '{': '{}', '}': '{}', '<': '<>', '>': '<>'}
	let counterparts = {'/*': ['/*', '*/'], '*/': ['/*', '*/'], '{{': ['{{', '}}'], '}}': ['{{', '}}'], '{%': ['{%', '%}'], '%}': ['{%', '%}'], '{#': ['{#', '#}'], '#}': ['{#', '#}'] }
	let linenum = line("'<")
	let line = getline("'<")
	let [start_position, end_position] = [getpos("'<")[2], getpos("'>")[2]]
	let delimiter = input('Type delimiter:')
	if has_key(counterchars, delimiter)
		let opening_delimiter = strcharpart(counterchars[delimiter], 0, 1)
		let closing_delimiter = strcharpart(counterchars[delimiter], 1)
	elseif has_key(counterparts, delimiter)
		let opening_delimiter = counterparts[delimiter][0] .' '
		let closing_delimiter = ' '. counterparts[delimiter][1]
	elseif len(delimiter) > 1 && strcharpart(delimiter, 0, 1) == '<'
		let opening_delimiter = delimiter
		let closing_delimiter = '</' . strcharpart(delimiter, 1)
	else
		let [opening_delimiter, closing_delimiter] = [delimiter, delimiter]
	endif

	let before = strcharpart(line, 0, start_position -1)
	let after = strcharpart(line, end_position)
	let inside = strcharpart(line, start_position -1, end_position - start_position + 1)

	call setline(linenum, before .opening_delimiter. inside .closing_delimiter. after)
endfunction
