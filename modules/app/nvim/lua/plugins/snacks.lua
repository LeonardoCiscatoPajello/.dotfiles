return {
  "folke/snacks.nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
                                                                     
       ████ ██████           █████      ██                     
      ███████████             █████                             
      █████████ ███████████████████ ███   ███████████   
     █████████  ███    █████████████ █████ ██████████████   
    █████████ ██████████ █████████ █████ █████ ████ █████   
  ███████████ ███    ███ █████████ █████ █████ ████ █████  
 ██████  █████████████████████ ████ █████ █████ ████ ██████ 
        ]],
        
        sections = {
          { section = "header" },
          {
            title = "Repositories",
            section = function()
              local ok, gd = pcall(require, "git_dashboard")
              if not ok then return {} end
              return gd.get_local_repos({
                "~/.dotfiles",
                "~/Documents/University",
		"~/.archive/UniArchive",
                "~/Projects",
              }, 8)
            end,
          },
          {
            title = "Recent Commits",
            section = function()
              if vim.fn.isdirectory(".git") == 0 then return {} end
              local ok, gd = pcall(require, "git_dashboard")
              if not ok then return {} end
              return gd.get_recent_commits(6)
            end,
          },
          { section = "keys" },
        },
      },
    },
    indent = { enabled = true },
    input = { enabled = true },
    git = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },

  keys = {
    { "<leader>sf",       function() Snacks.scratch() end,            desc = "Toggle Scratch Buffer" },
    { "<leader>S",        function() Snacks.scratch.select() end,     desc = "Select Scratch Buffer" },
    { "<leader>gl",       function() Snacks.lazygit.log_file() end,   desc = "Lazygit Log (cwd)" },
    { "<leader>lg",       function() Snacks.lazygit() end,            desc = "Lazygit" },
    { "<C-p>",            function() Snacks.picker.pick("files") end, desc = "Find Files" },
    { "<leader><leader>", function() Snacks.picker.recent() end,      desc = "Recent Files" },
    { "<leader>fb",       function() Snacks.picker.buffers() end,     desc = "Buffers" },
    { "<leader>fg",       function() Snacks.picker.grep() end,        desc = "Grep Files" },
    { "<C-n>",            function() Snacks.explorer() end,           desc = "Explorer" },

    -- Added Git dashboard integrations
    { "<leader>rp", function()
        local gd = require("git_dashboard")
        local items = gd.get_local_repos({ "~/.dotfiles", "~/.archive/UniArchive", "~/Documents/University", "~/Projects" }, 20)
        Snacks.picker.pick("Repositories", { items = items })
      end, desc = "Repo Picker" },
    { "<leader>gc", function()
        local gd = require("git_dashboard")
        Snacks.picker.pick("Commits", { items = gd.get_recent_commits(30) })
      end, desc = "Recent Commits" },
    { "<leader>gS", function()
        local gd = require("git_dashboard")
        Snacks.picker.pick("Changes", { items = gd.get_changed_files() })
      end, desc = "Git Changed Files" },
  }
}
