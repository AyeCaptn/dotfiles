local colors = require("colors")
local settings = require("settings")

local bar_chart = {}

local function clamp(value)
  return math.max(0, math.min(100, value))
end

function bar_chart.new(options)
  local sample_count = options.sample_count or 6
  local bar_width = options.bar_width or 4
  local max_height = options.max_height or 18
  local min_height = options.min_height or 4
  local history = {}
  local bars = {}
  local palette = options.palette or colors.chart
  local initialized = false

  for index = 1, sample_count do
    history[index] = { value = 0, color = colors.accent }
  end

  -- Right-positioned items render in reverse creation order. This spacer is
  -- therefore placed after the chart, keeping its last bar inside the bracket.
  sbar.add("item", options.name .. ".chart_padding", {
    position = "right",
    width = options.chart_padding or 8,
    padding_left = 0,
    padding_right = 0,
    icon = { drawing = false },
    label = { drawing = false },
    background = { drawing = false },
  })

  for index = sample_count, 1, -1 do
    bars[index] = sbar.add("item", options.name .. ".bar." .. index, {
      position = "right",
      width = bar_width,
      padding_left = 0,
      padding_right = 0,
      icon = {
        drawing = true,
        string = "",
        width = bar_width,
        align = "center",
        font = { family = settings.font.text_mono, style = "Bold", size = 8.0 },
        color = colors.lavender,
        padding_left = 0,
        padding_right = 0,
        shadow = {
          drawing = true,
          color = colors.bracket,
          angle = 90,
          distance = 1,
        },
      },
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

  local icon = sbar.add("item", options.name .. ".icon", {
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

  local function render_percentage(value)
    local text = string.format("%d", math.floor(value + 0.5))
    local first_index = math.floor((sample_count - #text) / 2) + 1

    for index = 1, sample_count do
      local character_index = index - first_index + 1
      local character = ""
      if character_index >= 1 and character_index <= #text then
        character = text:sub(character_index, character_index)
      end
      bars[index]:set({ icon = { string = character } })
    end
  end

  local function push(value)
    value = clamp(value)
    render_percentage(value)

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
    item = icon,
    push = push,
  }
end

return bar_chart
