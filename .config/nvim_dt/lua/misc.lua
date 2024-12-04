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


-- Options through Telescope
vim.api.nvim_set_keymap("n", "<Leader><tab>", "<Cmd>lua require('telescope.builtin').commands()<CR>", {noremap=false})

-- Fterm
vim.api.nvim_set_keymap("n", "<C-e>", ":lua require('FTerm').toggle()<CR>", {noremap=true})
vim.api.nvim_set_keymap("t", "<C-e>", '<C-\\><C-n>:lua require("FTerm").toggle()<CR>', {noremap=true})

-- Noice
vim.api.nvim_set_keymap("n", "<leader>nn", ":NoiceDismiss<CR>", {noremap=true})

vim.keymap.set("n", "<leader>ee", "<cmd>GoIfErr<cr>",
  {silent = true, noremap = true}
)

-- Git
-- vim.api.nvim_set_keymap("n", "<leader>gc", ":Git commit -m \"", {noremap=false})
-- vim.api.nvim_set_keymap("n", "<leader>gp", ":Git push -u origin HEAD<CR>", {noremap=false})

-- Nvim-tree
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", {noremap=false, silent=true})

-- Toggle inlay hint
vim.keymap.set('n', '<leader>l', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

