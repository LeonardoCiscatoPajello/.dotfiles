return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")
      config.setup({
        auto_install = false,
        ensure_installed = {
          "bash",
          "ruby",
          "nix",
          "html",
          "php",
          "css",
          "c",
          "java",
          "python",
          "scss",
          "javascript",
          "typescript",
          "json",
          "lua",
        },
        highlight = { enable = true },
        indent = { enable = false },
      })
    end
  }
}
