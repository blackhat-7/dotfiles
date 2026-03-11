-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local conf = require('telescope.config').values
require('telescope').setup {
  defaults = {
    layout_strategy = "vertical",
    layout_config = {
      vertical = {
        preview_height = 0.7,
        size = {
          width = "95%",
          height = "95%",
        },
      },
    },
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
      },
    },
    -- vimgrep_arguments = {
    --   "--fixed-strings"
    -- },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>fo', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fa', "<cmd>Telescope find_files no_ignore=true hidden=true<cr>", { desc = '[F]ind [F]iles [A]ll' })
vim.keymap.set('n', '<leader>fz', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[F]ind fu[Z]zy' })
vim.keymap.set('n', '<leader>fs', require('telescope.builtin').lsp_dynamic_workspace_symbols, { desc = '[F]ind [S]ymbols' })
vim.keymap.set('n', 'gt', require('telescope.builtin').lsp_type_definitions, { desc = '[G]o to [T]ype' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fk', require('telescope.builtin').keymaps, { desc = '[F]ind [K]eymaps' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[F]ind current [W]ord' })
vim.keymap.set('n', '<leader>fw', require('telescope.builtin').live_grep, { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fr', require('telescope.builtin').resume, { desc = '[F]ind [R]esume' })
vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = '[F]ind existing [B]uffers' })
vim.keymap.set('n', '<leader>gt', require('telescope.builtin').git_status, { desc = '' })
vim.keymap.set('n', '<leader>cm', require('telescope.builtin').git_commits, { desc = '' })
vim.keymap.set('n', '<leader>th', ":Telescope colorscheme<CR>", { desc = 'Select [TH]eme' })
vim.keymap.set('n', '<leader>fm', ":lua vim.lsp.buf.format({async = true})<CR>", { desc = 'LSP [F]or[M]at' })

-- DiffviewOpen picker: list branches + special refs and open with DiffviewOpen
vim.keymap.set('n', '<leader>dv', function()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  -- Collect git branches
  local branches = vim.fn.systemlist('git branch -a --format="%(refname:short)" 2>/dev/null')

  -- Prepend useful special targets
  local entries = { 'HEAD', 'HEAD~1', 'HEAD~2', 'HEAD~3' }
  for _, b in ipairs(branches) do
    local trimmed = vim.trim(b)
    if trimmed ~= '' then
      table.insert(entries, trimmed)
    end
  end

  pickers.new({}, {
    prompt_title = 'DiffviewOpen',
    finder = finders.new_table { results = entries },
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          vim.cmd('DiffviewOpen ' .. selection[1])
        end
      end)
      return true
    end,
  }):find()
end, { desc = '[D]iff[V]iew open branch' })
