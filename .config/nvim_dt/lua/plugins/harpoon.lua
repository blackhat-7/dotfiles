local harpoon = require("harpoon")
local conf = require("telescope.config").values
local M = {}

M.toggle = function(harpoon_files)
  local make_finder = function()
    local paths = {}
    for _, item in ipairs(harpoon_files.items) do
      table.insert(paths, item.value)
    end

    return require("telescope.finders").new_table({
      results = paths,
    })
  end

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = make_finder(),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_buffer_number, map)
        map("i", "<D-d>", function()
          local state = require("telescope.actions.state")
          local selected_entry = state.get_selected_entry()
          local current_picker = state.get_current_picker(prompt_buffer_number)

          harpoon:list():removeAt(selected_entry.index)
          current_picker:refresh(make_finder())
          -- current_picker:set_selection(selected_entry.index)
        end)

        return true
      end,
    })
    :find()
end

vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file, { desc = '[H]arpoon [A]dd' })
vim.keymap.set('n', '<leader>hn', require('harpoon.ui').nav_next, { desc = '[H]arpoon [N]ext' })
vim.keymap.set('n', '<leader>hp', require('harpoon.ui').nav_prev, { desc = '[H]arpoon [P]rev' })
vim.keymap.set('n', '<leader>hm', require('harpoon.cmd-ui').toggle_quick_menu, { desc = '[H]arpoon [M]enu' })
