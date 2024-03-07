-- local on_attach = require("plugins.configs.lspconfig").on_attach
-- local capabilities = require("plugins.configs.lspconfig").capabilities
--
-- local lspconfig = require "lspconfig"
--
-- -- if you just want default config for the servers then put them in a table
-- local servers = { "html", "cssls", "tsserver", "clangd", "pyright", "gopls", "rust_analyzer" }
--
-- for _, lsp in ipairs(servers) do
--   lspconfig[lsp].setup {
--     on_attach = on_attach,
--     capabilities = capabilities,
--   }
-- end

-- 
-- lspconfig.pyright.setup { blabla}
--
--
--

local utils = require "core.utils"
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "clangd", "pyright", "gopls", "rust_analyzer", "lua_ls", "zls", "ocamllsp", "jsonls", "nil_ls" }

on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true

    utils.load_mappings("lspconfig", { buffer = bufnr })

    -- if client.server_capabilities.signatureHelpProvider then
    --     require("nvchad_ui.signature").setup(client)
    -- end
    if client.server_capabilities.document_formatting then
        vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
end

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

lspconfig['pyright'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = 'basic',
                inlayHints = {
                    functionReturnTypes = true,
                    variableTypes = true
                },
                useImportHeuristic = true
            },
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
            hint = {
                enable = true
            }
        }
    }
}

lspconfig["gopls"].setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
})

local ih = require "inlay-hints"
lspconfig["rust_analyzer"].setup({
    tools = {
        on_initialized = function()
            ih.set_all()
        end,
        inlay_hints = {
            auto = false,
        },
    },
})

lspconfig["lua_ls"].setup({
    settings = {
        Lua = {
            hint = {
                enable = true
            }
        }
    }
})
