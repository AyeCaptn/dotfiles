local function toggle_sidekick_fullscreen(terminal)
    terminal:hide()
    if terminal.fullscreen_layout then
        terminal.opts.layout = terminal.fullscreen_layout
        terminal.fullscreen_layout = nil
    else
        terminal.fullscreen_layout = terminal.opts.layout
        terminal.opts.layout = "float"
    end
    terminal:focus()
end

return {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },
    {
        "folke/sidekick.nvim",
        keys = {
            {
                "<leader>ac",
                function()
                    require("sidekick.cli.state").with(function(state)
                        if state.terminal then
                            toggle_sidekick_fullscreen(state.terminal)
                        end
                    end, { attach = true, filter = { installed = true } })
                end,
                desc = "Sidekick Toggle Fullscreen",
            },
            {
                "<leader>as",
                function()
                    require("sidekick.cli").select({ filter = { installed = true } })
                end,
                desc = "Select CLI",
            },
            {
                "<leader>aa",
                function()
                    require("sidekick.cli").toggle({ filter = { installed = true } })
                end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<c-.>",
                function()
                    require("sidekick.cli").focus({ filter = { installed = true } })
                end,
                desc = "Sidekick Focus",
                mode = { "n", "t", "i", "x" },
            },
        },
        opts = {
            cli = {
                win = {
                    float = {
                        width = 1,
                        height = 1,
                        row = 0,
                        col = 0,
                        border = "none",
                    },
                    keys = {
                        fullscreen = {
                            "<leader>ac",
                            toggle_sidekick_fullscreen,
                            mode = "n",
                            desc = "Sidekick Toggle Fullscreen",
                        },
                    },
                    config = function(terminal)
                        local function resize()
                            if terminal.opts.layout == "float" then
                                if terminal:win_valid() then
                                    vim.api.nvim_win_set_config(terminal.win, {
                                        relative = "editor",
                                        width = vim.o.columns,
                                        height = vim.o.lines - vim.o.cmdheight,
                                        row = 0,
                                        col = 0,
                                    })
                                end
                                return
                            end
                            if terminal.tool.name ~= "opencode" then
                                return
                            end
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
