-- For Neovide
if vim.g.neovide then
  vim.keymap.set({ 'n', 'v' }, '<C-=>', ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>', { noremap = true, silent = true })
  vim.keymap.set({ 'n', 'v' }, '<C-->', ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>', { noremap = true, silent = true })
  vim.keymap.set({ 'n', 'v' }, '<C-0>', ':lua vim.g.neovide_scale_factor = 1<CR>', { noremap = true, silent = true })

  vim.g.neovide_scale_factor = 0.8
  -- vim.g.neovide_no_vsync = true
  -- vim.g.neovide_no_idle = true
  vim.g.neovide_transparency = 0.99
  vim.cmd.NeovideFocus = true
end
