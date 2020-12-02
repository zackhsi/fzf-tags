command! -nargs=? -bar FZFTags :call fzf_tags#FindCommand(<q-args>)
command! -nargs=? -bar FZFTselect :call fzf_tags#SelectCommand(<q-args>)
nnoremap <silent> <Plug>(fzf_tags) :FZFTags<Return>
