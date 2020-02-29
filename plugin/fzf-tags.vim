command! -nargs=? -bar FZFTags :call fzf_tags#FindCommand(<q-args>)
nnoremap <silent> <Plug>(fzf_tags) :FZFTags<Return>
