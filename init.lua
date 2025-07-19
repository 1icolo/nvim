-- ============================================================================
-- Project Management
-- ============================================================================

-- State management
local state = {
  current_dir = vim.fn.getcwd(),
  file_win = nil,
  file_buf = nil,
  terminal_state = {
    buf = nil,
    win = nil,
    is_open = false,
    job_id = nil,
  }
}

-- ============================================================================
-- Project Navigation
-- ============================================================================

-- Open directory as project
function open_project(path)
  path = path or vim.fn.input("Project path: ", vim.fn.getcwd(), "dir")
  if path == "" then return end

  path = vim.fn.expand(path)
  if not vim.fn.isdirectory(path) then
    print("Error: " .. path .. " is not a directory")
    return
  end

  state.current_dir = path
  vim.cmd("cd " .. vim.fn.fnameescape(path))
  print("Project opened: " .. path)

  -- Auto-open file explorer
  toggle_explorer()
end

-- Get directory contents
local function get_dir_contents(dir)
  local items = {}

  -- Add parent directory option
  if dir ~= "/" then
    table.insert(items, "../")
  end

  -- Get directory contents
  local handle = vim.loop.fs_scandir(dir)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then break end

      if name:sub(1, 1) ~= "." then -- Skip hidden files
        if type == "directory" then
          table.insert(items, name .. "/")
        else
          table.insert(items, name)
        end
      end
    end
  end

  -- Sort: directories first, then files
  table.sort(items, function(a, b)
    local a_is_dir = a:sub(-1) == "/"
    local b_is_dir = b:sub(-1) == "/"
    if a_is_dir and not b_is_dir then return true end
    if not a_is_dir and b_is_dir then return false end
    return a < b
  end)

  return items
end

-- Create file explorer
function create_explorer()
  if state.file_buf and vim.api.nvim_buf_is_valid(state.file_buf) then
    vim.api.nvim_buf_delete(state.file_buf, { force = true })
  end

  -- Create buffer
  state.file_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.file_buf].buftype = "nofile"
  vim.bo[state.file_buf].swapfile = false
  vim.bo[state.file_buf].buflisted = false
  vim.bo[state.file_buf].bufhidden = "wipe"

  -- Set buffer name
  vim.api.nvim_buf_set_name(state.file_buf, "Explorer: " .. state.current_dir)

  -- Populate with directory contents
  local items = get_dir_contents(state.current_dir)
  local lines = { "Project: " .. state.current_dir, "" }

  for _, item in ipairs(items) do
    table.insert(lines, item)
  end

  vim.api.nvim_buf_set_lines(state.file_buf, 0, -1, false, lines)
  vim.bo[state.file_buf].modifiable = false

  -- Set up keymaps
  local opts = { buffer = state.file_buf, silent = true }

  vim.keymap.set("n", "<CR>", open_item, opts)
  vim.keymap.set("n", "q", close_explorer, opts)
  vim.keymap.set("n", "R", refresh_explorer, opts)
  vim.keymap.set("n", "~", function() change_directory(vim.fn.expand("~")) end, opts)
  vim.keymap.set("n", "t", toggle_terminal, opts)

  return state.file_buf
end

-- Toggle file explorer
function toggle_explorer()
  if state.file_win and vim.api.nvim_win_is_valid(state.file_win) then
    close_explorer()
    return
  end

  -- Create buffer
  create_explorer()

  -- Create window (vertical split)
  vim.cmd("vsplit")
  state.file_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.file_win, state.file_buf)

  -- Set window width
  vim.api.nvim_win_set_width(state.file_win, 30)

  -- Set window options
  vim.wo[state.file_win].number = false
  vim.wo[state.file_win].relativenumber = false
  vim.wo[state.file_win].wrap = false
  vim.wo[state.file_win].cursorline = true
end

-- Close file explorer
function close_explorer()
  if state.file_win and vim.api.nvim_win_is_valid(state.file_win) then
    vim.api.nvim_win_close(state.file_win, false)
    state.file_win = nil
  end
end

-- Refresh explorer
function refresh_explorer()
  if not state.file_buf or not vim.api.nvim_buf_is_valid(state.file_buf) then
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  create_explorer()

  if state.file_win and vim.api.nvim_win_is_valid(state.file_win) then
    vim.api.nvim_win_set_buf(state.file_win, state.file_buf)
    -- Restore cursor position
    pcall(vim.api.nvim_win_set_cursor, state.file_win, cursor_pos)
  end
