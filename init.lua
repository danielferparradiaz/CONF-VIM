-- =============================================================================
--  Neovim IDE completo - init.lua  |  Estilo VS Code  +  Velocidad Vim
-- =============================================================================
--  REQUISITOS:
--    * Neovim >= 0.9  →  brew install neovim
--    * Nerd Font      →  JetBrainsMono Nerd Font / Hack Nerd Font
--    * Herramientas externas (se instalan con Mason o tu gestor):
--        Python: pyright, ruff, black, pytest
--        JS/TS:  typescript-language-server (ts_ls), prettier, eslint_d
--        Java:   jdtls (Eclipse JDT LS) + JDK 17+
--        Bash:   bash-language-server, shellcheck, shfmt
--        Ruby:   ruby-lsp, rubocop
--        Rust:   rust-analyzer
--        Go:     gopls
--        C/C++:  clangd
--        Lua:    lua-language-server
--        JSON/YAML/TOML/Docker/Markdown: jsonls, yamlls, taplo, dockerls, marksman
--
--  INSTALACION:
--    1) cp init.lua ~/.config/nvim/init.lua
--    2) nvim  →  :Lazy sync  →  :Mason  (los LSP se autoinstalan)
--    3) :checkhealth para verificar
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 0) MEJORA DE ARRANQUE (<100ms con lazy.nvim + bytecode cache)
-- ─────────────────────────────────────────────────────────────────────────────
if vim.loader then vim.loader.enable() end
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.autoformat = true -- poner a false para desactivar formateo al guardar

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) OPCIONES GENERALES (Visual + UX estilo VS Code)
-- ─────────────────────────────────────────────────────────────────────────────
local opt = vim.opt
opt.number = true
opt.relativenumber = true      -- relativo + absoluto en linea actual
opt.termguicolors = true
opt.mouse = "a"
opt.showmode = false           -- lualine muestra el modo
opt.clipboard = "unnamedplus"  -- sistema
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 200
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.tabstop = 2                -- 2 para web, 4 para python (ver .editorconfig)
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.colorcolumn = "100"        -- margen visual 100
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 12
opt.completeopt = "menu,menuone,noselect"
opt.wildmode = "longest:full,full"
opt.foldlevel = 99
opt.inccommand = "split"
opt.fillchars = { eob = " " }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-blinkwait700-blinkon200-blinkoff400,r-cr-o:hor20"
-- .editorconfig nativo desde Nvim 0.9
vim.g.editorconfig = true

local aug = vim.api.nvim_create_augroup("IDE", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug,
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 }) end,
})
-- Autosave al cambiar de buffer / perder foco
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  group = aug,
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) ATAJOS GLOBALES (siempre disponibles)
-- ─────────────────────────────────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Guardar" })
map("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Guardar" })
map("v", "<C-s>", "<Esc><cmd>w<CR>gv", { desc = "Guardar" })

map("n", "<leader>y", '"+y', { desc = "Copiar al portapapeles" })
map("v", "<leader>y", '"+y', { desc = "Copiar al portapapeles" })
map("n", "<leader>Y", '"+Y', { desc = "Copiar linea al portapapeles" })

