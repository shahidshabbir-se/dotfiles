return {
  "PedroKlein/pi.nvim",
  cmd = { "Pi", "PiSend", "PiQuick", "PiModel", "PiThinking", "PiSession", "PiStop" },
  keys = {
    { "<leader>ao", desc = "Pi: Toggle terminal" },
    { "<leader>aO", desc = "Pi: Toggle terminal (float)" },
    { "<leader>as", desc = "Pi: Send to terminal", mode = { "n", "v" } },
    { "<leader>aq", desc = "Pi: Quick prompt", mode = { "n", "v" } },
    { "<leader>ae", desc = "Pi: Explain", mode = "v" },
    { "<leader>av", desc = "Pi: Review", mode = "v" },
    { "<leader>am", desc = "Pi: Switch model" },
    { "<leader>ai", desc = "Pi: Session info" },
  },
  opts = {
    split = "vertical",
    model = "github-copilot/gpt-5.4-mini",
    thinking = "medium",
  },
  config = function(_, opts)
    require("pi").setup(opts)

    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({ { "<leader>a", group = "AI (Pi)" } })
    end
  end,
}
