-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'rose-pine'
-- config.color_scheme = 'Tokyo Night'
-- config.color_scheme = 'Tango (terminal.sexy)'
-- config.color_scheme = 'Laser'
-- config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'Gruvbox Dark (Gogh)'
--
-- Font
-- config.font = wezterm.font 'Fira Code'
-- config.font = wezterm.font('Cascadia Code', { weight = 'Regular' })
-- config.font = wezterm.font('Menlo', { weight = 'Regular' })
config.font = wezterm.font('FiraCode Nerd Font', { weight = 'Regular' })
-- config.font = wezterm.font('JetBrains Mono NL', { weight = 'Regular' })
-- config.font = wezterm.font('SF Mono', { weight = 'Regular' })
-- config.font = wezterm.font('Monaspace Neon', { weight = 'Regular' })
-- config.font = wezterm.font('Monaspace Krypton', { weight = 'Regular' })
-- config.font = wezterm.font('Hack Nerd font', { weight = 'Regular' })
config.font_size = 13
config.line_height = 1.1
config.front_end = "OpenGL"

-- Window
config.window_background_opacity = 0.1
config.macos_window_background_blur = 50
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.max_fps = 120
config.tab_bar_at_bottom = true

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.keys = {
    {
      key = 'Enter',
      mods = 'ALT',
      action = wezterm.action.DisableDefaultAssignment,
    },
}

-- and finally, return the configuration to wezterm
return config
