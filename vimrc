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

if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8
  scriptencoding utf-8
  setglobal fileencoding=utf-8
  " Uncomment to have 'bomb' on by default for new files.
  " Note, this will not apply to the first, empty buffer created at Vim startup.
  "setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
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

" Set a 256 color terminal
set t_Co=256
if exists('$TMUX')
  set term=screen-256color
elseif !(has('win32') || has('win64'))
  set term=xterm-256color
endif

let s:win_shell = (has('win32') || has('win64')) && &shellcmdflag =~ '/'
if s:win_shell
  set renderoptions=type:directx,gamma:1.5,contrast:0.5,geom:1,renmode:5,taamode:1,level:0.5
endif

if has('gui_running')
  set guioptions-=T " no toolbar
  if s:win_shell
    set guioptions=dgMRLt
    set guifont=Cascadia_Code:h10:cANSI:qDRAFT
  else
    set guifont=Cascadia\ Code\ 10
  endif
endif

set rtp+=~/.vim/bundle/pyclewn

let s:vimDir = s:win_shell ? '$HOME/vimfiles' : '$HOME/.vim'
let &runtimepath .= ',' . expand(s:vimDir . '/autoload/plug.vim')
exec "source " . expand(s:vimDir . '/vim-plug/plug.vim')

" if (win_shell)
"   " Requires python to be in the system path
"   echo \"Requires python\"
"   if executable("python")
"         echo \"Python check sycce\"
"         let s:pythonpath = system('python
"           \  -c "import sys; sys.stdout.write(
"           \    str(sys.path[1])
"           \    )"' )
"           echo expand(s:pythonpath)
"     let &pythonthreehome = expand(s:pythonpath)
"     let &pythonthreedll = expand(s:pythonpath . '/python38.dll')
"   endif
" endif

" Specify a directory for plugins
" Avoid using standard Vim directory names like plugins
call plug#begin(expand(s:vimDir . '/plugged'))

" We could also add repositories with a '.git' extension
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'scrooloose/nerdcommenter'
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }

" Vim-Signature plugin to show marks
Plug 'kshenoy/vim-signature'

" CtrlP plugin
" Plug 'vim-scripts/ctrlp.vim'

" File Fuzzy Finder plugin
Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Diffchanges plugin
Plug 'vim-scripts/diffchanges.vim'

" Fugitive
Plug 'tpope/vim-fugitive'

" Fugitivev blame helper
Plug 'tommcdo/vim-fugitive-blame-ext'

" Gitv
" Plug 'gregsexton/gitv'
Plug 'sankhesh/gitv'

" Vim-unimpaired
Plug 'tpope/vim-unimpaired'

" repeat.vim
Plug 'tpope/vim-repeat'

" UltiSnips
Plug 'sirver/ultisnips', { 'on': [] }
"{{{ UltiSnips
  let g:UltiSnipsSnippetsDir = expand(s:vimDir . '/UltiSnips')
  let g:UltiSnipsExpandTrigger="<c-j>"
  let g:UltiSnipsJumpForwardTrigger="<c-j>"
  let g:UltiSnipsJumpBackwardTrigger="<c-k>"
  let g:UltiSnipsListSnippets="<c-l>"

  inoremap <silent> <C-j> <C-r>=LoadUltiSnips()<cr>

  " This function only runs when UltiSnips is not loaded
  function! LoadUltiSnips()
    let l:curpos = getcurpos()
    execute plug#load('ultisnips')
    call cursor(l:curpos[1], l:curpos[2])
    call UltiSnips#ExpandSnippet()
    return ""
  endfunction
"}}}

" Tabular / vim-markdown
Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', {'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" QuickFix list handling
Plug 'yssl/QFEnter'

" Draw ASCII text drawings DrawIt
Plug 'vim-scripts/DrawIt'

" Signify plugin
Plug 'mhinz/vim-signify'

" Syntax highlighting
Plug 'sheerun/vim-polyglot'

" Colorschemes
Plug 'tomasiser/vim-code-dark'

" Vim CMake completion
Plug 'richq/vim-cmake-completion', { 'for': 'cmake' }

