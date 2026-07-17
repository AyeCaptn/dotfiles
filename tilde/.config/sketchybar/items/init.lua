-- Left side
require("items.apple")
require("items.spaces")
require("items.front_app")

-- Right side (rightmost first)
require("items.calendar")
require("items.widgets")

-- Brackets
local colors = require("colors")
local settings = require("settings")

sbar.add("bracket", "connectivity", { "volume", "battery", "wifi", "bluetooth" }, {
  padding_left = 0,
  padding_right = 0,
  background = {
    color = colors.bracket,
    corner_radius = settings.bracket.corner_radius,
    height = settings.bracket.height,
    drawing = true,
  },
})
