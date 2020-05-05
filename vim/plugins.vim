" Install vim-plug and plugins if they are not installed yet
if empty(glob(g:my_additional_installs_dir . '/autoload/plug.vim'))
    let command = '!curl -fLo ' . g:my_additional_installs_dir . '/autoload/plug.vim' .
        \ ' --create-dirs ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    execute(command)
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(g:my_additional_installs_dir . '/bundle')


" Syntax and highlighting
" -----------------------

Plug 'viniciusban/vim-polyglot'
Plug 'viniciusban/vim-distractionfree-colorschemes'

let g:rainbow_active = 0
let g:rainbow_conf = {
    \ 'operators': '',
    \ 'guis': ['bold'],
    \ 'guifgs': ['seagreen3', 'magenta', 'royalblue3', 'orange', 'firebrick'],
\}
Plug 'luochen1990/rainbow'

Plug 'ap/vim-css-color'  | " Show the color in CSS


" Features and shortcuts for improve editing
" ------------------------------------------

Plug 'tpope/vim-commentary'  | " gcc, gc<motion>, {Visual}gc
Plug 'machakann/vim-sandwich'  | " sa, sd, sr
Plug 'andymass/vim-matchup'  | " %, g%, a%, i%, and more

" New text-objects
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent' | " ai, ii
Plug 'glts/vim-textobj-comment' | " ac, ic (remapped below to...)
omap aC <Plug>(textobj-comment-a) 
xmap aC <Plug>(textobj-comment-a)
omap iC <Plug>(textobj-comment-i)
xmap iC <Plug>(textobj-comment-i)

" class, function, and docstring text-objects 
" 
" Both plugins below implement class and function text-objects, but only
" vim-textobj-python handles multiline decorators correctly.
" Thus, I use vim-pythonsense to handle only docstring text-objects.
" Their actual mappings are in `after/ftplugin/python.vim`
"
" NOTE: Maybe I should develop one plugin to handle docstrings and get rid
" of vim-pythonsense.
Plug 'bps/vim-textobj-python' | " ac, ic, af, if.
let g:is_pythonsense_suppress_object_keymaps = 1
Plug 'jeetsukumaran/vim-pythonsense' | " ad, id (docstring objects).

Plug 'inkarkat/vim-ReplaceWithRegister'  | " <register>gr{motion}, {Visual}<register>gr
Plug 'tpope/vim-unimpaired'  | " [q, ]q, [e, ]e, etc.

let g:jedi#popup_on_dot=0
let g:jedi#show_call_signatures_delay=100
Plug 'davidhalter/jedi-vim'

let g:UltiSnipsSnippetDirectories=[$HOME.'/src/vim-snippets']
Plug 'SirVer/ultisnips'
Plug 'viniciusban/vim-ft-markdown'
let g:user_emmet_leader_key = '<C-\>'
Plug 'mattn/emmet-vim'


" File searching and handling
" ------------------------------------------

Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', {'dir': g:my_additional_installs_dir . '/bundle/fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'

let NERDTreeIgnore=['__pycache__[[dir]]']
let NERDCreateDefaultMappings = 0
let NERDMenuMode = 0
let NERDCommentEmptyLines = 1
let NERDDefaultAlign='left'
let NERDSpaceDelims = 1
let NERDTrimTrailingWhitespace = 1
let NERDTreeHijackNetrw = 0
Plug 'scrooloose/nerdtree'

call plug#end()

filetype plugin indent on
syntax enable
