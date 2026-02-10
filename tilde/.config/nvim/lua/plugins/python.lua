return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = {
                enabled = true,
            },
            servers = {
                pytest_lsp = {
                    cmd = { "pytest-language-server" },
                    filetypes = { "python" },
                    root_markers = {
                        "pytest.ini",
                        "pyproject.toml",
                        "setup.py",
                        "setup.cfg",
                        ".git",
                    },
                },
                ty = {
                    settings = {
                        ty = {
                            -- Diagnostic settings
                            diagnosticMode = "workspace", -- "off" | "workspace" | "openFilesOnly"
                            showSyntaxErrors = true,

                            -- Inlay hints settings (matching your basedpyright config)
                            inlayHints = {
                                variableTypes = false,
                                callArgumentNames = false,
                            },

                            -- Completions settings
                            completions = {
                                autoImport = true, -- equivalent to autoImportCompletions
                            },

                            -- Optional: Configuration inline (takes precedence over config files)
                            -- configuration = {
                            --     rules = {
                            --         ["unresolved-reference"] = "warn",
                            --     },
                            -- },

                            -- Optional: Path to custom ty.toml config file
                            -- configurationFile = nil,

                            -- Optional: Disable language services if you only want type checking
                            -- disableLanguageServices = false,
                        },
                    },
                },
                -- Keep basedpyright config for reference/fallback
                -- basedpyright = {
                --     settings = {
                --         basedpyright = {
                --             analysis = {
                --                 inlayHints = {
                --                     variableTypes = false,
                --                     functionReturnTypes = true,
                --                     callArgumentNames = false,
                --                 },
                --                 typeCheckingMode = "basic",
                --                 autoImportCompletions = true,
                --                 enablePytestSupport = true,
                --             },
                --         },
                --     },
                -- },
            },
        },
    },
    {
        "nvim-neotest/neotest",
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
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                python = { "ruff" }, -- mypy
            },
            linters = {
                -- mypy = {
                --     condition = function(ctx)
                --         return not ctx.filename:match("/tests?/")
                --     end,
                -- },
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
}
