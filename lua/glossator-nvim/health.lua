local M = {}

function M.check()
	vim.health.start("glossator-nvim")

	if vim.fn.isdirectory(vim.fn.expand("~/Documents/glossator")) == 1 then
		vim.health.ok("~/Documents/glossator")
	else
		vim.health.info("~/Documents/glossator will be auto-created on first use")
	end
end

return M
