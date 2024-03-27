local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {
    -- Override plugin definition options
    -- {
    --     "NvChad/nvim-colorizer.lua",
    --     enabled = false
    -- },
    {
        "NvChad/nvterm",
        init = function()
            require("core.utils").load_mappings "nvterm"
        end,
        config = function(_, opts)
            require "base46.term"
            require("nvterm").setup(opts)
        end,
        opts = overrides.nvterm,
    },

    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = true },
        },
        dependencies = {
            -- format & linting
            {
                "jose-elias-alvarez/null-ls.nvim",
                config = function()
                    require "custom.configs.null-ls"
                end,
            },
        },
        config = function()
            require "plugins.configs.lspconfig"
            require "custom.configs.lspconfig"
        end, -- Override to setup mason-lspconfig
    },
    -- override plugin configs
    {
        "williamboman/mason.nvim",
        opts = overrides.mason,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = overrides.treesitter,
    },
    {
        "nvim-tree/nvim-tree.lua",
        opts = overrides.nvimtree,
    },
    -- Install a plugin
    {
        "max397574/better-escape.nvim",
        event = "InsertEnter",
        config = function()
            require("better_escape").setup()
        end,
    },
    -- To make a plugin not be loaded
    -- {
    --   "NvChad/nvim-colorizer.lua",
    --   enabled = false
    -- },

    -- My Additions
    -- {
    --     "zbirenbaum/copilot.lua",
    --     event = { "VimEnter" },
    --     config = function()
    --         vim.defer_fn(function()
    --             require("copilot").setup {
    --                 panel = {
    --                     enabled = true,
    --                     auto_refresh = false,
    --                     keymap = {
    --                         jump_prev = "[[",
    --                         jump_next = "]]",
    --                         accept = "<CR>",
    --                         refresh = "gr",
    --                         open = "<M-g>",
    --                     },
    --                 },
    --                 suggestion = {
    --                     enabled = true,
    --                     auto_trigger = true,
    --                     debounce = 75,
    --                     keymap = {
    --                         accept = "<M-l>",
    --                         accept_word = false,
    --                         accept_line = false,
    --                         next = "<M-]>",
    --                         prev = "<M-[>",
    --                         dismiss = "<C-]>",
    --                     },
    --                 },
    --                 filetypes = {
    --                     yaml = false,
    --                     markdown = true,
    --                     help = false,
    --                     gitcommit = false,
    --                     gitrebase = false,
    --                     hgcommit = false,
    --                     svn = false,
    --                     cvs = false,
    --                     ["."] = false,
    --                 },
    --                 copilot_node_command = "node", -- Node.js version must be > 16.x
    --                 server_opts_overrides = {},
    --             }
    --         end, 100)
    --     end,
    -- },
    {
        "declancm/cinnamon.nvim",
        lazy = false,
        config = function()
            require("cinnamon").setup()
        end,
    },
    {
        "kylechui/nvim-surround",
        lazy = false,
        -- tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup {
                -- Configuration here, or leave empty to use defaults
            }
        end,
    },
    -- {
    --     "akinsho/git-conflict.nvim",
    --     lazy = false,
    --     -- tag = "*",
    --     config = function()
    --         require("git-conflict").setup()
    --     end,
    -- },
    {
        "tpope/vim-fugitive",
        lazy = false,
        require("core.utils").load_mappings "vim_fugitive",
    },
    {
        "nvim-lua/lsp-status.nvim",
        lazy = false,
    },
    {
        "ruanyl/vim-gh-line",
        lazt = false,
    },
    {
        "simrat39/rust-tools.nvim",
        ft = { "rust" },
        after = "nvim-lspconfig",
        config = function()
            require "custom.configs.rust-tools"
        end,
    },
    {
        "simrat39/inlay-hints.nvim",
        lazy = false,
        config = function()
            require("inlay-hints").setup {
                only_current_line = false,

                eol = {
                    right_align = false,
                },
            }
        end,
    },
    -- {
    --     "nvim-telescope/telescope.nvim",
    --     cmd = "Telescope",
    --     config = function()
    --         require "custom.configs.telescope"
    --     end,
    --     require("core.utils").load_mappings "telescope"
    -- },

    -- {
    --     "sidebar-nvim/sidebar.nvim",
    --     lazy = false,
    --     require("core.utils").load_mappings "sidebar",
    --     config = function()
    --         require("sidebar-nvim").setup {
    --             disable_default_keybindings = 0,
    --             bindings = nil,
    --             open = false,
    --             side = "left",
    --             initial_width = 35,
    --             hide_statusline = false,
    --             update_interval = 1000,
    --             sections = { "datetime", "git", "diagnostics" },
    --             section_separator = { "", "-----", "" },
    --             section_title_separator = { "" },
    --             containers = {
    --                 attach_shell = "/bin/sh",
    --                 show_all = true,
    --                 interval = 5000,
    --             },
    --             datetime = { format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
    --             todos = { ignored_paths = { "~" } },
    --         }
    --     end,
    -- },
    {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    },
    {
        "preservim/tagbar",
        lazy = false,
        -- Load custom mappings
        require("core.utils").load_mappings "tagbar",
    },
    {
        "Exafunction/codeium.vim",
        lazy = false,
        config = function()
            vim.g.codeium_disable_bindings = 1
            vim.keymap.set("i", "<M-;>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true })
            -- vim.keymap.set("i", "<M-;>", function()
            --   return vim.fn["codeium#CycleCompletions"](1)
            -- end, { expr = true })
            -- vim.keymap.set("i", "<M-,>", function()
            --   return vim.fn["codeium#CycleCompletions"](-1)
            -- end, { expr = true })
        end,
    },
    -- {
    --     "lukas-reineke/indent-blankline.nvim",
    --     config = function()
    --         vim.opt.list = true
    --         vim.opt.listchars:append "space:⋅"
    --         vim.opt.listchars:append "eol:↴"
    --
    --         require("indent_blankline").setup {
    --             show_end_of_line = true,
    --             space_char_blankline = " ",
    --         }
    --     end
    -- },
    {
        "dstein64/vim-startuptime",
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        lazy = false,
    },
    {
        "MunifTanjim/prettier.nvim",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "markdown" },
    },
    {
        "christoomey/vim-tmux-navigator",
        require("core.utils").load_mappings "vim_tmux_navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
    },
    -- {
    --     "tpope/vim-dadbod",
    --     lazy = false
    -- },
    -- {
    --     "kristijanhusak/vim-dadbod-ui",
    --     lazy = false
    -- },
    -- {
    --     "kristijanhusak/vim-dadbod-completion",
    --     ft = { "sql", "mysql", "plsql" },
    --     lazy = false
    -- },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    signature = {
                        enabled = false
                    },
                    hover = {
                        enabled = false
                    }
                }
            })
            require("notify").setup({
                background_colour = "#000000",
            })
        end
    },
    {
        "nvim-neorg/neorg",
        ft = "norg",
        run = ":Neorg sync-parsers", -- This is the important bit!
        config = function()
            require('neorg').setup {
                load = {
                    ["core.defaults"] = {},
                    ["core.concealer"] = {},
                    ["core.integrations.treesitter"] = {},
                    ["core.esupports.indent"] = {},
                    ["core.summary"] = {},
                    ["core.completion"] = {
                        config = {
                            engine = "nvim-cmp",
                        }
                    },
                    ["core.export.markdown"] = {},
                    ["core.export"] = {},
                }
            }
        end,
    },
    {
        "rhysd/conflict-marker.vim",
        lazy = false
    },
    {
        "sindrets/diffview.nvim",
        lazy = false
    }
}

return plugins
