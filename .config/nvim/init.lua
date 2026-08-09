local o = vim.o
local g = vim.g

g.mapleader = ' '
o.autocomplete = true
o.colorcolumn = '+1'
o.complete = '.,w,b,t,o'
o.completeopt = 'fuzzy,menuone,noselect,popup'
o.ignorecase = true
o.list = true
o.listchars = 'tab:> ,trail:.,nbsp:_'
o.showmode = true
o.showtabline = 2
o.number = true
o.numberwidth = 5
o.pumheight = 7
o.relativenumber = true
o.scrolloff = 2048
o.signcolumn = 'yes'
o.smartcase = true
o.splitbelow = true
o.splitright = true

o.expandtab = true
o.shiftround = true
o.shiftwidth = 4
o.softtabstop = -1
o.textwidth = 75
o.wrap = true

local km = vim.keymap
local ko = { noremap = true, silent = true }
local ke = { noremap = true, silent = true, expr = true }

local function tabComplete()
    return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end

km.set('n', '<leader><space>', ':noh<cr>', ko)
km.set('n', 'gb', ':bnext<cr>', ko)
km.set('n', 'gB', ':bprev<cr>', ko)
km.set('i', '<Tab>', tabComplete, ke)

local api = vim.api
local aug = vim.api.nvim_create_augroup('userconfig', {})

api.nvim_create_autocmd('BufWinEnter', {
    group = aug,
    pattern = '*',
    command = 'silent! normal! g`"zv',
})

api.nvim_create_autocmd('BufWritePre', {
    group = aug,
    pattern = '*',
    command = 'lua vim.lsp.buf.format()',
})

local function updateMainWidth()
    -- TODO
end

api.nvim_create_autocmd('OptionSet', {
    group = aug,
    pattern = { 'textwidth', 'signcolumn', 'colorcolumn' },
    callback = updateMainWidth,
})

local function gh(s)
    return 'https://github.com/' .. s
end

vim.pack.add({
    { src = gh('neovim/nvim-lspconfig') },
    { src = gh('kylechui/nvim-surround') },
    { src = gh('rebelot/kanagawa.nvim'), name = 'kanagawa' },
    { src = gh('nvim-lua/plenary.nvim'), name = 'plenary' },
    {
        src = gh('nvim-telescope/telescope.nvim'),
        name = 'telescope',
        version = 'v0.2.2',
    },
})

vim.lsp.enable({ 'bashls', 'lua_ls' })

vim.diagnostic.config({
    virtual_text = {
        current_line = true,
        virt_text_pos = 'eol_right_align',
    },
})

require('kanagawa').setup({
    colors = {
        theme = {
            all = {
                ui = {
                    bg_gutter = 'none'
                }
            }
        }
    }
})

vim.cmd('colorscheme kanagawa-wave')

local tele = require('telescope.builtin')

km.set('n', '<leader>ff', tele.find_files)
km.set('n', '<leader>fg', tele.live_grep)
km.set('n', '<leader>fb', tele.buffers)
km.set('n', '<leader>fh', tele.help_tags)
km.set('n', '<leader>fd', tele.diagnostics)

require('zaim.status')
