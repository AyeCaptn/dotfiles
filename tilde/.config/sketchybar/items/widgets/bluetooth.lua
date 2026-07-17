local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local bluetooth = sbar.add("item", "bluetooth", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  icon = {
    string = icons.bluetooth.connected,
    padding_left = 6,
    padding_right = 4,
  },
  label = {
    string = "0",
    padding_right = 5,
  },
  padding_left = 0,
  padding_right = 6,
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

    bluetooth:set({
      icon = {
        string = icons.bluetooth.connected,
        color = is_off and colors.muted or colors.item,
      },
      label = {
        string = is_off and "off" or value,
        color = is_off and colors.muted or colors.item,
      },
    })
  end)
end

bluetooth:subscribe({ "routine", "system_woke" }, update)
update()