end

-- Open item under cursor
function open_item()
  local line = vim.api.nvim_get_current_line()
  if line == "" or line:match("^Project:") then return end

  local item = line
  local full_path = state.current_dir .. "/" .. item

  if item == "../" then
    -- Go to parent directory
    change_directory(vim.fn.fnamemodify(state.current_dir, ":h"))
  elseif item:sub(-1) == "/" then
    -- Enter directory
    change_directory(full_path:sub(1, -2))
  else
    -- Open file
    -- Go to main window (not explorer window)
    local main_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if win ~= state.file_win then
        main_win = win
        break
      end
    end

    if main_win then
      vim.api.nvim_set_current_win(main_win)
      vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    end
  end
end

-- Change directory
function change_directory(new_dir)
  if vim.fn.isdirectory(new_dir) == 0 then
    print("Error: " .. new_dir .. " is not a directory")
    return
  end

  state.current_dir = vim.fn.resolve(new_dir)
  vim.cmd("cd " .. vim.fn.fnameescape(state.current_dir))
  refresh_explorer()
end

-- ============================================================================
-- Project Keymaps
-- ============================================================================

-- Project management
vim.keymap.set("n", "<leader>po", open_project, { desc = "Open project" })
vim.keymap.set("n", "<leader>pe", toggle_explorer, { desc = "Toggle project explorer" })
vim.keymap.set("n", "<leader>pc", function() change_directory(vim.fn.getcwd()) end,
  { desc = "Change to current directory" })

-- Quick navigation
vim.keymap.set("n", "<leader>.", function() open_project(vim.fn.getcwd()) end,
  { desc = "Open current directory as project" })

-- ============================================================================
-- Basic Configuration
-- ============================================================================
--

-- [[ Keymaps ]]
vim.keymap.set("n", "<D-v>", '"+p', { noremap = true, silent = true }) -- Paste from system clipboard using Command+V (macOS)

-- Reformat paragraph and retab using <leader>gr
vim.keymap.set("n", "<leader>gr", function()
  vim.cmd("normal! gq")
  vim.cmd("retab")
end, { noremap = true, silent = true, desc = "Reformat and retab" })

-- [[ Set colorscheme ]]
vim.cmd.colorscheme("zaibatsu")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.g.have_nerd_font = true

-- [[ Basic settings ]]
vim.opt.number = true         -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true     -- Highlight current line
vim.opt.wrap = true           -- Wrap lines
vim.opt.scrolloff = 10        -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8     -- Keep 8 columns left/right of cursor

-- [[ File browser ]]
vim.g.netrw_list_style = 3

-- [[ Indentation ]]
vim.opt.tabstop = 2        -- Tab width
vim.opt.shiftwidth = 2     -- Indent width
vim.opt.softtabstop = 2    -- Soft tab stop
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true  -- Copy indent from current line

-- [[ Search settings ]]
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true  -- Case sensitive if uppercase in search
vim.opt.hlsearch = false  -- Don't highlight search results
vim.opt.incsearch = true  -- Show matches as you type

-- [[ Visual settings ]]
vim.opt.termguicolors = true                      -- Enable 24-bit colors
vim.opt.signcolumn = "yes"                        -- Always show sign column
-- vim.opt.colorcolumn = "100" -- Show column at 100 characters
vim.opt.showmatch = true                          -- Highlight matching brackets
vim.opt.matchtime = 2                             -- How long to show matching bracket
vim.opt.cmdheight = 1                             -- Command line height
vim.opt.completeopt = "menuone,noinsert,noselect" -- Completion options
vim.opt.showmode = false                          -- Don't show mode in command line
vim.opt.pumheight = 10                            -- Popup menu height
vim.opt.pumblend = 10                             -- Popup menu transparency
vim.opt.winblend = 0                              -- Floating window transparency
vim.opt.conceallevel = 0                          -- Don't hide markup
vim.opt.concealcursor = ""                        -- Don't hide cursor line markup
vim.opt.lazyredraw = true                         -- Don't redraw during macros
vim.opt.synmaxcol = 300                           -- Syntax highlighting limit

