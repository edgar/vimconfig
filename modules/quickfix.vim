nmap <LEADER>b :<C-u>make<CR>

au FileType qf nnoremap <silent><buffer> q :<C-u>cclose<CR>
au QuickFixCmdPost make call OpenQuickFixBuffer()

" Depends on MarkLines in order to work
" see: 
"  * modules/marklines.vim
"  * :help marklines
function! HighlightQuickFixLines(qflist)
  if exists('g:marklines_loaded') && !empty(a:qflist)
    let l:curPos = getpos('.')
    " We clear all the previous Higlights
    %MarkLinesOff
    " We save the cursor position
    for qferror in a:qflist
      exec qferror.lnum . 'MarkLinesOn'
    endfor
    " we keep the cursor in the same place
    call setpos('.', l:curPos)
  endif
endfunction

function! OpenQuickFixBuffer()
  let l:qflist = getqflist()
  if empty(l:qflist)
    cclose
  else
    call HighlightQuickFixLines(l:qflist)
    copen
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

au FileType haskell call QuickFixHaskell()

function! QuickFixHaskell()
  let l:cabalFilePresent = filereadable(glob('*.cabal'))
  if l:cabalFilePresent
    setl makeprg=cabal\ build
  else
    let l:currentFile = expand('%')
    if !exists('b:qfOutputdir')
      let b:qfOutputdir = tempname()
      call mkdir(b:qfOutputdir)
    endif
    let &l:makeprg = 'ghc --make % -outputdir ' . b:qfOutputdir
  endif 

  setl errorformat=
                   \%-Z\ %#,
                   \%W%f:%l:%c:\ Warning:\ %m,
                   \%E%f:%l:%c:\ %m,
                   \%E%>%f:%l:%c:,
                   \%+C\ \ %#%m,
                   \%W%>%f:%l:%c:,
                   \%+C\ \ %#%tarning:\ %m,
endfunction