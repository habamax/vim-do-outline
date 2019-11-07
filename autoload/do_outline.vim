let s:do_outline_filetypes = ['asciidoc', 'asciidoctor']

func! do_outline#do_outline() abort
	if index(s:do_outline_filetypes, &filetype) < 0
		echomsg &filetype . ' filetype is not supported.'
		return
	endif
	let [bufnr, outline_pos, outline] = s:rebuild_outline()
	call s:show_outline(bufnr, outline)
	exe 'normal ' . outline_pos . 'gg'
endfunc

func! s:rebuild_outline() abort
	let bufnr = bufnr('%')
	let outline = []
	let outline_pos = -1
	let cursor_pos = getcurpos()[1]

	let line_idx = 0
	let buf_lines = getbufline(bufnr, 0, '$')
	for line in buf_lines
		let match = matchlist(line, '^\(=\+\)\s\+\(.*\)$')
		if !empty(match)
			let level = len(match[1]) - 1
			let line = repeat("\t", level) . match[2]
			call add(outline, {"line_nr": line_idx, "text": line})
		endif
		if outline_pos == -1 && line_idx >= cursor_pos
			let outline_pos = len(outline)
		endif
		let line_idx += 1
	endfor
	" return buffer number, cursorline, outline info
	return [bufnr, outline_pos, outline]
endfunc

func! s:goto_outline() abort
	let outline_idx = line('.') - 1
	let src_idx = b:outline[outline_idx]['line_nr'] + 1

	let bufwinnr = bufwinnr(b:outline_src_bufnr)
	if bufwinnr == -1
		exe ':b'.b:outline_src_bufnr . '| normal ' . src_idx . 'gg'
	else
		exe 'wincmd c | '. bufwinnr . 'wincmd w | normal ' . src_idx . 'gg'
	endif
endfunc

func! s:show_outline(bufnr, outline) abort
	exe 'new ' . '[Outline: ' . bufname(a:bufnr) . ']'
	%delete _

	setl buftype=nofile
	setl bufhidden=hide
	setl noswapfile

	let b:outline_src_bufnr = a:bufnr
	let b:outline = a:outline

	call append(0, map(copy(b:outline), {k,v -> v.text}))
	$delete _

	nnoremap <buffer> <CR> :call <SID>goto_outline()<CR>
	syn match DoOutlineLevel0 '^[^\t].*$'
	syn match DoOutlineLevel1 '^\t[^\t].*$'
	syn match DoOutlineLevel2 '^\t\{2}[^\t].*$'
	syn match DoOutlineLevel3 '^\t\{3}[^\t].*$'
	syn match DoOutlineLevel4 '^\t\{4}[^\t].*$'
	syn match DoOutlineLevel5 '^\t\{5}[^\t].*$'
	syn match DoOutlineLevel6 '^\t\{6}[^\t].*$'
	syn match DoOutlineLevel7 '^\t\{7}[^\t].*$'
	syn match DoOutlineLevel8 '^\t\{8}[^\t].*$'
	syn match DoOutlineLevel9 '^\t\{9}[^\t].*$'
	hi def link DoOutlineLevel0 Title
	hi def link DoOutlineLevel1 Statement
	hi def link DoOutlineLevel2 Type
	hi def link DoOutlineLevel3 String
	hi def link DoOutlineLevel4 Identifier
	hi def link DoOutlineLevel5 Normal
	hi def link DoOutlineLevel6 Normal
	hi def link DoOutlineLevel7 Normal
	hi def link DoOutlineLevel8 Normal
	hi def link DoOutlineLevel9 Normal
endfunc
