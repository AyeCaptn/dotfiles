local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}
local SPACE_COUNT = settings.space.count

sbar.add("event", "workspace_update")
sbar.add("event", "windows_on_spaces")

for i = 1, SPACE_COUNT do
  local space = sbar.add("space", "space." .. i, {
    associated_space = i,
    icon = {
      string = tostring(i),
      font = { family = settings.font.text_mono, style = "Bold", size = 12.0 },
      color = colors.space.inactive_fg,
      padding_left = 8,
      padding_right = 4,
    },
    label = {
      font = { family = settings.font.app, style = "Regular", size = 13.0 },
      color = colors.space.inactive_fg,
      padding_left = 1,
      padding_right = 8,
      y_offset = settings.item.app_icon_y_offset,
    },
    background = {
      color = colors.transparent,
      corner_radius = settings.space.corner_radius,
      height = settings.space.height,
      drawing = false,
    },
    padding_left = 2,
    padding_right = 2,
    click_script = "$HOME/.config/yabai/focus_space.sh " .. i,
  })

  spaces[i] = space
end

local focused_space = nil
local space_labels = {}
local occupied_spaces = {}
local apps_refresh_id = 0
local has_data = false

for sid = 1, SPACE_COUNT do
  space_labels[sid] = ""
  occupied_spaces[sid] = false
end

local function render_space(sid, selected)
  if not sid or sid < 1 or sid > SPACE_COUNT then return end

  local color = colors.space.colors[sid] or colors.highlight
  if selected == nil then selected = sid == focused_space end

  spaces[sid]:set({
    icon = { color = selected and colors.space.active_fg or color },
    label = {
      string = space_labels[sid],
      color = selected and colors.space.active_fg or colors.space.inactive_fg,
    },
    background = {
      drawing = selected,
      color = selected and color or colors.transparent,
    },
    drawing = selected or occupied_spaces[sid],
  })
end

local function set_focused_space(sid)
  if not sid or sid < 1 or sid > SPACE_COUNT then return end

  local previous_space = focused_space
  focused_space = sid

  if previous_space ~= focused_space then
    render_space(previous_space)
    render_space(focused_space)
  end
end

local function refresh_yabai_focus()
  sbar.exec("yabai -m query --spaces --space", function(focused)
    if type(focused) ~= "table" or not focused.index then return end
    set_focused_space(focused.index)
  end)
end

local function refresh_yabai_apps()
  apps_refresh_id = apps_refresh_id + 1
  local refresh_id = apps_refresh_id

  sbar.exec("yabai -m query --windows", function(windows_json)
    if refresh_id ~= apps_refresh_id or type(windows_json) ~= "table" then return end

    local space_apps = {}
    for sid = 1, SPACE_COUNT do space_apps[sid] = {} end

    for _, win in ipairs(windows_json) do
      local sid = win.space
      if sid >= 1 and sid <= SPACE_COUNT and win.app then
        space_apps[sid][win.app] = true
      end
    end

    for sid = 1, SPACE_COUNT do
      local app_names = {}
      for app_name in pairs(space_apps[sid]) do
        table.insert(app_names, app_name)
      end
      table.sort(app_names)

      local icon_strip = {}
      for _, app_name in ipairs(app_names) do
        table.insert(icon_strip, app_icons(app_name))
      end

      space_labels[sid] = table.concat(icon_strip, " ")
      occupied_spaces[sid] = #app_names > 0
      render_space(sid)
    end
  end)
end

-- SketchyBar's native space event arrives with the macOS workspace change and
-- avoids waiting for yabai's delayed space_changed signal on this machine.
for sid, space in ipairs(spaces) do
  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
    if selected then focused_space = sid end
    render_space(sid, selected)
  end)
end

local observer = sbar.add("item", "space_observer", {
  drawing = false,
  updates = true,
})

local function refresh()
  refresh_yabai_focus()
  refresh_yabai_apps()
  has_data = true
end

observer:subscribe({ "workspace_update", "windows_on_spaces", "forced" }, function()
  refresh()
end)

-- Heal the launch-order race, then stop polling once yabai answers.
local watchdog = sbar.add("item", "workspace_watchdog", {
  drawing = false,
  update_freq = 2,
})
watchdog:subscribe("routine", function()
  if has_data then
    watchdog:set({ update_freq = 0 })
  else
    refresh()
  end
end)

refresh()