" Vim 8 asyncrun for asynchronous commands run
Plug 'skywind3000/asyncrun.vim'

" Youcompleteme plugin
function! BuildYCM(info)
  if a:info.status == 'installed' || a:info.status == 'updated' || a:info.force
    if s:win_shell
      !python install.py --preview-msvc --clangd-completer --ts-completer --cs-completer
    else
      !python install.py --clangd-completer --ts-completer
    endif
  endif
endfunction
Plug 'Valloric/YouCompleteMe', { 'do' : function('BuildYCM'), 'for': ['cpp', 'cs', 'javascript', 'python', 'typescript'] }
autocmd! User YouCompleteMe if !has('vim_starting') | call youcompleteme#Enable() | endif

" Vista.vim (Tagbar alternative)
" Plug 'liuchengxu/vista.vim'

" Tagbar
Plug 'majutsushi/tagbar'

if !s:win_shell
  " Vim Latex vimtex
  Plug 'lervag/vimtex', { 'for': 'tex' }

  " Tmux.conf syntax highlighting
  Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
endif

" Obsession plugin
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'

" FastFold and FoldText plugins
Plug 'Konfekt/FastFold'
Plug 'Konfekt/FoldText'

" Asynchronous linting engine
Plug 'dense-analysis/ale'

" Clang format plugin for vim
Plug 'rhysd/vim-clang-format'

" Goyo plugin for prose mode
Plug 'junegunn/goyo.vim'

" Auto highlight word under cursor
Plug 'RRethy/vim-illuminate'

" Switch between source/header files
" Plug 'ericcurtin/CurtineIncSw.vim', { 'for': ['cpp', 'c'] }

" Matchup
Plug 'andymass/vim-matchup'

" .lvimrc support
Plug 'embear/vim-localvimrc'

" Initialize plugin system
call plug#end()

" Add the TermDebug plugin
packadd! termdebug

" Set to a dark background
set background=dark

