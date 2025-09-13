return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "" },
      topdelete    = { text = "" },
      changedelete = { text = "▎" },
      untracked    = { text = "▎" },
    },
    current_line_blame = true,
    current_line_blame_opts = { delay = 400 },
    max_file_length = 20000,
  },
  keys = {
    { "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Git Blame Line" },
    { "<leader>hp", function() require("gitsigns").preview_hunk() end,            desc = "Git Preview Hunk" },
    { "<leader>hs", function() require("gitsigns").stage_hunk() end,              desc = "Git Stage Hunk" },
    { "<leader>hu", function() require("gitsigns").undo_stage_hunk() end,         desc = "Git Undo Stage Hunk" },
    { "<leader>hr", function() require("gitsigns").reset_hunk() end,              desc = "Git Reset Hunk" },
  }
}
