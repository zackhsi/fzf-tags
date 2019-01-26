scriptencoding utf-8

function! fzf_tags#Find(identifier)
  let identifier = s:strip_leading_bangs(a:identifier)
  let source_lines = s:source_lines(identifier)

  if len(source_lines) == 0
    echohl WarningMsg
    echo 'Tag not found: ' . identifier
    echohl None
  elseif len(source_lines) == 1
    execute 'tag' identifier
  else
    call fzf#run({
    \   'source': source_lines,
    \   'sink':   function('s:sink', [identifier]),
    \   'options': '--ansi --no-sort --tiebreak index --prompt " 🔎 \"' . identifier . '\" > "',
    \   'down': '40%',
    \ })
  endif
endfunction

function! s:strip_leading_bangs(identifier)
  if (a:identifier[0] !=# '!')
    return a:identifier
  else
    return s:strip_leading_bangs(a:identifier[1:])
  endif
endfunction

function! s:source_lines(identifier)
  let relevant_fields = map(
  \   taglist('^' . a:identifier . '$', expand('%:p')),
  \   function('s:tag_to_string')
  \ )
  return map(s:align_lists(relevant_fields), 'join(v:val, " ")')
endfunction

function! s:tag_to_string(index, tag_dict)
  let components = [a:index + 1]
  if has_key(a:tag_dict, 'filename')
    call add(components, s:magenta(a:tag_dict['filename']))
  endif
  if has_key(a:tag_dict, 'class')
    call add(components, s:green(a:tag_dict['class']))
  endif
  if has_key(a:tag_dict, 'cmd')
    call add(components, s:red(a:tag_dict['cmd']))
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

function! s:sink(identifier, selection)
  let l:count = split(a:selection)[0]
  execute l:count . 'tag' a:identifier
endfunction

function! s:green(s)
  return "\033[32m" . a:s . "\033[m"
endfunction
function! s:magenta(s)
  return "\033[35m" . a:s . "\033[m"
endfunction
function! s:red(s)
  return "\033[31m" . a:s . "\033[m"
endfunction
