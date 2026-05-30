return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
      },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            layout = {
              auto_hide = { "input" }, -- Automatically hides the input/search bar
              layout = {
                width = 30,
                min_width = 30,
              },
            },
          },
        },
      },
    },
  },
}
