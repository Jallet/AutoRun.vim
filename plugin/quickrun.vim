"QuickRun - Compile and Run code in vim with hotkeys and output to quickfix
" Author: Liang Jiang
" Email: jiangliang0811@gmail.com

if !exists('g:quickrun_vertical')
  let g:quickrun_vertical = 1
endif

let s:args_path="./.args/%.args"

func! s:RunPython(vertical, size)
  exec "w"
  exec "AsyncRun cat ".s:args_path." 2>/dev/null | xargs python %"
  if a:vertical== 1
    exec "vertical copen ".a:size
  else
    exec "copen ".a:size
  endif
  exec "wincmd w"
endfunc

"function to compile and runn C file
func! s:RunGcc(vertical, size)
  exec "w"
  " exec "AsyncRun gcc % -o %<"
  exec "AsyncRun gcc % -o %< && cat ".s:args_path." 2>/dev/null | xargs ./%<"
  if a:vertical== 1
    exec "vertical copen ".a:size
  else
    exec "copen ".a:size
  endif
  exec "wincmd w"

endfunc
func! s:DebugGcc()
  exec "w"
  exec "!gcc % -o %< -g"
  exec "!cgdb %<"
endfunc


"function to compile and runn C++ file
func! s:RunGpp(vertical, size)
  exec "w"
  exec "AsyncRun g++ % -o %< -g && cat ".s:args_path." 2>/dev/null | xargs ./%<"
  if a:vertical== 1
    exec "vertical copen ".a:size
  else
    exec "copen ".a:size
  endif
  exec "wincmd w"
endfunc

func! s:DebugGpp()
  exec "w"
  exec "!g++ % -o %< -g"
  exec "!cgdb %<"
endfunc

func! s:RunSH(vertical, size)
  exec "w"
  " exec "!chmod a+x %"
  exec "AsyncRun chmod a+x % && cat ".s:args_path." 2>/dev/null | xargs ./%"
  if a:vertical== 1
    exec "vertical copen ".a:size
  else
    exec "copen ".a:size
  endif
  exec "wincmd w"
endfunc

au BufEnter * call s:LastWindow()

"Close quickfix if it's the last window
func! s:LastWindow()
  " if the window is quickfix go on
  if &buftype=="quickfix"
    " if this window is last on screen quit without warning
    if winbufnr(2) == -1
      quit!
    endif
  endif
endfunction

func! QuickRun()
  if g:quickrun_vertical == 1
    let l:size = winwidth(0) / 2
  else
    let l:size = winheight(0) / 2
  endif

  if &ft == 'c'
    call s:RunGcc(g:quickrun_vertical, l:size)
  elseif &ft == 'cpp'
    call s:RunGpp(g:quickrun_vertical, l:size)
  elseif &ft == 'python'
    call s:RunPython(g:quickrun_vertical, l:size)
  elseif &ft == "sh"
    call s:RunSH(g:quickrun_vertical, l:size)
  endif
endfunc

func! QuickDebug()
  if &ft == 'c'
    call s:DebugGcc()
  elseif &ft == 'cpp'
    call s:DebugGpp()
  endif
endfun

func! Mkdir(path)
  if !isdirectory(a:path)
    call mkdir(a:path, "p")
  endif
endfunc

func! OpenArgsFile()
  :execute "below split ".s:args_path
endfunc

autocmd! BufWritePre *.args :call Mkdir(expand("<afile>:p:h"))

command! -nargs=0 QuickRun call QuickRun()
command! -nargs=0 QuickDebug call QuickDebug()
command! -nargs=0 QuickOpenArgs call OpenArgsFile()

nnoremap <leader>r :QuickRun<cr>
nnoremap <leader>d :QuickDebug<cr>
nmap <leader>c :QuickOpenArgs<cr>

