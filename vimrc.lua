local root = debug.getinfo(1, "S").source:sub(2):match("(.*)/")
local lazy_root = root .. "/.lazy"

-- Bootstrap lazy.nvim
local lazypath = lazy_root .. "/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = "\\"
vim.keymap.set('n', '<leader>l', require('lazy').home)

-- Setup lazy.nvim
require("lazy").setup({
    root = lazy_root,
    lockfile = root .. "/lazy-lock.json",
    spec = {
        {
            "lukas-reineke/lsp-format.nvim",
            config = function()
                require('lsp-format').setup()
            end,
        },
        {
            'williamboman/mason.nvim',
            dependencies = {
                'williamboman/mason-lspconfig.nvim',
            },
            config = function()
                require('mason').setup()
                require('mason-lspconfig').setup({
                    ensure_installed = { 'lua_ls' },
                    automatic_installation = true,
                })
            end
        },
        {
            'neovim/nvim-lspconfig',
            dependencies = {
                'williamboman/mason.nvim',
                'lukas-reineke/lsp-format.nvim',
            },
            event = { "BufReadPre", "BufNewFile" },
            config = function()
                return require("lspconfig").lua_ls.setup({
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                                preloadFileSize = 500,
                            },
                            hint = {
                                enable = true,
                            },
                        }
                    },
                    on_attach = require("lsp-format").on_attach,
                })
            end
        },
        {
            'nvimtools/none-ls.nvim',
            dependencies = {
                'nvim-lua/plenary.nvim',
                'lukas-reineke/lsp-format.nvim',
            },
            config = function()
                local none_ls = require('null-ls')

                none_ls.setup({
                    sources = {
                        -- any of these sources being enabled seems to introduce the formatting issues
                        none_ls.builtins.code_actions.gitsigns,
                        -- none_ls.builtins.code_actions.refactoring,
                        -- none_ls.builtins.code_actions.ts_node_action,

                        -- whereas this source doesn't seem to cause any issues
                        -- none_ls.builtins.formatting.prettierd.with({
                        --     disabled_filetypes = { 'yaml', 'markdown' },
                        -- }),
                    },
                    on_attach = require("lsp-format").on_attach,
                })
            end,
        },
    },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

local delay = '250m'
vim.api.nvim_create_user_command("ReproduceBug", function()
    vim.cmd("e " .. root .. "/a.lua")
    vim.cmd("sleep " .. delay)

    vim.cmd("w")
    vim.cmd("sleep " .. delay)

    vim.cmd("e " .. root .. "/b.lua")
    vim.cmd("sleep " .. delay)

    vim.cmd("w")
    vim.cmd("sleep " .. delay)

    vim.cmd("e " .. root .. "/a.lua")
end, {})
