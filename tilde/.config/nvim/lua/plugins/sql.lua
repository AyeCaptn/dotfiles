return {
    {
        "kristijanhusak/vim-dadbod-ui",
        init = function()
            local base = vim.fn.expand("~/.db_config")
            vim.g.db_ui_save_location = base
            vim.g.db_ui_tmp_query_location = base .. "/tmp"
        end,
    },
}
