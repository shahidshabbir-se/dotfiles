return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    init = function()
      -- Override LazyVim's default init that auto-opens neo-tree on directory buffers.
      -- This prevents neo-tree from stealing focus on session restore.
    end,
    opts = {
      window = {
        -- position = "right",
        width = 30,
      },
    },
  },
}
