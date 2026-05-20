local M = {}

function M.check()
  vim.health.start("glossator-nvim")

  if vim.g.loaded_glossator_nvim == 1 then
    vim.health.ok("loaded guard is set (vim.g.loaded_glossator_nvim)")
  else
    vim.health.error("loaded guard is not set")
  end

  local has_ui_input = pcall(vim.fn.exists, "*vim.ui.input")
  if has_ui_input then
    vim.health.ok("vim.ui.input available (annotation prompt)")
  else
    vim.health.warn("vim.ui.input not available (annotations require prompt)")
  end

  local notes_dir = vim.fn.expand("~/Documents/glossator")
  if vim.fn.isdirectory(notes_dir) == 1 then
    if vim.fn.filewritable(notes_dir) == 2 then
      vim.health.ok(notes_dir .. " (exists, writable)")
    else
      vim.health.warn(notes_dir .. " (exists but not writable)")
    end
  else
    vim.health.info(notes_dir .. " will be auto-created on first use")
  end

  local ok, mod = pcall(require, "glossator-nvim")
  if ok then
    vim.health.ok("module loads successfully")
    if type(mod.setup) == "function" then
      vim.health.ok("setup() function is available")
    end
    if type(mod.open_toolbar) == "function" then
      vim.health.ok("open_toolbar() function is available")
    end
    if type(mod.open_glossator) == "function" then
      vim.health.ok("open_glossator() function is available")
    end
    if type(mod.load_highlights) == "function" then
      vim.health.ok("load_highlights() function is available")
    end
  else
    vim.health.error("module failed to load: " .. tostring(mod))
  end

  local hasmapto_toolbar = vim.fn.hasmapto("<Plug>(GlossatorToolbar)", "v")
  local hasmapto_pane = vim.fn.hasmapto("<Plug>(GlossatorPane)", "n")
  if hasmapto_toolbar == 1 then
    vim.health.ok("<Plug>(GlossatorToolbar) has a keymap in visual mode")
  else
    vim.health.info("no keymap for <Plug>(GlossatorToolbar) in visual mode (add one to use the toolbar)")
  end
  if hasmapto_pane == 1 then
    vim.health.ok("<Plug>(GlossatorPane) has a keymap in normal mode")
  else
    vim.health.info("no keymap for <Plug>(GlossatorPane) in normal mode (add one to use the glossator pane)")
  end
end

return M
