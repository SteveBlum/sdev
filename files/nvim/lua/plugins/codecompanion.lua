return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-1.5-flash",
              },
            },
            env = {
              api_key = function()
                return os.getenv("GEMINI_API_KEY")
              end,
            },
          })
        end,
      },
      display = {
        chat = {
          start_in_insert_mode = true,
          window = {
            width = 0.2,
            position = "right",
          },
        },
      },
      strategies = {
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
      },
    })
    vim.keymap.set("n", "<C-a>", "<cmd>CodeCompanionActions<cr>" )
    vim.keymap.set("n" , "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>")
    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])
  end,
}
