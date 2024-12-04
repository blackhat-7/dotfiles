require('keymaps')
require('plugins.lazy')
require('plugins.misc')
require('plugins.lualine')
require('options')
require('misc')
-- require('plugins.dap')
require('plugins.gitsigns')
require('plugins.tele')
require('plugins.treesitter')
require('plugins.null_ls')
require('plugins.lsp')
require('plugins.trouble')
-- require('plugins.ai')
-- require('plugins.cody')
-- require('plugins.copilot')
-- require('plugins.gpt')
-- require('plugins.nvim-llama')
require('plugins.obsidian')
require('plugins.zenmode')
require('plugins.openingh')
require('plugins.glow')
require('plugins.harpoon')
-- require('plugins.fugitive')
require('plugins.neogit')

-- Neovide
if vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
    -- Helper function for transparency formatting
    -- local alpha = function()
    --     return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
    -- end
    -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
    -- vim.g.neovide_transparency = 0.8
    -- vim.g.transparency = 0.8
    -- vim.g.neovide_background_color = "#0f1117" .. alpha()
    -- vim.o.guifont = "Jetbrains mono:h14" -- text below applies for VimScript

    -- Allow clipboard copy paste in neovim
    vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
    vim.keymap.set('v', '<D-c>', '"+y') -- Copy
    vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
    vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
    vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
    vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode
end


