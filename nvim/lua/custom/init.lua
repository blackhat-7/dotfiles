-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.guicursor = "a:blinkon100"

-- Shift blocks of text
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep search words in moddle of screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- auto centre screen on gd and gr
vim.keymap.set("n", "gd", "gdzz")
vim.keymap.set("n", "gr", "grzz")

-- better paste
vim.keymap.set("x", "<leader>p", '\"_dP')

-- transparent background
vim.g.transparency = 0.5

-- code folding
vim.foldmethod = "expr"

-- Neovide
-- if vim.g.neovide then
-- Put anything you want to happen only in Neovide here
-- vim.g.neovide_refresh_rate = 120
-- vim.g.neovide_input_macos_alt_is_meta = false

-- end

vim.g.shell = "/bin/bash"
-- vim.lsp.inlay_hint(0, true)

vim.opt.pumheight = 10
