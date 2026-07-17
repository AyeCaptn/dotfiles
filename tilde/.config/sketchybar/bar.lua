local colors = require("colors")
local settings = require("settings")

sbar.bar({
	height = settings.bar.height,
	color = colors.bar.bg,
	blur_radius = 16,
	position = "top",
	y_offset = settings.bar.y_offset,
	sticky = true,
	notch_width = settings.bar.notch_width,
	padding_left = 8,
	padding_right = 8,
	shadow = false,
	display = "all",
})
