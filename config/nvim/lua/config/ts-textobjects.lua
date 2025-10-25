require("nvim-treesitter.configs").setup({
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["a="] = { query = "@assignment.outer", desc = "Select outer assignment" },
        ["i="] = { query = "@assignment.inner", desc = "Select inner assignment" },
        ["l="] = { query = "@assignment.lhs", desc = "Select left-hand assignment" },
        ["r="] = { query = "@assignment.rhs", desc = "Select right-hand assignment" },

        ["a:"] = { query = "@property.outer", desc = "Select outer property" },
        ["i:"] = { query = "@property.inner", desc = "Select inner property" },
        ["l:"] = { query = "@property.lhs", desc = "Select left property" },
        ["r:"] = { query = "@property.rhs", desc = "Select right property" },

        ["aa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
        ["ia"] = { query = "@parameter.inner", desc = "Select inner parameter" },

        ["ai"] = { query = "@conditional.outer", desc = "Select outer conditional" },
        ["ii"] = { query = "@conditional.inner", desc = "Select inner conditional" },

        ["al"] = { query = "@loop.outer", desc = "Select outer loop" },
        ["il"] = { query = "@loop.inner", desc = "Select inner loop" },

        ["afc"] = { query = "@call.outer", desc = "Select outer function call" },
        ["ifc"] = { query = "@call.inner", desc = "Select inner function call" },

        ["af"] = { query = "@function.outer", desc = "Select outer method" },
        ["if"] = { query = "@function.inner", desc = "Select inner method" },

        ["am"] = { query = "@function.outer", desc = "Select outer method" },
        ["im"] = { query = "@function.inner", desc = "Select inner method" },

        ["ac"] = { query = "@class.outer", desc = "Select outer class" },
        ["ic"] = { query = "@class.inner", desc = "Select inner class" },

        ["a/"] = { query = "@comment.outer", desc = "Select outer comment" },
        ["i/"] = { query = "@comment.inner", desc = "Select inner comment" },
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
        ["]a"] = "@parameter.inner",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
        ["]A"] = "@parameter.inner",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[a"] = "@parameter.inner",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
        ["[A"] = "@parameter.inner",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["]s"] = "@parameter.inner",
        ["]p"] = "@property.outer",
        ["]m"] = "@function.outer",
      },
      swap_previous = {
        ["[s"] = "@parameter.inner",
        ["[p"] = "@property.outer",
        ["[m"] = "@function.outer",
      },
    },
  },
})

