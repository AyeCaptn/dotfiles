require("items.widgets.volume")
require("items.widgets.battery")
require("items.widgets.wifi")
require("items.widgets.bluetooth")

sbar.add("item", "stats_connectivity_spacer", {
  position = "right",
  width = 6,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
})

require("items.widgets.memory")
require("items.widgets.cpu")

local colors = require("colors")
local settings = require("settings")

sbar.add("bracket", "system_stats", { "memory", "cpu" }, {
  padding_left = 0,
  padding_right = 0,
  background = {
    color = colors.bracket,
    corner_radius = settings.bracket.corner_radius,
    height = settings.bracket.height,
  },
})
