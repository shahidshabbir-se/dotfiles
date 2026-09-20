return {
  "folke/sidekick.nvim",
  cmd = "Sidekick",
  event = "VeryLazy",
  keys = {
    -- AI Suggestions (NES)
    {
      "<leader>as",
      "<cmd>Sidekick nes toggle<cr>",
      desc = "Toggle AI Suggestions (NES)",
    },
    -- Toggle AI Chat (CLI)
    {
      "<leader>ac",
      "<cmd>Sidekick cli toggle<cr>",
      desc = "Toggle AI CLI Chat",
    },
    -- Context Injection Keymaps (Normal Mode via direct Lua calls)
    {
      "<leader>al",
      function()
        local ok, sidekick = pcall(require, "sidekick.cli")
        if ok then
          sidekick.send({ msg = "{line}" })
        end
      end,
      desc = "Send current line to AI",
    },
    {
      "<leader>af",
      function()
        local ok, sidekick = pcall(require, "sidekick.cli")
        if ok then
          sidekick.send({ msg = "{file}" })
        end
      end,
      desc = "Send current file reference to AI",
    },
    {
      "<leader>ab",
      function()
        local ok, sidekick = pcall(require, "sidekick.cli")
        if ok then
          sidekick.send({ msg = "{buffers}" })
        end
      end,
      desc = "Send open buffers list to AI",
    },
    -- Selection Injection Keymap (Visual Mode)
    {
      "<leader>as",
      function()
        local ok, sidekick = pcall(require, "sidekick.cli")
        if ok then
          -- Restores select and sends visual code context to active session
          sidekick.send()
        end
      end,
      mode = "v",
      desc = "Send visual selection to AI",
    },
    -- Explain / Review prompts
    {
      "<leader>ae",
      function()
        local ok, sidekick = pcall(require, "sidekick.cli")
        if ok then
          sidekick.send({ prompt = "explain" })
        end
      end,
      mode = { "n", "v" },
      desc = "Explain code with AI",
    },
    {
      "<leader>ar",
      function()
        local ok, sidekick = pcall(require, "sidekick.cli")
        if ok then
          sidekick.send({ prompt = "review" })
        end
      end,
      desc = "Review active file with AI",
    },
    -- Apply suggestion keymap
    {
      "<Tab>",
      function()
        local ok, sidekick = pcall(require, "sidekick")
        if ok and sidekick.nes_jump_or_apply() then
          return
        end
        -- Default fallback behavior for Tab key
        return "<Tab>"
      end,
      expr = true,
      mode = { "i", "s" },
      desc = "Apply/Jump to AI Suggestion",
    },
  },
  opts = {
    nes = {
      enabled = true,
      diff = {
        inline = "words", -- Shows inline word differences for suggestions
      },
    },
    cli = {
      picker = "telescope", -- Integrates Telescope for context buffer & file pickers
      mux = {
        backend = "tmux",
        enabled = true,
        create = "split", -- Opens in a tmux split pane instead of inside Neovim's terminal
      },
      win = {
        keys = {
          stopinsert = { "<esc><esc>", "stopinsert", mode = "t" },
        },
      },
    },
  },
}
