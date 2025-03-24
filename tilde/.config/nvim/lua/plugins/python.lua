return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "ninja", "rst" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = {
                enabled = true,
            },
            servers = {
                pylance = {
                    cmd = {
                        "node",
                        vim.fn.expand(
                            "~/.vscode/extensions/ms-python.vscode-pylance-2025.3.1/dist/server_nvim.js",
                            false,
                            true
                        )[1],
                        "--stdio",
                    },
                    settings = {
                        python = {
                            analysis = {
                                inlayHints = {
                                    variableTypes = false,
                                    functionReturnTypes = true,
                                    callArgumentNames = false,
                                },
                                typeCheckingMode = "basic",
                                autoImportCompletions = true,
                                enablePytestSupport = true,
                            },
                        },
                    },
                },
            },
        },
    },
    -- {
    --     "neovim/nvim-lspconfig",
    --     opts = {
    --         inlay_hints = {
    --             enabled = true,
    --         },
    --         servers = {
    --             basedpyright = {
    --                 settings = {
    --                     basedpyright = {
    --                         analysis = {
    --                             inlayHints = {
    --                                 variableTypes = false,
    --                                 functionReturnTypes = true,
    --                                 callArgumentNames = false,
    --                             },
    --                             typeCheckingMode = "basic",
    --                             autoImportCompletions = true,
    --                             enablePytestSupport = true,
    --                         },
    --                     },
    --                 },
    --             },
    --         },
    --     },
    -- },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/neotest-python",
        },
        opts = {
            adapters = {
                ["neotest-python"] = {
                    dap = { justMyCode = false },
                    args = { "--log-level", "DEBUG", "-vvl" },
                    runner = "pytest",
                    python = ".venv/bin/python",
                },
            },
        },
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "mfussenegger/nvim-dap-python",
            -- stylua: ignore
            keys = {
              { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
              { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
            },
            config = function()
                if vim.fn.has("win32") == 1 then
                    require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
                else
                    require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
                end
            end,
        },
    },
    {
        "linux-cultist/venv-selector.nvim",
        cmd = "VenvSelect",
        opts = function(_, opts)
            if require("lazyvim.util").has("nvim-dap-python") then
                opts.dap_enabled = true
            end
            return vim.tbl_deep_extend("force", opts, {
                name = {
                    "venv",
                    ".venv",
                    "env",
                    ".env",
                },
                poetry_path = "/Users/sem/Library/Caches/pypoetry/virtualenvs/",
            })
        end,
        keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" } },
    },
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                python = { "mypy", "ruff" },
            },
            linters = {
                mypy = {
                    condition = function(ctx)
                        return not ctx.filename:match("/tests?/")
                    end,
                },
            },
        },
    },
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                -- ["python"] = { "isort", "black" },
                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_format", "ruff_organize_imports" }
                    else
                        return { "isort", "black" }
                    end
                end,
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "black",
            },
        },
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
            handlers = {
                python = function() end,
            },
        },
    },
}
