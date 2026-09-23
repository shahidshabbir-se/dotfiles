return {
  "rmarganti/sidekick.nvim",
  branch = "herdr",
  opts = {
    nes = {
      enabled = false,
    },
    cli = {
      mux = {
        backend = "herdr", -- Enable herdr as the multiplexer
        enabled = true,
        create = "split",
        split = {
          size = 0.33, -- Adjust the size of the new herdr pane/window
        },
      },
    },
  },
}
