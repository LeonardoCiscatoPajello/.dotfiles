local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lazy").setup("plugins")
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets" })

vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.ttyfast = true

vim.opt.termguicolors = true


vim.g.vimtex_fold_enabled=1
vim.opt.foldmethod="expr"
vim.opt.foldexpr="vimtex#fold#level()"

vim.env.TERM = "xterm-256color"


vim.cmd.colorscheme "catppuccin-mocha"

vim.cmd("set relativenumber")

