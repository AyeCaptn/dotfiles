return {
    "obsidian-nvim/obsidian.nvim",
    event = {
        "BufReadPre " .. vim.fn.expand("~") .. "/Projects/Repos/obsidian-vault-engie/**.md",
        "BufNewFile " .. vim.fn.expand("~") .. "/Projects/Repos/obsidian-vault-engie/**.md",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    -- LazyVim-style keymaps
    keys = {
        -- Smart action (follow link, toggle checkbox, cycle folds)
        {
            "<cr>",
            function()
                return require("obsidian").util.smart_action()
            end,
            desc = "Obsidian smart action",
            ft = "markdown",
            expr = true,
        },
        -- Toggle checkbox
        {
            "<leader>ch",
            function()
                return require("obsidian").util.toggle_checkbox()
            end,
            desc = "Toggle checkbox",
            ft = "markdown",
        },
        -- Navigate to next/previous links
        {
            "]o",
            function()
                return require("obsidian").util.nav_link("next")
            end,
            desc = "Next Obsidian link",
            ft = "markdown",
        },
        {
            "[o",
            function()
                return require("obsidian").util.nav_link("prev")
            end,
            desc = "Previous Obsidian link",
            ft = "markdown",
        },

        -- Command keymaps (globally available)
        { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New Obsidian note" },
        { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch notes" },
        { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
        { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's note" },
        { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
        { "<leader>om", "<cmd>Obsidian tomorrow<cr>", desc = "Tomorrow's note" },
        { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks" },
        { "<leader>og", "<cmd>Obsidian tags<cr>", desc = "Search tags" },
        { "<leader>oi", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
        { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },

        -- Visual mode keymaps (globally available)
        { "<leader>ol", "<cmd>Obsidian link<cr>", desc = "Link selection", mode = "v" },
        { "<leader>on", "<cmd>Obsidian link_new<cr>", desc = "Link to new note", mode = "v" },
        { "<leader>oe", "<cmd>Obsidian extract_note<cr>", desc = "Extract to note", mode = "v" },
    },

    opts = {
        workspaces = {
            {
                name = "engie",
                path = "/Users/sem/Projects/Repos/obsidian-vault-engie",
            },
        },

        -- Disable legacy commands (recommended)
        legacy_commands = false,

        -- Configure note ID generation (custom Zettelkasten format)
        note_id_func = function(title)
            local suffix = ""
            if title ~= nil then
                suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
                for _ = 1, 4 do
                    suffix = suffix .. string.char(math.random(65, 90))
                end
            end
            return tostring(os.time()) .. "-" .. suffix
        end,

        -- Organize notes in a subfolder
        notes_subdir = "notes",

        -- Configure daily notes
        daily_notes = {
            folder = "daily",
            alias_format = "%B %-d, %Y",
            workdays_only = false, -- Different from default (true)
        },

        -- Custom image folder location
        attachments = {
            folder = "assets/imgs",
        },
    },
}
