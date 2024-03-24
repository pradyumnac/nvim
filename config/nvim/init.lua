-- vim: foldmethod=marker
-- Neovim Configuration for Pradyumna Chatterjee
-- Currently, I use same branch for all platforms
-- (Windows/Linux/WSl/Termux/Raspberry Pi )
--
-- TODO:
-- ctags with telescope

-- vim.cmd([[{{{}}}
-- set shell=bash
-- ]])
vim.o.encoding = "utf-8"
vim.o.shell = "bash"
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- disable netrw at the very start (For nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- Config: [[ Setting options ]] {{{

-- TODO: port to lua
vim.cmd([[
" filetype plugin indent on
" syntax on
]])

-- See `:help vim.o`
vim.o.hlsearch = false
vim.o.incsearch = true -- starts searching as soon as typing, without enter needed
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.number = true
vim.o.numberwidth = 3 -- always reserve 3 spaces for line number
vim.o.relativenumber = true
vim.o.mouse = 'nicr'
-- vim.o.breakindent = true
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath 'data' .. '.undo//'     -- undo files
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.o.termguicolors = true

vim.o.hidden=true
vim.o.lazyredraw=true
vim.o.backup=false
vim.o.writebackup=false
vim.o.swapfile=false
vim.o.ruler=true
vim.o.autowrite=true
vim.o.backspace="indent,eol,start"
vim.o.history=1000
vim.o.scrolloff=4
vim.opt.clipboard="unnamed,unnamedplus"
vim.opt.syntax="on"
vim.o.showmatch  = true -- show matching bracket
vim.o.matchtime = 2 -- delay before showing matching paren
vim.o.synmaxcol = 300 -- stop syntax highlight after x lines for performance

vim.o.list = false -- do not display white characters
-- vim.o.foldenable = false
vim.o.foldlevel = 4 -- limit folding to 4 levels
vim.o.foldmethod = 'syntax' -- use language syntax to generate folds
vim.o.wrap = false --do not wrap lines even if very long
vim.o.eol = false -- show if there's no eol char
vim.o.showbreak= '↪' -- character to show when line is broken

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.tabstop = 2 -- 1 tab = 2 spaces
vim.o.shiftwidth = 2 -- indentation rule
vim.o.formatoptions = 'qnj1' -- q  - comment formatting; n - numbered lists; j - remove comment when joining lines; 1 - don't break after one-letter word
vim.o.expandtab = true -- expand tab to spaces
vim.o.completeopt = 'menuone,noselect'

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')
-- }}}

-- Autocmds {{{{{{
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.o.foldlevel = 0
  end,
})
-- }}}}}}

-- Functions {{{
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
vim.cmd([[
function! MinExec(cmd)
redir @a
exec printf('silent %s',a:cmd)
redir END
return @a
endfunction
function! GetLeaderMappings()
let lines=MinExec('map <space>')
" let lines=system("rg '<leader>' ~/repos/nvim -N -I|sed 's/^[ ]*//g'|sed 's/^.*<leader>//g'|sort -r")
let lines=split(lines,'\n')
return lines
endfunction
function! GetMappings()
let lines=MinExec('map')
let lines=split(lines,'\n')
return lines
endfunction
function! RenameFile()
let old_name = expand('%')
let new_name = input('New file name: ', expand('%'), 'file')
if new_name != '' && new_name != old_name
exec ':saveas ' . new_name
exec ':silent !rm ' . old_name
redraw!
endif
endfunction
" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
let l:file = expand('%')
if l:file =~# '^\f\+_test\.go$'
call go#test#Test(0, 1)
elseif l:file =~# '^\f\+\.go$'
call go#cmd#Build(0)
endif
endfunction
" Merge a tab into a split in the previous window
function! MergeTabs()
if tabpagenr() == 1
return
endif
let bufferName = bufname("%")
if tabpagenr("$") == tabpagenr()
close!
else
close!
tabprev
endif
split
execute "buffer " . bufferName
endfunction
function! CheckBackspace() abort
let col = col('.') - 1
return !col || getline('.')[col - 1]  =~# '\s'
endfunction
function! ShowDocumentation()
if CocAction('hasProvider', 'hover')
call CocActionAsync('doHover')
else
call feedkeys('K', 'in')
endif
endfunction
function! NumberToggle()
if(&relativenumber == 1)
set norelativenumber
set number
else
set relativenumber
endif
endfunction
function! AdjustFontSize(amount)
let s:fontsize = s:fontsize+a:amount
:execute "GuiFont! Consolas:h" . s:fontsize
endfunction
]])
-- }}}

