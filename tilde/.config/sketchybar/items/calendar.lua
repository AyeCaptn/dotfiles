local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local weather_cache = { last_fetch = 0 }
local calendar_cache = { last_fetch = 0, title = nil, starts_at = nil }

local clock = sbar.add("item", "clock", {
  position = "right",
  y_offset = settings.item.right_y_offset,
  update_freq = 30,
  icon = {
    string = icons.clock,
    font = { family = settings.font.icon, style = "Semibold", size = 13.0 },
    color = colors.item,
    padding_left = 7,
    padding_right = 4,
  },
  label = {
    string = os.date("%a %d/%m %H:%M"),
    font = { family = settings.font.text_mono, style = "Medium", size = 11.0 },
    padding_left = 3,
    padding_right = 9,
  },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  click_script = "open -a Calendar",
})

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
    max_chars = 24,
    padding_left = 3,
    padding_right = 9,
  },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  click_script = "open -a Raycast 'raycast://extensions/raycast/calendar/my-schedule'",
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

sbar.add("bracket", "date_time", { "weather", "calendar", "clock" }, {
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

local function calendar_label()
  if not calendar_cache.title or not calendar_cache.starts_at then
    return "No upcoming events"
  end

  local minutes = math.max(0, math.floor((calendar_cache.starts_at - os.time()) / 60))
  local countdown
  if minutes == 0 then
    countdown = "now"
  elseif minutes < 60 then
    countdown = minutes .. "m"
  elseif minutes < 1440 then
    local hours = math.floor(minutes / 60)
    local remainder = minutes % 60
    countdown = hours .. "h"
    if hours < 2 and remainder > 0 then countdown = countdown .. " " .. remainder .. "m" end
  else
    countdown = os.date("%a %H:%M", calendar_cache.starts_at)
  end

  local title = calendar_cache.title
  if #title > 16 then title = title:sub(1, 15) .. "…" end
  return title .. " · " .. countdown
end

local function fetch_calendar()
  local command = "/opt/homebrew/bin/icalBuddy -n -nc -nrd -ea -li 1 "
    .. "-df '%Y-%m-%d' -tf '%H:%M' -po 'title,datetime' -ps '|^|' -b '' "
    .. "eventsFrom:now to:today+7 2>/dev/null"

  sbar.exec(command, function(result)
    calendar_cache.last_fetch = os.time()
    local title, year, month, day, hour, minute = result:match(
      "^(.-)%^(%d%d%d%d)%-(%d%d)%-(%d%d) at (%d%d):(%d%d)"
    )

    if title then
      calendar_cache.title = title
      calendar_cache.starts_at = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(minute),
        sec = 0,
      })
    else
      calendar_cache.title = nil
      calendar_cache.starts_at = nil
    end

    calendar:set({ label = { string = calendar_label() } })
  end)
end

calendar:subscribe({ "routine", "forced", "system_woke" }, function(env)
  -- Refresh weather every 30 minutes
  if os.time() - weather_cache.last_fetch > 1800 then
    fetch_weather()
  end
  if os.time() - calendar_cache.last_fetch > 300
    or (calendar_cache.starts_at and calendar_cache.starts_at <= os.time()) then
    fetch_calendar()
  else
    calendar:set({ label = { string = calendar_label() } })
  end
end)

clock:subscribe({ "routine", "forced", "system_woke" }, function()
  clock:set({ label = { string = os.date("%a %d/%m %H:%M") } })
end)

calendar:set({ label = { string = "Loading calendar..." } })
fetch_weather()
fetch_calendar()
