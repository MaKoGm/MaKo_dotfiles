return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- 1. LOGO: Estilo de bloques pesados (Inspirado en la Imagen 1)
    dashboard.section.header.val ={
        [[                                                                       ]],
        [[                                                                     ]],
        [[       ████ ██████           █████      ██                     ]],
        [[      ███████████             █████                             ]],
        [[      █████████ ███████████████████ ███   ███████████   ]],
        [[     █████████  ███    █████████████ █████ ██████████████   ]],
        [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
        [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
        [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
        [[                                                                       ]],
      }  
    -- 2. FUNCIÓN PERSONALIZADA PARA EL MENÚ
    local function custom_button(sc, text, keybind)
      local b = dashboard.button(sc, text, keybind)
      
      -- Forzamos el formato exacto de tu imagen
      b.val = string.format("[%s] > %s", sc, text)

      b.opts.cursor = 1 
      b.opts.shortcut = ""

      -- Aplicamos colores individuales a cada parte de la línea para el toque minimalista
      b.opts.hl = {
        { "Comment", 0, 1 },
        { "Keyword", 1, 2 },
        { "Comment", 2, #b.val },
      }
      
      return b
    end

    -- 3. Construimos los botones usando nuestra nueva función
    dashboard.section.buttons.val = {
      custom_button("f", "Find file", ":Telescope find_files <CR>"),
      custom_button("n", "New file", ":ene <BAR> startinsert <CR>"),
      custom_button("r", "Recent files", ":Telescope oldfiles <CR>"),
      custom_button("g", "Grep", ":Telescope live_grep <CR>"), 
      custom_button("q", "Quit", ":qa<CR>"),
    }

    -- 5. Layout ultra compacto y espaciado
    dashboard.config.layout = {
      { type = "padding", val = 6 },
      dashboard.section.header,
      { type = "padding", val = 5 },
      dashboard.section.buttons,
      { type = "padding", val = 20 },
    }

    
    alpha.setup(dashboard.opts)
  end,
}
