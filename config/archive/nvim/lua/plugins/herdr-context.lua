return {
  'mcuste/herdr-context.nvim',
  lazy = false,

  opts = {
    mappings = {
      buffer = '<leader>aa',
      buffers = '<leader>aA',
      diagnostics = '<leader>ad',
      buffers_diagnostics = '<leader>aD',
      messages = '<leader>am',
      quickfix = '<leader>aq',
      quickfix_all = '<leader>aQ',
      loclist = '<leader>al',
    },
  },

  keys = {
    {
      '<leader>ah',
      function()
        vim.system({
          'sh',
          '-c',
          [[
            split=$(herdr pane split --current --direction right --ratio 0.70 --focus) || exit 1
            pane=$(printf '%s\n' "$split" | jq -r '.result.pane.pane_id') || exit 1
            herdr agent start pi --kind pi --pane "$pane"
          ]],
        }, { text = true }, function(result)
          if result.code ~= 0 then
            vim.schedule(function()
              vim.notify(
                result.stderr ~= '' and result.stderr or 'Failed to start Pi in Herdr pane',
                vim.log.levels.ERROR
              )
            end)
          end
        end)
      end,
      desc = 'Open Pi in Herdr pane',
    },
  },
}
