-- Minimal configuration to reproduce glossator-nvim issues.
-- Usage: nvim --clean -u scripts/minimal.lua test.md

vim.cmd("set rtp+=.")

require("glossator-nvim").setup({})
