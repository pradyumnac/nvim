-- vim: foldmethod=marker
--
-- Install packer {{{
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end
-- }}}

require('packer').startup(function(use)
  -- Package manager {{{
  use 'wbthomason/packer.nvim'

  -- Go Plugin
  use 'fatih/vim-go' -- Go Plugin 
  use 'leoluz/nvim-dap-go'


  -- lsp related plugins
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
 
  -- Treesitter
  use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
          local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
          ts_update()
      end,
  }

  -- dap
  use 'mfussenegger/nvim-dap'

  -- Git related plugins
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use 'lewis6991/gitsigns.nvim'
  use 'mattn/webapi-vim' -- vim gist dependency
  use 'mattn/vim-gist' -- Gist helpers @Prefix: gs

  -- Navigation
  -- use 'unblevable/quick-scope' --Char jump highlight
  
  -- Text Manipulation
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
  use 'jiangmiao/auto-pairs'
  use 'tpope/vim-surround' -- ysiw, ysaw ysa}

  -- Appearences
  use 'gruvbox-community/gruvbox'
  -- use 'navarasu/onedark.nvim' -- Theme inspired by Atom
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  -- use {'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}

  -- Utilities
  use {
  'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  
  use 'mhinz/vim-startify'
  use 'junegunn/vim-peekaboo' -- Show Refisters on "
  use 'simnalamburt/vim-mundo' -- Undo
  use 'ellisonleao/glow.nvim' -- Markdown
  use 'majutsushi/tagbar'  --Right Ctags bar ( Universal ctags, install separately)
  use 'junegunn/goyo.vim' -- Distraction free
  use 'akinsho/toggleterm.nvim' -- Distraction free

  -- Diagnostics {{{
  -- use 'dstein64/vim-startuptime'
  -- }}}

  -- Custom Plugins/Bootstrap {{{
  -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
  local has_plugins, plugins = pcall(require, 'custom.plugins')
  if has_plugins then
    plugins(use)
  end

  if is_bootstrap then
    require('packer').sync()
  end
  -- }}}
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
  -- }}}
end

-- Config: [[ Setting options ]] {{{
-- See `:help vim.o`
-- Set highlight on search
vim.o.hlsearch = false
-- Make line numbers default
vim.wo.number = true
-- Enable mouse mode
vim.o.mouse = 'a'
-- Enable break indent
-- vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
-- Set colorscheme
vim.o.termguicolors = true
vim.cmd [[colorscheme gruvbox]]
-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
-- }}}

-- Config: Statusline{{{
-- See `:help lualine.txt`
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox-material',
    component_separators = '|',
    section_separators = '',
  },
}
-- }}}

-- Config: Comment{{{
require('Comment').setup()
-- }}}

-- Config: Gitsigns {{{
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}
-- }}}

-- Config: Quickscope {{{
vim.g.qs_highlight_on_keys = {'f', 'F'}
vim.g.qs_buftype_blacklist = {'terminal', 'nofile'}
vim.g.qs_filetype_blacklist = {'dashboard', 'startify'}
-- }}}

-- Config: lsp/cmp/luasnps {{{
-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')
-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'pyright', 'tsserver', 'gopls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end
-- luasnip setup
local luasnip = require 'luasnip'
-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
-- }}}

-- Config: Terminal {{{ 
require("toggleterm").setup({
  -- size can be a number or function which is passed the current terminal
  -- size = 20 | function(term)
  function(term)
          if term.direction == "horizontal" then
                  return 20
          elseif term.direction == "vertical" then
                  return vim.o.columns * 0.4
          end
  end,
  hide_numbers = false, -- hide the number column in toggleterm buffers
  shade_filetypes = {},
  shade_terminals = true,
  start_in_insert = true,
  insert_mappings = false, -- whether or not the open mapping applies in insert mode
  persist_size = true,
  -- direction = 'vertical' | 'horizontal' | 'window' | 'float',
  direction = "tab",
  close_on_exit = true, -- close the terminal window when the process exits
  shell = fish, -- change the default shell
  -- This field is only relevant if direction is set to 'float'
  float_opts = {
          -- The border key is *almost* the same as 'nvim_open_win'
          -- see :h nvim_open_win for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
          border = "curved",
          winblend = 3,
          highlights = {
                  border = "Normal",
                  background = "Normal",
          },
  },
})

-- }}}

