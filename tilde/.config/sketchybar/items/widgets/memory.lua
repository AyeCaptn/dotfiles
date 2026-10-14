local icons = require("icons")
local bar_chart = require("items.widgets.bar_chart")

local memory_chart = bar_chart.new({
  name = "memory",
  icon = icons.memory,
  icon_width = 22,
  click_script = "open -na /Applications/Ghostty.app --args -e btop",
})
local memory = memory_chart.item

local function update_memory(used_percent)
  memory_chart.push(used_percent)
end

memory:set({ update_freq = 5 })
memory:subscribe("routine", function(env)
  sbar.exec("memory_pressure | awk '/System-wide memory free percentage:/ {gsub(\"%\", \"\", $5); printf \"%.0f\", 100 - $5}'", function(result)
    update_memory(tonumber(result) or 0)
  end)
end)
