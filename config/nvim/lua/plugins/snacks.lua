local function tmux_select_left()
  if not vim.env.TMUX or vim.env.TMUX == "" then
    vim.cmd("TmuxNavigateLeft")
    return
  end

  local executable = vim.env.TMUX:find("tmate") and "tmate" or "tmux"
  local socket = vim.env.TMUX:match("^[^,]+")
  local cmd = { executable }

  if socket and socket ~= "" then
    vim.list_extend(cmd, { "-S", socket })
  end

  vim.list_extend(cmd, { "select-pane" })
  if vim.env.TMUX_PANE and vim.env.TMUX_PANE ~= "" then
    vim.list_extend(cmd, { "-t", vim.env.TMUX_PANE })
  end
  table.insert(cmd, "-L")

  vim.fn.system(cmd)
end

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
            -- The explorer sits on the far-left side. From inside that Snacks
            -- window, generic Vim window navigation can wrap back to the editor
            -- instead of escaping to tmux. Make <C-h> explorer-local and send
            -- tmux left directly.
            win = {
              list = {
                keys = {
                  ["<C-h>"] = { tmux_select_left, mode = "n", desc = "Go to left tmux pane" },
                },
              },
              preview = {
                keys = {
                  ["<C-h>"] = { tmux_select_left, mode = "n", desc = "Go to left tmux pane" },
                },
              },
            },
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
