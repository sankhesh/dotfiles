" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" every time an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible
set nocompatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
if has("gui_running")
  set background=light
else
  set background=dark
endif

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
"  filetype plugin indent on
  filetype off
endif

" Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" This is the Vundle package, which can be found on GitHub.
" For GitHub repos, you specify plugins using the
" 'user/repository' format
Plugin 'gmarik/vundle'

" We could also add repositories with a '.git' extension
Plugin 'scrooloose/nerdtree.git'
Plugin 'scrooloose/nerdcommenter.git'

" ShowMarks plugin
Plugin 'ShowMarks7'

" CtrlP plugin
Plugin 'ctrlp.vim'

" Diffchanges plugin
Plugin 'diffchanges.vim'

" Youcompleteme plugin
Plugin 'Valloric/YouCompleteMe'

" Fugitive
Plugin 'tpope/vim-fugitive.git'

" Vim-unimpaired
Plugin 'tpope/vim-unimpaired.git'

" Tagbar
Plugin 'majutsushi/tagbar.git'

" UltiSnips
Plugin 'SirVer/ultisnips.git'

" Instant Preview
Plugin 'greyblake/vim-preview.git'

" PEP 8 style checker for python files
Plugin 'nvie/vim-flake8'

" Re-enable filetype plugins
filetype plugin indent on

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase	" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden      " Hide buffers when they are abandoned
set mouse=a	  	" Enable mouse usage (all modes)
set pastetoggle=<F2>  " Toggle paste mode to preserve indentation of text being copied
"set title       " Change the terminal's title
set wildignore=*.swp,*.bak,*.pyc,*.class

" Highlight all matches for the pattern with a yellow background
if !&hlsearch
  " Don't set this again as it'll turn highlighting back on every time the
  " vimrc is reloaded. This can get quite annoying when testing changes
  set hlsearch
endif

" Highlight merge conflicts delimiters
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

