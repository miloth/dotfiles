local wezterm = require "wezterm"
local config = wezterm.config_builder()

-- config.default_prog = { "/opt/homebrew/bin/nu" }
config.default_prog = { "/opt/homebrew/bin/tmux", "new-session", "-A", "-s", "Atlas" }

config.check_for_updates = true
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.enable_tab_bar = false
config.initial_cols = 180
config.initial_rows = 50

config.font = wezterm.font "JetBrainsMono NF"

config.color_scheme_dirs = { '/Users/tmiletti/.config/wezterm/colors' }
config.color_scheme = "Tokyo Night"

config.keys = {
  { mods = "OPT", key = "LeftArrow",  action = wezterm.action.SendKey({ mods = "ALT", key = "b" }) },
  { mods = "OPT", key = "RightArrow", action = wezterm.action.SendKey({ mods = "ALT", key = "f" }) },
  { mods = "CMD", key = "LeftArrow",  action = wezterm.action.SendKey({ mods = "CTRL", key = "a" }) },
  { mods = "CMD", key = "RightArrow", action = wezterm.action.SendKey({ mods = "CTRL", key = "e" }) },
  { mods = "CMD", key = "Backspace",  action = wezterm.action.SendKey({ mods = "CTRL", key = "u" }) },
}

-- URLs in Markdown files are not handled properly by default
-- Source: https://github.com/wez/wezterm/issues/3803#issuecomment-1608954312
config.hyperlink_rules = {
  -- Matches: a URL in parens: (URL)
  {
    regex = '\\((\\w+://\\S+)\\)',
    format = '$1',
    highlight = 1,
  },
  -- Matches: a URL in brackets: [URL]
  {
    regex = '\\[(\\w+://\\S+)\\]',
    format = '$1',
    highlight = 1,
  },
  -- Matches: a URL in curly braces: {URL}
  {
    regex = '\\{(\\w+://\\S+)\\}',
    format = '$1',
    highlight = 1,
  },
  -- Matches: a URL in angle brackets: <URL>
  {
    regex = '<(\\w+://\\S+)>',
    format = '$1',
    highlight = 1,
  },
  -- Then handle URLs not wrapped in brackets
  {
    -- Before
    --regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
    --format = '$0',
    -- After
    regex = '[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)',
    format = '$1',
    highlight = 1,
  },
  -- implicit mailto link
  {
    regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b',
    format = 'mailto:$0',
  },
}

return config
