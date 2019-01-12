function! fzf_tags#Find(keyword)
  let source_lines = s:source_lines(a:keyword)

  if len(source_lines) == 0
    echohl WarningMsg
    echo 'Tag not found: ' . a:keyword
    echohl None
    return
  elseif len(source_lines) == 1
    execute 'tag' a:keyword
    return
  endif

  call fzf#run({
  \   'source': source_lines,
  \   'sink':   function('s:sink'),
  \ })
endfunction

function! s:source_lines(keyword)
  let relevant_fields = map(
  \   taglist('^' . a:keyword . '$', expand('%:p')),
  \   function('s:tag_to_string')
  \ )
  return map(s:align_lists(relevant_fields), 'join(v:val, "\t")')
endfunction

function! s:tag_to_string(index, tag_dict)
  let components = [a:index + 1, a:tag_dict['name']]
  call add(components, "\n")
  if has_key(a:tag_dict, 'class')
    call add(components, a:tag_dict['class'])
  endif
  if has_key(a:tag_dict, 'filename')
    call add(components, a:tag_dict['filename'])
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
  execute 'tag' split(a:selection)[1]
endfunction
