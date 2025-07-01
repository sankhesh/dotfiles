" =============================================================================
" Folding, :help fold -> All fold commands start with z
" Options for folds start at :help fcl
set foldenable

" auto open folds in these conditions
set foldopen=block,insert,jump,mark,percent,quickfix,search,tag,undo

function! MyFoldText()
    let line = getline(v:foldstart)
    let numberOfLines = 1 + v:foldend - v:foldstart
    let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
    return v:folddashes .. sub .. ' (' .. numberOfLines .. ' Lines)'
endfunction

if has('nvim')
    " Treesitter folding
    " https://www.reddit.com/r/neovim/comments/16xz3q9/treesitter_highlighted_folds_are_now_in_neovim/
    set foldmethod=expr
    set foldexpr=v:lua.vim.treesitter.foldexpr()
    " set foldtext=v:lua.vim.treesitter.foldtext()
    set foldtext=MyFoldText()
else
    set foldmethod=syntax       " Fold based on indention levels.
    set foldtext=MyFoldText()
endif


" Folds with a level > foldlevel will be closed
" Setting 0 will close all folds
" Setting 99 ensures folds are open by default
set foldlevel=99
set foldlevelstart=-1
set foldnestmax=5               " Only fold up to this many nested levels.
set foldminlines=1              " Only fold if there are at least this many lines.
set fillchars=fold:·,foldopen:,foldclose:

" alias for fold current cursor position for convenience
nnoremap <silent> zz  za

highlight Folded ctermfg=14 ctermbg=236 gui=underdouble guisp=#008080 guifg=#00FFFF guibg=#303030

highlight SignColumn ctermfg=51 ctermbg=234 guifg=#00FFFF guibg=#1C1C1C
highlight LineNr ctermfg=11 ctermbg=234 guifg=#FFFF00 guibg=#1C1C1C
