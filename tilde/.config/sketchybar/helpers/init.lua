-- Load SbarLua by absolute path before config.lua requires it. This prevents a
-- stray sketchybar.lua in the config directory from shadowing the native
-- module and recursively requiring itself.
local home = assert(os.getenv("HOME"), "HOME is not set")
local module_path = home .. "/.local/share/sketchybar_lua/sketchybar.so"
local loader, load_error = package.loadlib(module_path, "luaopen_sketchybar")
if not loader then
  error("Unable to load SbarLua from " .. module_path .. ": " .. load_error)
end
package.loaded.sketchybar = loader()

-- Compile C event providers (silently fail if missing toolchain)
local config_dir = os.getenv("CONFIG_DIR")
  or home .. "/.config/sketchybar"
os.execute("(cd " .. config_dir .. "/helpers/event_providers/cpu_load && make 2>/dev/null)")
