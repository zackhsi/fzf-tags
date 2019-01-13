function! fzf_tags#Find(keyword)
  let source_lines = s:source_lines(a:keyword)

  if len(source_lines) == 0
    echohl WarningMsg
    echo 'Tag not found: ' . a:keyword
    echohl None
  elseif len(source_lines) == 1
    execute 'tag' a:keyword
  else
    call fzf#run({
    \   'source': source_lines,
    \   'sink':   function('s:sink'),
    \   'options': '--ansi',
    \   'down': '40%',
    \ })
  endif

endfunction

function! s:source_lines(keyword)
  let relevant_fields = map(
  \   taglist('^' . a:keyword . '$', expand('%:p')),
  \   function('s:tag_to_string')
  \ )
  return map(s:align_lists(relevant_fields), 'join(v:val, " ")')
endfunction

function! s:tag_to_string(index, tag_dict)
  let components = [a:index + 1, s:blue(a:tag_dict['name'])]
  if has_key(a:tag_dict, 'class')
    call add(components, s:green(a:tag_dict['class']))
  endif
  if has_key(a:tag_dict, 'filename')
    call add(components, s:magenta(a:tag_dict['filename']))
  endif
  return components
endfunction

function! s:align_lists(lists)
  let maxes = {}
  for list in a:lists
    let i = 0
    while i < len(list)
      let maxes[i] = max([get(maxes, i, 0), len(list[i])])
      let i += 1
    endwhile
  endfor
  for list in a:lists
    call map(list, "printf('%-'.maxes[v:key].'s', v:val)")
  endfor
  return a:lists
endfunction

function! s:sink(selection)
  let l:count = split(a:selection)[0]
  let identifier = split(a:selection)[1]
  execute l:count . 'tag' identifier
endfunction

function! s:green(s)
  return "\033[32m" . a:s . "\033[m"
endfunction
function! s:blue(s)
  return "\033[34m" . a:s . "\033[m"
endfunction
function! s:magenta(s)
  return "\033[35m" . a:s . "\033[m"
endfunction
