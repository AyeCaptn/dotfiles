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

local space_items = {}
for i = 1, settings.space.count do
  table.insert(space_items, "space." .. i)
end

sbar.add("bracket", "workspaces", space_items, {
  padding_left = 0,
  padding_right = 0,
  background = {
    color = colors.bracket,
    border_color = colors.border,
    border_width = 1,
    corner_radius = settings.bracket.corner_radius,
    height = settings.bracket.height,
    drawing = true,
  },
})

sbar.add("bracket", "connectivity", { "volume", "battery", "wifi", "bluetooth" }, {
  padding_left = 0,
  padding_right = 0,
  background = {
    color = colors.bracket,
    border_color = colors.border,
    border_width = 1,
    corner_radius = settings.bracket.corner_radius,
    height = settings.bracket.height,
    drawing = true,
  },
})
