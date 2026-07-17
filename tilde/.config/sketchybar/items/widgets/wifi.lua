local icons = require("icons")
local settings = require("settings")

local wifi = sbar.add("item", "wifi", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  icon = {
    string = icons.wifi.connected,
    padding_left = 5,
    padding_right = 5,
  },
  label = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  click_script = "open x-apple.systempreferences:com.apple.preference.network",
})

wifi:subscribe("wifi_change", function(env)
  sbar.exec("system_profiler SPAirPortDataType | awk '/Current Network Information:/ { getline; print substr($0, 13, (length($0) - 13)); exit }'", function(ssid)
    if ssid and ssid ~= "" then
      wifi:set({ icon = { string = icons.wifi.connected } })
    else
      wifi:set({ icon = { string = icons.wifi.disconnected } })
    end
  end)
end)