set shiftwidth=2      " 2 spaces for indenting
"set tabstop=2	        " 2 stops
set softtabstop=2     " 2 stops
set expandtab         " Spaces instead of tabs
set autoindent        " Always set auto indenting on
set cindent
set cinoptions+=g0,{1s,:0,l1,c0,(0,m0 " Place public:, etc. on the same indent as the {. VTK/ITK style
"set spell            " Spell checker on
set number            " Show line numbers
set matchpairs+=<:>   " To match arguments of templates
set laststatus=2      " Show status line even if there is only one window
set tw=80             " Set textwidth to 80 characters so that line breaks at that width
set splitright        " Open new vertical split to right
set splitbelow        " Open new horizontal split below
set statusline=%<%f\ %{fugitive#statusline()}\ %h%m%r%=%-14.(%l/%L,%c%V%)\ %P  " Status line

" Set make program
set makeprg=make\ -C\ %:p:h/../bld\ -j10

" Color 80th column
set colorcolumn=80
highlight ColorColumn ctermbg=Blue

" Set leader (vim prefix) to ','
:let mapleader = ","

" Allow backspace to delete indents, line breaks and past the start of the
" current insert. This makes the key work like in every other editor
set backspace=indent,eol,start

set nocp

" Insert current file name
inoremap <leader>fn <C-R>=expand("%t")<CR>

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = $HOME."/.vim/.ycm_extra_conf.py"
let g:ycm_key_list_select_completion=[] " Load tab completion without pressing tab key
let g:ycm_key_list_previous_completion=[] " Load tab completion without pressing tab key
let g:ycm_register_as_syntastic_checker = 1
let g:ycm_collect_identifiers_from_tags_files = 1 " Load identifiers from tags files
let g:ycm_confirm_extra_conf = 0
let g:ycm_always_populate_location_list = 1 " Allows to navigate to next/previous errors
nnoremap <leader>jd :YcmCompleter GoTo<CR>

" Tagbar
nmap <F8> :TagbarToggle<CR>

"" flake8 settings
" Show error marks in gutter
let g:flake8_show_in_gutter=1
" highlight using colors defined in the colorscheme
highlight link Flake8_Error       Error
highlight link Flake8_Warning     WarningMsg
highlight link Flake8_Complexity  WarningMsg
highlight link Flake8_Naming      WarningMsg
highlight link Flake8_PyFlake     WarningMsg
" auto run flake8 everytime when writing python files
autocmd BufWritePost *.py call Flake8()

" Set omnifunc
"autocmd FileType python set omnifunc=pythoncomplete#Complete
"autocmd FileType javascript set omnifunc=javascriptcomplete#Complete
"autocmd FileType c set omnifunc=ccomplete#CompleteCpp
"autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags

"Omnicppcomplete tags
"ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f gl /usr/include/GL/
"set tags+=/home/sankhesh/.vim/tags/cpp
"set tags+=/home/sankhesh/.vim/tags/qt4
"set tags+=/home/sankhesh/.vim/tags/gl
"set tags+=/home/sankhesh/.vim/tags/vtk
"set tags+=/home/sankhesh/.vim/tags/paraview


" Build tags for current project
map <C-F6> :!ctags -R --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>

" OmniCppComplete
"let OmniCpp_NamespaceSearch = 2
"let OmniCpp_GlobalScopeSearch = 1
"let OmniCpp_DisplayMode = 1
"let OmniCpp_ShowAccess = 1
"let OmniCpp_ShowScopeInAbbr = 0
"let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
"let OmniCpp_MayCompleteDot = 1 " autocomplete after .
"let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
"let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
"let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
"set completeopt=menuone,menu,longest,preview

" Smart_TabComplete
"function! Smart_TabComplete()
"  let line = getline('.')                         " current line
"
"  let substr = strpart(line, -1, col('.')+1)      " from the start of the current
"                                                  " line to one character right
"                                                  " of the cursor
"  let substr = matchstr(substr, "[^ \t()]*$")     " word till cursor
"  if (strlen(substr)==0)                          " nothing to match on empty string
"    return "\<tab>"
"  endif
"  let has_period = match(substr, '\.') != -1      " position of period, if any
"  let has_slash = match(substr, '\/') != -1       " position of slash, if any
"  if (!has_period && !has_slash)
"    return "\<C-X>\<C-P>"                         " existing text matching
"  elseif ( has_slash )
"    return "\<C-X>\<C-F>"                         " file matching
"  else
"    return "\<C-X>\<C-O>"                         " plugin matching
"  endif
"endfunction
"inoremap <tab> <c-r>=Smart_TabComplete()<CR>

" Switch between source and header files
function! SwitchSourceHeader()
  let s:ext = expand("%:e")
  let s:base = expand("%:t:r")
  let s:cmd = "find " . s:base
  if (s:ext == "cpp" || s:ext == "c" || s:ext == "C" || s:ext == "cxx")
    if findfile(s:base . ".h"   ) != "" | exe s:cmd . ".h"   | return | en
    if findfile(s:base . ".hpp" ) != "" | exe s:cmd . ".hpp" | return | en
    if findfile(s:base . ".hxx" ) != "" | exe s:cmd . ".hxx" | return | en
  else
    if findfile(s:base . ".cpp" ) != "" | exe s:cmd . ".cpp" | return | en
    if findfile(s:base . ".c"   ) != "" | exe s:cmd . ".c"   | return | en
    if findfile(s:base . ".C"   ) != "" | exe s:cmd . ".C"   | return | en
    if findfile(s:base . ".cxx" ) != "" | exe s:cmd . ".cxx" | return | en
  endif
endfunc
nmap ,s :call SwitchSourceHeader()<CR>

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" Set a 256 color terminal
" set t_Co=256

" Show trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Highlight current line
set cursorline
:hi CursorLine cterm=NONE ctermbg=16 ctermfg=white guibg=darkred guifg=white

" Highlight for showmarks
:hi ShowMarksHLl ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white
:hi ShowMarksHLu ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white
:hi ShowMarksHLo ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white
:hi ShowMarksHLm ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white

" Add the current directory to the path
let s:default_path = escape(&path, '\ ') " store default value of 'path'
" Always add the current file's directory to the path and tags list if not
" already there. Add it to the beginning to speed up searches.
autocmd BufRead *
      \ let s:tempPath=escape(escape(expand("%:p:h:h"), ' '), '\ ') |
      \ exec "set path-=".s:tempPath |
      \ exec "set path-=".s:default_path |
      \ exec "set path^=".s:tempPath |
      \ exec "set path^=".s:default_path

" Session options
set ssop-=options                             " Do not store global or local options in a session
set ssop-=folds                               " Do not store folds in a session

" Folds options
" zc, zo, za - 1 level folding within a function
" zC, zO, zA - All levels folding within a function
" zr, zm     - 1 level folding throughout
" zR, zM     - All levels folding throughout
set foldmethod=syntax                         " Folds according to syntax
set foldlevelstart=4                          " Start fold level

" Show diff between current buffer and saved file
" Show changes using DiffChanges
nmap <leader>f :DiffChangesDiffToggle<CR>
nmap <leader>p :DiffChangesPatchToggle<CR>

" NERDTreeToggle
nmap <leader>m :NERDTreeToggle<CR>
nmap <leader>n :NERDTreeFind<CR>

" CtrlP word under cursor
nmap <leader>cp :CtrlP<CR><C-\>w

" Rename tabs to show tab number.
" (Based on http://stackoverflow.com/questions/5927952/whats-implementation-of-vims-default-tabline-function)
if exists("+showtabline")
    function! MyTabLine()
        let s = ''
        let wn = ''
        let t = tabpagenr()
        let i = 1
        while i <= tabpagenr('$')
            let buflist = tabpagebuflist(i)
            let winnr = tabpagewinnr(i)
            let s .= '%' . i . 'T'
            let s .= (i == t ? '%1*' : '%2*')
            let s .= ' '
            let wn = tabpagewinnr(i,'$')

            let s .= '%#TabNum#'
            let s .= i
            " let s .= '%*'
            let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
            let bufnr = buflist[winnr - 1]
            let file = bufname(bufnr)
            let buftype = getbufvar(bufnr, 'buftype')
            if buftype == 'nofile'
                if file =~ '\/.'
                    let file = substitute(file, '.*\/\ze.', '', '')
                endif
            else
                let file = fnamemodify(file, ':p:t')
            endif
            if file == ''
                let file = '[No Name]'
            endif
            let s .= ' ' . file . ' '
            let i = i + 1
        endwhile
        let s .= '%T%#TabLineFill#%='
        let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
        return s
    endfunction
    set stal=2
    set tabline=%!MyTabLine()
    set showtabline=1
    highlight link TabNum Special
endif

" Grep mappings
"" Map gr to vimgrep word under cursor in parent directory of current file
:nnoremap gr :execute "vimgrep /" . expand("<cword>") . "/j %:p:h/**" <Bar> cw<CR>
"" Map Gr to git grep word under cursor in current working tree
:nnoremap Gr :execute "Ggrep! " expand("<cword>") <Bar> cw<CR>

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif
