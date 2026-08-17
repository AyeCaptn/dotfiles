local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local weather_cache = { last_fetch = 0 }

local calendar = sbar.add("item", "calendar", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  update_freq = 30,
  icon = {
    string = icons.calendar,
    font = { family = settings.font.icon, style = "Semibold", size = 13.0 },
    color = colors.item,
    padding_left = 6,
    padding_right = 4,
  },
  label = {
    font = { family = settings.font.text, style = "Medium", size = 11.0 },
    padding_left = 3,
    padding_right = 9,
  },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  click_script = "open -a Calendar",
})

local weather = sbar.add("item", "weather", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  icon = {
    string = icons.weather.cloud,
    font = { family = "Symbols Nerd Font", style = "Regular", size = 18.0 },
    color = colors.item,
    padding_left = 9,
    padding_right = 4,
  },
  label = {
    string = "--°C",
    font = { family = settings.font.text_mono, style = "Regular", size = 11.0 },
    color = colors.item,
    padding_left = 3,
    padding_right = 4,
  },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  click_script = "open 'https://wttr.in'",
})

sbar.add("bracket", "date_time", { "weather", "calendar" }, {
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

local function weather_icon(condition)
  local value = condition:lower()

  if value:find("thunder") or value:find("storm") then
    return icons.weather.storm
  elseif value:find("snow") or value:find("blizzard") or value:find("sleet") or value:find("ice") then
    return icons.weather.snow
  elseif value:find("rain") or value:find("drizzle") or value:find("shower") then
    return icons.weather.rain
  elseif value:find("fog") or value:find("mist") or value:find("haze") then
    return icons.weather.fog
  elseif value:find("clear") or value:find("sunny") then
    return icons.weather.clear
  end

  return icons.weather.cloud
end

local function fetch_weather()
  sbar.exec("curl -s --max-time 4 'wttr.in/?format=%C|%t' 2>/dev/null | head -1 | sed 's/+//'", function(result)
    local condition, temperature = result:match("^([^|]+)|([^|]+)")
    if condition and temperature and not result:find("Unknown") then
      weather_cache.last_fetch = os.time()
      weather:set({
        icon = { string = weather_icon(condition) },
        label = { string = temperature:gsub("%s+$", "") },
      })
    end
  end)
end

calendar:subscribe({ "routine", "forced", "system_woke" }, function(env)
  -- Refresh weather every 30 minutes
  if os.time() - weather_cache.last_fetch > 1800 then
    fetch_weather()
  end
  calendar:set({ label = { string = os.date("%a %d %b · %I:%M %p") } })
end)

calendar:set({ label = { string = os.date("%a %d %b · %I:%M %p") } })
fetch_weather()
