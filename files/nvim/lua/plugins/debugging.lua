return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      require("dapui").setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set("n", "<Leader>dt", function()
        dap.set_breakpoint()
      end)
      vim.keymap.set("n", "<Leader>dc", function()
        dap.set_continue()
      end)
    end,
  },{
    "mxsdev/nvim-dap-vscode-js",
     config = function()
        require("dap-vscode-js").setup({
          debugger_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter',
          debugger_cmd = { 'js-debug-adapter' },
          adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
        })
    end
  }
}
