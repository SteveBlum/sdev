return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
  },
  -- comment the following line to ensure hub will be ready at the earliest
  cmd = "MCPHub",                         -- lazy load by default
  build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
  config = function()
    require("mcphub").setup({
      auto_approve = false, -- Auto approve mcp tool calls 
      -- Extensions configuration
      extensions = {
        codecompanion = {
          -- Show the mcp tool result in the chat buffer
          -- NOTE:if the result is markdown with headers, content after the headers wont be sent by codecompanion
          show_result_in_chat = true,
          make_vars = true, -- make chat #variables from MCP server resources
          make_slash_commands = true, -- make /slash commands from MCP server prompts
        },
      },
    })
  end,
}
