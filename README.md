fzf-tags
========

`fzf-tags` bridges the gap between tags and fzf.vim.

It combines `:tag` and `:tselect` into a single improved command.

`:FZFTags` looks up the identifier under the cursor.
- If there are 0 or 1 definitions, the behavior is same as `:tag`.
- When there are multiple definitions, the results are piped to fzf for
  interactive filtering (https://github.com/junegunn/fzf#search-syntax).

`:FZFTselect` behaves just like `:tselect`.
- Loads the tags matching the argument into an FZF window.
- If no argument is provided, the last tag on the tag-stack is used.

This plugin uses the built-in `:tag` command under the hood, which
yields a couple benefits.

- Tag stack management works as expected (CTRL-T or `:pop` return you
  to your previous location).
- Tag priority works as expected (`:help tag-priority`).

Installation
------------

```vim
Plug 'zackhsi/fzf-tags'
```

Configuration
-------------

`fzf-tags` exposes the `<Plug>(fzf_tags)` mapping.

To override the default jump-to-tag binding:

```vim
nmap <C-]> <Plug>(fzf_tags)
```

Additionally, `fzf-tags` exposes a fuzzy `:tselect`. To replace the default `:ts`:

```vim
noreabbrev <expr> ts getcmdtype() == ":" && getcmdline() == 'ts' ? 'FZFTselect' : 'ts'
```

To replace the default prompt `🔎`:

```vim
let g:fzf_tags_prompt = "Gd "
```

Fzf-tags inherits layout configuration from `fzf.vim`, but if you want a different layout from `fzf.vim`:
```
let g:fzf_tags_layout = { 
  \ 'window': {
    \ 'width': 0.7,
    \ 'height': 0.5,
    \ 'xoffset': 0.5,
    \ 'yoffset': 0.7 
    \ }
  \ }
```
