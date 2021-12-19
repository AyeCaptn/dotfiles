
" Set how many lines of history VIM should remember
set history=500

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'tpope/vim-sensible'
Plug 'chrisbra/vim-diff-enhanced'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'easymotion/vim-easymotion'
Plug 'osyo-manga/vim-over'
Plug 'markonm/traces.vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

let g:airline_theme='onedark'