-- [[ File handling ]]
vim.opt.backup = false                             -- Don't create backup files
vim.opt.writebackup = false                        -- Don't create backup before writing
vim.opt.swapfile = false                           -- Don't create swap files
vim.opt.undofile = true                            -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.nvim/undodir") -- Undo directory
vim.opt.updatetime = 300                           -- Faster completion
vim.opt.timeoutlen = 500                           -- Key timeout duration
vim.opt.ttimeoutlen = 0                            -- Key code timeout
vim.opt.autoread = true                            -- Auto reload files changed outside vim
vim.opt.autowrite = false                          -- Don't auto save

-- [[ Behavior settings ]]
vim.opt.hidden = true                   -- Allow hidden buffers
vim.opt.errorbells = false              -- No error bells
vim.opt.backspace = "indent,eol,start"  -- Better backspace behavior
vim.opt.autochdir = false               -- Don't auto change directory
vim.opt.iskeyword:append("-")           -- Treat dash as part of word
vim.opt.path:append("**")               -- include subdirectories in search
vim.opt.selection = "exclusive"         -- Selection behavior
vim.opt.mouse = "a"                     -- Enable mouse support
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.opt.modifiable = true               -- Allow buffer modifications
vim.opt.encoding = "UTF-8"              -- Set encoding

-- [[ Cursor settings ]]
-- vim.opt.guicursor = " \
-- n-v-c:block, \
-- i-ci-ve:block, \
-- r-cr:hor20, \
-- o:hor50, \
-- a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor, \
-- sm:block-blinkwait175-blinkoff150-blinkon175 \
-- "

-- [[ Folding settings ]]
vim.opt.foldmethod = "expr" -- Use expression for folding
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99      -- Start with all folds open

-- [[ Split behavior ]]
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

-- [[ Key mappings ]]
vim.g.mapleader = ","      -- Set leader key to space
vim.g.maplocalleader = "," -- Set local leader key (NEW)

-- [[ Normal mode mappings ]]
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- [[ Center screen when jumping ]]
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- [[ Delete without yanking ]]
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- [[ Buffer navigation ]]
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- [[ Better window navigation ]]
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- [[ Splitting & Resizing ]]
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- [[ Move lines up/down ]]
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- [[ Quick file navigation ]]
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find file" })

-- [[ Quick config editing ]]
local config_path = "~/.config/nvim/init.lua"
if vim.fn.has("win32") == 1 then
  config_path = "~/AppData/Local/nvim/init.lua"
end
vim.keymap.set("n", "<leader>rc", ":e " .. config_path .. "<CR>", { desc = "Edit config" })

-- [[ See neovim data such as logs and etc. ]]
local data_path = "~/.config/nvim-data"
if vim.fn.has("win32") == 1 then
  data_path = "~/AppData/Local/nvim-data"
end
vim.keymap.set("n", "<leader>rl", ":e " .. data_path .. "<CR>", { desc = "See data directory" })

-- ============================================================================
-- USEFUL FUNCTIONS
-- ============================================================================

-- Copy Full File-Path
vim.keymap.set("n", "<leader>pa", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("file:", path)
end)

-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})


-- Auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Better diff options
vim.opt.diffopt:append("linematch:60")

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

-- Builtin Treesitter
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================

local terminal_state = {
  buf = nil,
  win = nil,
  is_open = false,
  job_id = nil,
}

