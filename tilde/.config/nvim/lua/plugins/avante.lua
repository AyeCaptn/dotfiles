return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
        provider = "claude",
        cursor_applying_provider = "openai",
        copilot = {
            endpoint = "https://api.githubcopilot.com",
            model = "claude-3.7-sonnet",
            proxy = nil, -- [protocol://]host[:port] Use this proxy
            allow_insecure = false, -- Allow insecure server connections
            timeout = 30000, -- Timeout in milliseconds
            temperature = 0,
            max_tokens = 4096,
            disable_tools = true,
        },
        openai = {
            endpoint = "https://api.openai.com/v1",
            model = "gpt-4o-mini", -- your desired model (or use gpt-4o, etc.)
            timeout = 30000, -- timeout in milliseconds
            temperature = 0, -- adjust if needed
            max_tokens = 4096,
            api_key_name = "cmd:cat /Users/sem/.openai",
            -- reasoning_effort = "high" -- only supported for reasoning models (o1, etc.)
        },
        behaviour = {
            --- ... existing behaviours
            enable_cursor_planning_mode = false, -- enable cursor planning mode!
            enable_claude_text_editor_tool_mode = false,
        },
        claude = {
            endpoint = "https://api.anthropic.com",
            model = "claude-3-7-sonnet-latest",
            timeout = 30000,
            temperature = 0,
            max_tokens = 4096,
            ["local"] = false,
            api_key_name = "cmd:cat /Users/sem/.anthropic",
            disable_tools = true,
        },
    },
    build = "make",
    dependencies = {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to set this up properly if you have lazy=true
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
