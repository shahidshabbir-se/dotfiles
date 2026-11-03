local in_tmux = vim.env.TMUX and vim.env.TMUX ~= ""
local in_herdr = (vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "") or vim.env.HERDR_ENV == "1"

return {
  "rmarganti/sidekick.nvim",
  branch = "herdr",
  opts = {
    nes = {
      enabled = false,
    },
    cli = {
      mux = {
        backend = in_tmux and "tmux" or in_herdr and "herdr" or "tmux",
        enabled = true,
        create = "split",
        split = {
          size = 0.33, -- Adjust the size of the new herdr/tmux pane/window
        },
      },
    },
  },
}