local function FloatingTerminal()
  -- If terminal is already open, close it (toggle behavior)
  if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
    terminal_state.win = nil
    return
  end

  -- Create buffer if it doesn't exist or is invalid
  if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
    terminal_state.buf = vim.api.nvim_create_buf(false, true)
    -- Set buffer options for better terminal experience
    vim.bo[terminal_state.buf].bufhidden = "hide"
    vim.bo[terminal_state.buf].buflisted = false
    vim.bo[terminal_state.buf].swapfile = false
  end

  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create the floating window
  terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- Set window options using vim.wo
  vim.wo[terminal_state.win].winblend = 0
  vim.wo[terminal_state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"

  -- Define highlight groups for transparency
  vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "NONE", fg = "#565f89" })

  -- Start terminal if not already running or if job ended
  if not terminal_state.job_id or terminal_state.job_id == -1 then
    -- Start terminal in the buffer
    vim.api.nvim_buf_call(terminal_state.buf, function()
      terminal_state.job_id = vim.fn.termopen(vim.o.shell or os.getenv("SHELL") or "bash", {
        on_exit = function(_, exit_code)
          terminal_state.job_id = nil
        end
      })
    end)
  end

  terminal_state.is_open = true
  vim.cmd("startinsert")

  -- Set up keymaps for the terminal buffer
  local opts = { buffer = terminal_state.buf, silent = true }

  -- Escape to close terminal
  vim.keymap.set("t", "<Esc>", function()
    if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
      vim.api.nvim_win_close(terminal_state.win, false)
      terminal_state.is_open = false
      terminal_state.win = nil
    end
  end, opts)

  -- Ctrl+] to close terminal (alternative)
  vim.keymap.set("t", "<C-]>", function()
    if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
      vim.api.nvim_win_close(terminal_state.win, false)
      terminal_state.is_open = false
      terminal_state.win = nil
    end
  end, opts)

  -- Set up autocmd to handle window close
  local group = vim.api.nvim_create_augroup("FloatingTerminal", { clear = false })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      local closed_win = tonumber(args.match)
      if closed_win == terminal_state.win then
        terminal_state.is_open = false
        terminal_state.win = nil
      end
    end,
  })
end

-- Function to explicitly close the terminal
local function CloseFloatingTerminal()
  if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
    terminal_state.win = nil
  end
end

-- Function to kill terminal process and buffer
local function KillFloatingTerminal()
  if terminal_state.job_id then
    vim.fn.jobstop(terminal_state.job_id)
    terminal_state.job_id = nil
  end
  if terminal_state.buf and vim.api.nvim_buf_is_valid(terminal_state.buf) then
    vim.api.nvim_buf_delete(terminal_state.buf, { force = true })
    terminal_state.buf = nil
  end
  terminal_state.is_open = false
  terminal_state.win = nil
end

-- Key mappings
vim.keymap.set("n", "<leader>t", FloatingTerminal, {
  noremap = true,
  silent = true,
  desc = "Toggle floating terminal"
})

vim.keymap.set("n", "<leader>T", KillFloatingTerminal, {
  noremap = true,
  silent = true,
  desc = "Kill floating terminal"
})

-- Make functions global for debugging
_G.FloatingTerminal = FloatingTerminal
_G.CloseFloatingTerminal = CloseFloatingTerminal
_G.KillFloatingTerminal = KillFloatingTerminal

-- ============================================================================
-- Tab Line
-- ============================================================================

-- Tab display settings
vim.opt.showtabline = 1 -- Always show tabline (0=never, 1=when multiple tabs, 2=always)
vim.opt.tabline = ""    -- Use default tabline (empty string uses built-in)

-- Transparent tabline appearance
vim.cmd([[
  hi TabLineFill guibg=NONE ctermfg=242 ctermbg=NONE
]])

vim.api.nvim_set_hl(0, "TabLine", {
  fg = "#ffffff",
  bg = "NONE", -- Transparent background
})

vim.api.nvim_set_hl(0, "TabLineSel", {
  fg = "#ffffff",
  bg = "NONE",     -- Transparent background for active tab
  bold = true,
  underline = true -- Add underline to distinguish active tab
})

vim.api.nvim_set_hl(0, "TabLineFill", {
  bg = "NONE" -- Transparent background for empty tabline space
})

-- Alternative navigation (more intuitive)
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })

-- Tab moving
vim.keymap.set("n", "<leader>tm", ":tabmove<CR>", { desc = "Move tab" })
vim.keymap.set("n", "<leader>t>", ":tabmove +1<CR>", { desc = "Move tab right" })
vim.keymap.set("n", "<leader>t<", ":tabmove -1<CR>", { desc = "Move tab left" })

-- Function to open file in new tab
local function open_file_in_tab()
  vim.ui.input({ prompt = "File to open in new tab: ", completion = "file" }, function(input)
    if input and input ~= "" then
      vim.cmd("tabnew " .. input)
    end
  end)
end

-- Function to duplicate current tab
local function duplicate_tab()
  local current_file = vim.fn.expand("%:p")
  if current_file ~= "" then
    vim.cmd("tabnew " .. current_file)
  else
    vim.cmd("tabnew")
  end
end

