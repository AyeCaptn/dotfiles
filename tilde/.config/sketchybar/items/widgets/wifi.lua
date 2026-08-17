local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local wifi = sbar.add("item", "wifi", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  update_freq = 30,
  icon = {
    string = icons.wifi.connected,
    padding_left = 6,
    padding_right = 4,
  },
  label = {
    string = "--%",
    font = { family = settings.font.text_mono, style = "Regular", size = 11.0 },
    padding_left = 2,
    padding_right = 6,
  },
  padding_left = 0,
  padding_right = 0,
  click_script = "open x-apple.systempreferences:com.apple.preference.network",
})

local function update()
  sbar.exec([=[osascript -l JavaScript -e 'ObjC.import("CoreWLAN"); const i = $.CWWiFiClient.sharedWiFiClient.interface; i ? i.rssiValue : 0;']=], function(result)
    local rssi = tonumber(result)
    if rssi and rssi < 0 then
      local percent = math.max(0, math.min(100, math.floor((rssi + 100) * 2 + 0.5)))
      local color = percent < 40 and colors.warning or colors.item
      wifi:set({
        icon = { string = icons.wifi.connected, color = color },
        label = { string = percent .. "%", color = color },
      })
    else
      wifi:set({
        icon = { string = icons.wifi.disconnected, color = colors.muted },
        label = { string = "off", color = colors.muted },
      })
    end
  end)
end

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, update)
update()
