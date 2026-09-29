local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local vertical_meter = require("items.widgets.vertical_meter")

local wifi = sbar.add("item", "wifi", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  update_freq = 30,
  icon = {
    string = icons.wifi.connected,
    padding_left = 6,
    padding_right = 4,
  },
  label = vertical_meter.label(),
  padding_left = 0,
  padding_right = 6,
  click_script = "open x-apple.systempreferences:com.apple.preference.network",
})

local function color_for_signal(percent)
  if percent >= 75 then return colors.success end
  if percent >= 50 then return colors.highlight end
  if percent >= 25 then return colors.warning end
  return colors.danger
end

local function update()
  sbar.exec([=[osascript -l JavaScript -e 'ObjC.import("CoreWLAN"); const i = $.CWWiFiClient.sharedWiFiClient.interface; i ? i.rssiValue : 0;']=], function(result)
    local rssi = tonumber(result)
    if rssi and rssi < 0 then
      local percent = math.max(0, math.min(100, math.floor((rssi + 100) * 2 + 0.5)))
      local color = color_for_signal(percent)
      wifi:set({
        icon = { string = icons.wifi.connected, color = color },
        label = vertical_meter.properties(percent, color),
      })
    else
      wifi:set({
        icon = { string = icons.wifi.disconnected, color = colors.muted },
        label = vertical_meter.properties(0, colors.muted),
      })
    end
  end)
end

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, update)
update()
