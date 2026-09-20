-- Hyprland config (Lua format). See https://wiki.hypr.land/Configuring/
-- Lua API stubs for editor completion: /usr/share/hypr/stubs/hl.meta.lua

------------------
---- MONITORS ----
------------------

-- Pinned by monitor DESCRIPTION, not connector name: DP-N numbering
-- shifts across kernel upgrades / port changes (seen 2026-09-17).
local aorus   = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. AORUS FO27Q3 25150B002212"
local samsung = "desc:Samsung Electric Company LC27G5xT HNAT300655"

-- scripts/toggle-color-mode.sh finds this block by `output = aorus` and
-- rewrites cm / sdrbrightness / sdrsaturation in place. Keep them one per line.
hl.monitor({
  output = aorus,
  mode = "2560x1440@360",
  position = "0x0",
  scale = 1,
  bitdepth = 10,
  cm = "srgb",
  supports_hdr = 1,
  supports_wide_color = 1,
  sdrbrightness = 1.0,
  sdrsaturation = 1.0,
})

hl.monitor({
  output = samsung,
  mode = "2560x1440@144",
  position = "2560x0",
  scale = 1,
})

hl.config({
  render = {
    cm_auto_hdr = 1,
    cm_enabled = true,
    direct_scanout = 0,
    send_content_type = true,
  },
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "vicinae toggle"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("dms run")
  hl.exec_cmd("sunshine")

  hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user start graphical-session.target")
  hl.exec_cmd("swaybg -i /home/illusion/Pictures/Wallpapers/windows-11-blue-logo.png -m fill")
  hl.exec_cmd("systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland")
  hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
  hl.exec_cmd("systemctl --user start xdg-desktop-portal")
  hl.exec_cmd("xwaylandvideobridge")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")

---------------------
---- PERMISSIONS ----
---------------------

-- Permission changes require a Hyprland restart.
hl.config({ ecosystem = { enforce_permissions = true } })

hl.permission({ binary = "/usr/(bin|local/bin)/grim",                        type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-wlr",  type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm",                      type = "plugin",     mode = "allow" })

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 0,
    border_size = 1,
    col = {
      active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
  },

  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "ctrl:nocaps",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0.0,
    accel_profile = "flat",
    touchpad = {
      natural_scroll = false,
    },
  },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Example per-device config
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.window.float())
hl.bind(mainMod .. " + space",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",      hl.dsp.layout("togglesplit")) -- dwindle

-- Move focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces / move window to workspace with mainMod (+ SHIFT) + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key,            hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key,    hl.dsp.window.move({ workspace = i }))
end

for i = 1, 9 do
  hl.workspace_rule({ workspace = tostring(i), monitor = aorus, default = (i == 1) })
end
hl.workspace_rule({ workspace = "10", monitor = samsung, default = true, persistent = true })

hl.bind(mainMod .. " + f",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + F10",         hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-color-mode.sh toggle"))
hl.bind(mainMod .. " + SHIFT + F10", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-color-mode.sh srgb"))
hl.bind(mainMod .. " + CTRL + F10",  hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-color-mode.sh toggle"))

-- Toggle tabbed windows
hl.bind(mainMod .. " + comma", hl.dsp.group.toggle())

-- Switch windows in tab group
hl.bind(mainMod .. " + j", hl.dsp.group.prev())
hl.bind(mainMod .. " + k", hl.dsp.group.next())

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window --freeze"))
hl.bind("Print",               hl.dsp.exec_cmd("hyprshot -m output --freeze"))
hl.bind("ALT + SHIFT + 4",     hl.dsp.exec_cmd("hyprshot -m region --freeze"))

-- Volume and brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
-- brightnessctl finds no backlight on this desktop; the panel is driven
-- over DDC/CI instead.
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("~/.local/bin/monitor-brightness up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.local/bin/monitor-brightness down"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

----------------------
---- WINDOW RULES ----
----------------------

-- Picture-in-Picture: floating overlay, follows across workspaces
hl.window_rule({
  name = "pip",
  match = { title = "^(Picture-in-Picture|Picture in picture)$" },
  float = true,
  pin = true,
  keep_aspect_ratio = true,
  no_initial_focus = true,
  size = { "monitor_w*0.25", "monitor_h*0.25" },
  move = { "monitor_w-window_w-20", "monitor_h-window_h-20" },
})
