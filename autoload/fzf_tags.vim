scriptencoding utf-8

let s:actions = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'
  \ }

let s:preview_cmd = [
  \'--preview-window="up:50%"',
  \ '--preview="',
  \ 'bat ',
  \ '--number',
  \ '--color always',
  \ '--theme OneHalfDark',
  \ '--line-range {4}:',
  \ '--highlight-line {3} {2}"'
  \ ]

function! fzf_tags#FindCommand(identifier)
  return fzf_tags#Find(empty(a:identifier) ? expand('<cword>') : a:identifier)
endfunction

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
    let expect_keys = join(keys(s:actions), ',')
    let preview_source_cmd = join(s:preview_cmd, ' ')
    call fzf#run({
    \   'source': source_lines,
    \   'sink*':   function('s:sink', [identifier]),
    \   'options': preview_source_cmd . ' --expect=' . expect_keys . ' --with-nth 1,2,3 --ansi --no-sort --tiebreak index --prompt " � \"' . identifier . '\" > "',
    \   'window': { 'width': 0.90, 'height': 0.90, 'border': 'sharp'} 
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
  if has_key(a:tag_dict, 'line')
    call add(components, s:green(a:tag_dict['line']))
    if (a:tag_dict['line'] > 8) 
      call add(components, s:green(a:tag_dict['line'] - 8))
    else
      call add(components, s:green(a:tag_dict['line']))
    endif
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
  let selected_with_key = a:selection[0]
  let selected_text = a:selection[1]

  " Open new split or tab.
  if has_key(s:actions, selected_with_key)
    execute 'silent' s:actions[selected_with_key]
  endif

  " Go to tag!
  let l:count = split(selected_text)[0]
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