-- -- Config: Bufferline {{{
-- --
-- require("bufferline").setup({
--   options = {
--     diagnostics = "nvim_lsp",
--     separator_style = "thick",
--     diagnostics_indicator = function(_, _, diagnostics_dict)
--             local s = " "
--             for e, n in pairs(diagnostics_dict) do
--                     local sym = e == "error" and " "
--                             or (e == "warning" and " " or (e == "info" and " " or " "))
--                     s = s .. " " .. sym .. n
--             end
--             return s
--     end,
--     offsets = {
--             {
--                     filetype = "NvimTree",
--                     text = "Nvim Tree",
--                     highlight = "Directory",
--                     text_align = "left",
--             },
--     },
--   },
-- })
-- -- }}}

-- Config: Telescope {{{

---}}}

-- Config: Telescope {{{
require('telescope').setup{}
-- }}}
-- Treesitter

-- Make runtime files discoverable to the server {{{
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')
-- }}}

-- Maps: Init {{{
local silent_opts = { noremap = true, silent = true }
local opts = { noremap = true, silent = false }
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",
--   }}}

-- Maps: Default {{{
keymap("i", "jk", "<ESC>", silent_opts)
keymap("i", "kj", "<ESC>", silent_opts)
keymap("n", "j", "gj", silent_opts)
keymap("n", "k", "gk", silent_opts)
-- Plugin management 
keymap("n", "<leader>se", ":vi $MYVIMRC<cr>", silent_opts)
keymap("n", "<leader>ss", ":source $MYVIMRC<cr>", opts)
keymap("n", "<leader>sc", ":PackerClean<cr>", silent_opts)
keymap("n", "<leader>si", ":PackerInstall<cr>", silent_opts)
keymap("n", "<leader>su", ":PackerUpdate<cr>", silent_opts)
-- Save/Save-Quit/Quit
keymap("n", "<C-s>", ":w<cr>", opts)
keymap("i", "<C-s>", "<ESC>:w<cr>", opts)
keymap("n", "<leader>qw", ":wq<cr>", opts)
keymap("n", "<leader>qa", ":qa<cr>", opts)
keymap("n", "<leader>qx", ":q<cr>", opts)
keymap("n", "<leader>qxxx", ":q!<cr>", opts)
-- " Get off my lawn
-- keymap("n","Left",":echoe "Use h"<CR>", opts)
-- keymap("n","Right",":echoe "Use l"<CR>", opts)
-- keymap("n","Up",":echoe "Use k"<CR>", opts)
-- keymap("n","Down",":echoe "Use j"<CR>", opts)
-- Toggle relative line numbers
keymap("n", "leader>tn", ":call NumberToggle()<cr>", opts)
-- src:https://gist.github.com/jedfoster/0559494b1ff8f16cd15f
keymap("n", "<leader><leader>", ":", silent_opts)
keymap("n", "<leader>sh", ":!", silent_opts)
-- -- command mode typos
-- map q: :q
-- command! Q q -- Bind :Q to :q
-- command! Qall qall
-- command! QA qall
-- command! E e
-- command! Wq wq
-- }}}

-- Maps: Plugins {{{
keymap("n","<F3>", ":MundoToggle<cr>", silent_opts)
keymap("n","<F4>", ":ToggleTerm<cr>", silent_opts)
keymap("n","<leader>tg", ":ToggleTerm<cr>", silent_opts)
keymap("n","<leader>tt", ":ToggleTerm<cr>", silent_opts)
keymap("n","<leader>tf", ":ToggleTerm<cr>", silent_opts)
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>,', builtin.find_files, {})
vim.keymap.set('n', '<leader>/', builtin.live_grep, {})
vim.keymap.set('n', '<leader>;', builtin.buffers, {})
vim.keymap.set('n', '<leader>\\', builtin.help_tags, {})
-- }}}

