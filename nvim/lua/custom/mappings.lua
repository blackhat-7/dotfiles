---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
}

-- more keybinds!
M.tabufline = {
    plugin = true,

    n = {
        -- cycle through buffers
        ["<C-TAB>"] = {
            function()
                require("nvchad.tabufline").tabuflineNext()
            end,
            "goto next buffer",
        },

        ["<S-Tab>"] = {
            function()
                require("nvchad.tabufline").tabuflinePrev()
            end,
            "goto prev buffer",
        },

        -- pick buffers via numbers
        ["<Bslash>"] = { "<cmd> TbufPick <CR>", "Pick buffer" },

        -- close buffer + hide terminal buffer
        ["<leader>x"] = {
            function()
                require("nvchad.tabufline").close_buffer()
            end,
            "close buffer",
        },
    },
}

M.nvterm = {
  plugin = true,

  t = {
    -- toggle in terminal mode
    ["<M-i>"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "toggle floating term",
    },

    ["<A-h>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "toggle horizontal term",
    },

    ["<A-v>"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "toggle vertical term",
    },
  },

  n = {
    -- toggle in normal mode
    ["<A-i>"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "toggle floating term",
    },

    ["<A-h>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
      end,
      "toggle horizontal term",
    },

    ["<A-v>"] = {
      function()
        require("nvterm.terminal").toggle "vertical"
      end,
      "toggle vertical term",
    },

    -- new
    ["<leader>h"] = {
      function()
        require("nvterm.terminal").new "horizontal"
      end,
      "new horizontal term",
    },

    ["<leader>v"] = {
      function()
        require("nvterm.terminal").new "vertical"
      end,
      "new vertical term",
    },
  },
}


M.undotree = {
    plugin = true,

    n = {
        -- Toggle undo tree and then focus
        ["<leader>u"] = { "<cmd> UndotreeToggle <CR> <cmd> UndotreeFocus <CR>", "Toggle undo tree" },
    },
}

-- vim fugitive
M.vim_fugitive = {
    plugin = true,

    n = {
        ["<leader>gs"] = { "<cmd> G<CR>", "Git status" },
        ["<leader>gd"] = { "<cmd> Gdiffsplit<CR>", "Git diff" },
        ["<leader>gS"] = { "<cmd> Gvdiffsplit<CR>", "Git diff split" },
    },
}

M.telescope = {
    plugin = true,

    n = {
        -- find
        ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "find files" },
        ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "find all" },
        ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "live grep" },
        ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "find buffers" },
        ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "help page" },
        ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "find oldfiles" },
        ["<leader>tk"] = { "<cmd> Telescope keymaps <CR>", "show keys" },
        ["<leader>lf"] = { "<cmd> Telescope treesitter <CR>", "show keys" },

        -- git
        ["<leader>cm"] = { "<cmd> Telescope git_commits <CR>", "git commits" },
        ["<leader>gt"] = { "<cmd> Telescope git_status <CR>", "git status" },

        -- pick a hidden term
        ["<leader>pt"] = { "<cmd> Telescope terms <CR>", "pick hidden term" },

        -- theme switcher
        -- ["<leader>th"] = { "<cmd> Telescope themes <CR>", "nvchad themes" },

        ["<leader>fs"] = { "<cmd> Telescope lsp_dynamic_workspace_symbols <CR>", "workspace symbol browser" },

    },
}

M.sidebar = {
    plugin = true,
    n = {
        ["<leader>s"] = { "<cmd> SidebarNvimToggle <CR>", "Toggle sidebar"},
    }
}


M.gonvim = {
    plugin = true,
    n = {
        ["<leader>gn"] = { "<cmd> GonvimSidebarToggle <CR>", "Toggle gonvim sidebar"},
        ["<leader>gm"] = { "<cmd> GonvimMiniMap <CR>", "Toggle gonvim minmap"},
        ["<leader>gw"] = { "<cmd> GonvimWorkspaceSwitch <CR>", "Toggle gonvim sidebar"},
    }
}

M.tagbar = {
    plugin = true,
    n = {
        ["<leader>tb"] = { "<cmd> TagbarToggle <CR>", "Toggle tagbar"},
    }
}

M.chatgpt = {
    plugin = true,
    n = {
        ["<leader>gp"] = { "<cmd> ChatGPT <CR>", "Toggle tagbar"},
    }
}


M.vim_tmux_navigator = {
    plugin = true,
    n = {
        ["<c-h>"] = { "<cmd>TmuxNavigateLeft<cr>" },
        ["<c-j>"] = { "<cmd>TmuxNavigateDown<cr>" },
        ["<c-k>"] = { "<cmd>TmuxNavigateUp<cr>" },
        ["<c-l>"] = { "<cmd>TmuxNavigateRight<cr>" },
        ["<c-\\>"] = { "<cmd>TmuxNavigatePrevious<cr>" },
    }
}

-- M.codeium = {
--     plugin = true,
--     n = {
--         -- vim fn codeium#Accept with <M-l>
--         ["<M-l>"] = { "<cmd> call codeium#Accept() <CR>", "Codeium" },
--     }
-- }

M.lspconfig = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {
    ["gD"] = {
      function()
        vim.lsp.buf.declaration()
      end,
      "lsp declaration",
    },

    ["gd"] = {
      function()
        vim.lsp.buf.definition()
      end,
      "lsp definition",
    },

    ["K"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "lsp hover",
    },

    ["gi"] = {
      function()
        vim.lsp.buf.implementation()
      end,
      "lsp implementation",
    },

    ["<leader>ls"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "lsp signature_help",
    },

    ["<leader>D"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "lsp definition type",
    },

    ["<leader>ra"] = {
      function()
        require("nvchad.renamer").open()
      end,
      "lsp rename",
    },

    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "lsp code_action",
    },

    ["gr"] = {
      function()
        vim.lsp.buf.references()
      end,
      "lsp references",
    },

    ["<leader>di"] = {
      function()
        vim.diagnostic.open_float()
      end,
      "floating diagnostic",
    },

    ["[d"] = {
      function()
        vim.diagnostic.goto_prev()
      end,
      "goto prev",
    },

    ["d]"] = {
      function()
        vim.diagnostic.goto_next()
      end,
      "goto_next",
    },

    ["<leader>q"] = {
      function()
        vim.diagnostic.setloclist()
      end,
      "diagnostic setloclist",
    },

    ["<leader>fm"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      "lsp formatting",
    },

    ["<leader>wa"] = {
      function()
        vim.lsp.buf.add_workspace_folder()
      end,
      "add workspace folder",
    },

    ["<leader>wr"] = {
      function()
        vim.lsp.buf.remove_workspace_folder()
      end,
      "remove workspace folder",
    },

    ["<leader>wl"] = {
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      "list workspace folders",
    },
  },
}

return M
