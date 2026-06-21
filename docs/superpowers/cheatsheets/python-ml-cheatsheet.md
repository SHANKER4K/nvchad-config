# Python ML Neovim Cheat Sheet

## LSP & Code Intelligence

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>vp` | Set Python interpreter (pyright) |

## Jupyter Notebooks (molten-nvim)

Use `# %%` cell markers in `.py` files.

| Key | Action |
|-----|--------|
| `<leader>mi` | Initialize kernel (pick conda/venv) |
| `<leader>mr` | Re-run current cell |
| `<leader>mc` | Evaluate current cell |
| `<leader>ms` (visual) | Send selection to kernel |
| `<leader>mo` | Show output window |
| `<leader>md` | Delete cell output |

**Workflow:**
1. Open a `.py` file → `<leader>mi` → pick your kernel
2. Write code with `# %%` between cells
3. `<leader>mr` to run a cell — see pandas, plots, tensors inline

## REPL (Send to Python Terminal)

| Key | Action |
|-----|--------|
| `<leader>sl` | Send current line to REPL |
| `<leader>sl` (visual) | Send selected lines to REPL |
| `<leader>sa` | Send entire buffer to REPL |
| `<A-i>` | Toggle floating terminal (manual Python) |

**Workflow:**
1. Select a few lines of pandas/numpy code
2. `<leader>sl` — code runs in the REPL, output visible

## Debugging (nvim-dap)

| Key | Action |
|-----|--------|
| `<F5>` | Start / Continue debugging |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>pdr` | Debug Python test method |

## General Workflow

| Key | Action |
|-----|--------|
| `<leader>sf` | Search files (Telescope) |
| `<leader>sg` | Search by grep |
| `<leader>fm` | Format file (ruff) |
| `<leader>x` | Close buffer |
| `<Tab>` / `<S-Tab>` | Next/prev buffer |
| `<leader>th` | Switch theme |

## Useful Commands

| Command | What it does |
|---------|-------------|
| `:Lazy` | Plugin manager dashboard |
| `:Mason` | LSP/formatter/linter installer |
| `:LspInfo` | Check which LSP servers are attached |
| `:PyrightSetPython /path/to/python` | Set Python interpreter manually |
| `:checkhealth` | Health check for all plugins |
