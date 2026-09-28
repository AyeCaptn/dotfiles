local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}
local SPACE_COUNT = settings.space.count

sbar.add("event", "workspace_update")
sbar.add("event", "windows_on_spaces")

-- Plain items work for OmniWM's virtual workspaces and for yabai's native
-- Spaces. Selection and occupancy are rendered from the active WM's query.
for i = 1, SPACE_COUNT do
  local space = sbar.add("item", "space." .. i, {
    position = "left",
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
    click_script = "$HOME/.config/omniwm/focus_workspace.sh " .. i,
  })

  spaces[i] = space
end

local focused_space = nil
local space_labels = {}
local occupied_spaces = {}
local refresh_id = 0
local has_data = false

for sid = 1, SPACE_COUNT do
  space_labels[sid] = ""
  occupied_spaces[sid] = false
end

local function render_space(sid)
  if not sid or sid < 1 or sid > SPACE_COUNT then return end

  local selected = sid == focused_space
  local color = colors.space.colors[sid] or colors.highlight
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

local function render_all()
  for sid = 1, SPACE_COUNT do render_space(sid) end
end

local function refresh_omniwm(id)
  sbar.exec("omniwmctl query workspace-bar", function(response)
    if id ~= refresh_id or type(response) ~= "table" then return end
    local payload = response.result and response.result.payload
    if type(payload) ~= "table" or type(payload.monitors) ~= "table" then return end

    local apps_by_space = {}
    for sid = 1, SPACE_COUNT do apps_by_space[sid] = {} end

    for _, monitor in ipairs(payload.monitors) do
      for _, workspace in ipairs(monitor.workspaces or {}) do
        local sid = tonumber(workspace.rawName)
        if sid and sid >= 1 and sid <= SPACE_COUNT then
          if workspace.isFocused then focused_space = sid end
          for _, app in ipairs(workspace.windows or {}) do
            if app.appName then apps_by_space[sid][app.appName] = true end
          end
        end
      end
    end

    for sid = 1, SPACE_COUNT do
      local names = {}
      for app_name in pairs(apps_by_space[sid]) do table.insert(names, app_name) end
      table.sort(names)
      local icons = {}
      for _, app_name in ipairs(names) do table.insert(icons, app_icons(app_name)) end
      space_labels[sid] = table.concat(icons, " ")
      occupied_spaces[sid] = #names > 0
    end
    has_data = true
    render_all()
  end)
end

local function refresh_yabai(id)
  sbar.exec("yabai -m query --spaces --space", function(focused)
    if id == refresh_id and type(focused) == "table" then focused_space = focused.index end
  end)
  sbar.exec("yabai -m query --windows", function(windows)
    if id ~= refresh_id or type(windows) ~= "table" then return end
    local apps_by_space = {}
    for sid = 1, SPACE_COUNT do apps_by_space[sid] = {} end
    for _, window in ipairs(windows) do
      local sid = window.space
      if sid and sid >= 1 and sid <= SPACE_COUNT and window.app then
        apps_by_space[sid][window.app] = true
      end
    end
    for sid = 1, SPACE_COUNT do
      local names = {}
      for app_name in pairs(apps_by_space[sid]) do table.insert(names, app_name) end
      table.sort(names)
      local icons = {}
      for _, app_name in ipairs(names) do table.insert(icons, app_icons(app_name)) end
      space_labels[sid] = table.concat(icons, " ")
      occupied_spaces[sid] = #names > 0
    end
    has_data = true
    render_all()
  end)
end

local function refresh()
  refresh_id = refresh_id + 1
  local id = refresh_id
  sbar.exec("pgrep -x OmniWM >/dev/null && omniwmctl ping >/dev/null 2>&1 && echo omniwm || echo yabai", function(result)
    if id ~= refresh_id then return end
    if tostring(result):match("omniwm") then refresh_omniwm(id) else refresh_yabai(id) end
  end)
end

local observer = sbar.add("item", "space_observer", { drawing = false, updates = true })
observer:subscribe({ "workspace_update", "windows_on_spaces", "forced" }, refresh)

local watchdog = sbar.add("item", "workspace_watchdog", { drawing = false, update_freq = 2 })
watchdog:subscribe("routine", function()
  if has_data then watchdog:set({ update_freq = 0 }) else refresh() end
end)

refresh()
