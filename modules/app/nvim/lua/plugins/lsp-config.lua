return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_nvim_lsp.default_capabilities()
      )

      local lspconfig = require("lspconfig")

      lspconfig.tailwindcss.setup({
        capabilities = capabilities
      })
      lspconfig.ruby_lsp.setup({
        capabilities = capabilities,
        cmd = { "/home/typecraft/.asdf/shims/ruby-lsp" }
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      lspconfig.clangd.setup({
        capabilites = capabilites
      })
      lspconfig.pyright.setup({
        capabilites = capabilites
      })

      local root_markers = { 'pom.xml', 'gradlew', 'build.gradle', '.git' } 
      local util = require('lspconfig.util') 
      local root_dir = util.root_pattern(unpack(root_markers))(vim.fn.getcwd()) or vim.fn.getcwd() 
      local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t') 
      local workspace = vim.fn.expand('~/.cache/jdtls/workspace/' .. project_name) 

      lspconfig.jdtls.setup({ 
        capabilities = capabilities, 
        cmd = { 'jdt-language-server', '-data', workspace }, 
        root_dir = root_dir, 
      })
      

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, {})
    end,
  },
}
