return {
    "artemave/workspace-diagnostics.nvim",
    keys = {
        {
            "<leader>xw",
            function()
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                    require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
                end

                local ok, trouble = pcall(require, "trouble")
                if ok then
                    trouble.open({ mode = "diagnostics" })
                else
                    vim.cmd("Trouble diagnostics")
                end
            end,
            desc = "Workspace Diagnostics (Trouble)",
        },
    },
}
