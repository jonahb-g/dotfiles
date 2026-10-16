local wezterm = require("wezterm")
local act = wezterm.action


local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

-- ui
config.color_scheme = "rose-pine-moon"
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "Regular" })

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
}

config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  config.window_background_opacity = 0.92
  config.macos_window_background_blur = 20
end

-- Pane keys drive tmux (prefix Ctrl+a) when the pane runs tmux, or ssh into the
-- VM's tmux; in a plain local shell they act on WezTerm's own panes instead.
local function in_tmux(pane)
  local process = (pane:get_foreground_process_name() or ""):match("[^/]+$") or ""
  return process == "tmux" or process == "ssh"
end

local function tmux_or(keys, fallback)
  return wezterm.action_callback(function(window, pane)
    if in_tmux(pane) then
      window:perform_action(act.SendString(keys), pane)
    else
      window:perform_action(fallback, pane)
    end
  end)
end

config.keys = {
  -- Cmd+Shift+i splits side by side, Cmd+Shift+b splits below
  { key = "I", mods = "CMD|SHIFT", action = tmux_or("\x01|", act.SplitHorizontal({ domain = "CurrentPaneDomain" })) },
  { key = "B", mods = "CMD|SHIFT", action = tmux_or("\x01-", act.SplitVertical({ domain = "CurrentPaneDomain" })) },
  { key = "w", mods = "CMD", action = tmux_or("\x01x", act.CloseCurrentPane({ confirm = true })) },
  { key = "u", mods = "CMD", action = act.SendString("\x01b") },
  { key = "r", mods = "CMD", action = act.SendString("\x01b") },
  { key = "LeftArrow", mods = "CMD", action = tmux_or("\x01\x1b[D", act.ActivatePaneDirection("Left")) },
  { key = "RightArrow", mods = "CMD", action = tmux_or("\x01\x1b[C", act.ActivatePaneDirection("Right")) },
  { key = "UpArrow", mods = "CMD", action = tmux_or("\x01\x1b[A", act.ActivatePaneDirection("Up")) },
  { key = "DownArrow", mods = "CMD", action = tmux_or("\x01\x1b[B", act.ActivatePaneDirection("Down")) },
  -- Cmd+h/j/k/l -> Ctrl+h/j/k/l, which nvim maps to window navigation
  { key = "h", mods = "CMD", action = act.SendKey({ key = "h", mods = "CTRL" }) },
  { key = "l", mods = "CMD", action = act.SendKey({ key = "l", mods = "CTRL" }) },
  { key = "j", mods = "CMD", action = act.SendKey({ key = "j", mods = "CTRL" }) },
  { key = "k", mods = "CMD", action = act.SendKey({ key = "k", mods = "CTRL" }) },
  -- Cmd+c copies a WezTerm mouse selection if there is one; otherwise it sends
  -- Alt+c, which nvim maps to copying its visual selection to the system clipboard.
  -- Cmd+v keeps WezTerm's default paste.
  { key = "c", mods = "CMD", action = wezterm.action_callback(function(window, pane)
    if window:get_selection_text_for_pane(pane) ~= "" then
      window:perform_action(act.CopyTo("Clipboard"), pane)
    else
      window:perform_action(act.SendString("\x1bc"), pane)
    end
  end) },
  -- Cmd+f -> Alt+f (nvim: search like /), Cmd+Shift+f -> Alt+F (nvim: search the whole project)
  { key = "f", mods = "CMD", action = act.SendString("\x1bf") },
  { key = "F", mods = "CMD|SHIFT", action = act.SendString("\x1bF") },
}

return config
