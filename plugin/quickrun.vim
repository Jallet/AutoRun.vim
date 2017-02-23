"QuickRun - Compile and Run code in vim with hotkeys and output to quickfix
" Author: Liang Jiang
" Email: jiangliang0811@gmail.com

if !exists('g:quickrun_mode')
  let g:quickrun_mode = "dynamic"
endif

let s:args_path="./.args/%.args"

func! s:RunPython(mode, size)
  exec "w"
  exec "AsyncRun cat ".s:args_path." 2>/dev/null | xargs python %"
  if a:mode== 'vertical'
    exec "vertical copen ".a:size
  elseif a:mode == 'horizontal'
    exec "below copen ".a:size
  endif
  exec "wincmd p"
endfunc

"function to compile and runn C file
func! s:RunGcc(mode, size)
  exec "w"
  " exec "AsyncRun gcc % -o %<"
  exec "AsyncRun gcc % -o %< && cat ".s:args_path." 2>/dev/null | xargs ./%<"
  if a:mode== 'vertical'
    exec "vertical copen ".a:size
  elseif a:mode == 'horizontal'
    exec "below copen ".a:size
  endif
  exec "wincmd p"

endfunc
func! s:DebugGcc()
  exec "w"
  exec "!gcc % -o %< -g"
  exec "!cgdb %<"
endfunc


"function to compile and runn C++ file
func! s:RunGpp(mode, size)
  exec "w"
  exec "AsyncRun g++ % -o %< -g && cat ".s:args_path." 2>/dev/null | xargs ./%<"
  if a:mode== 'vertical'
    exec "vertical copen ".a:size
  elseif a:mode == 'horizontal'
    exec "below copen ".a:size
  endif
  exec "wincmd p"
endfunc

func! s:DebugGpp()
  exec "w"
  exec "!g++ % -o %< -g"
  exec "!cgdb %<"
endfunc

func! s:RunSH(mode, size)
  exec "w"
  " exec "!chmod a+x %"
  exec "AsyncRun chmod a+x % && cat ".s:args_path." 2>/dev/null | xargs ./%"
  if a:mode== 'vertical'
    exec "vertical copen ".a:size
  elseif a:mode == 'horizontal'
    exec "below copen ".a:size
  endif
  exec "wincmd p"
endfunc

func! s:RunLua(mode, size)
  exec "w"
  exec "AsyncRun cat ".s:args_path." 2>/dev/null | xargs th %"
  if a:mode== 'vertical'
    exec "vertical copen ".a:size
  elseif a:mode == 'horizontal'
    exec "below copen ".a:size
  endif
  exec "wincmd p"
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
  :execute "cclose"
  let quickrun_size = 0
  let quickrun_mode = ""
  if g:quickrun_mode == "vertical"
    let l:quickrun_mode = "vertical"
  elseif g:quickrun_mode == "horizontal"
    let l:quickrun_mode = "horizontal"
  else
    if winwidth(0) > &columns / 2
      let l:quickrun_mode = "vertical"
    else
      let l:quickrun_mode = "horizontal"
    endif
  endif
  if l:quickrun_mode == "vertical"
    if !exists('g:quickrun_width')
      let l:quickrun_size = winwidth(0) / 3
    else
      let l:quickrun_size = g:quickrun_width
    endif

  elseif l:quickrun_mode == "horizontal"
    if !exists('g:quickrun_height')
      let l:quickrun_size = winheight(0) / 3
    else
      let l:quickrun_size = g:quickrun_height
    endif
  endif
  if &ft == 'c'
    call s:RunGcc(l:quickrun_mode, l:quickrun_size)
  elseif &ft == 'cpp'
    call s:RunGpp(l:quickrun_mode, l:quickrun_size)
  elseif &ft == 'python'
    call s:RunPython(l:quickrun_mode, l:quickrun_size)
  elseif &ft == "sh"
    call s:RunSH(l:quickrun_mode, l:quickrun_size)
  elseif &ft == 'lua'
    call s:RunLua(l:quickrun_mode, l:quickrun_size)
  endif
  let g:qfix_win = bufnr("$")
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

function! QuickToggleOutput(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    let quickrun_size = 0
    let quickrun_mode = ""
    if g:quickrun_mode == "vertical"
      let l:quickrun_mode = "vertical"
    elseif g:quickrun_mode == "horizontal"
      let l:quickrun_mode = "horizontal"
    else
      if winwidth(0) > &columns / 2
        let l:quickrun_mode = "vertical"
      else
        let l:quickrun_mode = "horizontal"
      endif
    endif
    if l:quickrun_mode == "vertical"
      if !exists('g:quickrun_width')
        let l:quickrun_size = winwidth(0) / 2
      else
        let l:quickrun_size = g:quickrun_width
      endif

    elseif l:quickrun_mode == "horizontal"
      if !exists('g:quickrun_height')
        let l:quickrun_size = winheight(0) / 2
      else
        let l:quickrun_size = g:quickrun_height
      endif
    endif
    if l:quickrun_mode == 'vertical'
      exec "vertical copen ".l:quickrun_size
    elseif l:quickrun_mode == 'horizontal'
      exec "below copen ".l:quickrun_size
    endif
    let g:qfix_win = bufnr("$")
  endif
endfunction


autocmd! BufWritePre *.args :call Mkdir(expand("<afile>:p:h"))

command! -nargs=0 QuickRun call QuickRun()
command! -nargs=0 QuickDebug call QuickDebug()
command! -nargs=0 QuickOpenArgs call OpenArgsFile()
command! -bang -nargs=? QuickToggleOutput call QuickToggleOutput(<bang>0)

nnoremap <leader>r :QuickRun<cr>
nnoremap <leader>d :QuickDebug<cr>
nmap <leader>c :QuickOpenArgs<cr>
nmap <leader><leader>c :QuickToggleOutput<cr>

