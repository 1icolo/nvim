return {
  'sustech-data/wildfire.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('wildfire').setup()
  end,
}
