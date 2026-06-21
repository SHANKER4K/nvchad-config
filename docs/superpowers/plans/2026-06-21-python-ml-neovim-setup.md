# Python ML Neovim Setup — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the existing NvChad-based Neovim config with Python ML-specific tooling: treesitter, pyright venv detection, Jupyter cells (molten-nvim), and REPL send-to-terminal.

**Architecture:** Add 2 new plugin spec files, edit 3 existing files, targeting only the Python ML workflow gaps. No config restructuring — everything follows existing NvChad plugin patterns.

**Tech Stack:** Neovim 0.10+, NvChad, lazy.nvim, molten-nvim, pyright, ruff

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `lua/plugins/override/nvim-treesitter.lua` | Edit | Add `"python"` to `ensure_installed` |
| `lua/plugins/override/lspconfig.lua` | Edit | Add pyright venv settings + keymap |
| `lua/plugins/spec/molten.lua` | **Create** | molten-nvim Jupyter kernel runner |
| `lua/plugins/spec/repl-send.lua` | **Create** | Send Python lines to terminal REPL |
| `lua/plugins/init.lua` | Edit | Register the two new plugin specs |
| `docs/superpowers/cheatsheets/python-ml-cheatsheet.md` | **Create** | Cheat sheet with all new keybindings |

---

### Task 1: Add Python treesitter parser

**Files:**
- Modify: `lua/plugins/override/nvim-treesitter.lua:7` (inside `ensure_installed` list)

- [ ] **Step 1: Add "python" to ensure_installed**

Open `lua/plugins/override/nvim-treesitter.lua` and add `"python"` to the `ensure_installed` list (alphabetically between `"markdown_inline"` and `"rust"`):

```lua
      "markdown_inline",
      "python",
      "rust",
```

- [ ] **Step 2: Run TSUpdate to install the parser**

```bash
nvim --headless "+TSInstall python" "+q"
```

Expected: `python` parser installed successfully.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/override/nvim-treesitter.lua
git commit -m "feat: add python treesitter parser"
```

---

### Task 2: Configure pyright for virtual environments

**Files:**
- Modify: `lua/plugins/override/lspconfig.lua:57-58` (the `pyright = {}` entry)

- [ ] **Step 1: Add settings block to pyright config**

Replace the existing `pyright = {},` entry (line 57-58 in original) with a config that includes venv detection:

```lua
      pyright = {
        settings = {
          python = {
            pythonPath = vim.fn.executable("python3") and vim.fn.executable("python3") or "python",
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              autoImportCompletions = true,
            },
          },
        },
      },
```

- [ ] **Step 2: Add a keymap to manually set Python path**

In `lua/mappings.lua`, add after the existing LSP keymaps (around line 57):

```lua
-- Python
map("n", "<leader>vp", "<cmd>PyrightSetPython<CR>", { desc = "Python set pyright interpreter" })
```

- [ ] **Step 3: Restart Neovim and verify pyright picks up the venv**

Open a Python file in a project with a venv. Run `:LspInfo` and confirm pyright is attached with the correct Python path.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/override/lspconfig.lua lua/mappings.lua
git commit -m "feat: configure pyright venv detection"
```

---

### Task 3: Add molten-nvim for Jupyter kernel support

**Files:**
- Create: `lua/plugins/spec/molten.lua`
- Modify: `lua/plugins/init.lua` (add import)

- [ ] **Step 1: Create the molten-nvim plugin spec**

Write `lua/plugins/spec/molten.lua`:

```lua
---@type NvPluginSpec
return {
  "benlubas/molten-nvim",
  build = ":UpdateRemotePlugins",
  init = function()
    vim.g.molten_image_provider = "none"
    vim.g.molten_output_win_border = { "", "", "", " ", "", "", "", "" }
    vim.g.molten_auto_open_output = true
  end,
  keys = {
    { "<leader>mi", ":MoltenInit<CR>", desc = "Molten: init kernel" },
    { "<leader>mr", ":MoltenReevaluateCell<CR>", desc = "Molten: re-run cell" },
    { "<leader>md", ":MoltenDelete<CR>", desc = "Molten: delete cell output" },
    { "<leader>mo", ":MoltenShowOutput<CR>", desc = "Molten: show output" },
    { "<leader>mc", ":Molteenate<CR>", desc = "Molten: evaluate cell" },
    { "<leader>ms", ":<C-u>MoltenSend<CR>", mode = "v", desc = "Molten: send selection" },
    { "<leader>me", ":<C-u>MoltenEvaluateOperator<CR>", desc = "Molten: evaluate operator" },
  },
}
```

- [ ] **Step 2: Register the plugin in init.lua**

Add the following import to `lua/plugins/init.lua` in alphabetical position (after `"plugins.spec.markview"`):

```lua
  { import = "plugins.spec.molten" },
```

- [ ] **Step 3: Install the plugin**

```bash
nvim --headless "+Lazy sync" "+q"
```

Check output shows molten-nvim installed.

- [ ] **Step 4: Install a Jupyter kernel for testing**

