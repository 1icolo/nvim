return {
  'jvgrootveld/telescope-zoxide',
  init = function()
    vim.keymap.set('n', '<leader>?', require('telescope').extensions.zoxide.list)
  end,
}
