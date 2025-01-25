return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function(_, opts)
			require("telescope").setup({
				pickers = {
					find_files = {
						file_ignore_patterns = { "node_modules", ".git", ".venv" },
						hidden = true,
					},
					grep_string = {
						file_ignore_patterns = { "node_modules", ".git", ".venv" },
						additional_args = { "--hidden" },
					},
					live_grep = {
						file_ignore_patterns = { "node_modules", ".git", ".venv" },
						additional_args = { "--hidden" },
					},
				},
			})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<C-p>", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		  vim.keymap.set("n", "<leader>sr", builtin.resume, {})
    end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
