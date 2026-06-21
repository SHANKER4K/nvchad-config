# Python ML Neovim Setup

**Date:** 2026-06-21
**Status:** Draft

## Goal

Extend the existing NvChad-based Neovim configuration with targeted additions
for Python machine learning / deep learning workflows (PyTorch, Hugging Face,
scikit-learn, pandas, numpy, seaborn, Jupyter notebooks).

The existing config already provides:
- LSP: pyright + ruff
- Formatting: ruff_format via conform.nvim (auto-format on save)
- Completion: nvim-cmp + luasnip
- Debugging: nvim-dap-python with debugpy
- Terminal: NvChad term module (<A-v>, <A-h>, <A-i>)
- General editing: autopairs, treesitter, telescope, harpoon, etc.

The additions fill the gaps specific to Python ML work without restructuring
the config or adding speculative plugins.

## Changes

### 1. Python Treesitter Parser

Add `"python"` to the `ensure_installed` list in
`lua/plugins/override/nvim-treesitter.lua`.

Gives syntax-aware folding, text objects (function/class selection via `if`,
`af`, `ic`, `ac`), and accurate highlighting for Python.

### 2. Pyright Virtual Environment Detection

Add a `settings` block to the `pyright` entry in
`lua/plugins/override/lspconfig.lua` so pyright searches for and uses the
project's active Python interpreter and virtual environment.

Also add a `<leader>vp` keymap to run `:PyrightSetPython` for manual venv
selection per project.

### 3. Jupyter Notebook Support (molten-nvim)

Add `benlubas/molten-nvim` as a new plugin spec in
`lua/plugins/spec/molten.lua`. This runs Jupyter kernels inside Neovim and
displays output (text, plots, DataFrames) as virtual text or in a floating
window.

Workflow:
- Open a `.py` file with `# %%` cell markers (or a `.ipynb` file)
- `<leader>mi` to initialize a kernel
- `<leader>mr` to run the current cell
- `<leader>ms` (visual mode) to send selected code to the kernel
- See pandas output, matplotlib/seaborn plots, tensor shapes inline

### 4. REPL Send-to-Terminal

Add a small utility in `lua/plugins/spec/repl-send.lua` that sends the current
line or visual selection from a Python file into the running Python REPL
terminal, reusing the existing NvChad terminal toggle.

Keymaps:
- `<leader>sp` — send current line
- `<leader>sp` (visual) — send selected lines

No new terminal plugin needed.

## Files Changed

| File | Action | Lines |
|------|--------|-------|
| `lua/plugins/override/nvim-treesitter.lua` | Edit: add `"python"` to `ensure_installed` | +1 |
| `lua/plugins/override/lspconfig.lua` | Edit: add settings to `pyright = {}` + keymap | +11 |
| `lua/plugins/spec/molten.lua` | **New**: molten-nvim plugin spec | ~30 |
| `lua/plugins/spec/repl-send.lua` | **New**: REPL send utility | ~30 |
| `lua/plugins/init.lua` | Edit: add `molten` and `repl-send` imports | +2 |

Total: ~75 lines added across 5 files.

## Out of Scope (for now)

- Remote GPU / SSH workflows
- Neotest / pytest integration
- Dataframe-specific viewers
- Ruff linter (already installed via Mason)
- Notebook-native editing quirks (jupytext auto-conversion)
