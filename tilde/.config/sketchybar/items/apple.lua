local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local apple = sbar.add("item", "apple", {
  icon = {
    string = icons.apple,
    font = { family = settings.font.icon, style = "Regular", size = 16.0 },
    color = colors.highlight,
    padding_left = 9,
    padding_right = 9,
  },
  label = { drawing = false },
  background = {
    color = colors.bracket,
    border_color = colors.border,
    border_width = 1,
    corner_radius = settings.bracket.corner_radius,
    height = settings.bracket.height,
    drawing = true,
  },
  click_script = "open -a Launchpad",
})
