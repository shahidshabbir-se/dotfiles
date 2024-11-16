return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin",
        icons_enabled = true,
        disabled_filetypes = { "mason", "dashboard", "lazy", "ministarter" },
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
    })
  end,
}
