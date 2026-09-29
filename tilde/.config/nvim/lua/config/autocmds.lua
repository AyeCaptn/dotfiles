local api = vim.api

-- Close a dap-ui widget with q
api.nvim_create_autocmd("FileType", {
  pattern = { "dap-float" },
  command = [[nnoremap <buffer><silent> q <cmd>close!<CR>]],
})

-- Preserve modified Return when OpenCode runs inside a Neovim terminal.
api.nvim_create_autocmd("TermOpen", {
  callback = function(event)
    local name = (" " .. api.nvim_buf_get_name(event.buf):lower() .. " ")
    if not name:find("[/:%s]opencode[%s]") then
      return
    end

    vim.keymap.set("t", "<M-CR>", function()
      local job = vim.b[event.buf].terminal_job_id
      if job then
        api.nvim_chan_send(job, "\27[13;3u")
      end
    end, {
      buffer = event.buf,
      desc = "Queue OpenCode prompt",
      silent = true,
    })
  end,
})
