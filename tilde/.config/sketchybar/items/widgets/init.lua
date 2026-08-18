local colors = require("colors")
local settings = require("settings")

sbar.add("item", "datetime_connectivity_spacer", {
  position = "right",
  width = settings.bracket.gap,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
})

require("items.widgets.volume")
require("items.widgets.battery")
require("items.widgets.wifi")
require("items.widgets.bluetooth")

sbar.add("item", "stats_connectivity_spacer", {
  position = "right",
  width = settings.bracket.gap,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
})

require("items.widgets.memory")
require("items.widgets.cpu")

sbar.add("bracket", "system_stats", { "memory", "cpu" }, {
  padding_left = 0,
  padding_right = 0,
  background = {
    color = colors.bracket,
    border_color = colors.border,
    border_width = 1,
    corner_radius = settings.bracket.corner_radius,
    height = settings.bracket.height,
  },
})