-- Maps: Default {{{
local silent_opts = { noremap = true, silent = true }
local opts = { noremap = true, silent = false }
-- local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

keymap("i", "jk", "<ESC>", silent_opts)
keymap("i", "kj", "<ESC>", silent_opts)
keymap("n", "j", "gj", silent_opts)
keymap("n", "k", "gk", silent_opts)
-- Plugin management 
keymap("n", "<leader>se", ":vi $MYVIMRC<cr>", opts)
keymap("n", "<leader>ss", ":source $MYVIMRC<cr>", opts)
keymap("n", "<leader>sc", ":PackerClean<cr>", opts)
keymap("n", "<leader>si", ":PackerInstall<cr>", opts)
keymap("n", "<leader>su", ":PackerUpdate<cr>", opts)
-- Save/Save-Quit/Quit
keymap("n", "<C-s>", ":w<cr>", opts)
keymap("i", "<C-s>", "<ESC>:w<cr>", opts)
keymap("n", "<leader>qw", ":wq<cr>", opts)
keymap("n", "<leader>qa", ":qa<cr>", opts)
keymap("n", "<leader>q", ":q<cr>", opts)
keymap("n", "<leader>qxxx", ":q!<cr>", opts)

keymap("n", "H", "^", silent_opts)
keymap("n", "L", "g_", silent_opts)
keymap("n", "zC", "zM", silent_opts)
keymap("n", "zO", "zR", silent_opts)

keymap("n", "<leader>tn", ":call NumberToggle()<cr>", opts)
keymap("n", "<leader>fr", ":call RenameFile()<cr>", opts)

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

-- Install packer {{{
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end
-- }}}

-- -- Alt Plugin Managers: Disabled {{{
-- -- Lazypath {{{
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable", -- latest stable release
--     lazypath,
--   })
-- end
-- vim.o.rtp:prepend(lazypath)
-- --}}}
--
--Mason {{{
-- use { "williamboman/mason.nvim" }
--}}}
-- }}}

require('packer').startup(function(use)
  -- Package manager {{{
  use 'wbthomason/packer.nvim'
  use 'lewis6991/impatient.nvim'
  -- use 'folke/neoconf.nvim' -- folder specific/global lsp configuraton
  use 'williamboman/mason.nvim'
  use 'dstein64/vim-startuptime'
  use { "nvim-neotest/nvim-nio" }
  -- use 'github/copilot.vim'

  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional
    },
    config = function()
      require("nvim-tree").setup {}
    end
  }

  use {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup {
      }
    end
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  }

  -- lsp 
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lua' -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'williamboman/mason-lspconfig.nvim'
  -- use 'j-hui/fidget.nvim'

  -- SNIPPETS
  --
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use "rafamadriz/friendly-snippets"
  use "honza/vim-snippets"
  use "molleweide/LuaSnip-snippets.nvim"

  -- dap
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'theHamsta/nvim-dap-virtual-text'
  use 'leoluz/nvim-dap-go'
  use 'mfussenegger/nvim-dap-python'
  -- Go Plugin
  use 'fatih/vim-go' -- Go Plugin 
  --test
  use 'janko-m/vim-test'

  -- Git related plugins
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'
  use 'nvim-telescope/telescope-github.nvim'

  -- Utilities
  use 'mhinz/vim-startify'
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cd build && make' }
  use 'nvim-telescope/telescope-file-browser.nvim'
  use 'LukasPietzschmann/telescope-tabs'
  -- use {
  --   'rmagatti/session-lens',
  --   requires = {'rmagatti/auto-session', 'nvim-telescope/telescope.nvim'}
  -- }
  use 'junegunn/vim-peekaboo' -- Show Refisters on "
  use 'nanotee/zoxide.vim'
  use 'akinsho/toggleterm.nvim' -- Distraction free
  use 'unblevable/quick-scope' --Char jump highlight

  use 'mechatroner/rainbow_csv'
  use 'ellisonleao/glow.nvim' -- Markdown

  -- Text Manipulation
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
  use 'tommcdo/vim-lion' -- alignment : gl/gL action => glip=
  use 'windwp/nvim-autopairs' --autopair
  use 'tpope/vim-surround' -- ysiw, ysaw ysa}
  use {
    "AckslD/nvim-neoclip.lua",
    requires = {
      {'kkharji/sqlite.lua', module = 'sqlite'},
      {'nvim-telescope/telescope.nvim'},
    },
  }

  -- Appearences
  use 'gruvbox-community/gruvbox'
  -- use 'navarasu/onedark.nvim' -- Theme inspired by Atom
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

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

-- Config: Plugins => neoconf, autopairs,vim-lion {{{
-- require("neoconf").setup()
require("impatient")
require("nvim-autopairs").setup {}
vim.g.lion_squeeze_spaces = 1
vim.g.copilot_no_tab_map = true
-- vim.g.copilot_filetypes = {
--     ["*"] = false,
--     ["javascript"] = true,
--     ["typescript"] = true,
--     ["lua"] = false,
--     ["rust"] = true,
--     ["c"] = true,
--     ["c#"] = true,
--     ["c++"] = true,
--     ["go"] = true,
--     ["python"] = true,
-- }
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

-- Config: Nvim-Tree {{{
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },

})
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

-- Config: Mason-Lspconfig {{{
-- lua fails over and over in armv8l - not available for arch
-- require("mason-lspconfig").setup {
--     ensure_installed = { "lua_ls", "gopls", "pyright" },
--   automatic_installation=true
-- }
-- }}}

-- Config: Mason {{{
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- }}}

-- Maps: lspconfig {{{
-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>yd', require('telescope.builtin').lsp_document_symbols, '[D]ocument S[y]mbols')
  nmap('<leader>ys', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace S[y]mbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

-- }}}

-- Config: lsp/cmp/luasnps {{{
-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')

require'lspconfig'.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
-- TODO: Isnt this duplicate with mason
local servers = { 'pyright', 'tsserver', 'gopls'}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
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
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable() 
        -- they way you will only jump inside the snippet region
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'luasnip', option = { show_autosnippets = true }},
  },
}

local types = require("luasnip.util.types")
luasnip.setup({
  history = true,
  -- Update more often, :h events for more info.
  update_events = "TextChanged,TextChangedI",
  -- Snippets aren't automatically removed if their text is deleted.
  -- `delete_check_events` determines on which events (:h events) a check for
  -- deleted snippets is performed.
  -- This can be especially useful when `history` is enabled.
  delete_check_events = "TextChanged",
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "choiceNode", "Comment" } },
      },
    },
  },
  -- treesitter-hl has 100, use something higher (default is 200).
  ext_base_prio = 300,
  -- minimal increase in priority.
  ext_prio_increase = 1,
  enable_autosnippets = true,
  -- mapping for cutting selected text so it's usable as SELECT_DEDENT,
  -- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
  store_selection_keys = "<Tab>",
  -- luasnip uses this function to get the currently active filetype. This
  -- is the (rather uninteresting) default, but it's possible to use
  -- eg. treesitter for getting the current filetype by setting ft_func to
  -- require("luasnip.extras.filetype_functions").from_cursor (requires
  -- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
  -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
  ft_func = function()
    return vim.split(vim.bo.filetype, ".", true)
  end,
})
-- luasnip.snippets=require("luasnip-snippets").load_snippets()
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()


-- }}}

