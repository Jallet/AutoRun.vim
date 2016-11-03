"AutoRun - Compile and Run code in vim with hotkeys and output to quickfix
" Author: Liang Jiang
" Email: jiangliang0811@gmail.com

func! RunPython()
  exec "w"
  exec "AsyncRun cat ./.args/.%.args 2>/dev/null | xargs python %"
  exec "vertical 80 copen"
  exec "wincmd w"
endfunc

"function to compile and runn C file
func! RunGcc()
  exec "w"
  " exec "AsyncRun gcc % -o %<"
  exec "AsyncRun gcc % -o %< && cat ./.args/.%.args 2>/dev/null | xargs ./%<"
  exec "vertical 80 copen"
  exec "wincmd w"

endfunc
func!  DebugGcc()
  exec "w"
  exec "!gcc % -o %< -g"
  exec "!cgdb %<"
endfunc


"function to compile and runn C++ file
func! RunGpp()
  exec "w"
  exec "AsyncRun g++ % -o %< -g && cat ./.args/.%.args 2>/dev/null | xargs ./%<"
  exec "vertical 80 copen"
  exec "wincmd w"
endfunc

func!  DebugGpp()
  exec "w"
  exec "!g++ % -o %< -g"
  exec "!cgdb %<"
endfunc

func! RunSH()
  exec "w"
  exec "!chmod a+x %"
  exec "AsyncRun cat ./.args/.%.args 2>/dev/null | xargs ./%"
  exec "vertical 80 copen"
  exec "wincmd w"
endfunc
au BufEnter * call MyLastWindow()

"Close quickfix if it's the last window
function! MyLastWindow()
  " if the window is quickfix go on
  if &buftype=="quickfix"
    " if this window is last on screen quit without warning
    if winbufnr(2) == -1
      quit!
    endif
  endif
endfunction

autocmd FileType python map <leader>r :call RunPython()<cr>
autocmd FileType sh map <leader>r :call RunSH()<cr>
autocmd FileType c map <leader>r :call RunGcc()<cr>
autocmd FileType c map <leader>d :call DebugGcc()<cr>
autocmd FileType cpp map <leader>r :call RunGpp()<cr>
autocmd FileType cpp map <leader>d :call DebugGpp()<cr>

" Open arguments files of current file
nmap <leader>c :below split .args/.%.args<cr>
