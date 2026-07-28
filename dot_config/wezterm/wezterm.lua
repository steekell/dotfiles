-- ~/.config/wezterm/wezterm.lua

local wezterm = require("wezterm")

return {
  font = wezterm.font("JetBrainsMono Nerd Font"),
  font_size = 11.0,

  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,

  window_decorations = "RESIZE",

  default_prog = { "zsh" },

  scrollback_lines = 10000,

  keys = {
    {
      key = "Enter",
      mods = "ALT",
      action = wezterm.action.ToggleFullScreen,
    },
    -- Entrée en mode copie (navigation vi)
    {
      key = "v",
      mods = "ALT",
      action = wezterm.action.ActivateCopyMode,
    },
    -- Ajout de l'auto-paire
    {
      key = "[",
      mods = "NONE",
      action = wezterm.action.Multiple {
        wezterm.action.SendString "[]",
        wezterm.action.SendKey { key = 'LeftArrow' },
      },
    },
  },
}