-- Config: LSPFidget {{{
-- Turn on lsp status information
-- require('fidget').setup()

-- }}}

-- Config: DAP {{{
require('dap-go').setup()

require("nvim-dap-virtual-text").setup {
  enabled = true,                        -- enable this plugin (the default)
  enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
  highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
  highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
  show_stop_reason = true,               -- show stop reason when stopped for exceptions
  commented = false,                     -- prefix virtual text with comment string
  only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
  all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
  filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
  -- experimental features:
  virt_text_pos = 'eol',                 -- position of virtual text, see `:h nvim_buf_set_extmark()`
  all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
  virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
  virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
  -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
}

require("dapui").setup({
  icons = { expanded = "", collapsed = "", current_frame = "" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Use this to override mappings for specific elements
  element_mappings = {
    -- Example:
    -- stacks = {
    --   open = "<CR>",
    --   expand = "o",
    -- }
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
  }
})

local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- ################## Go
require('dap-go').setup {
  -- Additional dap configurations can be added.
  -- dap_configurations accepts a list of tables where each entry
  -- represents a dap configuration. For more details do:
  -- :help dap-configuration
  dap_configurations = {
    {
      -- Must be "go" or it will be ignored by the plugin
      type = "go",
      name = "Attach remote",
      mode = "remote",
      request = "attach",
    },
  },
  -- delve configurations
  delve = {
    -- time to wait for delve to initialize the debug session.
    -- default to 20 seconds
    initialize_timeout_sec = 20,
    -- a string that defines the port to start delve debugger.
    -- default to string "${port}" which instructs nvim-dap
    -- to start the process in a random available port
    port = "${port}"
  },
}

-- ####################Python
require('dap-python').setup()
-- lua require('dap-python').test_runner = 'pytest' -- optional
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
  direction = "float",
  close_on_exit = true, -- close the terminal window when the process exits
  shell = "bash", -- change the default shell
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

-- Config: Telescope {{{
-- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua 
local actions = require'telescope.actions'
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<tab>"] = actions.add_selection,
        ["<cr>"] = actions.select_tab,
        ["<C-t>"] = actions.select_default,
      },
      n = {
        ["<esc>"] = actions.close,
        ["<tab>"] = actions.add_selection,
        ["<cr>"] = actions.select_tab,
        ["<C-t>"] = actions.select_default,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
    file_browser = {
      theme = "ivy",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      mappings = {
        ["i"] = {},
        ["n"] = {},
      },
    },
  },
}

require("telescope").load_extension "file_browser"
-- require("telescope").load_extension("software-licenses")
-- require('telescope').load_extension('gh')
--
-- }}}

-- Config: Treesitter {{{
vim.cmd([[
augroup filetype
    autocmd!
    autocmd BufRead,BufNewFile Jenkinsfile set filetype=groovy
augroup END
]])
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "python", "go","json","jsonc"},

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.o.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- set to `false` to disable one of the mappings
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- }}}

-- -- Config: Sessions Disabled {{{
-- require('auto-session').setup({
--   auto_session_enabled = false
-- })
-- require('session-lens').setup({
--   -- path_display = {'shorten'},
--   theme = 'ivy', -- default is dropdown
--   theme_conf = { border = false },
--   previewer = true,
--   prompt_title = 'SESSIONS',
-- })
-- -- }}}

-- Config: Neoclip{{{
require('neoclip').setup({
  history = 1000,
  enable_persistent_history = false,
  length_limit = 1048576,
  continuous_sync = false,
  filter = nil,
  preview = true,
  prompt = nil,
  default_register = '"',
  default_register_macros = 'q',
  enable_macro_history = true,
  content_spec_column = false,
  on_select = {
    move_to_front = true,
    close_telescope=true
  },
  on_paste = {
    set_reg = false,
    move_to_front = false,
  },
  on_replay = {
    set_reg = false,
    move_to_front = false,
  },
  keys = {
    telescope = {
      i = {
        select = '<cr>',
        paste = '<c-p>',
        paste_behind = '<c-k>',
        replay = '<c-q>',  -- replay a macro
        delete = '<c-d>',  -- delete an entry
      },
      n = {
        select = '<cr>',
        paste = 'p',
        --- It is possible to map to more than one key.
        -- paste = { 'p', '<c-p>' },
        paste_behind = 'P',
        replay = 'q',
        delete = 'd',
        custom = {},
      },
    },
    fzf = {
      select = 'default',
      paste = 'ctrl-p',
      paste_behind = 'ctrl-k',
      custom = {},
    },
  },
})

require('telescope').load_extension('neoclip')

-- }}}

-- Config: Vim-Go {{{
-- let g:go_debug_windows = {
--       \ 'vars':  'leftabove 35vnew',
--       \ 'stack': 'botright 10new',
--       \ }
vim.g.go_test_show_name = 1
vim.g.go_list_type = "quickfix"
vim.g.go_autodetect_gopath = 1
vim.g.go_gopls_complete_unimported = 1
vim.g.go_gopls_gofumpt = 1
-- 2 is for errors and warnings
vim.g.go_diagnostics_level = 2 
vim.g.go_doc_popup_window = 1
vim.g.go_doc_balloon = 1
vim.g.go_imports_mode="gopls"
vim.g.go_imports_autosave=1
vim.g.go_highlight_build_constraints = 1
vim.g.go_highlight_operators = 1
-- vim.g.go_fold_enable = []
-- }}}

-- Maps: Plugins {{{
keymap("n","<F3>", ":MundoToggle<cr>", silent_opts)

-- Terminal
keymap("n","<F4>", ":ToggleTerm<cr>", silent_opts)
keymap("n","<leader>tg", ":ToggleTerm<cr>", silent_opts)
keymap("n","<leader>tt", ":ToggleTerm<cr>", silent_opts)
keymap("n","<leader>tf", ":ToggleTerm<cr>", silent_opts)
function _G.set_terminal_keymaps()
  local t_opts = {buffer = 0}
  vim.keymap.set('t', '<F4>', [[<esc><C-\><C-n>]], t_opts)
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], t_opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], t_opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], t_opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], t_opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], t_opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], t_opts)
end
-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- telescope
local builtin              = require('telescope.builtin')
local find_files_no_ignore = function() builtin.find_files({no_ignore = true}) end
vim.keymap.set('n', '<leader>-' , find_files_no_ignore             , silent_opts) -- non hidden files
vim.keymap.set('n', '<leader>=' , builtin.find_files               , silent_opts) --git checked in file
vim.keymap.set('n', '<leader>,'  , builtin.git_commits              , silent_opts)
vim.keymap.set('n', '<leader>.' , builtin.oldfiles                 , silent_opts)
vim.keymap.set('n', '<leader>/' , builtin.live_grep                , silent_opts)
vim.keymap.set('n', '<leader>:' , builtin.current_buffer_fuzzy_find, silent_opts)
vim.keymap.set('n', '<leader>;' , builtin.buffers                  , silent_opts)
vim.keymap.set('n', '<leader>\\', builtin.help_tags                , silent_opts)