" Color scheme here would override all colors
" Activates italicized comments (make sure your terminal supports italics)
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
let g:codedark_italics=1
let g:codedark_modern=1
colorscheme codedark
if has("gui_running")
  let macvim_skip_colorscheme=1
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
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
set cinoptions+=g0,l1,c0,(0,m0 " Place public:, etc. on the same indent as the {. VTK/ITK style
"set spell            " Spell checker on
set number            " Show line numbers
set matchpairs+=<:>   " To match arguments of templates
set laststatus=2      " Show status line even if there is only one window
set tw=100             " Set textwidth to 100 characters so that line breaks at that width
set splitright        " Open new vertical split to right
set splitbelow        " Open new horizontal split below
" set statusline=%<%f\ %{NearestMethodOrFunction()}\ %{fugitive#statusline()}\ %{ObsessionStatus('[Obsession]',\ '[ObsessionPaused]')}\ %h%m%r%=%-14.(%l/%L,%c%V%)\ %P  " Status line
set statusline=%<%f\ %{fugitive#statusline()}\ %{ObsessionStatus('[Obsession]',\ '[ObsessionPaused]')}\ %h%m%r%=%-14.(%l/%L,%c%V%)\ %P  " Status line
set switchbuf=usetab,newtab  " Use existing tab or open new tab when switching buffers

" Set make program
" set makeprg=make\ -C\ %:p:h/../bld\ -j10
set makeprg=ninja\ -C\ ../bld

" Color 80th column
set colorcolumn=100
highlight ColorColumn ctermfg=163

" Set leader (vim prefix) to ','
:let mapleader = ","

" Allow backspace to delete indents, line breaks and past the start of the
" current insert. This makes the key work like in every other editor
set backspace=indent,eol,start

set nocp

" Insert current file name
inoremap <leader>fn <C-R>=expand("%t")<CR>

" Termdebug options
let g:termdebug_wide=163
let g:termdebug_popup=0

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = expand(s:vimDir . "/.ycm_extra_conf.py")
let g:ycm_key_list_select_completion=[] " Load tab completion without pressing tab key
let g:ycm_key_list_previous_completion=[] " Load tab completion without pressing tab key
let g:ycm_register_as_syntastic_checker = 1
let g:ycm_collect_identifiers_from_tags_files = 1 " Load identifiers from tags files
let g:ycm_confirm_extra_conf = 0
let g:ycm_always_populate_location_list = 1 " Allows to navigate to next/previous errors
let g:ycm_auto_hover = 'CursorHold' " Show a balloon with doc for function under cursor
if !exists("g:ycm_semantic_triggers")
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers = {
  \ 'cmake': [ 're!\_' ],
  \ 'c,cpp,objc': [ 're!\w{3}', '_' ],
  \ }
let g:ycm_enable_semantic_highlighting = 1 " Ycm's semantic highlighting
let g:ycm_enable_inlay_hints = 1 " inlay hints
nnoremap <leader>jd :YcmCompleter GoTo<CR>
nnoremap <leader>jf :YcmCompleter FixIt<CR>
nmap <leader>jp <plug>(YCMHover)
let g:ycm_python_interpreter_path=""
let g:ycm_extra_conf_vim_data = ['g:ycm_python_interpreter_path']

" Tagbar
nmap <F8> :TagbarToggle<CR> <bar> :TagbarTogglePause<CR>
let g:tagbar_show_tag_linenumbers = 2 " Show tag line numbers to the left in the tagbar window
let g:tagbar_show_visibility = 1 " Show the visibility symbols (public/protected/private) in tagbar

" " Vista
" function! NearestMethodOrFunction() abort
"   return get(b:, 'vista_nearest_method_or_function', '')
" endfunction
" " Make vista run the above function automatically
" autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" Prosession
let g:prosession_dir = expand(s:vimDir . '/session/') " Session cache directory
let g:prosession_tmux_title = !has('gui_running') " Update TMUX window title based on vim session
let g:prosession_default_session = 0 " Don't create a default session
let g:prosession_on_startup = !has('gui_running')

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
set completeopt=menuone,menu,longest,preview

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

" Show trailing whitespace and highlight based on the colorscheme
highlight link ExtraWhitespace Error
match ExtraWhitespace /\s\+\%#\@<!$/

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬,space:·

"Invisible character colors
" highlight NonText guifg=#4a4a59 ctermfg=239
" highlight SpecialKey guifg=#4a4a59 ctermfg=239

" Automatically remove trailing whitespace
autocmd FileType c,cpp,java,python,qml
  \ autocmd BufWritePre <buffer>
  \ let w:wv = winsaveview() | :%s/\s\+$//e | call winrestview(w:wv)

" Highlight current line
set cursorline
":hi CursorLine cterm=NONE ctermbg=16 ctermfg=white guibg=darkgray

" Highlight for showmarks
" :hi ShowMarksHLl ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white
" :hi ShowMarksHLu ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white
" :hi ShowMarksHLo ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white
" :hi ShowMarksHLm ctermfg=white ctermbg=darkblue guifg=darkblue guibg=white

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
set foldmethod=indent                         " Folds according to indent
autocmd FileType c,cpp,objc
      \ setlocal foldmethod=syntax            " Folds according to syntax
set foldlevelstart=4                          " Start fold level

" Show diff between current buffer and saved file
" Show changes using DiffChanges
nmap <leader>f :DiffChangesDiffToggle<CR>
nmap <leader>p :DiffChangesPatchToggle<CR>
if (has('win32') || has('win64'))
  let g:diffchanges_patch_cmd = 'FC'
endif

" NERDTree
nmap <leader>m :NERDTreeToggle<CR>
nmap <leader>n :NERDTreeFind<CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" NERDCommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prefitted multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code
" indentation
let g:NERDDefaultAlign = 'left'
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Vim-Vue
let g:vue_pre_processors = ['scss', 'typescript']
" Support vim-vue with NERDCommenter
let g:ft = ''
function! NERDCommenter_before()
  if &ft == 'vue'
    let g:ft = 'vue'
    let stack = synstack(line('.'), col('.'))
    if len(stack) > 0
      let syn = synIDattr((stack)[0], 'name')
      if len(syn) > 0
        exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
      endif
    endif
  endif
endfunction
function! NERDCommenter_after()
  if g:ft == 'vue'
    setf vue
    let g:ft = ''
  endif
endfunction

" CtrlP word under cursor
" nmap <leader>cp :CtrlP<CR><C-\>w
" let g:ctrlp_max_files = 20000
" let g:ctrlp_max_depth = 7

" Fzf options
" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R'
" [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = 'alt-enter,ctrl-x'
" Enable per-command history
let g:fzf_history_dir = '~/.local/share/fzf-history'
" Files command with preview window
command! -bang -nargs=? -complete=dir Files
 \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
nnoremap <leader>cp :call fzf#vim#files('.', {'options':'--query '.expand('<cword>')})<CR>
nnoremap <C-P> :Files<CR>
nnoremap <silent> <leader>ag :Ag <C-R><C-W><CR>
function! SwitchSourceHeader()
  let file_path = expand("%:t")
  let file_name = expand("%:t:r")
  let extension = split(file_path, '\.')[-1] " '\.'
  let string_to_search = ""
  if extension =~ 'h'
    let string_to_search = file_name . '.c'
  else
    let string_to_search = file_name . '.h'
  endif
  call fzf#vim#files('.', {'options':'--query '.string_to_search})
endfunction
nnoremap <silent> <leader>s :call SwitchSourceHeader()<CR>

" Rename tabs to show tab number.
" (Based on http://stackoverflow.com/questions/5927952/whats-implementation-of-vims-default-tabline-function)
if exists("+showtabline")
  if has("gui_running") && !s:win_shell
    function! GuiTabLabel()
      let label = ''
      let bufnrlist = tabpagebuflist(v:lnum)
      " Add '+' if one of the buffers in the tab page is modified
      for bufnr in bufnrlist
        if getbufvar(bufnr, "&modified")
          let label = '+'
          break
        endif
      endfor
      " Append the tab number
      let label .= v:lnum.': '
      " Append the buffer name
      let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
      if name == ''
        " give a name to no-name documents
        if &buftype=='quickfix'
          let name = '[Quickfix List]'
        else
          let name = '[No Name]'
        endif
      else
        " get only the file name
        let tname = fnamemodify(name,":t")
        if tname == 'index.js'
          let name = fnamemodify(name, ':p:.:h')
        endif
      endif
      let label .= name
      " Append the number of windows in the tab page
      let wincount = tabpagewinnr(v:lnum, '$')
      if wincount > 1
        let label .= '  [' . wincount . ']'
      endif
      return label
    endfunction
    set guitablabel=%{GuiTabLabel()}
  else
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
            let s .= (i == t ? '%#TabLineSelect#' : '%#TabLine#')
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
            if file == 'index.js'
              let file = fnamemodify(bufname(bufnr), ':p:.:h')
            endif
            if file == ''
              " give a name to no-name documents
              if &buftype=='quickfix'
                let file = '[Quickfix List]'
              else
                let file = '[No Name]'
              endif
            endif
            let s .= ' ' . file . ' '
            " Append the number of windows in the tab page
            if wn > 1
              let s .= ' [' . wn . ']'
            endif
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
    highlight link TabLineSelect SpecialComment
  endif
endif

" vim-signature options
let g:SignatureMarkTextHLDynamic = 1 " Dynamic mark highlight based on gitgutter

" vim-signify options
let g:signify_vcs_list = ['git'] " Default vcs is git
let g:signify_realtime = 1       " Aggressive diffing
let g:signify_sign_change = '~'
let g:signify_sign_delete = '-'
let g:signify_cursorhold_insert = 0 " Disable update in insert mode
highlight SignifySignAdd    cterm=bold ctermbg=235  ctermfg=119 guifg=green
highlight SignifySignDelete cterm=bold ctermbg=235  ctermfg=167 guifg=red
highlight SignifySignChange cterm=bold ctermbg=235  ctermfg=227 guifg=yellow
nnoremap ]df :SignifyHunkDiff<CR>
nnoremap ]du :SignifyHunkUndo<CR>

