fzf-tags
========

This vim plugin bridges the gap between tags and fzf.vim.

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
