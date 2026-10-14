local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local keep_awake = sbar.add("item", "keep_awake", {
  position = "right",
  drawing = true,
  y_offset = settings.item.right_y_offset,
  update_freq = 30,
  icon = {
    string = icons.awake,
    font = { family = "Symbols Nerd Font", style = "Regular", size = 13.0 },
    color = colors.warning,
    padding_left = 7,
    padding_right = 7,
  },
  label = {
    string = "●",
    font = { family = settings.font.text, style = "Bold", size = 12.0 },
    color = colors.danger,
    y_offset = 5,
    padding_left = -13,
    padding_right = 6,
    drawing = false,
  },
  padding_left = 0,
  padding_right = 0,
  click_script = "$HOME/.dotfiles/bin/remote-workstation toggle",
})

local command = [=[
  profile_pid=$(launchctl print "gui/$(id -u)/com.sem.remote-workstation-awake" 2>/dev/null |
    awk '/^[[:space:]]*pid =/ { print $3; exit }')
  profile_pids=$(ps -Ao pid=,ppid= | awk -v root="$profile_pid" '
    { pid[NR]=$1; parent[NR]=$2 }
    END {
      if (root == "") exit
      own[root]=1
      changed=1
      while (changed) {
        changed=0
        for (i=1; i<=NR; i++) {
          if (own[parent[i]] && !own[pid[i]]) {
            own[pid[i]]=1
            changed=1
          }
        }
      }
      for (value in own) {
        if (own[value]) printf "%s ", value
      }
    }
  ')
  mode=off
  if launchctl print "gui/$(id -u)/com.sem.remote-workstation-awake" >/dev/null 2>&1; then
    mode=$("$HOME/.dotfiles/bin/remote-workstation" mode)
  fi
  blocked=false
  if pmset -g assertions | awk -v profile_pids="$profile_pids" '
    BEGIN { split(profile_pids, own, " ") }
    /^Listed by owning process:/ { owners=1; next }
    /^Kernel Assertions:/ { owners=0 }
    owners && /Prevent(UserIdle(Display|System)Sleep|SystemSleep)/ && !/pid [0-9]+\(powerd\):/ {
      own_profile=0
      for (i in own) {
        if (own[i] != "" && $0 ~ ("pid " own[i] "\\(")) own_profile=1
      }
      if (!own_profile) found=1
    }
    END { exit !found }
  '; then
    blocked=true
  fi
  printf '%s %s\n' "$mode" "$blocked"
]=]

local function update()
  sbar.exec(command, function(result)
    local mode = result:match("%S+") or "off"
    local blocked = result:match("%S+%s+(%S+)") == "true"
    local color = colors.success
    if mode == "all-on" then
      color = colors.purple
    elseif mode == "on" then
      color = colors.orange
    end

    keep_awake:set({
      drawing = true,
      icon = { color = color },
      label = { drawing = blocked },
    })
  end)
end

keep_awake:subscribe({ "routine", "system_woke", "keep_awake_change" }, update)
update()
