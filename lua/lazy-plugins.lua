-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins, you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({

  -- [[ Plugin Specs list ]]

  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  --
  -- 'tpope/vim-sleuth',

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})
  -- { 'numToSr/Comment.nvim', opts = {} },

  -- modular approach: using `require 'path/name'` will
  -- include a plugin definition from file lua/path/name.lua

  require 'colorschemes', -- Import all colorschemes here
  require 'plugins.Comment', -- For commenting
  require 'plugins.cmp', -- Autocompletion
  require 'plugins.conform', -- Autoformat
  require 'plugins.debug', -- Shows how to use the DAP plugin to debug your code
  require 'plugins.gitsigns', -- Adds git related signs to the gutter, as well as utilities for managing changes
  require 'plugins.highlight-colors', -- Highlighting hex or rgba codes
  require 'plugins.indent_line', -- Add indentation guides even on blank lines
  require 'plugins.java', -- Java integration
  require 'plugins.lazygit', -- Github TUI
  require 'plugins.lspconfig', -- Language server protocol
  require 'plugins.lualine', -- Status line, tab line, and window bar modification
  require 'plugins.mini', -- A collection of small plugins
  require 'plugins.neodev', -- Annotations for completion, hover and signatures
  require 'plugins.refractoring', -- Refractoring
  require 'plugins.sleuth', -- Detect tabstop and shiftwidth automatically
  require 'plugins.telescope', -- Fuzzy finder
  require 'plugins.telescope-file-browser', -- File browser inside telescope
  require 'plugins.todo-comments', -- Highlight todo, notes, etc in comments
  require 'plugins.treesitter', -- Highlight, edit, and navigate code
  require 'plugins.ts-autotag', -- Auto closing of html tags through treesitter
  require 'plugins.vim-tmux-navigator', -- Vim-Tmux integration for navigation
  require 'plugins.web-devicons', -- Icons
  require 'plugins.which-key', -- Useful plugin to show you pending keybinds
  require 'plugins.wildfire', -- Incremental selection with <CR>
  require 'plugins.telescope-zoxide', -- Better cd

  -- Uncomment this to simply import all plugins in the specified folder
  -- { import = 'plugins' },
}, {
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
