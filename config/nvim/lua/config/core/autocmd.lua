vim.cmd [[autocmd BufNewFile,BufRead .env* set filetype=sh]]

-- -- Close the startup directory buffer (e.g. "[nvim]") when launching in a folder
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function(data)
--     local directory = vim.fn.isdirectory(data.file) == 1
--     if directory then
--       vim.cmd("bd") -- close the [nvim] buffer
--     end
--   end,
-- })
