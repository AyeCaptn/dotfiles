local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local bluetooth = sbar.add("item", "bluetooth", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  update_freq = 30,
  icon = {
    string = icons.bluetooth.connected,
    font = { family = "Symbols Nerd Font", style = "Regular", size = 14.0 },
    padding_left = 7,
    padding_right = 7,
  },
  label = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  click_script = "open x-apple.systempreferences:com.apple.BluetoothSettings",
})

local function update()
  sbar.exec([=[system_profiler SPBluetoothDataType | awk '
    /State: Off/ { print "off"; exit }
    /^[[:space:]]+Connected:$/ { connected = 1; next }
    /^[[:space:]]+Not Connected:$/ { connected = 0 }
    connected && /^[[:space:]]+Address:/ { count++ }
    END { if (!count) count = 0; print count }
  ']=], function(result)
    local value = result:gsub("%s+", "")
    local is_off = value == "off"
    local is_connected = (tonumber(value) or 0) > 0
    local color = colors.item

    if is_off then
      color = colors.muted
    elseif is_connected then
      color = colors.highlight
    end

    bluetooth:set({
      icon = {
        string = icons.bluetooth.connected,
        color = color,
      },
    })
  end)
end

bluetooth:subscribe({ "routine", "system_woke" }, update)
update()
