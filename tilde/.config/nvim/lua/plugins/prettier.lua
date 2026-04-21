local supported = {
  "astro",
  "css",
  "graphql",
  -- "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  -- "markdown",
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
  -- "yaml",
}

return {
    -- {
    --     "mason-org/mason.nvim",
    --     opts = function(_, opts)
    --         table.insert(opts.ensure_installed, "prettier")
    --     end,
    -- },
    -- {
    --     "stevearc/conform.nvim",
    --     optional = true,
    --     opts = {
    --         formatters_by_ft = {
    --             ["javascript"] = { "prettier" },
    --             ["javascriptreact"] = { "prettier" },
    --             ["typescript"] = { "prettier" },
    --             ["typescriptreact"] = { "prettier" },
    --             ["vue"] = { "prettier" },
    --             ["css"] = { "prettier" },
    --             ["scss"] = { "prettier" },
    --             ["less"] = { "prettier" },
    --             ["html"] = { "prettier" },
    --             ["json"] = { "prettier" },
    --             ["jsonc"] = { "prettier" },
    --             ["yaml"] = { "prettier" },
    --             -- ["markdown"] = { "prettier" },
    --             -- ["markdown.mdx"] = { "prettier" },
    --             ["graphql"] = { "prettier" },
    --             ["handlebars"] = { "prettier" },
    --         },
    --     },
    -- },
    {
        "stevearc/conform.nvim",
        opts = function(_, opts)
            opts.formatters_by_ft = opts.formatters_by_ft or {}
            for _, ft in ipairs(supported) do
                opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
                table.insert(opts.formatters_by_ft[ft], "biome-organize-imports")
            end

            opts.formatters = opts.formatters or {}
            opts.formatters.biome = {
                require_cwd = true,
            }
        end,
    },
}
