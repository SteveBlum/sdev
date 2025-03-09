vim.cmd("Lazy! install all")
vim.cmd("Lazy load all")
vim.cmd("MasonToolsInstallSync")
-- simple workaround for issue similar to https://github.com/nvim-treesitter/nvim-treesitter/issues/3092
vim.cmd("TSUpdateSync rust")
