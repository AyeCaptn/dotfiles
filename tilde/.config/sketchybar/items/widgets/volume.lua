local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local vertical_meter = require("items.widgets.vertical_meter")

local volume = sbar.add("item", "volume", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  icon = {
    padding_left = 6,
    padding_right = 4,
  },
  label = vertical_meter.label(),
  padding_left = 0,
  padding_right = 7,
  click_script = "open x-apple.systempreferences:com.apple.preference.sound",
})

local function update_volume(value)
  local vol = math.max(0, math.min(100, tonumber(value) or 0))
  local icon = icons.vol._0

  if vol >= 60 then
    icon = icons.vol._100
  elseif vol >= 30 then
    icon = icons.vol._33
  elseif vol >= 1 then
    icon = icons.vol._10
  end

  volume:set({
    icon = { string = icon },
    label = vertical_meter.properties(vol, colors.highlight),
  })
end

volume:subscribe("volume_change", function(env)
  update_volume(env.INFO)
end)

sbar.exec("osascript -e 'output volume of (get volume settings)'", update_volume)
