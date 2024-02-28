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

  -- require 'kickstart.plugins.mini',
  require 'kickstart.plugins.Comment', -- For commenting
  require 'kickstart.plugins.autopairs', -- Auto pairing of {}, [], etc
  require 'kickstart.plugins.cmp', -- Autocompletion
  require 'kickstart.plugins.colorscheme', -- Import all colorschemes here
  require 'kickstart.plugins.conform', -- Autoformat
  require 'kickstart.plugins.debug', -- Shows how to use the DAP plugin to debug your code
  require 'kickstart.plugins.gitsigns', -- Adds git related signs to the gutter, as well as utilities for managing changes
  require 'kickstart.plugins.highlight-colors', -- Highlighting hex or rgba codes
  require 'kickstart.plugins.indent_line', -- Add indentation guides even on blank lines
  require 'kickstart.plugins.java', -- Java integration
  require 'kickstart.plugins.lazygit', -- Github TUI
  require 'kickstart.plugins.lspconfig', -- Language server protocol
  require 'kickstart.plugins.lualine', -- Status line, tab line, and window bar modification
  require 'kickstart.plugins.neodev', -- Annotations for completion, hover and signatures
  require 'kickstart.plugins.noice', -- Notification and command popups
  require 'kickstart.plugins.refractoring', -- Refractoring
  require 'kickstart.plugins.sleuth', -- Detect tabstop and shiftwidth automatically
  require 'kickstart.plugins.telescope', -- Fuzzy finder
  require 'kickstart.plugins.telescope-file-browser', -- File browser inside telescope
  require 'kickstart.plugins.todo-comments', -- Highlight todo, notes, etc in comments
  require 'kickstart.plugins.treesitter', -- Highlight, edit, and navigate code
  require 'kickstart.plugins.ts-autotag', -- Auto closing of html tags through treesitter
  require 'kickstart.plugins.vim-tmux-navigator', -- Vim-Tmux integration for navigation
  require 'kickstart.plugins.web-devicons', -- Icons
  require 'kickstart.plugins.which-key', -- -- Useful plugin to show you pending keybinds

  -- Uncomment this to simply import all plugins in the specified folder
  -- { import = 'kickstart.plugins' },
}, {})

-- vim: ts=2 sts=2 sw=2 et
