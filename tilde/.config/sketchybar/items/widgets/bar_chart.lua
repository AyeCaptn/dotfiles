local colors = require("colors")
local settings = require("settings")

local bar_chart = {}

local function clamp(value)
  return math.max(0, math.min(100, value))
end

function bar_chart.new(options)
  local sample_count = options.sample_count or 10
  local max_height = options.max_height or 18
  local min_height = options.min_height or 4
  local history = {}
  local bars = {}
  local palette = options.palette or colors.chart
  local initialized = false

  for index = 1, sample_count do
    history[index] = { value = 0, color = colors.accent }
  end

  -- Right-positioned items appear in reverse creation order. Creating the
  -- percentage first and the icon last keeps the visual order icon/chart/%.
  local percentage = sbar.add("item", options.name, {
    position = "right",
    width = 37,
    y_offset = settings.item.right_y_offset,
    padding_left = 0,
    padding_right = 0,
    icon = { drawing = false },
    label = {
      string = "00%",
      width = 31,
      align = "left",
      font = { family = settings.font.text_mono, style = "Regular", size = 11.0 },
      color = colors.item,
      padding_left = 3,
      padding_right = 3,
    },
    background = { drawing = false },
    click_script = options.click_script,
  })

  for index = sample_count, 1, -1 do
    bars[index] = sbar.add("item", options.name .. ".bar." .. index, {
      position = "right",
      width = 3,
      padding_left = 0,
      padding_right = 0,
      icon = { drawing = false },
      label = { drawing = false },
      background = {
        drawing = true,
        color = colors.accent,
        border_color = colors.bracket,
        border_width = 1,
        height = min_height,
        corner_radius = 1,
        y_offset = math.floor((min_height - max_height) / 2),
      },
      click_script = options.click_script,
    })
  end

  sbar.add("item", options.name .. ".icon", {
    position = "right",
    width = options.icon_width or 20,
    y_offset = settings.item.right_y_offset,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = options.icon,
      font = { family = settings.font.icon, style = "Semibold", size = 12.0 },
      color = colors.item,
      padding_left = options.icon_padding_left or 4,
      padding_right = options.icon_padding_right or 4,
    },
    label = { drawing = false },
    background = { drawing = false },
    click_script = options.click_script,
  })

  local function color_for(value)
    local index = math.min(#palette, math.floor(value / 100 * #palette) + 1)
    return palette[index]
  end

  local function render_history()
    for index = 1, sample_count do
      local sample = history[index]
      local scaled_height = min_height + sample.value / 100 * (max_height - min_height)
      local height = math.floor(scaled_height / 2 + 0.5) * 2
      bars[index]:set({
        background = {
          color = sample.color,
          height = height,
          -- Heights are always even, keeping this bottom edge invariant.
          y_offset = (height - max_height) / 2,
        },
      })
    end
  end

  local function push(value)
    value = clamp(value)
    percentage:set({
      label = { string = string.format("%02d%%", math.floor(value)) },
    })

    if not initialized then
      for index = 1, sample_count do
        history[index] = { value = value, color = color_for(value) }
      end
      initialized = true
      render_history()
      return
    end

    for index = 1, sample_count - 1 do
      history[index] = history[index + 1]
    end
    history[sample_count] = { value = value, color = color_for(value) }
    render_history()
  end

  return {
    item = percentage,
    push = push,
  }
end

return bar_chart