--others
vim.keymap.set('n', '<leader>mq', builtin.quickfix, silent_opts)
keymap('n', '<leader>ms', ':SearchSession<cr>', silent_opts)

-- help
vim.keymap.set('n', '<leader>mt', builtin.treesitter      , silent_opts)
vim.keymap.set('n', '<leader>mh', builtin.help_tags       , silent_opts)
vim.keymap.set('n', '<leader>mm', builtin.keymaps         , silent_opts)
vim.keymap.set('n', '<leader>mk', builtin.keymaps         , silent_opts)
vim.keymap.set('n', '<leader>mc', builtin.commands        , silent_opts)
vim.keymap.set('n', '<leader>mo', builtin.vim_options     , silent_opts)
vim.keymap.set('n', '<leader>"' , ":Telescope neoclip<cr>", silent_opts)

vim.keymap.set("n","<leader>ff", ":Telescope file_browser<cr>", silent_opts)
vim.keymap.set("n","<leader>fg", ":Telescope file_browser path=%:p:h select_buffer=true<cr>", silent_opts)
vim.keymap.set("n","<leader>fd", ":Telescope oldfiles<cr>", silent_opts)
-- nvim-tree keymap
vim.api.nvim_set_keymap("n", "<leader>fe", ":NvimTreeToggle<cr>", silent_opts)
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes

