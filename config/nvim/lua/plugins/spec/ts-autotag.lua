local status_ok, auto_tag = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

---@type NvPluginSpec
return {
  "windwp/nvim-ts-autotag",
  -- https://github.com/windwp/nvim-ts-autotag?tab=readme-ov-file#a-note-on-lazy-loading
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-ts-autotag").setup {
      opts = {
        -- Defaults
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = false, -- Auto close on trailing </
      },
      -- Also override individual filetype configs, these take priority.
      -- Empty by default, useful if one of the "opts" global settings
      -- doesn't work well in a specific filetype
      per_filetype = {
        ["html"] = {
          -- enable_close = false,
        },
      },
    }
  end,
}
