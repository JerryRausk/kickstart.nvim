vim.opt.number = true -- Make line numbers default
vim.opt.relativenumber = true
vim.opt.mouse = 'a' -- Enable mouse
vim.opt.showmode = false
vim.schedule(function() --  Schedule the setting after `UiEnter` because it can increase startup-time.
	vim.opt.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim.
end)
vim.opt.breakindent = true -- Enable break indent
vim.opt.undofile = true -- Save undo history
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
