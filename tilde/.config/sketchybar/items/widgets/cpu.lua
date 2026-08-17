local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local cpu = sbar.add("graph", "cpu", 30, {
  position = "right",
  y_offset = settings.item.right_y_offset,
  graph = {
    color = colors.highlight,
    fill_color = colors.with_alpha(colors.highlight, 0.2),
    line_width = 1.5,
  },
  icon = {
    string = icons.cpu,
    font = { family = settings.font.icon, style = "Semibold", size = 12.0 },
    color = colors.item,
    padding_left = 3,
    padding_right = 3,
  },
  label = {
    font = { family = settings.font.text_mono, style = "Regular", size = 11.0 },
    color = colors.item,
    padding_left = 3,
    padding_right = 6,
  },
  width = 84,
  padding_left = 0,
  padding_right = 0,
  background = {
    color = 0x00000000,
    height = settings.bracket.height,
    drawing = true,
  },
  click_script = "open -na /Applications/Ghostty.app --args -e btop",
})

local config_dir = os.getenv("CONFIG_DIR")
  or os.getenv("HOME") .. "/.config/sketchybar"
local provider_bin = config_dir .. "/helpers/event_providers/cpu_load/bin/cpu_load"

local function update_cpu(load)
  local color = colors.highlight

  if load > 80 then
    color = colors.danger
  elseif load > 50 then
    color = colors.warning
  end

  sbar.animate("tanh", 20, function()
    cpu:set({
      graph = { color = color },
      label = { string = string.format("%02d%%", math.floor(load)) },
    })
  end)
  cpu:push({ load / 100 })
end

-- Check if provider binary exists synchronously
local f = io.open(provider_bin, "r")
if f then
  f:close()
  -- Register event and subscribe during config phase
  sbar.add("event", "cpu_update")
  cpu:subscribe("cpu_update", function(env)
    update_cpu(tonumber(env.total_load) or 0)
  end)
  -- Launch provider after config is applied (routine fires after event_loop starts)
  cpu:subscribe("routine", function(env)
    -- Only launch once
    cpu:set({ update_freq = 0 })
    sbar.exec("killall cpu_load 2>/dev/null; " .. provider_bin .. " cpu_update 2.0")
  end)
  cpu:set({ update_freq = 1 })
else
  -- Fallback: shell polling
  cpu:set({ update_freq = 5 })
  cpu:subscribe("routine", function(env)
    sbar.exec("ps -eo pcpu | awk -v cores=$(sysctl -n machdep.cpu.thread_count) '{sum+=$1} END {printf \"%.0f\", sum/cores}'", function(result)
      update_cpu(tonumber(result) or 0)
    end)
  end)
end