-- Which key 
vim.keymap.set('n', '<C-/>', ':WhichKey<cr>', silent_opts)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>l', vim.diagnostic.setloclist)


-- Maps: DAP {{{
-- Already defined in config
-- local dap    = require('dap')
-- local dapui  = require('dapui')
local dapgo     = require('dap-go')
local dappython = require('dap-python')
vim.keymap.set("n", "<leader>ds", dap.continue, silent_opts)
vim.keymap.set("n", "<leader>dq", dap.terminate, silent_opts)
vim.keymap.set("n", "<leader>dQ", dapui.close, silent_opts)
vim.keymap.set("n", "<leader>do", dap.step_over, silent_opts)
vim.keymap.set("n", "<leader>di", dap.step_into, silent_opts)
vim.keymap.set("n", "<leader>dO", dap.step_out, silent_opts)
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, silent_opts)
vim.keymap.set("n", "<leader>dr", dap.repl.open, silent_opts)
vim.keymap.set("n", "<leader>dt", dapgo.debug_test, silent_opts)
vim.keymap.set("n", "<leader>dm", dappython.test_method, silent_opts)
vim.keymap.set("n", "<leader>dc", dappython.test_class, silent_opts)
vim.keymap.set("v", "<leader>dv", dappython.debug_selection, silent_opts)
-- vnoremap <silent> <leader>dv <ESC>:lua require('dap-python').debug_selection()<CR>
vim.keymap.set("n", "<leader>dB", function () dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, silent_opts)
vim.keymap.set("n", "<leader>dlp", function () dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, silent_opts)
-- }}}

