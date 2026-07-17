local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local memory = sbar.add("graph", "memory", 30, {
  position = "right",
  y_offset = settings.item.right_y_offset,
  graph = {
    color = colors.success,
    fill_color = colors.with_alpha(colors.success, 0.2),
    line_width = 1.5,
  },
  icon = {
    string = icons.memory,
    font = { family = settings.font.icon, style = "Semibold", size = 12.0 },
    color = colors.item,
    padding_left = 14,
    padding_right = 4,
  },
  label = {
    font = { family = settings.font.text_mono, style = "Regular", size = 11.0 },
    color = colors.item,
    padding_left = 4,
    padding_right = 14,
  },
  width = 90,
  padding_left = 0,
  padding_right = 4,
  background = {
    color = colors.bracket,
    corner_radius = settings.bracket.corner_radius,
    height = settings.bracket.height,
    drawing = true,
  },
  click_script = "open -na /Applications/Ghostty.app --args -e btop",
})

local function update_memory(used_percent)
  local color = colors.success

  if used_percent > 85 then
    color = colors.danger
  elseif used_percent > 70 then
    color = colors.warning
  end

  sbar.animate("tanh", 20, function()
    memory:set({
      graph = { color = color },
      label = { string = math.floor(used_percent) .. "%" },
    })
  end)
  memory:push({ used_percent / 100 })
end

memory:set({ update_freq = 5 })
memory:subscribe("routine", function(env)
  sbar.exec("memory_pressure | awk '/System-wide memory free percentage:/ {gsub(\"%\", \"\", $5); printf \"%.0f\", 100 - $5}'", function(result)
    update_memory(tonumber(result) or 0)
  end)
end)
