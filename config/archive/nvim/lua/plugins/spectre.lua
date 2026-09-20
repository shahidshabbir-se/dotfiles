return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>p",  function() require("spectre").toggle() end, desc = "Toggle Search & Replace (Spectre)" },
    { "<leader>pw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word" },
    { "<leader>pf", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search in current file" },
  },
  opts = {
    open_cmd = "vnew",
  },
}
