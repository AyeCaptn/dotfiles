local function main_screen_has_notch()
	local command = [[osascript -l JavaScript -e 'ObjC.import("AppKit"); ObjC.unwrap($.NSScreen.mainScreen.safeAreaInsets.top)' 2>/dev/null]]
	local process = io.popen(command)
	if not process then return false end

	local safe_area_top = tonumber(process:read("*a")) or 0
	process:close()
	return safe_area_top > 0
end

local has_notch = main_screen_has_notch()

return {
	font = {
		text = "GeistMono Nerd Font",
		text_mono = "GeistMono Nerd Font Mono",
		icon = "SF Pro",
		app = "sketchybar-app-font",
	},
	bar = {
		height = has_notch and 38 or 27,
		notch_width = 210,
		y_offset = 0,
		padding = 10,
	},
	item = {
		padding = 4,
		right_y_offset = 0,
		icon_y_offset = 0,
		label_y_offset = -1,
		app_icon_y_offset = 0,
		front_app_label_y_offset = 1,
		icon_padding_left = 3,
		icon_padding_right = 3,
		label_padding_left = 3,
		label_padding_right = 3,
	},
	space = {
		count = 9,
		height = has_notch and 24 or 20,
		corner_radius = has_notch and 8 or 7,
	},
	bracket = {
		corner_radius = 10,
		height = has_notch and 28 or 24,
		gap = 8,
	},
}
