function! nodejscomplete#CompleteJS(findstart, base)
  if a:findstart
    return javascriptcomplete#CompleteJS(a:findstart, a:base)
  else
    let nodeCompl = nodejscomplete#FindNodeComplete(a:base)
    let jsCompl = javascriptcomplete#CompleteJS(a:findstart, a:base)

    return nodeCompl + jsCompl
  endif
endfunction

" complete node's build-in module
function! nodejscomplete#FindNodeComplete(base)
    let context = getline('.')

    Decho 'context: ' . context

    let ret = []
    " fs.
    let var_name = matchstr(context, '\k\+\ze\.$')
    if (len(var_name) == 0)
        return ret
    endif

    Decho 'var_name: ' . var_name

    let decl_line = search(var_name . '\s*=\s*require\s*(.\{-})', 'bn')
    if (decl_line == 0) 
        return ret
    endif
    let mod_name = matchstr(getline(decl_line), var_name . '\s*=\s*require\s*(\s*\(["' . "'" . ']\)\zs.\{-}\ze\(\1\)\s*)')

    if exists('mod_name')
        let ret = ret + nodejscomplete#GetModData(mod_name, a:base)
    endif

    return ret

endfunction

function! nodejscomplete#GetModData(mod_name, prop_name)
    Decho 'mod_name: ' . a:mod_name
    Decho 'prop_name: ' . a:prop_name

    return ['myhere']
endfunction
