return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            metals = {
                keys = {
                    {
                        "<leader>me",
                        function()
                            require("telescope").extensions.metals.commands()
                        end,
                        desc = "Metals commands",
                    },
                    {
                        "<leader>mc",
                        function()
                            require("metals").compile_cascade()
                        end,
                        desc = "Metals compile cascade",
                    },
                },
                init_options = {
                    statusBarProvider = "off",
                },
                settings = {
                    showImplicitArguments = true,
                    excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
                },
            },
        },
        setup = {
            metals = function(_, opts)
                local metals = require("metals")
                local metals_config = vim.tbl_deep_extend("force", metals.bare_config(), opts)
                metals_config.find_root_dir_max_project_nesting = 4
                metals_config.on_attach = LazyVim.has("nvim-dap") and metals.setup_dap or nil

                local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = { "scala", "sbt" },
                    callback = function()
                        metals.initialize_or_attach(metals_config)
                    end,
                    group = nvim_metals_group,
                })
                return true
            end,
        },
    },
}
