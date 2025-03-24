return {
    {
        "nvim-neotest/neotest",
        optional = true,
        dependencies = {
            "marilari88/neotest-vitest",
        },
        opts = function(_, opts)
            opts = opts or {}
            if vim.uv.fs_stat(vim.fn.getcwd() .. "/package.json") then
                opts.adapters = opts.adapters or {}
                opts.adapters["neotest-vitest"] = {}
            end
        end,
    },
}
