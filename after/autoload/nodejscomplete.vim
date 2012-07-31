" Vim completion script
" Language:	Javascript(node)
" Maintainer:	Lin Zhang ( myhere.2009 AT gmail DOT com )
" Last Change:	2012-7-31 14:14:02

" save current dir
let s:nodejs_doc_file = expand('<sfile>:p:h') . '/nodejs-doc.vim'

function! nodejscomplete#CompleteJS(findstart, base)
  if a:findstart
    let start = javascriptcomplete#CompleteJS(a:findstart, a:base)

    " complete context
    let line = getline('.')
    let b:nodecompl_context = line[0:start-1]
    "Decho 'start: ' . start
    return start
  else
    let nodeCompl = nodejscomplete#FindNodeComplete(a:base)
    let jsCompl = javascriptcomplete#CompleteJS(a:findstart, a:base)

    return nodeCompl + jsCompl
  endif
endfunction


" complete node's build-in module
function! nodejscomplete#FindNodeComplete(base)
  " get complete context
  let context = b:nodecompl_context
  unlet b:nodecompl_context

  "Decho 'context: ' . context
  "Decho 'base: ' . a:base

  let ret = []

  " get object name
  let obj_name = matchstr(context, '\k\+\ze\.$')

  if (len(obj_name) == 0) " variable complete
    let ret = nodejscomplete#GetVariableComplete(context, a:base)
  else " module complete
    "Decho 'obj_name: ' . obj_name

    " get variable declared line number
    let decl_line = search(obj_name . '\s*=\s*require\s*(.\{-})', 'bn')
    "Decho 'decl_line: ' . decl_line

    if (decl_line == 0) 
      " maybe a global module
      let ret = nodejscomplete#GetModuleComplete(obj_name, a:base, 'globals')
    else
      " find the node module name
      let mod_name = matchstr(getline(decl_line), obj_name . '\s*=\s*require\s*(\s*\([''"]\)\zs.\{-}\ze\(\1\)\s*)')

      if exists('mod_name')
        let ret = nodejscomplete#GetModuleComplete(mod_name, a:base, 'modules')
      endif
    endif
  endif

  return ret
endfunction


function! nodejscomplete#GetModuleComplete(mod_name, prop_name, type)
  "Decho 'mod_name: ' . a:mod_name
  "Decho 'prop_name: ' . a:prop_name
  "Decho 'type: ' . a:type

  call nodejscomplete#LoadNodeDocData()

  let ret = []
  let mods = {}
  let mod = []

  if (has_key(g:nodejs_complete_data, a:type))
    let mods = g:nodejs_complete_data[a:type]
  endif

  if (has_key(mods, a:mod_name))
    let mod = mods[a:mod_name]
  endif

  " no prop_name suplied
  if (len(a:prop_name) == 0)
    let ret = mod
  else
    " filter properties with prop_name
    let ret = filter(copy(mod), 'v:val["word"] =~# "' . a:prop_name . '"')
  endif
  "Decho string(ret)

  return ret
endfunction


function! nodejscomplete#GetVariableComplete(context, var_name)
  "Decho 'var_name: ' . a:var_name

  " complete require's arguments
  let matched = matchlist(a:context, 'require\s*(\s*\([''"]\)\=$')
  if (len(matched) > 0)
    "Decho 'require: ' . string(matched)

    let mod_names = nodejscomplete#GetModuleNames()
    if (len(matched[1]) == 0)     " complete -> require(
      call map(mod_names, '"''" . v:val . "'')"')
    elseif (len(a:var_name) == 0) " complete -> require('
      call map(mod_names, 'v:val . "' . escape(matched[1], '"') . ')"')
    else                          " complete -> require('ti
      let mod_names = filter(mod_names, 'v:val =~# "^' . a:var_name . '"')
      call map(mod_names, 'v:val . "' . escape(matched[1], '"') . ')"')
    endif

    return mod_names
  endif

  " complete global variables
  let vars = []
  if (len(a:var_name) == 0)
    return vars
  endif

  call nodejscomplete#LoadNodeDocData()

  if (has_key(g:nodejs_complete_data, 'vars'))
    let vars = g:nodejs_complete_data.vars
  endif

  let ret = filter(copy(vars), 'v:val["word"] =~# "^' . a:var_name . '"')

  return ret
endfunction


function! nodejscomplete#GetModuleNames()
  call nodejscomplete#LoadNodeDocData()

  let mod_names = []
  if (has_key(g:nodejs_complete_data, 'modules'))
    let mod_names = keys(g:nodejs_complete_data.modules)
  endif

  return sort(mod_names)
endfunction


function! nodejscomplete#LoadNodeDocData()
  " load node module data
  if (!exists('g:nodejs_complete_data'))
    " load data from external file
    let filename = s:nodejs_doc_file
    "Decho 'filename: ' . filename
    if (filereadable(filename))
      "Decho 'readable'
      execute 'so ' . filename
      "Decho string(g:nodejs_complete_data)
    else
      "Decho 'not readable'
    endif
  endif
endfunction


"
" use plugin Decho(https://github.com/vim-scripts/Decho) for debug
"
" turn off debug mode
" :%s;^\(\s*\)\(Decho\);\1"\2;g
"
" turn on debug mode
" :%s;^\(\s*\)"\(Decho\);\1\2;g
"
