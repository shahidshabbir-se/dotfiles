return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  config = function()
    local opencode_pane_id = nil
    local opencode_visible = false

    local function pane_exists()
      if not opencode_pane_id then
        return false
      end

      local check = vim.fn.system("tmux has-session -t " .. opencode_pane_id .. " 2>/dev/null; echo $?")
      if vim.trim(check) == "0" then
        return true
      end

      opencode_pane_id = nil
      opencode_visible = false
      return false
    end

    local function start()
      if pane_exists() and opencode_visible then
        return
      end

      if pane_exists() then
        vim.fn.system("tmux join-pane -h -l 35% -s " .. opencode_pane_id)
      else
        local result = vim.fn.system("tmux split-window -h -p 35 -P -F '#{pane_id}' 'opencode --port'")
        opencode_pane_id = vim.trim(result)
      end
      opencode_visible = true
    end

    local function stop()
      if not pane_exists() then
        return
      end

      vim.fn.system("tmux send-keys -t " .. opencode_pane_id .. " C-c")
      vim.defer_fn(function()
        vim.fn.system("tmux kill-pane -t " .. opencode_pane_id)
        opencode_pane_id = nil
        opencode_visible = false
      end, 500)
    end

    local function toggle()
      if not pane_exists() then
        start()
      elseif opencode_visible then
        vim.fn.system("tmux break-pane -d -s " .. opencode_pane_id)
        opencode_visible = false
      else
        vim.fn.system("tmux join-pane -h -l 35% -s " .. opencode_pane_id)
        opencode_visible = true
      end
    end

    vim.g.opencode_opts = {
      server = {
        start = start,
        stop = stop,
        toggle = toggle,
      },
    }

    vim.o.autoread = true
  end,
  keys = {
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ")
      end,
      desc = "Ask OpenCode",
      mode = { "n", "x" },
    },
    {
      "<leader>oc",
      function()
        require("opencode").select()
      end,
      desc = "Select OpenCode",
      mode = { "n", "x" },
    },
    {
      "go",
      function()
        return require("opencode").operator("@this ")
      end,
      desc = "Append range to OpenCode",
      expr = true,
      mode = { "n", "x" },
    },
    {
      "goo",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      desc = "Append line to OpenCode",
      expr = true,
    },
    {
      "<S-C-u>",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "Scroll OpenCode up",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "Scroll OpenCode down",
    },
    {
      "<leader>os",
      function()
        vim.g.opencode_opts.server.start()
      end,
      desc = "OpenCode start pane",
    },
    {
      "<leader>ot",
      function()
        vim.g.opencode_opts.server.toggle()
      end,
      desc = "OpenCode toggle pane",
    },
    {
      "<leader>oq",
      function()
        vim.g.opencode_opts.server.stop()
      end,
      desc = "OpenCode quit pane",
    },
  },
}