-- }}}

-- Maps: Vim-Go [Disabled] {{{
-- ## AUTOCOMD conflicts with nvim_cmd
-- vim.cmd([[
-- augroup go
--     autocmd!
--
--     autocmd FileType go nmap <silent> <Leader>gv <Plug>(go-def-vertical)
--     autocmd FileType go nmap <silent> <Leader>gs <Plug>(go-def-split)
--     autocmd FileType go nmap <silent> <Leader>gw <Plug>(go-def-tab)
--
--     autocmd FileType go nmap <silent> <Leader>gi <Plug>(go-doc)
--
--     autocmd FileType go nmap <silent> <leader>gb :<C-u>call <SID>build_go_files()<CR>
--     autocmd FileType go nmap <silent><Leader>gr <Plug> (go-run)
--     autocmd FileType go nmap <silent> <leader>gt  <Plug>(go-test)
--     autocmd FileType go nmap <silent> <Leader>gc <Plug>(go-coverage-toggle)
--
--     autocmd FileType go nmap <silent> <C-g> :GoDecls<cr>
--     autocmd FileType go imap <silent> <C-g> <esc>:<C-u>GoDecls<cr>
--     autocmd FileType go map <silent> <Leader>gn :cnext<CR>
--     autocmd FileType go map <silent> <Leader>gp :cprevious<CR>
--     autocmd FileType go nnoremap <silent> <Leader>gx :cclose<CR>
--
--     " Fatih: I like these more!
--     " autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
--     " autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
--     " autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
--     " autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
-- augroup END
-- ]])
-- }}}

vim.cmd [[colorscheme gruvbox]]
--https://github.com/arnvald/viml-to-lua

vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
