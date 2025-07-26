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
    dap.listeners.before.event_terminated.dapui_config = function() end
    dap.listeners.before.event_exited.dapui_config = function() end

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
        name = "Launch Current File (pwa-node with ts-node)",
        runtimeArgs = { "-r", "ts-node/register" },
        runtimeExecutable = "node",
        args = { "--inspect", "${file}" },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
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
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Test Current File (pwa-node with mocha)",
        runtimeArgs = { "${workspaceFolder}/node_modules/.bin/mocha" },
        runtimeExecutable = "node",
        cwd = vim.fn.getcwd(),
        args = { "${file}", "--coverage", "false" },
        rootPath = "${workspaceFolder}",
        sourceMaps = true,
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch npm run start:dev",
        runtimeExecutable = "npm",
        args = { "run", "start:dev" },
        rootPath = "${workspaceFolder}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        protocol = "inspector",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        outFiles = { "${workspaceFolder}/dist/**/*.js" },
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch npm run start:debug",
        runtimeExecutable = "npm",
        args = { "run", "start:debug" },
        rootPath = "${workspaceFolder}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        protocol = "inspector",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        outFiles = { "${workspaceFolder}/dist/**/*.js" },
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
    }

    -- DAPUI Keymaps
    vim.keymap.set("n", "<leader>dq", dapui.close)

    -- DAP Keymaps
    local function add_tagfunc(widget)
      local orig_new_buf = widget.new_buf
      widget.new_buf = function(...)
        local bufnr = orig_new_buf(...)
        vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.require'me.lsp.ext'.symbol_tagfunc")
        return bufnr
      end
    end

    local widgets = require("dap.ui.widgets")
    add_tagfunc(widgets.expression)
    add_tagfunc(widgets.scopes)
    local keymap = vim.keymap
    local function set(mode, lhs, rhs)
      keymap.set(mode, lhs, rhs, { silent = true })
    end
    set({ "n", "t" }, "<F3>", dap.terminate)
    set({ "n", "t" }, "<F5>", dap.continue)
    set({ "n", "t" }, "<F10>", dap.step_over)
    set({ "n", "t" }, "<F11>", dap.step_into)
    set({ "n", "t" }, "<F12>", dap.step_out)
    set("n", "<leader>b", dap.toggle_breakpoint)
    set("n", "<leader>B", function()
      dap.toggle_breakpoint(vim.fn.input("Breakpoint Condition: "), nil, nil, true)
    end)
    set("n", "<leader>lp", function()
      dap.toggle_breakpoint(nil, nil, vim.fn.input("Log point message: "), true)
    end)
    set("n", "<leader>dr", function()
      dap.repl.toggle({ height = 15 })
    end)
    set("n", "<leader>dl", dap.run_last)
    set("n", "<leader>dj", dap.down)
    set("n", "<leader>dk", dap.up)
    set("n", "<leader>dc", dap.run_to_cursor)
    set("n", "<leader>dg", dap.goto_)
    set("n", "<leader>dS", function()
      widgets.centered_float(widgets.frames)
    end)
    set("n", "<leader>dt", function()
      widgets.centered_float(widgets.threads)
    end)
    set("n", "<leader>ds", function()
      widgets.centered_float(widgets.scopes)
    end)
    set({ "n", "v" }, "<leader>dh", widgets.hover)
    set({ "n", "v" }, "<leader>dp", widgets.preview)
  end,
}