-- Function to close tabs to the right
local function close_tabs_right()
  local current_tab = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr("$")

  for i = last_tab, current_tab + 1, -1 do
    vim.cmd(i .. "tabclose")
  end
end

-- Function to close tabs to the left
local function close_tabs_left()
  local current_tab = vim.fn.tabpagenr()

  for i = current_tab - 1, 1, -1 do
    vim.cmd("1tabclose")
  end
end

-- Enhanced keybindings
vim.keymap.set("n", "<leader>tO", open_file_in_tab, { desc = "Open file in new tab" })
vim.keymap.set("n", "<leader>td", duplicate_tab, { desc = "Duplicate current tab" })
vim.keymap.set("n", "<leader>tr", close_tabs_right, { desc = "Close tabs to the right" })
vim.keymap.set("n", "<leader>tL", close_tabs_left, { desc = "Close tabs to the left" })

-- Function to close buffer but keep tab if it's the only buffer in tab
local function smart_close_buffer()
  local buffers_in_tab = #vim.fn.tabpagebuflist()
  if buffers_in_tab > 1 then
    vim.cmd("bdelete")
  else
    -- If it's the only buffer in tab, close the tab
    vim.cmd("tabclose")
  end
end
vim.keymap.set("n", "<leader>bd", smart_close_buffer, { desc = "Smart close buffer/tab" })

-- ============================================================================
-- Status Line
-- ============================================================================

-- [[ Colors ]]
vim.api.nvim_set_hl(0, "StatusLine", {
  fg = "#ffffff", -- White text
  bg = "NONE",    -- Dark background
  bold = true
})

vim.api.nvim_set_hl(0, "StatusLineNC", {
  fg = "#ffffff", -- Gray text for inactive windows
  bg = "#888888", -- Darker background
})

-- Git branch function
-- local function git_branch()
--   local branch
--   if vim.fn.has("win32") == 1 then
--     branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
--   else
--     branch = vim.fn.system("git branch --show-current"):gsub("%s+", "")
--   end
--   if branch ~= "" then
--     return "  " .. branch .. " "
--   end
--   return ""
-- end

-- File type with icon
-- local function file_type()
--   local ft = vim.bo.filetype
--   local icons = {
--     lua = "[LUA]",
--     python = "[PY]",
--     javascript = "[JS]",
--     html = "[HTML]",
--     css = "[CSS]",
--     json = "[JSON]",
--     markdown = "[MD]",
--     vim = "[VIM]",
--     sh = "[SH]",
--   }
--
--   if ft == "" then
--     return "  "
--   end
--
--   return (icons[ft] or ft)
-- end

-- LSP status
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    return "  LSP "
  end
  return ""
end

-- -- Word count for text files
-- local function word_count()
--   local ft = vim.bo.filetype
--   if ft == "markdown" or ft == "text" or ft == "tex" then
--     local words = vim.fn.wordcount().words
--     return "  " .. words .. " words "
--   end
--   return ""
-- end

-- File size
local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand('%'))
  if size < 0 then return "" end
  if size < 1024 then
    return size .. "B "
  elseif size < 1024 * 1024 then
    return string.format("%.1fK", size / 1024)
  else
    return string.format("%.1fM", size / 1024 / 1024)
  end
end

-- -- Mode indicators with icons
local function mode_icon()
  local mode = vim.fn.mode()
  local modes = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK", -- Ctrl-V
    c = "COMMAND",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK", -- Ctrl-S
    R = "REPLACE",
    r = "REPLACE",
    ["!"] = "SHELL",
    t = "TERMINAL"
  }
  return modes[mode] or "  " .. mode:upper()
end

_G.mode_icon = mode_icon
-- _G.git_branch = git_branch
-- _G.file_type = file_type
_G.file_size = file_size
_G.lsp_status = lsp_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold

]])


-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    callback = function()
      vim.opt_local.statusline = table.concat {
        "  ",
        "%#StatusLineBold#",
        "%{v:lua.mode_icon()}",
        "%#StatusLine#",
        " │ %f %h%m%r",
        -- "%{v:lua.git_branch()}",
        -- " │ ",
        -- "%{v:lua.file_type()}",
        -- " | ",
        "%=", -- Right-align everything after this
        "%#StatusLine#",
        "%{v:lua.file_size()}",
        " | ",
        "%{v:lua.lsp_status()}",
        " | ",
        "%l:%c  %P ", -- Line:Column and Percentage
      }
    end
  })
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

  -- vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
  --   callback = function()
  --     vim.opt_local.statusline = "  %f %h%m%r │ %{v:lua.file_type()} | %=  %l:%c   %P "
  --   end
  -- })
