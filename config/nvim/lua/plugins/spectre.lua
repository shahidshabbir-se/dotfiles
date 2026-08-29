return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>sr", function() require("spectre").open() end, desc = "Search & Replace (Spectre)" },
    { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word" },
    { "<leader>sp", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search in current file" },
  },
  opts = {
    open_cmd = "vnew",
  },
}
