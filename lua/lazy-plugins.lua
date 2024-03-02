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

  -- require 'plugins.mini',
  require 'plugins.Comment', -- For commenting
  require 'plugins.autopairs', -- Auto pairing of {}, [], etc
  require 'plugins.cmp', -- Autocompletion
  require 'plugins.colorscheme', -- Import all colorschemes here
  require 'plugins.conform', -- Autoformat
  require 'plugins.debug', -- Shows how to use the DAP plugin to debug your code
  require 'plugins.gitsigns', -- Adds git related signs to the gutter, as well as utilities for managing changes
  require 'plugins.highlight-colors', -- Highlighting hex or rgba codes
  require 'plugins.indent_line', -- Add indentation guides even on blank lines
  require 'plugins.java', -- Java integration
  require 'plugins.lazygit', -- Github TUI
  require 'plugins.lspconfig', -- Language server protocol
  require 'plugins.lualine', -- Status line, tab line, and window bar modification
  require 'plugins.neodev', -- Annotations for completion, hover and signatures
  require 'plugins.noice', -- Notification and command popups
  require 'plugins.refractoring', -- Refractoring
  require 'plugins.sleuth', -- Detect tabstop and shiftwidth automatically
  require 'plugins.telescope', -- Fuzzy finder
  require 'plugins.telescope-file-browser', -- File browser inside telescope
  require 'plugins.todo-comments', -- Highlight todo, notes, etc in comments
  require 'plugins.treesitter', -- Highlight, edit, and navigate code
  require 'plugins.ts-autotag', -- Auto closing of html tags through treesitter
  require 'plugins.vim-tmux-navigator', -- Vim-Tmux integration for navigation
  require 'plugins.web-devicons', -- Icons
  require 'plugins.wildfire', -- Incremental selection
  require 'plugins.which-key', -- -- Useful plugin to show you pending keybinds

  -- Uncomment this to simply import all plugins in the specified folder
  -- { import = 'plugins' },
}, {})

-- vim: ts=2 sts=2 sw=2 et