end

setup_dynamic_statusline()

-- ============================================================================
-- LSP
-- ============================================================================


-- Go LSP
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start golang LSP",
  pattern = "go",
  callback = function()
    vim.lsp.config['gopls'] = {
      cmd = { 'gopls' },
      root_markers = { { 'go.mod', 'go.sum' }, '.git' },
      filetypes = { 'lua' },
      settings = {}
    }
    vim.lsp.enable('gopls')
  end,
})

-- Lua LSP
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start lua LSP",
  pattern = "lua",
  callback = function()
    vim.lsp.config['luals'] = {
      cmd = { 'lua-language-server' },
      root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
      filetypes = { 'lua' },
      settings = {}
    }
    vim.lsp.enable('luals')
  end,
})

-- HTML LSP configuration
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start HTML LSP",
  pattern = "html",
  callback = function()
    vim.lsp.config['html'] = {
      cmd = { 'vscode-html-languageservice', '--stdio' },
      root_markers = { 'package.json', '.git' },
      filetypes = { 'html' },
      settings = {}
    }
    vim.lsp.enable('html')
  end,
})

-- Tailwind CSS LSP configuration
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start Tailwind CSS LSP",
  pattern = { "html", "css", "scss", "javascript", "typescript", "vue", "svelte", "templ" },
  callback = function()
    -- Check if tailwindcss-language-server is available
    if vim.fn.executable('tailwindcss-language-server') == 1 then
      vim.lsp.config['tailwindcss'] = {
        -- cmd = { 'tailwindcss-language-server', '--stdio', '--allow-env' },
        cmd = { "deno", "run", "--allow-env", "--allow-read", "--allow-sys", "--allow-net", "npm:@tailwindcss/language-server@latest", "--stdio" },
        root_markers = { 'tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', 'package.json', '.git' },
        filetypes = { 'html', 'css', 'scss', 'javascript', 'typescript', 'vue', 'svelte', 'templ' },
        settings = {
          tailwindCSS = {
            classAttributes = { "class", "className", "classList", "ngClass" },
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidConfigPath = "error",
              invalidScreen = "error",
              invalidTailwindDirective = "error",
              invalidVariant = "error",
              recommendedVariantOrder = "warning"
            },
            validate = true
          }
        }
      }
      vim.lsp.enable('tailwindcss')
    else
      vim.notify("tailwindcss-language-server not found. Install with: npm install -g @tailwindcss/language-server",
        vim.log.levels.WARN)
    end
  end,
})

-- Templ LSP configuration (for Go templating)
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start Templ LSP",
  pattern = "templ",
  callback = function()
    vim.lsp.config['templ'] = {
      cmd = { 'templ', 'lsp' },
      root_markers = { 'go.mod', '.git' },
      filetypes = { 'templ' },
    }
    vim.lsp.enable('templ')
  end,
})

vim.lsp.config('*', {
  root_markers = { '.git', '.hg' },
})

vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  }
})

-- Formatting
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  command = "set formatprg=jq",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  command = "set formatprg=shfmt",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  command = "set formatprg=gofmt",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  command = "set formatprg=stylua\\ -",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "py",
  command = "set formatprg=ruff\\ format\\ -",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  command = "set formatprg=yq",
})

-- Custom Formatting
local function format_code()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype

  -- Save cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  if filetype == "python" or filename:match("%.py$") then
    if filename == "" then
      print("Save the file first before formatting Python")
      return
    end

    local black_cmd = "black --quiet " .. vim.fn.shellescape(filename)
    local black_result = vim.fn.system(black_cmd)

    if vim.v.shell_error == 0 then
      vim.cmd("checktime")
      vim.api.nvim_win_set_cursor(0, cursor_pos)
      print("Formatted with black")
      return
    else
      print("No Python formatter available (install black)")
      return
    end
  end

  if filetype == "sh" or filetype == "bash" or filename:match("%.sh$") then
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")

    local cmd = { "shfmt", "-i", "2", "-ci", "-sr" } -- 2 spaces, case indent, space redirects
    local result = vim.fn.system(cmd, content)

    if vim.v.shell_error == 0 then
      local formatted_lines = vim.split(result, "\n")
      if formatted_lines[#formatted_lines] == "" then
        table.remove(formatted_lines)
      end
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
      vim.api.nvim_win_set_cursor(0, cursor_pos)
      print("Shell script formatted with shfmt")
      return
    else
      print("shfmt error: " .. result)
      return
    end
  end

  print("No formatter available for " .. filetype)
end

vim.api.nvim_create_user_command("FormatCode", format_code, {

  desc = "Format current file",
})

vim.keymap.set("n", "<leader>fm", format_code, { desc = "Format file" })

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    -- Navigation
    vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

    -- Information
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

    -- Code actions
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    -- Diagnostics
    vim.keymap.set("n", "<leader>nd", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>pd", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
  end,
})

-- Better LSP UI
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✗",
      [vim.diagnostic.severity.WARN] = "⚠",
      [vim.diagnostic.severity.INFO] = "ℹ",
      [vim.diagnostic.severity.HINT] = "💡",
    },
  },
})

vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
  else
    for _, client in ipairs(clients) do
      print("LSP: " .. client.name .. " (ID: " .. client.id .. ")")
    end
  end
end, {})

-- ============================================================================
-- Plugins
-- ============================================================================

vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/folke/persistence.nvim' },
}

-- ============================================================================
-- Neovide Configuration
-- ============================================================================

if vim.g.neovide then
  vim.keymap.set(
    { "n", "v" },
    "<C-=>",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>",
    { noremap = true, silent = true }
  )
  vim.keymap.set(
    { "n", "v" },
    "<C-->",
    ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>",
    { noremap = true, silent = true }
  )
  vim.keymap.set(
    { "n", "v" },
    "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>",
    { noremap = true, silent = true }
  )

  vim.g.neovide_scale_factor = 0.8
  vim.g.neovide_no_vsync = true
  vim.g.neovide_no_idle = true
  vim.g.neovide_opacity = 0.90
  vim.cmd.NeovideFocus = true

  vim.cmd([[
      highlight Normal guibg=none
      highlight NonText guibg=none
      highlight Normal ctermbg=none
      highlight NonText ctermbg=none
    ]])

  vim.o.title = true
  vim.o.titlestring = "%{expand('%:t')}"
end

-- -- [[ Old Config ]]
-- vim.opt.number = true -- Make line numbers default
-- vim.opt.relativenumber = true
-- vim.opt.mouse = "a" -- Enable mouse mode, can be useful for resizing splits for example!
-- vim.opt.showmode = false -- Don't show the mode, since it's already in status line
-- vim.opt.clipboard = "unnamedplus" -- Sync clipboard between OS and Neovim.
-- vim.opt.breakindent = true -- Enable break indent
-- vim.opt.undofile = true -- Save undo history
-- vim.opt.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
-- vim.opt.smartcase = true
-- vim.opt.signcolumn = "yes" -- Keep signcolumn on by default
-- vim.opt.updatetime = 250 -- Decrease update time
-- -- Decrease mapped sequence wait time
-- vim.opt.timeoutlen = 300 -- Displays which-key popup sooner
-- -- vim.opt.splitright = true -- Configure how new splits should be opened !! Bugged with lualine globalstatus
-- -- vim.opt.splitbelow = true -- Configure how new splits should be opened !! Bugged with lualine globalstatus
-- vim.opt.list = true -- Sets how neovim will display certain whitespace in the editor.
-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- vim.opt.inccommand = "split" -- Preview substitutions live, as you type!
-- vim.opt.cursorline = true -- Show which line your cursor is on
-- vim.opt.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
-- vim.cmd.set("autochdir") -- Automatically change current directory
-- vim.cmd.set("laststatus=3") -- Status line at bottom
-- vim.cmd.set("cmdheight=1") -- Command line at the bottom
-- vim.cmd("cd " .. vim.fn.expand("$HOME")) -- Change initial directory to $HOME
-- vim.opt.termguicolors = true -- Terminal Colors
-- vim.opt.tabstop = 4 -- Tabs
-- vim.opt.shiftwidth = 4 -- Tabs
-- vim.opt.expandtab = true -- Tabs
-- vim.opt.autoindent = true
-- vim.opt.smartindent = true
