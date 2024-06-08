IsTransparent = true
IsTerminalColors = true
GetCodeStyle = {
  comments = 'italic',
  keywords = 'bold',
  strings = 'none',
  functions = 'bold',
  variables = 'bold',
  conditionals = '',
  loops = '',
  booleans = '',
  numbers = '',
  properties = '',
  operators = '',
}

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    -- priority = 1000,
  },
  {
    'navarasu/onedark.nvim',
    name = 'onedark',
    -- priority = 1000,
  },
  {
    'folke/tokyonight.nvim',
    name = 'tokyonight',
    -- priority = 1000,
  },
  {
    'rose-pine/neovim',
    priority = 1000,
    name = 'rose-pine',
    opts = {
      enable = {
        terminal = IsTerminalColors,
      },
      styles = {
        transparency = IsTransparent,
      },
    },
  },
}
