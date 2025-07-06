return {
  "nvim-tree/nvim-web-devicons",
  opts = {
    override = {
      md = { icon = "󰽛", color = "#FFFFFF", name = "Md" },
      mdx = { icon = "󰽛", color = "#FFFFFF", name = "Mdx" },
      jsonl = { icon = "", color = "#CBCB41", name = "Jsonl" },
      markdown = { icon = "󰽛", color = "#FFFFFF", name = "Markdown" },
      css = { icon = "", color = "#264de4", name = "Css" },
    },
    override_by_extension = {
      astro = { icon = "", color = "#FE5D02", name = "Astro" },
      javascript = { icon = "" },
      typescript = { icon = "󰛦" },
      lockb = { icon = "", color = "#FBF0DF", name = "bun-lock" },
      prettierrc = { icon = "", color = "#F7B93E", name = "PrettierRC" }, -- added
    },
    override_by_filename = {
      ["stylua.toml"] = { icon = "", color = "#6D8086", name = "stylua" },
      ["Makefile"] = { icon = "", color = "#FBBF24", name = "Makefile" },
      ["makefile"] = { icon = "", color = "#FBBF24", name = "Makefile" },
      [".gitignore"] = { icon = "", color = "#F44D27", name = "gitignore" },
      ["license"] = { icon = "󰿃", name = "License" },
      [".prettierrc"] = { icon = "", color = "#F7B93E", name = "Prettier" }, -- added
      [".prettierrc.json"] = { icon = "", color = "#F7B93E", name = "Prettier" }, -- optional
      [".prettierrc.js"] = { icon = "", color = "#F7B93E", name = "Prettier" }, -- optional
      [".prettierrc.cjs"] = { icon = "", color = "#F7B93E", name = "Prettier" }, -- optional
      [".prettierrc.yml"] = { icon = "", color = "#F7B93E", name = "Prettier" }, -- optional
      [".prettierrc.yaml"] = { icon = "", color = "#F7B93E", name = "Prettier" }, -- optional
    },
  },
}
