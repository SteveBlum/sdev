return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
    config = function()
			require("mason-lspconfig").setup({
      })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
			lspconfig.vtsls.setup({
        capabilities = capabilities
      })
      lspconfig.pyright.setup({
        capabilities = capabilities
      })
      lspconfig.yamlls.setup({
        capabilities = capabilities
      })
      lspconfig.helm_ls.setup({
        capabilities = capabilities,
        settings = {
          ['helm-ls'] = {
            yamlls = {
              path = "yaml-language-server",
            }
          }
        }
      })

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		requires = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"prettierd",
          "eslint_d",
					"stylua",
          "black",
          "isort",
          "lua_ls",
          "vtsls",
          "pyright",
          "yamlls",
          "helm_ls",
          "rust_analyzer",
          "js-debug-adapter"
				},
			})
		end,
	},
}
