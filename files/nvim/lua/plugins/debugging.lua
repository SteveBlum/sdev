return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
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

    local function get_pkg_path(pkg, path)
      pcall(require, "mason")
      local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
      path = path or ""
      local ret = root .. "/packages/" .. pkg .. "/" .. path
      return ret
    end
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          get_pkg_path("js-debug-adapter", "/js-debug/src/dapDebugServer.js"),
          "${port}",
        },
      },
    }
    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch JS file",
        program = "${file}",
        cwd = vim.fn.getcwd(),
      },
    }
    dap.configurations.typescript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch TS file",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Current File (pwa-node)",
        cwd = vim.fn.getcwd(),
        args = { "${file}" },
        sourceMaps = true,
        protocol = "inspector",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Current File (pwa-node with ts-node)",
        cwd = vim.fn.getcwd(),
        runtimeArgs = { "--loader", "ts-node/esm" },
        runtimeExecutable = "node",
        args = { "${file}" },
        sourceMaps = true,
        protocol = "inspector",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Test Current File (pwa-node with jest)",
        runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
        runtimeExecutable = "node",
        cwd = vim.fn.getcwd(),
        args = { "${file}", "--coverage", "false" },
        rootPath = "${workspaceFolder}",
        sourceMaps = true,
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
    }
    vim.keymap.set("n", "<Leader>dt", function()
      dap.set_breakpoint()
    end)
    vim.keymap.set("n", "<Leader>dc", function()
      dap.continue()
    end)
  end,
}
