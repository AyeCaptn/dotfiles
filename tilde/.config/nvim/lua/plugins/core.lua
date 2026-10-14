return {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },
    {
        "folke/sidekick.nvim",
        opts = {
            cli = {
                win = {
                    config = function(terminal)
                        if terminal.tool.name ~= "opencode" then
                            return
                        end

                        local function resize()
                            -- Vertical tabs need 106 columns; leave at least 100 for the editor.
                            local minimum = vim.o.columns >= 206 and 106 or 80
                            local width = math.max(minimum, math.floor(vim.o.columns * 0.33))
                            terminal.opts.split.width = width
                            if terminal:win_valid() then
                                vim.api.nvim_win_set_width(terminal.win, width)
                            end
                        end

                        resize()
                        vim.api.nvim_create_autocmd("VimResized", {
                            group = terminal.group,
                            callback = resize,
                        })
                    end,
                },
            },
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin-macchiato",
        },
    },
}
