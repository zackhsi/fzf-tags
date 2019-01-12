command! -bar FZFTags :call fzf_tags#Find(expand('<cword>'))
nnoremap <silent> <Plug>(fzf_tags) :FZFTags<Return>