```bash
python3 -m pip install ipykernel
python3 -m ipykernel install --user --name python3
```

- [ ] **Step 5: Quick smoke test**

```bash
nvim --headless -c "MoltenInit" -c "q"
```

Expected: no errors (MoltenInit will prompt for kernel in headless mode, but should not crash).

- [ ] **Step 6: Commit**

```bash
git add lua/plugins/spec/molten.lua lua/plugins/init.lua
git commit -m "feat: add molten-nvim for jupyter kernel support"
```

---

### Task 4: Add REPL send-to-terminal utility

**Files:**
- Create: `lua/plugins/spec/repl-send.lua`
- Modify: `lua/plugins/init.lua` (add import)

- [ ] **Step 1: Create the REPL send plugin spec**

Write `lua/plugins/spec/repl-send.lua`:

```lua
---@type NvPluginSpec
return {
  -- No external plugin — this spec only adds keymaps and a send helper.
  -- It uses the existing NvChad terminal module to open/send to a Python REPL.
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>s", group = "Send" },
      },
    },
  },
  init = function()
    local M = {}

    --- Get or create a Python REPL terminal buffer
    --- @return integer|nil job_id
    function M.get_or_open_python_repl()
      local terms = vim.g.nvchad_terms or {}
      local existing = terms["pyRepl"]

      if existing and vim.api.nvim_buf_is_valid(existing.buf) then
        local job_id = vim.b[existing.buf].terminal_job_id
        if job_id and job_id > 0 then
          return job_id
        end
      end

      -- Open a new Python REPL terminal
      local term = require "nvchad.term"
      term.toggle {
        pos = "float",
        id = "pyRepl",
        cmd = "python3",
      }
      vim.wait(1000, function()
        local t = vim.g.nvchad_terms or {}
        local e = t["pyRepl"]
        return e and e.buf and vim.b[e.buf].terminal_job_id and vim.b[e.buf].terminal_job_id > 0
      end)
      local entry = (vim.g.nvchad_terms or {})["pyRepl"]
      if entry and entry.buf then
        return vim.b[entry.buf].terminal_job_id
      end
      return nil
    end

    --- Send lines to the Python REPL
    --- @param lines string[]
    function M.send_to_repl(lines)
      local job_id = M.get_or_open_python_repl()
      if not job_id then
        vim.notify("No Python REPL available", vim.log.levels.WARN)
        return
      end
      local text = table.concat(lines, "\n") .. "\n"
      vim.api.nvim_chan_send(job_id, text)
    end

    -- Normal mode: send current line
    vim.keymap.set("n", "<leader>sl", function()
      local line = vim.api.nvim_get_current_line()
      M.send_to_repl({ line })
    end, { desc = "Send line to REPL", silent = true })

    -- Visual mode: send selected lines
    vim.keymap.set("v", "<leader>sl", function()
      local lines = vim.fn.getline("'<", "'>")
      M.send_to_repl(lines)
    end, { desc = "Send selection to REPL", silent = true })

    -- Normal mode: send entire buffer
    vim.keymap.set("n", "<leader>sa", function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      M.send_to_repl(lines)
    end, { desc = "Send all to REPL", silent = true })
  end,
}
```

- [ ] **Step 2: Register in init.lua**

Add to `lua/plugins/init.lua` (after `"plugins.spec.precognition"`):

```lua
  { import = "plugins.spec.repl-send" },
```

- [ ] **Step 3: Quick smoke test**

```bash
nvim --headless -c "lua vim.keymap.enable('n', '<leader>sl')" -c "q"
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/spec/repl-send.lua lua/plugins/init.lua
git commit -m "feat: add REPL send-to-terminal utility"
```

---

### Task 5: Create Python ML cheat sheet

**Files:**
- Create: `docs/superpowers/cheatsheets/python-ml-cheatsheet.md`

- [ ] **Step 1: Create cheat sheet**

Write `docs/superpowers/cheatsheets/python-ml-cheatsheet.md`:

```markdown
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

Use `# %%` cell markers in `.py` files, or open `.ipynb` files.

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
4. `<leader>mo` to pop open the output window

## REPL (Send to Python Terminal)

| Key | Action |
|-----|--------|
| `<leader>sl` | Send current line to REPL |
| `<leader>sl` (visual) | Send selected lines to REPL |
| `<leader>sa` | Send entire buffer to REPL |
| `<A-i>` | Toggle floating terminal (manual Python) |

**Workflow:**
1. Open a Python file
2. Select a few lines of pandas/numpy code
3. `<leader>sl` — code runs in the REPL, output visible

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
| `:TSInstall python` | Install Python treesitter parser |
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/cheatsheets/python-ml-cheatsheet.md
git commit -m "docs: add python ML cheatsheet"
```

---

## Verification

After all tasks complete, run:

```bash
# Verify treesitter parser installed
nvim --headless -c "TSInstallInfo python" -c "q"

# Verify plugins installed
nvim --headless -c "Lazy" -c "q"

# Open Neovim and check LSP
nvim -c "LspInfo" +"q"
```
