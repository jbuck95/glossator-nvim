-- plugin/glossator-nvim.lua

if vim.g.loaded_glossator_nvim == 1 then
  return
end
vim.g.loaded_glossator_nvim = 1

local api = vim.api

-- Trigger lazy-load on first markdown buffer
api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  once = true,
  callback = function()
    require("glossator-nvim")
  end,
})

-- Scoped user command
api.nvim_create_user_command("Glossator", function(info)
  local m = require("glossator-nvim")
  local sub = info.args
  if sub == "toolbar" then
    m.open_toolbar()
  elseif sub == "pane" then
    m.open_glossator()
  else
    vim.notify("glossator: unknown subcommand '" .. sub .. "'. Usage: Glossator {toolbar,pane}", vim.log.levels.WARN)
  end
end, {
  nargs = 1,
  complete = function()
    return { "toolbar", "pane" }
  end,
  desc = "Glossator: toolbar or pane",
})

-- <Plug> mappings
vim.keymap.set("v", "<Plug>(GlossatorToolbar)", function()
  local esc = api.nvim_replace_termcodes("<Esc>", true, false, true)
  api.nvim_feedkeys(esc, "x", false)
  vim.schedule(function()
    require("glossator-nvim").open_toolbar()
  end)
end, { desc = "Glossator: open toolbar" })

vim.keymap.set("n", "<Plug>(GlossatorPane)", function()
  require("glossator-nvim").open_glossator()
end, { desc = "Glossator: open pane" })
