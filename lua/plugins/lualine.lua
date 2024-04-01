return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      icons_enabled = true,
      theme = 'auto',
      -- component_separators = { left = '', right = '' },
      -- section_separators = { left = '', right = '' },
      component_separators = { left = '❫ ', right = '❪' },
      -- component_separators = { left = '❩', right = '❨' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = {},
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      -- lualine_a = {},
      -- lualine_b = {},
      -- lualine_c = {},
      lualine_x = { 'location' },
      -- lualine_y = {},
      -- lualine_z = {},
    },
    tabline = {
      -- lualine_a = { 'tabs' },
      -- lualine_b = { 'windows' },
      -- lualine_c = {},
      -- lualine_x = { 'selectioncount', 'searchcount' },
      lualine_x = {
        {
          'buffers',
          mode = 4,
          icon = false,
          separator = nil,
          max_length = vim.o.columns,
        },
      },
      lualine_y = {
        function()
          local path = vim.fn.getcwd()
          return path:match '([^/]+)$' -- Extract the last component
        end,
      },
      -- lualine_z = {}
    },
    winbar = {
      -- lualine_a = {},
      -- lualine_b = {},
      -- lualine_c = {},
      -- lualine_x = {},
      -- lualine_y = {},
      -- lualine_z = {},
    },
    inactive_winbar = {
      -- lualine_a = {},
      -- lualine_b = {},
      -- lualine_c = { 'filename' },
      -- lualine_x = {},
      -- lualine_y = {},
      -- lualine_z = {},
    },
    extensions = {},
  },
}
