return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- 1. Opciones visuales de los diagnósticos
    vim.diagnostic.config({
      update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      }
    })

    vim.diagnostic.config({ virtual_text = true })

    -- 2. Capacidades de autocompletado
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities()
    )

   -- 3. INICIALIZACIÓN DE LOS SERVIDORES LSP
    -- Verificamos si estás usando Neovim 0.11+ o Neovim 0.10
    if vim.lsp.config then
      -- NUEVO MÉTODO NATIVO (Neovim 0.11+)
      vim.lsp.config("clangd", { 
        capabilities = capabilities
      })
      vim.lsp.enable("clangd")

      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.enable("pyright")

      vim.lsp.config("ruff", { capabilities = capabilities })
      vim.lsp.enable("ruff")
    else
      -- MÉTODO CLÁSICO (Neovim 0.10 y anteriores)
      local lspconfig = require('lspconfig')
      
      lspconfig.clangd.setup({ 
        capabilities = capabilities,
        cmd = { "clangd", "--extra-arg=-std=c++23" }
      })
      
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.ruff.setup({ capabilities = capabilities })
    end

    -- 4. ATAJOS DE TECLADO
    local opts = { noremap = true, silent = true }
    
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  end,
}
