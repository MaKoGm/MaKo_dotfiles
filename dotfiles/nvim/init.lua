-- ==============================================================================
-- 1. OPCIONES BÁSICAS (Estilo r/unixporn y xero/dotfiles)
-- ==============================================================================
vim.g.mapleader = " "
vim.opt.number = true             
vim.opt.relativenumber = true     -- Números relativos para moverte rápido
vim.opt.mouse = "a"               -- Soporte para ratón
vim.opt.ignorecase = true         -- Búsquedas inteligentes
vim.opt.smartcase = true
vim.opt.termguicolors = true      -- Colores reales de alta calidad
vim.opt.cursorline = true         -- Resalta la línea donde estás parado
vim.opt.wrap = false              -- No corta las líneas largas
vim.opt.splitright = true         -- Las nuevas ventanas horizontales se abren a la derecha
vim.opt.splitbelow = true         -- Las nuevas ventanas verticales se abren abajo
vim.opt.laststatus = 3            -- Una sola barra de estado inferior global (Súper estético)

-- ==============================================================================
-- 2. INSTALADOR AUTOMÁTICO DE LAZY.NVIM
-- ==============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==============================================================================
-- 3. TODOS LOS PLUGINS Y SUS CONFIGURACIONES
-- ==============================================================================
require("lazy").setup({
  -- Iconos para todo el editor
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- A. EL TEMA OFICIAL DE XERO (Miasma)
  {
    "xero/miasma.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme miasma")
      
      -- TRUCO DE TRANSPARENCIA:
      -- Quita el fondo de Neovim para que se fusione con la transparencia de tu terminal.
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
    end
  },

  -- B. TINT: Atenúa los paneles en los que no estás escribiendo
  {
    "levouh/tint.nvim",
    config = function()
      require("tint").setup()
    end
  },

  -- C. LUALINE (Barra de estado inferior limpia y sólida)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = ' ', right = ' '},
          section_separators = { left = '█', right = '█'},
        }
      })
    end
  },

  -- D. ASCII.NVIM (La galería de arte ASCII y su dependencia)
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = { "MunifTanjim/nui.nvim" }
  },
 -- E. PANTALLA DE INICIO (Snacks.nvim con logo Sharp y Menú estilo Doom)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = function()
      -- Tu logo personalizado "Sharp"
      local custom_logo = {
        [[                                                                       ]],
        [[                                                                     ]],
        [[       ████ ██████            █████       ██                     ]],
        [[      ███████████             █████                             ]],
        [[      █████████ ███████████████████ ███   ███████████   ]],
        [[     █████████  ███    █████████████ █████ ██████████████   ]],
        [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
        [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
        [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
        [[                                                                       ]],
      }
      
      -- Convertimos la tabla a texto puro
      local header_text = table.concat(custom_logo, "\n")

      return {
        dashboard = {
          enabled = true,
          preset = {
            header = header_text,
            -- ¡AQUÍ ESTÁ LA MAGIA! Los botones exactamente como en tu imagen
            keys = {
              { icon = " ", key = "f", desc = "Find File",   action = ":Telescope find_files" },
              { icon = " ", key = "r", desc = "Recent File", action = ":Telescope oldfiles" },
              { icon = "󰈭 ", key = "F", desc = "Find Word",   action = ":Telescope live_grep" },
              { icon = " ", key = "b", desc = "Bookmarks",   action = ":Telescope marks" },
	      { icon = " ", key = "s", desc = "Settings",    action = ":e ~/.config/nvim/init.lua" },
            },
          },
          formats = {
            header = { "%s", hl = "String" },
          },
	  -- ESTO ES LO NUEVO: Sobrescribimos las secciones para omitir el contador de carga "startup"
          sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
          },
        }
      }
    end
  },
  -- F. BORDES CUADRADOS RETRO EN VENTANAS FLOTANTES
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "onsails/lspkind.nvim" },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      cmp.setup({
        window = {
          completion = cmp.config.window.bordered({ border = "single" }),
          documentation = cmp.config.window.bordered({ border = "single" }),
        },
	   formatting = {
          format = lspkind.cmp_format({ mode = 'symbol_text', maxwidth = 50 })
        }
      })
    end
  },

  -- G. TELESCOPE (Para que funcionen los botones del menú de inicio)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  }
})
