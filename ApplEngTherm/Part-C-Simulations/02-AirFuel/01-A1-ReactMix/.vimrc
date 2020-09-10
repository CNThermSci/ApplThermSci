"bring relief
set nocompatible

"color my stuff
syntax on
colorscheme elflord

"a little guidance on screen, please!
set ruler
set number

" PEP8
set shiftwidth=4  " operation >> indents 4 cols; << unindents 4 cols.
set tabstop=4     " an hard TAB displays as 4 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

" textwidth and colorcolumn
set textwidth=192
set colorcolumn=193 " https://superuser.com/a/249856

" Pathogen
execute pathogen#infect()
filetype plugin indent on

" Julia-vim
let g:latex_to_unicode_tab = 1
let g:latex_to_unicode_auto = 0
let g:latex_to_unicode_file_types = ".*"
noremap <expr> <F7> LaTeXtoUnicode#Toggle()
inoremap <expr> <F7> LaTeXtoUnicode#Toggle()

