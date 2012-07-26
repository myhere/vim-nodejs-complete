" Vim completion script
" Language:	Javascript
" Maintainer:	Lin Zhang ( myhere.2009 AT gmail DOT com )
" Last Change:	2012-7-26 12:36:45

" save current dir
let s:nodejs_doc_file = expand('<sfile>:p:h') . '/nodejs-doc.vim'

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
    "Decho 'context: ' . context

    let ret = []

    " get variable name
    let var_name = matchstr(context, '\k\+\ze\.$')
    if (len(var_name) == 0)
        return ret
    endif

    "Decho 'var_name: ' . var_name

    " get variable declared line number
    let decl_line = search(var_name . '\s*=\s*require\s*(.\{-})', 'bn')
    if (decl_line == 0) 
        return ret
    endif
    " find the node module name
    let mod_name = matchstr(getline(decl_line), var_name . '\s*=\s*require\s*(\s*\(["' . "'" . ']\)\zs.\{-}\ze\(\1\)\s*)')

    if exists('mod_name')
        let ret = ret + nodejscomplete#GetModData(mod_name, a:base)
    endif

    return ret

endfunction

function! nodejscomplete#GetModData(mod_name, prop_name)
    "Decho 'mod_name: ' . a:mod_name
    "Decho 'prop_name: ' . a:prop_name

    " load node module data
    if (!exists('g:nodejs_complete_modules'))
      " load data from external file
      let filename = s:nodejs_doc_file
      "Decho 'filename: ' . filename
      if (filereadable(filename))
        "Decho 'readable'
        execute 'so ' . filename
        "Decho string(g:nodejs_complete_modules)
      else
        "Decho 'not readable'
      endif
    endif

    let ret = []

    if (!has_key(g:nodejs_complete_modules, a:mod_name))
      return ret
    endif

    let mod = copy(g:nodejs_complete_modules[a:mod_name])

    " no prop_name suplied
    if (len(a:prop_name) == 0)
      let ret = mod
      "Decho string(mod)
    else
      " filter properties with prop_name
      let ret = filter(mod, 'v:val["word"] =~# "' . a:prop_name . '"')
    endif

    return ret
endfunction


"
" use plugin Decho(https://github.com/vim-scripts/Decho) for debug
"
" switch off debug
" :%s;^\(\s*\)\(Decho\);\1"\2;g
"
" switch on debug
" :%s;^\(\s*\)"\(Decho\);\1\2;g
"
