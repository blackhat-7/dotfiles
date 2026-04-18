local ts = require('nvim-treesitter')

local treesitter_filetypes = {
  'python',
  'go',
  'lua',
  'rust',
  'typescript',
  'regex',
  'bash',
  'sh',
  'zsh',
  'markdown',
  'kdl',
  'sql',
  'xml',
}

ts.setup {}

vim.api.nvim_create_autocmd('FileType', {
  pattern = treesitter_filetypes,
  callback = function(args)
    if vim.api.nvim_buf_line_count(args.buf) <= 5000 then
      pcall(vim.treesitter.start, args.buf)
    end

    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
}

for _, mode in ipairs { 'x', 'o' } do
  vim.keymap.set(mode, 'aa', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'ia', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'af', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'if', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'ac', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'ic', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'ii', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@conditional.inner', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'ai', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@conditional.outer', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'il', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@loop.inner', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'al', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@loop.outer', 'textobjects', mode)
  end)
  vim.keymap.set(mode, 'at', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@comment.outer', 'textobjects', mode)
  end)
end

for _, mode in ipairs { 'n', 'x', 'o' } do
  vim.keymap.set(mode, ']m', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set(mode, ']]', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set(mode, ']M', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set(mode, '][', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
  end)
  vim.keymap.set(mode, '[m', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set(mode, '[[', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set(mode, '[M', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set(mode, '[]', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
  end)
end

vim.keymap.set('n', '<leader>a', function()
  require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
end)

vim.keymap.set('n', '<leader>A', function()
  require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
end)
