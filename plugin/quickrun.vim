"QuickRun - Compile and Run code in vim with hotkeys and output to quickfix
" Author: Liang Jiang
" Email: jiangliang0811@gmail.com

let s:args_path="./.args/"

func! s:RunPython()
  exec "w"
  exec "AsyncRun ".s:args_path." 2>/dev/null | xargs python %"
  exec "vertical 80 copen"
  exec "wincmd w"
endfunc

"function to compile and runn C file
func! s:RunGcc()
  exec "w"
  " exec "AsyncRun gcc % -o %<"
  exec "AsyncRun gcc % -o %< && ".s:args_path." 2>/dev/null | xargs ./%<"
  exec "vertical 80 copen"
  exec "wincmd w"

endfunc
func! s:DebugGcc()
  exec "w"
  exec "!gcc % -o %< -g"
  exec "!cgdb %<"
endfunc


"function to compile and runn C++ file
func! s:RunGpp()
  exec "w"
  exec "AsyncRun g++ % -o %< -g && ".s:args_path." 2>/dev/null | xargs ./%<"
  exec "vertical 80 copen"
  exec "wincmd w"
endfunc

func! s:DebugGpp()
  exec "w"
  exec "!g++ % -o %< -g"
  exec "!cgdb %<"
endfunc

func! s:RunSH()
  exec "w"
  " exec "!chmod a+x %"
  exec "AsyncRun chmod a+x % && ".s:args_path." 2>/dev/null | xargs ./%"
  exec "vertical 80 copen"
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
  if &ft == 'c'
    call s:RunGcc()
  elseif &ft == 'cpp'
    call s:RunGpp()
  elseif &ft == 'python'
    call s:RunPython()
  elseif &ft == "sh"
    call s:RunSH()
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
  :echo s:args_path
  :execute "below split ".s:args_path."%.args"
endfunc

autocmd! BufWritePre *.args :call Mkdir(expand("<afile>:p:h"))

command! -nargs=0 QuickRun call QuickRun()
command! -nargs=0 QuickDebug call QuickDebug()
command! -nargs=0 QuickOpenArgs call OpenArgsFile()

nnoremap <leader>r :QuickRun<cr>
nnoremap <leader>d :QuickDebug<cr>
nmap <leader>c :call :QuickOpenArgs<cr>

" autocmd FileType python map <leader>r :call RunPython()<cr>
" autocmd FileType sh map <leader>r :call RunSH()<cr>
" autocmd FileType c map <leader>r :call RunGcc()<cr>
" autocmd FileType c map <leader>d :call DebugGcc()<cr>
" autocmd FileType cpp map <leader>r :call RunGpp()<cr>
" autocmd FileType cpp map <leader>d :call DebugGpp()<cr>

" Open arguments files of current file
