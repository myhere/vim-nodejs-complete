function! nodejscomplete#CompleteJS(findstart, base)
  if a:findstart
    return javascriptcomplete#CompleteJS(a:findstart, a:base)
  else
    let a:jsRet = javascriptcomplete#CompleteJS(a:findstart, a:base)
    let a:ret = ['hello-world']

    return a:ret + a:jsRet
  endif
endfunction
