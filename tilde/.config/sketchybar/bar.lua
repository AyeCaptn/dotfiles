local colors = require("colors")
local settings = require("settings")

sbar.bar({
	height = settings.bar.height,
	color = colors.bar.bg,
	blur_radius = 20,
	position = "top",
	y_offset = settings.bar.y_offset,
	sticky = true,
	notch_width = settings.bar.notch_width,
	padding_left = settings.bar.padding,
	padding_right = settings.bar.padding,
	shadow = false,
	display = "all",
})
