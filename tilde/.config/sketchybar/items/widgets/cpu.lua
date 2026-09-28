local icons = require("icons")
local bar_chart = require("items.widgets.bar_chart")

local cpu_chart = bar_chart.new({
  name = "cpu",
  icon = icons.cpu,
  click_script = "open -na /Applications/Ghostty.app --args -e btop",
})
local cpu = cpu_chart.item

local config_dir = os.getenv("CONFIG_DIR")
  or os.getenv("HOME") .. "/.config/sketchybar"
local provider_bin = config_dir .. "/helpers/event_providers/cpu_load/bin/cpu_load"

local function update_cpu(load)
  cpu_chart.push(load)
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
    sbar.exec("killall cpu_load 2>/dev/null; exec " .. provider_bin .. " cpu_update 2.0")
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
