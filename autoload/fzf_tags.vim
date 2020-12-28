scriptencoding utf-8

if !exists('g:fzf_tags_prompt')
  let g:fzf_tags_prompt = ' 🔎 '
endif

let s:actions = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

function! fzf_tags#SelectCommand(identifier)
  let identifier = empty(a:identifier) ? s:tagstack_head() : a:identifier
  if empty(identifier)
    echohl Error
    echo "Tag stack empty"
    echohl None
  else
    call fzf_tags#Find(identifier)
  endif
endfunction

function! fzf_tags#FindCommand(identifier)
  return fzf_tags#Find(empty(a:identifier) ? s:get_identifier() : a:identifier)
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
    call fzf#run({
    \   'source': source_lines,
    \   'sink*':   function('s:sink', [identifier]),
    \   'options': '--expect=' . expect_keys . ' --ansi --no-sort --tiebreak index --prompt "' . g:fzf_tags_prompt . '\"' . identifier . '\" > "',
    \   'down': '40%',
    \ })
  endif
endfunction

function! s:tagstack_head()
  let stack = gettagstack()
  return stack.length != 0 ? stack.items[-1].tagname : ""
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

" Get identifier like: is_it_method? instead of is_it_method
function! s:get_identifier()
  let suffix_symbols = '!?'
  let identifier_pattern = '\' . expand('<cword>') . '[' .suffix_symbols . ']' . '\|' . expand('<cword>')
  return matchstr(expand('<cWORD>'), identifier_pattern)
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
