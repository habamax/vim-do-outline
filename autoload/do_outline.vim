let s:do_outline_filetypes = {
            \  'asciidoctor': '^\(=\+\)\s\+\(.*\)$'
            \, 'asciidoc': '^\(=\+\)\s\+\(.*\)$'
            \, 'markdown': '^\(#\+\)\s\+\(.*\)$'
            \}

func! do_outline#do_outline() abort
    if index(keys(s:do_outline_filetypes), &filetype) < 0
        echomsg &filetype . ' filetype is not supported.'
        return
    endif

    let [bufnr, outline_pos, outline] = s:rebuild_outline(s:do_outline_filetypes[&filetype])
    call s:show_outline(bufnr, outline)
    exe 'normal ' . outline_pos . 'gg'
endfunc

func! s:rebuild_outline(regexp) abort
    let outline = []
    let outline_pos = -1
    let cursor_pos = getcurpos()[1]

    for linenr in range(0, line('$'))
        let line = getline(linenr)
        let match = matchlist(line, a:regexp)
        if !empty(match)
            let level = len(match[1]) - 1
            let line = repeat("\t", level) . match[2]
            call add(outline, {"line_nr": linenr, "text": line})
        endif
        if outline_pos == -1 && linenr >= cursor_pos
            let outline_pos = len(outline)
        endif
    endfor
    " return buffer number, cursorline, outline info
    return [bufnr('%'), outline_pos, outline]
endfunc

func! s:goto_outline() abort
    let outline_idx = line('.')
    let src_idx = b:outline[outline_idx-1]['line_nr']

    let winid = bufwinid(b:outline_src_bufnr)
    if winid == -1
        exe ':b'.b:outline_src_bufnr . ' | '. src_idx
    else
        wincmd c
        call win_gotoid(winid)
        exe src_idx
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

    call setline(1, map(copy(b:outline), {k,v -> v.text}))

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
