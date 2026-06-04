vim.api.nvim_set_keymap("i", "jj", "<Esc>", {noremap=false})
-- twilight
vim.api.nvim_set_keymap("n", "tw", ":Twilight<enter>", {noremap=false})
-- buffers
vim.api.nvim_set_keymap("n", "tk", ":blast<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "tj", ":bfirst<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "<S-Tab>", ":bprev<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "<Tab>", ":bnext<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "<leader>bd", ":bdelete<enter>", {noremap=false})
-- files
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "WW", ":w!<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "E", "$", {noremap=false})
vim.api.nvim_set_keymap("n", "B", "^", {noremap=false})
vim.api.nvim_set_keymap("n", "TT", ":TransparentToggle<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "st", ":TodoTelescope<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "ss", ":noh<CR>", {noremap=true})
-- splits
vim.api.nvim_set_keymap("n", "<C-W>,", ":vertical resize -10<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<C-W>.", ":vertical resize +10<CR>", {noremap=true})
vim.keymap.set('n', '<space><space>', "<cmd>set nohlsearch<CR>")
-- Insert Date
vim.api.nvim_set_keymap("n", "<space>id", ":pu=strftime('%a %d %b %Y')<CR>", {noremap=true})

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Markdown preview with pi-style Mermaid ASCII rendering
local markdown_preview = function()
  if vim.bo.filetype ~= 'markdown' then
    vim.notify('Current buffer is not markdown', vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Save the file before previewing markdown', vim.log.levels.WARN)
    return
  end

  local script = vim.fn.expand('~/dotfiles/scripts/md-mermaid-preview.mjs')
  vim.cmd('tabnew')
  local width = vim.api.nvim_win_get_width(0)
  local cmd = string.format(
    'node %s --width %d %s | bat -l markdown --paging=never --plain --wrap=never',
    vim.fn.shellescape(script),
    width,
    vim.fn.shellescape(file)
  )
  vim.fn.termopen({ 'bash', '-lc', cmd }, { cwd = vim.fn.fnamemodify(file, ':h') })
  vim.keymap.set('n', 'q', '<cmd>bd!<cr>', { buffer = true, desc = 'Close markdown preview' })
  vim.cmd('startinsert')
end
vim.api.nvim_create_user_command('MarkdownPreview', markdown_preview, {})
vim.keymap.set('n', '<space>mp', markdown_preview, { desc = 'Markdown preview' })

local open_file_under_cursor = function()
  local token = vim.fn.expand('<cWORD>')
    :gsub([=[^[`'"({%[<]+]=], '')
    :gsub([=[[`'"),.;}%]>]+$]=], '')
  local path, row, col = token:match('^(.+):(%d+):(%d+)$')
  if not path then
    path, row = token:match('^(.+):(%d+)$')
  end

  if path then
    local roots = { vim.fn.getcwd() }
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      local repo = line:match('^Repos:%s*(.+)$')
      if repo then
        table.insert(roots, repo)
        break
      end
    end

    for _, root in ipairs(roots) do
      local file = vim.startswith(path, '/') and path or vim.fs.normalize(root .. '/' .. path)
      if vim.fn.filereadable(file) == 1 then
        vim.cmd.edit(vim.fn.fnameescape(file))
        vim.api.nvim_win_set_cursor(0, { tonumber(row), math.max((tonumber(col) or 1) - 1, 0) })
        return
      end
    end
  end

  vim.ui.open(vim.fn.expand('<cfile>'))
end
vim.keymap.set('n', 'gx', open_file_under_cursor, { desc = 'Open file:line or URI under cursor' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Ctrl + hjkl to move windows
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', {noremap = true})

-- Search selection
vim.keymap.set('v', '/', '<esc>/\\%V', { noremap = true, silent = true })

