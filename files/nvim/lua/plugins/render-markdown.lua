return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "codecompanion" },
	config = function()
		require("render-markdown").setup({
			render_modes = true,
			sign = {
				enabled = false,
			},
			latex = { enabled = false },
			html = { enabled = false },
		})
	end,
}