" Gitv options
let g:Gitv_TruncateCommitSubjects = 1 " Fit log width to split
let g:Gitv_PromptToDeleteMergeBranch = 1 " Delete branch just merged

" Asyncrun options
"if exists(':Make') == 2
"  noautocmd Make
"else
"  silent noautocmd make!
"  redraw!
"  return 'call fugitive#cwindow()'
"endif
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
augroup vimrc
  autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
augroup END

" Modern C++ syntax highlight options
let g:cpp_function_highlight = 1
let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1
let g:cpp_simple_highlight = 0

" clang-format executable
if s:win_shell
  let $PATH.=";C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/Llvm/x64/bin/;C:/Program Files/Microsoft Visual Studio/2022/Preview/VC/Tools/Llvm/x64/bin;"
endif

" Ale options
" Disable ale linting for C/C++ as YCM does it for me
let g:ale_linters = {
      \ 'cpp': [],
      \ 'c': [],
      \}
let g:ale_fixers = {
      \ 'cpp': ['clang-format'],
      \ 'javascript': ['prettier', 'eslint'],
      \ 'python': ['autopep8', 'autoflake'],
      \}
" let g:ale_c_build_dir = '../bld'
let g:ale_c_clangformat_options = '-style="{
      \ AlignAfterOpenBracket : DontAlign,
      \ AlignOperands : false,
      \ AlwaysBreakAfterDefinitionReturnType : None,
      \ AlwaysBreakAfterReturnType : None,
      \ BasedOnStyle : Mozilla,
      \ BinPackArguments : true,
      \ BinPackParameters : true,
      \ BreakBeforeBraces : Allman,
      \ ColumnLimit : 100,
      \ SpaceAfterTemplateKeyword: true,
      \ Standard : C++11}"'
