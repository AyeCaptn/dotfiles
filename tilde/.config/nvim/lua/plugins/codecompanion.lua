return {}
-- return {
--     {
--         "olimorris/codecompanion.nvim",
--         lazy = false,
--         dependencies = {
--             "nvim-lua/plenary.nvim",
--             "nvim-treesitter/nvim-treesitter",
--             "hrsh7th/nvim-cmp",
--         },
--         config = function()
--             require("codecompanion").setup({
--                 adapters = {
--                     anthropic = function()
--                         return require("codecompanion.adapters").extend("anthropic", {
--                             env = {
--                                 api_key = "cmd:cat /Users/sem/.anthropic",
--                             },
--                         })
--                     end,
--                 },
--                 strategies = {
--                     chat = {
--                         adapter = "anthropic",
--                     },
--                     inline = {
--                         adapter = "anthropic",
--                     },
--                     agent = {
--                         adapter = "anthropic",
--                     },
--                 },
--                 display = {
--                     diff = {
--                         enabled = true,
--                         close_chat_at = 240,
--                         layout = "vertical",
--                         opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
--                         provider = "mini_diff",
--                     },
--                     chat = {
--                         window = {
--                             layout = "vertical", -- float|vertical|horizontal|buffer
--                         },
--                     },
--                 },
--             })
--         end,
--         init = function() end,
--     },
-- }
