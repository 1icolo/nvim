-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Navigate through tabs using alt + hjkl
vim.api.nvim_set_keymap('t', '<C-k>', '<C-\\><C-N><C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-j>', '<C-\\><C-N><C-w>j', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('t', "<A-h>", "<C-\\><C-N><C-w>h", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('t', "<A-j>", "<C-\\><C-N><C-w>j", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('t', "<A-k>", "<C-\\><C-N><C-w>k", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('t', "<A-l>", "<C-\\><C-N><C-w>l", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', "<A-h>", "<C-\\><C-N><C-w>h", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', "<A-j>", "<C-\\><C-N><C-w>j", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', "<A-k>", "<C-\\><C-N><C-w>k", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', "<A-l>", "<C-\\><C-N><C-w>l", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', "<A-h>", "<C-w>h", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', "<A-j>", "<C-w>j", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', "<A-k>", "<C-w>k", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', "<A-l>", "<C-w>l", { noremap = true, silent = true })

-- Ctrl + U or D should always center
local function lazy(keys) -- This function to removes flickering
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  return function()
    local old = vim.o.lazyredraw
    vim.o.lazyredraw = true
    vim.api.nvim_feedkeys(keys, 'nx', false)
    vim.o.lazyredraw = old
  end
end
vim.keymap.set('n', '<C-u>', lazy '<C-u>zz', { noremap = true, desc = 'Go half a page UP', silent = true })
vim.keymap.set('n', '<C-d>', lazy '<C-d>zz', { noremap = true, desc = 'Go half a page DOWN', silent = true })

-- Scrolling through buffers
vim.api.nvim_set_keymap('n', '<A-l>', ':bnext<CR>', { noremap = true, desc = 'Next Buffer', silent = true })
vim.api.nvim_set_keymap('n', '<A-h>', ':bprevious<CR>', { noremap = true, desc = 'Previous Buffer', silent = true })
vim.api.nvim_set_keymap('n', '<A-c>', ':bdelete<CR>', { noremap = true, desc = 'Delete Buffer', silent = true })
vim.api.nvim_set_keymap('n', '<C-A-c>', ':bdelete!<CR>', { noremap = true, desc = 'Force Delete Buffer', silent = true })

-- LazyGit
vim.api.nvim_set_keymap('n', '<leader>gl', ':LazyGit<CR>', { noremap = true, desc = 'Start [L]azyGit', silent = true })

-- Telescope File Browser
-- Browser in Git Root
-- local function get_git_root()
--   local dot_git_path = vim.fn.finddir('.git', '.;')
--   return vim.fn.fnamemodify(dot_git_path, ':h')
-- end
-- vim.api.nvim_set_keymap(
--   'n',
--   '<leader>su',
--   string.format(':Telescope file_browser path=%s<CR>', get_git_root()),
--   -- { noremap = true, desc = '[S]earch by [B]rowsing Files in Git Root' }
-- )
-- Browse in buffer directory
vim.api.nvim_set_keymap(
  'n',
  '<leader>sb',
  ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
  { noremap = true, desc = '[S]earch by [b]rowsing Files Relative', silent = true }
)
-- Browse in home
vim.api.nvim_set_keymap('n', '<space>sB', ':Telescope file_browser path=~<CR>', { noremap = true, desc = '[S]earch by [B]rowsing Files Global' })

-- Toggle Highlight Colors
vim.api.nvim_set_keymap('n', '<leader>tc', ":lua require('nvim-highlight-colors').toggle()<CR>", { noremap = true, desc = '[T]oggle Highlight [C]olors' })
