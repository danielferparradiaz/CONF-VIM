# 🚀 Mi Config de Neovim (CONF-VIM)

> IDE completo en Neovim: estética VS Code, velocidad Vim. Un solo `init.lua` + `lazy.nvim`.

[![Neovim](https://img.shields.io/badge/Neovim-0.12+-57A143?logo=neovim&logoColor=white)](https://neovim.io)
[![lazy.nvim](https://img.shields.io/badge/plugins-lazy.nvim-blueviolet)](https://github.com/folke/lazy.nvim)
[![OS](https://img.shields.io/badge/OS-macOS-black?logo=apple)](https://www.apple.com/macos/)

---

## ✨ Qué incluye

| Área | Plugins |
|---|---|
| 🎨 **UI** | tokyonight, bufferline (pestañas), lualine (status bar), indent-blankline, colorizer, devicons |
| 📁 **Explorador** | nvim-tree (`Ctrl+N`) |
| 🔍 **Búsqueda** | Telescope (`Ctrl+P` archivos, `Ctrl+F` grep) con ripgrep |
| 🌳 **Treesitter** | nvim-treesitter **rama `main`** (resaltado + indentación) |
| ⌨️ **Autocompletado** | nvim-cmp + LuaSnip + autopairs (`Tab` confirma, como en VS Code) |
| 🧠 **LSP** | Mason + lspconfig: Lua, Python, TS/JS, Bash, Ruby, Rust, Go, C/C++, JSON, YAML, TOML, Docker, Markdown, Java |
| ✅ **Lint/Format** | conform.nvim (format on save) + nvim-lint |
| 🧪 **Testing/ Debug** | neotest (pytest/go test/cargo test) + nvim-dap |
| 🌿 **Git** | gitsigns (signos en margen) + fugitive |
| 💻 **Terminal** | toggleterm (`Ctrl+T`, flotante) |
| 💾 **Sesiones** | persistence.nvim (`Space+qs` restaurar) |
| 📝 **Markdown** | markdown-preview (`Space+mp`) |

---

## 🍎 Setup en un Mac nuevo (5 minutos)

### 1. Dependencias del sistema

```sh
# Homebrew (si no lo tienes)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Neovim + herramientas obligatorias
brew install neovim tree-sitter-cli ripgrep fd git
brew install node python        # Mason/NPM y pyright

# Nerd Font (iconos). Elige tu terminal: iTerm2 / WezTerm / Kitty
brew install --cask font-jetbrains-mono-nerd-font iterm2
# → En Preferencias de la terminal selecciona la fuente "JetBrainsMono Nerd Font"
```

### 2. Clavar esta config

```sh
# Si ya tienes algo, haz backup
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

git clone git@github.com:danielferparradiaz/CONF-VIM.git ~/.config/nvim
```

### 3. Primer arranque

```sh
nvim
```

Eso es todo. **lazy.nvim se auto-instala** y descarga todos los plugins; en ese mismo arranque:
- nvim-treesitter compila los parsers (lua, python, js, rust, go, c/c++, markdown…)
- `:Mason` instala los LSP servers y formateadores automáticamente en segundo plano

Espera 1-2 min en el primer arranque, cierra con `:qa` y vuelve a abrir. Listo.

### 4. Verificación

```vim
:checkhealth
```

Todo en verde = OK. Los parsers con warnings suelen ser por lenguajes opcionales que no usas.

---

## ⌨️ Atajos esenciales

> **`<leader>` = `Espacio`**

### Generales
| Atajo | Acción |
|---|---|
| `Ctrl + S` | Guardar (normal/insert/visual) |
| `Ctrl + hjkl` | Moverse entre splits |
| `Space y` / `Space Y` | Copiar selección / línea al portapapeles |

### Navegación
| Atajo | Acción |
|---|---|
| `Ctrl + P` | Buscar archivos (Telescope) |
| `Ctrl + F` | Grep en el proyecto |
| `Space fo` | Archivos recientes |
| `Ctrl + N` | Explorador de archivos |
| `Tab` / `Shift+Tab` | Tab drive: siguiente/anterior pestaña |
| `Space bd` / `Space bo` | Cerrar buffer actual / cerrar los demás |

### LSP (sobre cualquier símbolo)
| Atajo | Acción |
|---|---|
| `K` | Documentación (hover) |
| `gd` / `gr` / `gi` | Definición / Referencias / Implementación |
| `Space rn` / `F2` | Renombrar símbolo |
| `Space ca` | Code actions |
| `[d` / `]d` | Diagnóstico anterior / siguiente |
| `Space q` | Quickfix con todos los problemas del proyecto |

### Testing / Debug
| Atajo | Acción |
|---|---|
| `Space tt` | Test más cercano |
| `Space tf` | Tests del archivo |
| `Space ts` | Resumen de tests |
| `F5` / `F10` / `F11` | DAP: continuar / step over / step into |
| `F12` | Terminal horizontal |

### Varios
| Atajo | Acción |
|---|---|
| `Ctrl + T` | Terminal flotante |
| `gc` | Comentar línea/selección |
| `Space u` | Árbol de deshacer (undotree) |
| `Space bl` | Git blame de la línea |
| `Space mp` | Preview de Markdown en navegador |
| `Space cf` | Formatear manual |
| `:Lazy` / `:Mason` | Gestores de plugins / herramientas |

---

## 🧰 LSP servers (se auto-instalan con Mason)

`lua_ls` · `pyright` · `ts_ls` · `bashls` · `ruby_lsp` · `rust_analyzer` · `gopls` · `clangd` · `jsonls` · `yamlls` · `taplo` · `dockerls` · `marksman` · `jdtls`

**Formateadores/linters:** `stylua` · `black` + `ruff` · `prettier` · `eslint_d` · `shfmt` + `shellcheck` · `rubocop` · `taplo` · `debugpy`

> Java y Go necesitan JDK 17+ / Go instalados: `brew install openjdk@17 go`

---

## 📁 Estructura

```
~/.config/nvim/
├── init.lua          # ⭐ Toda la config, en un solo archivo con secciones
├── lazy-lock.json    # Versiones exactas de plugins (reproducible)
└── .gitignore
```

## ⚙️ Personalización rápida

- **Tema:** en `init.lua` busca `tokyonight` → cambia `style = "night"` por `storm | moon | day`.
- **Autoformato al guardar:** `vim.g.autoformat = false` (línea ~32) o `:ConformInfo` para ver estado.
- **Añadir un plugin:** pega el spec dentro de `require("lazy").setup({...})`, luego `:Lazy sync`.
- **Quitar un servidor LSP:** bórralo de la lista `servers` en la sección 4.11 y ejecuta `:MasonUninstall <nombre>`.

## 🔧 Solución de problemas

| Síntoma | Fix |
|---|---|
| Iconos son cuadrados □ | Tu terminal no usa Nerd Font → pref. de fuente |
| Error de treesitter en markdown | (Ya corregido) Asegúrate de estar en rama `main` del plugin: `:Lazy` → nvim-treesitter |
| LSP no arranca | `:LspInfo` y `:Mason` para reinstalar |
| Todo muy lento | `:Lazy profile` para ver el arranque |
| Limpiar todo | `rm -rf ~/.local/share/nvim ~/.cache/nvim` y reabrir |

---

## 🚢 Restaurar en otro Mac / Linux

```sh
git clone git@github.com:danielferparradiaz/CONF-VIM.git ~/.config/nvim
brew install neovim tree-sitter-cli ripgrep fd node python
nvim   # espera a que lazy.nvim + Mason lo instalen todo
```

En Linux cambia `brew` por tu gestor (`apt install neovim ripgrep fd-find nodejs npm python3-pip`, y tree-sitter-cli desde [releases](https://github.com/tree-sitter/tree-sitter/releases)).

---

Con amor, trucos y `hjkl` ❤️