let g:ale_python_autopep8_options = '--max-line-length=100'

" Clang format options
let g:clang_format#style_options = {
      \ "AlignAfterOpenBracket" : "DontAlign",
      \ "AlignOperands" : "false",
      \ "AlwaysBreakAfterDefinitionReturnType" : "None",
      \ "AlwaysBreakAfterReturnType" : "None",
      \ "BasedOnStyle" : "Mozilla",
      \ "BinPackArguments" : "true",
      \ "BinPackParameters" : "true",
      \ "BreakBeforeBraces" : "Allman",
      \ "ColumnLimit" : "100",
      \ "SpaceAfterTemplateKeyword": "true",
      \ "Standard" : "C++11"}

" map to <Leader>cf in C++ code
" Main reason why I need ClangFormat - be able to format only selected code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>

" Key mappings
nmap ]w :ALENextWrap<CR>
nmap [w :ALEPreviousWrap<CR>
" Format echo messages
let g:ale_echo_msg_format = '[%linter%] %code: %%s [%severity%]'
let g:ale_set_loclist = 1

" Goyo options
let g:goyo_width = 100  " (default: 80)
let g:goyo_height = 95  " (default: 85%)
let g:goyo_linenr = 0   " (default: 0)
function! s:goyo_enter()
  set nocindent
endfunction
function! s:goyo_leave()
  set cindent
endfunction
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
nnoremap <leader>pm :Goyo<CR>

" vim-illuminate options
" hi link illuminatedWord ColorColumn
augroup illuminate_augroup
  autocmd!
  autocmd VimEnter * hi illuminatedWord ctermbg=237 guibg=#3a3a3a
  " autocmd VimEnter * hi illuminatedCurWord ctermbg=237 guibg=#00afaf
augroup END

" switch source header
" nmap ,s :call CurtineIncSw()<CR>

" markdown-preview options
nmap <leader>P <Plug>MarkdownPreviewToggle

" vimtex - set tex flavor based on
" help vim-tex-flavor
let g:tex_flavor = 'latex'

" termdebug mappings
nmap <F5> :Continue<CR>
nmap <leader><F5> :Run<CR>
nmap <F10> :Over<CR>
nmap <leader><F10> :Step<CR>
nmap <F9> :Break<CR>
nmap <leader><F9> :Clear<CR>
highlight debugPC term=reverse ctermbg=67 guibg=darkblue

" localvimrc options
let g:localvimrc_ask = 0 " remove prompt asking user to load lvimrc

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif
