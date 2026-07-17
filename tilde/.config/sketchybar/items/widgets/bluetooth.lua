local icons = require("icons")
local settings = require("settings")

local bluetooth = sbar.add("item", "bluetooth", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  icon = { string = icons.bluetooth.disconnected },
  label = { drawing = false },
  padding_left = 2,
  click_script = "open x-apple.systempreferences:com.apple.BluetoothSettings",
})

local function update()
  sbar.exec("system_profiler SPBluetoothDataType | grep -q 'Connected: Yes'", function(_, exit_code)
    bluetooth:set({
      icon = {
        string = exit_code == 0 and icons.bluetooth.connected or icons.bluetooth.disconnected,
      },
    })
  end)
end

bluetooth:subscribe({ "routine", "system_woke" }, update)
update()
