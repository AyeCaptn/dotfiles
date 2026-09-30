local vertical_meter = {}

local max_height = 10

function vertical_meter.label()
  return {
    string = "",
    drawing = true,
    width = 4,
    padding_left = 0,
    padding_right = 0,
    background = {
      drawing = false,
      height = 1,
      corner_radius = 1,
      y_offset = -5,
    },
  }
end

function vertical_meter.properties(value, color)
  value = math.max(0, math.min(100, tonumber(value) or 0))
  local level = math.floor(value / 10 + 0.5)
  local height = math.max(1, level)

  return {
    background = {
      drawing = level > 0,
      color = color,
      height = height,
      y_offset = math.floor((height - max_height) / 2),
    },
  }
end

return vertical_meter
