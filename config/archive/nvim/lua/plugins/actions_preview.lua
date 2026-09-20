return {
  "aznhe21/actions-preview.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local preview = require("actions-preview")
    preview.setup({
      telescope = {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.8,
          height = 0.9,
          prompt_position = "top",
          preview_cutoff = 20,
          preview_height = 0.5,
        },
        preview = { hide_on_startup = true },
        attach_mappings = function(prompt_bufnr)
          local action_state = require("telescope.actions.state")
          local action_layout = require("telescope.actions.layout")
          local picker = action_state.get_current_picker(prompt_bufnr)
          local orig = picker.refresh_previewer
          local busy = false

          picker.refresh_previewer = function(self)
            if busy then
              return orig(self)
            end
            local entry = self._selection_entry
            local action = entry and entry.value and entry.value.action
            if not action then
              return orig(self)
            end
            action:preview(function(p)
              vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(self.prompt_bufnr) then
                  return
                end
                if self._selection_entry ~= entry then
                  return
                end
                local available = p ~= nil and (p.cmdline ~= nil or p.syntax == "diff")
                local status = require("telescope.state").get_status(self.prompt_bufnr)
                local visible = status.layout and status.layout.preview and status.layout.preview.winid
                if available == (visible ~= nil) then
                  if available then
                    orig(self)
                  end
                  return
                end
                busy = true
                action_layout.toggle_preview(prompt_bufnr)
                busy = false
              end)
            end)
          end

          return true
        end,
      },
    })
  end,
  keys = {
    {
      "<leader>ca",
      function()
        require("actions-preview").code_actions()
      end,
      mode = { "n", "v" },
      desc = "LSP Code Actions (Visual Diff Preview)",
    },
  },
}
