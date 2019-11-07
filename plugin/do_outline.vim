" do-outline.vim -- Do outline asciidoc(, markdown)
" Maintainer:   Maxim Kim <habamax@gmail.com>

if exists("g:loaded_do_outline") || &cp || v:version < 700
	finish
endif
let g:loaded_do_outline = 1

command DoOutline call do_outline#do_outline()