-- Moverse entre splits sin pelear con terminal
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izq" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana dcha" })

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) GESTOR DE PLUGINS: lazy.nvim (lazy-loading = arranque rapido)
-- ─────────────────────────────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ─────────────────────────────────────────────────────────────────────────────
-- 4) LISTA DE PLUGINS
-- ─────────────────────────────────────────────────────────────────────────────
require("lazy").setup({

  -- =========================================================================
  -- 4.1 TEMA + ICONOS + UI (Tokyo Night / OneDarkPro)
  -- =========================================================================
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("tokyonight").setup({
        style = "night", -- storm | moon | night | day
        transparent = false,
        dim_inactive = false,
        lualine_bold = true,
        styles = { comments = { italic = true }, keywords = { italic = true }, sidebars = "dark" },
      })
      vim.cmd.colorscheme("tokyonight")
      -- Alternativa One Dark Pro (descomenta si prefieres):
      -- vim.cmd.colorscheme("tokyonight")  ->  cambiar a "onedark" instalando olimorris/onedarkpro.nvim
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Bufferline = pestanas superiores estilo VS Code con iconos
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<Tab>", "<cmd>BufferLineCycleNext<CR>", desc = "Siguiente pestana" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", desc = "Anterior pestana" },
      { "<leader>bd", "<cmd>bdelete<CR>", desc = "Cerrar buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Cerrar otros" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        show_buffer_close_icons = true,
        offsets = { { filetype = "NvimTree", text = "Explorador", separator = true } },
      },
    },
  },

  -- Lualine = barra de estado VS Code: modo | archivo | git | % | errores
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = { theme = "auto", globalstatus = true, component_separators = "", section_separators = "" },
      sections = {
        lualine_a = { { "mode", fmt = function(m) return m:upper() end } },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1, shorting_target = 40 } }, -- ruta relativa
        lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" }, -- % VS Code
        lualine_z = { "location" }, -- linea:columna
      },
      extensions = { "nvim-tree", "toggleterm", "lazy" },
    },
  },

  -- Indent guides (lineas verticales)
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = { "BufReadPost", "BufNewFile" }, opts = { indent = { char = "│" }, scope = { enabled = true } } },

  -- Colorizer opcional para #hex colores
  { "NvChad/nvim-colorizer.lua", event = { "BufReadPost" }, opts = { user_default_options = { names = false } } },

  -- =========================================================================
  -- 4.2 EXPLORADOR DE ARCHIVOS: nvim-tree  (<C-n>)
  -- =========================================================================
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle explorador" },
      { "<leader>e", "<cmd>NvimTreeFocus<CR>", desc = "Enfocar explorador" },
    },
    opts = {
      view = { width = 32, preserve_window_proportions = true },
      renderer = { icons = { show = { file = true, folder = true, git = true } }, root_folder_label = ":t" },
      filters = { dotfiles = false }, -- false = muestra ocultos; respeta .gitignore via git.ignore
      git = { enable = true, ignore = false },
      diagnostics = { enable = true, show_on_dirs = true },
      actions = { open_file = { quit_on_open = false, window_picker = { enable = false } } },
      -- Crear/renombrar/eliminar desde el arbol: a (crear), r (renombrar), d (borrar), x (cortar), c (copiar)
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        -- puedes agregar atajos propios aqui
      end,
    },
  },

  -- =========================================================================
  -- 4.3 BUSQUEDA: Telescope  (<C-p> archivos, <C-f> grep)
  -- =========================================================================
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Buscar archivos" },
      { "<C-f>", "<cmd>Telescope live_grep<CR>", desc = "Grep proyecto" },
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "Recientes" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fs", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Simbolos proyecto" },
      { "<leader>fr", "<cmd>Telescope lsp_references<CR>", desc = "Referencias" },
      { "<leader>gf", "<cmd>Telescope git_files<CR>", desc = "Git files" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
    },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top", width = 0.90, height = 0.85, preview_width = 0.55 },
          mappings = { i = { ["<C-j>"] = actions.move_selection_next, ["<C-k>"] = actions.move_selection_previous, ["<C-q>"] = actions.send_to_qflist + actions.open_qflist } },
        },
        pickers = {
          find_files = { hidden = true, file_ignore_patterns = { ".git/", "node_modules/", "target/", "dist/", "build/", ".venv/" } },
          live_grep = { additional_args = function() return { "--hidden", "--glob", "!.git/*" } end },
        },
      })
    end,
  },

  -- =========================================================================
  -- 4.4 TREESITTER (resaltado + indent + folds)
  --     Rama "main" (nueva API, requiere Neovim 0.12+ y tree-sitter-cli).
  -- =========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- API nueva: sin configs.setup; no soporta lazy-loading
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      -- Instala parsers si faltan (no-op si ya estan; corre en segundo plano)
      require("nvim-treesitter").install({
        "lua", "vim", "vimdoc", "bash", "python", "javascript", "typescript", "tsx",
        "java", "ruby", "rust", "go", "c", "cpp", "json", "yaml", "toml",
        "dockerfile", "markdown", "markdown_inline", "html", "css", "regex", "sql",
      })
      -- Highlighting lo provee Neovim (vim.treesitter.start); indent por
      -- nvim-treesitter (experimental). pcall evita errores en ft sin parser.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
      -- NOTA: incremental_selection NO existe en la rama main.
      --       Alternativa: plugin nvim-treesitter-textobjects o flash.treesitter()
    end,
  },

  -- =========================================================================
  -- 4.5 AUTOCOMPLETADO nvim-cmp  (Tab / S-Tab / Ctrl+Space) estilo VS Code
  -- =========================================================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      "windwp/nvim-autopairs", -- para cerrar brackets al completar
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load() -- todos los lenguajes

      -- Snippets personalizados por lenguaje (se suman a friendly-snippets)
      do
        local s, t, i = luasnip.snippet, luasnip.text_node, luasnip.insert_node
        luasnip.add_snippets("python", {
          s("pytest", { t("def test_"), i(1, "nombre"), t("("), i(2), t({ "):", "\t" }), i(0, "assert True") }),
          s("main", { t({ 'if __name__ == "__main__":', "\t" }), i(0) }),
        })
        luasnip.add_snippets("java", {
          s("sout", { t("System.out.println("), i(1), t(");") }),
          s("psvm", { t({ "public static void main(String[] args) {", "\t" }), i(0), t({ "", "}" }) }),
        })
        luasnip.add_snippets("go", {
          s("ferr", { t("if err != nil {"), t({ "", "\t" }), i(0, "log.Fatal(err)"), t({ "", "}" }) }),
        })
      end

      -- Integracion autopairs + cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 45,
            ellipsis_char = "...",
            before = function(entry, vim_item)
              vim_item.menu = ({
                nvim_lsp = "[LSP]", luasnip = "[Snip]", buffer = "[Buf]", path = "[Path]",
              })[entry.source.name]
              return vim_item
            end,
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(), -- forzar
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer", keyword_length = 3 },
        }),
      })

      -- Atajo especifico para snippets <C-l> (expandir)
      map("i", "<C-l>", function() if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() end end, { desc = "Expandir snippet" })
      map("s", "<C-l>", function() if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() end end, { desc = "Expandir snippet" })

      -- Autocompletado en linea de comandos : y /
      cmp.setup.cmdline(":", { mapping = cmp.mapping.preset.cmdline(), sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })
      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
    end,
  },

  -- Autopairs (cierra () [] {} "" '')
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = { check_ts = true } },

  -- Comentarios con gc  (gcc linea, gc seleccion)
  { "numToStr/Comment.nvim", keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } }, opts = {} },

  -- =========================================================================
  -- 4.6 GIT  (gitsigns + fugitive)  ->  <leader>bl  <leader>gd
  -- =========================================================================
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" }, change = { text = "│" }, delete = { text = "_" },
        topdelete = { text = "‾" }, changedelete = { text = "~" }, untracked = { text = "│" },
      },
      current_line_blame = false, -- se activa con <leader>bl
      current_line_blame_opts = { virt_text_pos = "eol", delay = 300 },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function bmap(mode, l, r, desc) map(mode, l, r, { buffer = bufnr, desc = desc }) end
        bmap("n", "]h", gs.next_hunk, "Siguiente hunk")
        bmap("n", "[h", gs.prev_hunk, "Anterior hunk")
        bmap("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        bmap("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage seleccion")
        bmap("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset seleccion")
        bmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        bmap("n", "<leader>bl", gs.toggle_current_line_blame, "Toggle blame linea")
        bmap("n", "<leader>gd", gs.preview_hunk, "Diff hunk") -- <leader>gd = diff (compatible con peticion)
        -- para diff de archivo completo usa :Gdiffsplit (fugitive)
      end,
    },
  },
  -- :Git  :Gdiffsplit  :Git blame  etc. para diff/stage/commit completos
  { "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite" } },

  -- =========================================================================
  -- 4.7 TERMINAL integrada  (<C-t> toggle)
  -- =========================================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-t>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal", mode = { "n", "t" } },
      { "<F12>", '<cmd>ToggleTerm direction=horizontal<CR>', desc = "Terminal horizontal" },
    },
    opts = {
      size = function(term) if term.direction == "horizontal" then return 14 elseif term.direction == "vertical" then return 52 else return 20 end end,
      open_mapping = false,
      direction = "float", -- flotante por defecto (VS Code panel)
      float_opts = { border = "curved", winblend = 6, width = function() return math.floor(vim.o.columns * 0.85) end, height = function() return math.floor(vim.o.lines * 0.8) end },
      highlights = { NormalFloat = { link = "Normal" } },
    },
  },

  -- =========================================================================
  -- 4.8 UTILIDADES: which-key, undotree, sesiones, editorconfig
  -- =========================================================================
  { "folke/which-key.nvim", event = "VeryLazy", opts = {}, config = function(_, opts) local wk = require("which-key"); wk.setup(opts) end },
  {
    "mbbill/undotree",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Arbol de deshacer" } },
    init = function() vim.g.undotree_WindowLayout = 2 end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { dir = vim.fn.stdpath("state") .. "/sessions/", options = { "buffers", "curdir", "tabpages", "winsize" } },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restaurar sesion dir actual" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restaurar ultima sesion" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "No guardar sesion" },
    },
  },

  -- =========================================================================
  -- 4.9 FORMATEO + LINTING por lenguaje (conform + nvim-lint)
  --     Usa el formateador/lynter especifico de cada lenguaje
  -- =========================================================================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      -- Formateadores por filetype (elige el primero disponible)
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black" }, -- ruff mas rapido; fallback black
        javascript = { "prettier", "prettierd" },
        typescript = { "prettier", "prettierd" },
        javascriptreact = { "prettier", "prettierd" },
        typescriptreact = { "prettier", "prettierd" },
        json = { "prettier", "prettierd" },
        jsonc = { "prettier", "prettierd" },
        yaml = { "prettier", "prettierd" },
        html = { "prettier", "prettierd" },
        css = { "prettier", "prettierd" },
        markdown = { "prettier", "prettierd" },
        go = { "gofmt", "goimports" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        ruby = { "rubocop" },
        toml = { "taplo" },
        -- Dockerfile / docker-compose no tienen formateador estable; se deja vacio
      },
      -- Formateo al guardar
      format_on_save = function(bufnr)
        if vim.g.autoformat == false then return nil end
        -- no formatear si el bufer es muy grande
        if vim.api.nvim_buf_line_count(bufnr) > 8000 then return nil end
        return { timeout_ms = 2500, lsp_fallback = true }
      end,
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
    init = function()
      -- <C-S-f> formateo manual (tambien <leader>cf por si tu terminal no distingue Ctrl+Shift)
      map({ "n", "i", "v" }, "<C-S-f>", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Formatear archivo" })
      map("n", "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Formatear (conform)" })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff", "pylint" },           -- desactiva pylint si solo quieres ruff
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        ruby = { "rubocop" },
        go = { "golangcilint" },
        -- yaml/json sin lint por defecto; anade "yamllint"/"jsonlint" si lo instalas
      }
      -- Para pylint/ruff en virtualenv, nvim-lint resuelve el ejecutable del PATH del proyecto
      local grp = vim.api.nvim_create_augroup("NvimLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = grp,
        callback = function() require("lint").try_lint() end,
      })
    end,
  },

  -- =========================================================================
  -- 4.10 TESTING  (pytest / go test / cargo test / rspec)  + DAP (debug)
  -- =========================================================================
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "rouge8/neotest-rust",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Test mas cercano" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Tests del archivo" },
      { "<leader>ta", function() require("neotest").run.run(vim.loop.cwd()) end, desc = "Todos los tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Resumen tests" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Salida test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({ dap = { justMyCode = false }, runner = "pytest", python = function()
            -- deteccion venv automatica: .venv / env / conda
            if vim.fn.filereadable("./.venv/bin/python") == 1 then return "./.venv/bin/python"
            elseif vim.fn.filereadable("./env/bin/python") == 1 then return "./env/bin/python"
            elseif vim.env.CONDA_PREFIX then return vim.env.CONDA_PREFIX .. "/bin/python"
            else return "python" end
          end }),
          require("neotest-go"),
          require("neotest-rust"),
        },
      })
    end,
  },
  -- Fallback universal con vim-test (si no usas neotest para un lenguaje)
  { "vim-test/vim-test", cmd = { "TestFile", "TestNearest", "TestSuite" }, keys = { { "<leader>tT", "<cmd>TestNearest<CR>", desc = "vim-test nearest" } } },

  -- Debugger DAP (Java / Python / Go / Rust / C++)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      require("mason-nvim-dap").setup({ automatic_installation = true, handlers = {}, ensure_installed = { "python", "codelldb", "delve", "js" } })
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
      require("nvim-dap-virtual-text").setup()
    end,
  },

  -- =========================================================================
  -- 4.11 LSP: Mason + vim.lsp nativo  (todos los lenguajes obligatorios)
  -- =========================================================================
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded", icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } } },
  },

  -- Auto-instala formateadores/linters/debuggers (los LSP los cubre mason-lspconfig).
  -- NOTA: golangci-lint no se incluye porque aun no tienes Go instalado
  -- (brew install go). Java igual: brew install openjdk.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "stylua", "black", "ruff", "pylint",
        "prettier", "eslint_d",
        "shfmt", "shellcheck", "rubocop", "taplo",
        "debugpy",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- Diagnosticos estilo VS Code: subrayados + signos + flotante
      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 2 },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many", header = "" },
      })
      -- Iconos de diagnostico en la columna de signos
      for _, type in ipairs({ "Error", "Warn", "Hint", "Info" }) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = ({ Error = "", Warn = "", Hint = "", Info = "" })[type], texthl = hl, numhl = hl })
      end

      -- Atajos LSP comunes (se activan solo cuando hay un servidor)
      local on_attach = function(_, bufnr)
        local function bmap(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc }) end
        bmap("n", "K", vim.lsp.buf.hover, "Hover docs")
        bmap("n", "gd", vim.lsp.buf.definition, "Ir a definicion")
        bmap("n", "gD", vim.lsp.buf.declaration, "Ir a declaracion")
        bmap("n", "gr", vim.lsp.buf.references, "Referencias")
        bmap("n", "gi", vim.lsp.buf.implementation, "Ir a implementacion")
        bmap("n", "gT", vim.lsp.buf.type_definition, "Definicion de tipo")
        bmap("n", "<leader>rn", vim.lsp.buf.rename, "Renombrar simbolo")
        bmap("n", "<F2>", vim.lsp.buf.rename, "Renombrar simbolo")
        bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions")
        bmap({ "n", "v" }, "<C-k>", vim.lsp.buf.code_action, "Code actions")
        bmap("n", "[d", vim.diagnostic.goto_prev, "Diag anterior")
        bmap("n", "]d", vim.diagnostic.goto_next, "Diag siguiente")
        bmap("n", "<leader>df", vim.diagnostic.open_float, "Diag flotante")
        bmap("n", "<leader>q", vim.diagnostic.setqflist, "Quickfix (todos los problemas)")
        -- inlay hints (Neovim 0.10+)
        if vim.lsp.inlay_hint then
          bmap("n", "<leader>uh", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr }) end, "Toggle inlay hints")
        end
      end

      -- ── Deteccion de virtualenv Python ( .venv / env / conda ) ──────────
      local function python_path()
        local cwd = vim.fn.getcwd()
        local venv = cwd .. "/.venv/bin/python"
        if vim.fn.filereadable(venv) == 1 then return venv end
        venv = cwd .. "/env/bin/python"
        if vim.fn.filereadable(venv) == 1 then return venv end
        if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then return vim.env.VIRTUAL_ENV .. "/bin/python" end
        if vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX ~= "" then return vim.env.CONDA_PREFIX .. "/bin/python" end
        return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
      end

      -- ── Lista de servidores que Mason instala auto ───────────────────────
      local servers = {
        "lua_ls", "pyright", "ts_ls", "bashls", "ruby_lsp",
        "rust_analyzer", "gopls", "clangd", "jsonls", "yamlls",
        "taplo", "dockerls", "docker_compose_language_service", "marksman",
        "jdtls", -- Java se configura aparte con nvim-jdtls pero Mason lo instala
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true, -- v1: instala lo que falte
        automatic_enable = false,      -- v2: NO activar servers con config por
                                       -- defecto; cada uno se configura a mano abajo
        handlers = {},                 -- v1: vacio para no duplicar los setup() de abajo
      })

      -- ── Activador moderno (Neovim 0.11+): vim.lsp.config + vim.lsp.enable ──
      -- Reemplaza al framework legacy require("lspconfig") (obsoleto).
      local function enable(name, cfg)
        cfg = cfg or {}
        cfg.capabilities = capabilities
        if cfg.on_attach == nil then cfg.on_attach = on_attach end
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end

      -- Lua
      enable("lua_ls", {
        on_attach = on_attach, capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry = { enable = false },
            completion = { callSnippet = "Replace" },
          },
        },
      })

      -- Python: pyright con venv auto
      enable("pyright", {
        settings = {
          python = { pythonPath = python_path(), analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true, diagnosticMode = "openFilesOnly" } },
        },
      })

      -- TypeScript / JavaScript: monorepo + import automatico
      enable("ts_ls", {
        init_options = { preferences = { importModuleSpecifierPreference = "relative", includeInlayParameterNameHints = "all" } },
        -- Soporte monorepo: detecta root con package.json / tsconfig.json
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
        workspace_required = true, -- no arrancar en archivos sueltos fuera de proyecto
      })

      -- Bash
      enable("bashls", { filetypes = { "sh", "bash" } })

      -- Ruby (Rails: detecta Gemfile)
      enable("ruby_lsp", {
        init_options = { formatter = "rubocop", linters = { "rubocop" } },
      })
      -- Si ruby_lsp no esta disponible, fallback a solargraph:
      -- enable("solargraph", {})

      -- Rust: clippy + hover rico
      enable("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = { allFeatures = true },
            procMacro = { enable = true },
          },
        },
      })

      -- Go: modulos + gofumpt opcional
      enable("gopls", {
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            usePlaceholders = true,
            completeUnimported = true,
          },
        },
      })

      -- C / C++
      enable("clangd", {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
      })

      -- JSON (con schemas). pcall porque schemastore es lazy y puede no estar cargado aun
      local ok_ss, schemastore = pcall(require, "schemastore")
      enable("jsonls", {
        settings = { json = { schemas = (ok_ss and schemastore.json.schemas()) or {}, validate = { enable = true } } },
      })

      -- YAML
      enable("yamlls", {
        settings = { yaml = { schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" }, keyOrdering = false } },
      })

      -- TOML
      enable("taplo", {})

      -- Dockerfile
      enable("dockerls", {})
      enable("docker_compose_language_service", {})

      -- Markdown
      enable("marksman", {})
    end,
  },
  -- Schemastore para JSON/YAML (schemas actualizados)
  { "b0o/schemastore.nvim", lazy = true },

  -- =========================================================================
  -- 4.12 JAVA: nvim-jdtls (Maven/Gradle, getters/setters, debugger)
  -- =========================================================================
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      -- jdtls se inicia por proyecto (Maven/Gradle) via autocmd FileType java.
      -- OJO: el autocmd creado aqui NO se dispara para el buffer actual
      -- (el evento FileType ya esta en curso cuando lazy carga el plugin),
      -- por eso se llama a start_jdtls() directamente si ya estamos en java.
      local jdtls = require("jdtls")
      local function start_jdtls()
        -- Binario de Mason (enlace en mason/bin, fallback al paquete)
        local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
        local pkg_bin = vim.fn.stdpath("data") .. "/mason/packages/jdtls/bin/jdtls"
        local jdtls_bin = vim.fn.executable(mason_bin) == 1 and mason_bin or pkg_bin
        if vim.fn.executable(jdtls_bin) ~= 1 then
          vim.notify("jdtls aun no instalado. Abre :Mason e instalalo.", vim.log.levels.WARN)
          return
        end
        local root = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }) or vim.fn.getcwd()
        local workspace = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")
        vim.fn.mkdir(workspace, "p")
        local config = {
          cmd = { jdtls_bin, "-data", workspace },
          root_dir = root,
          settings = { java = { eclipse = { downloadSources = true }, maven = { downloadSources = true }, implementationsCodeLens = { enabled = true }, referencesCodeLens = { enabled = true } } },
          init_options = { bundles = {} },
          on_attach = function(_, bufnr)
            -- atajos Java especificos
            local function bmap(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end
            bmap("n", "<leader>jo", jdtls.organize_imports, "Organizar imports")
            bmap("n", "<leader>jc", jdtls.extract_constant, "Extraer constante")
            bmap("v", "<leader>jc", function() jdtls.extract_constant(true) end, "Extraer constante")
            bmap("n", "<leader>jv", jdtls.extract_variable, "Extraer variable")
            bmap("v", "<leader>jv", function() jdtls.extract_variable(true) end, "Extraer variable")
            bmap("n", "<leader>jm", jdtls.extract_method, "Extraer metodo")
            -- getters/setters/constructores via code_action <leader>ca
            jdtls.setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
          end,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        }
        jdtls.start_or_attach(config)
      end
      vim.api.nvim_create_autocmd("FileType", { pattern = "java", callback = start_jdtls })
      if vim.bo.filetype == "java" then start_jdtls() end
    end,
  },

  -- (Snippets personalizados por lenguaje: definidos dentro del bloque nvim-cmp,
  --  seccion "Snippets personalizados por lenguaje", para no duplicar el spec LuaSnip)

  -- Markdown preview <leader>mp
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    ft = { "markdown" },
    keys = { { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Preview Markdown" } },
    init = function() vim.g.mkdp_filetypes = { "markdown" } vim.g.mkdp_theme = "dark" end,
  },
}, {
  -- Opciones de lazy.nvim
  ui = { border = "rounded" },
  checker = { enabled = false }, -- no chequear updates al iniciar (mas rapido)
  performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } } },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- 5) DIAGNOSTICO: quickfix con todos los problemas del proyecto
--    Ya tienes:  <leader>q  -> llena quickfix con errores del workspace
--    Y: :Telescope diagnostics  si prefieres Telescope
-- ─────────────────────────────────────────────────────────────────────────────

-- Mensaje de bienvenida minimal
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.notify("IDE Neovim listo  •  <C-p> archivos  •  <C-f> grep  •  <C-n> arbol  •  <C-t> terminal", vim.log.levels.INFO)
    end
  end,
})
