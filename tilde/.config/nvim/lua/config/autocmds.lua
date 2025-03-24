local api = vim.api

-- Close a dap-ui widget with q
api.nvim_create_autocmd("FileType", {
  pattern = { "dap-float" },
  command = [[nnoremap <buffer><silent> q <cmd>close!<CR>]],
})
