return {
  "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  opts = {
    override = {
      md = { icon = "󰽛", color = "#FFFFFF", name = "Md" },
      mdx = { icon = "󰽛", color = "#FFFFFF", name = "Mdx" },
      proto = { icon = "󰿘", color = "#FCB03B", name = "Proto" },
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
      [".vscode"] = {
        icon = "", -- VS Code icon
        color = "#007ACC", -- VS Code blue
        name = "VscodeFolder",
      },
      ["stylua.toml"] = { icon = "", color = "#6D8086", name = "stylua" },
      ["drizzle.config.ts"] = { icon = "󱙌", color = "#A78BFA", name = "DrizzleConfig" },
      ["orval.config.js"] = { icon = "", color = "#6f40c9", name = "OrvalConfig" },
      ["orval.config.ts"] = { icon = "", color = "#6f40c9", name = "OrvalConfig" },
      ["next.config.ts"] = { icon = "", color = "#ffffff", name = "NextConfig" },
      ["nest-cli.json"] = { icon = "", color = "#E0234E", name = "NestConfig" },
      ["main.ts"] = { icon = "", color = "#E0234E", name = "NestMain" },
      ["app.module.ts"] = { icon = "", color = "#E0234E", name = "NestModule" },
      ["app.controller.ts"] = { icon = "", color = "#E0234E", name = "NestController" },
      ["app.service.ts"] = { icon = "", color = "#E0234E", name = "NestService" },
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
