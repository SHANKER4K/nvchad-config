---@type NvPluginSpec
-- iron.nvim: Interactive Repls Over Neovim
-- Manages terminal-based REPLs per language with split/float windows.
--
-- REPL DEFINITIONS:
--   python => ipython (with bracketed paste for Python 3.13+)
--   sh     => zsh
--
-- KEYBINDINGS (iron-managed):
--   <leader>rr    => IronRepl (toggle REPL)
--   <leader>rR    => IronRestartRepl
--   <leader>sc    => IronSendMotion / visual send
--   <leader>sf    => IronSendFile
--   <leader>sl    => IronSendLine
--   <leader>sp    => IronSendParagraph
--   <leader>su    => IronSendUntilCursor
--   <leader>sm    => IronSendMark
--   <leader>sb    => IronSendCodeBlock
--   <leader>sn    => IronSendCodeBlockAndMove
--   <leader>mc    => IronMarkMotion / MarkVisual
--   <leader>md    => IronRemoveMark
--   <leader>s<cr> => IronSendCr
--   <leader>s<space> => IronInterrupt
--   <leader>sq    => IronExit
--   <leader>cl    => IronClear
--   <leader>rf    => IronFocus
--   <leader>rh    => IronHide
--   <S-CR>        => send line (mappings.lua)
return {
  "Vigemus/iron.nvim",
  keys = { "<leader>rr", "<leader>sl", "<leader>sc", "<S-CR>" },
  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")
    local common = require("iron.fts.common")

    iron.setup {
      config = {
        scratch_repl = true,
        repl_definition = {
          sh = {
            command = { "zsh" },
          },
          python = {
            command = { "ipython", "--no-autoindent" },
            format = common.bracketed_paste_python,
            block_dividers = { "# %%", "#%%" },
            env = { PYTHON_BASIC_REPL = "1" },
          },
        },
        repl_filetype = function(_, ft)
          return ft
        end,
        dap_integration = true,
        repl_open_cmd = view.split.vertical.rightbelow("40%"),
      },
      keymaps = {
        send_motion = "<leader>sc",
        visual_send = "<leader>sc",
        send_file = "<leader>sf",
        send_line = "<leader>sl",
        send_paragraph = "<leader>sp",
        send_until_cursor = "<leader>su",
        send_mark = "<leader>sm",
        send_code_block = "<leader>sb",
        send_code_block_and_move = "<leader>sn",
        mark_motion = "<leader>mc",
        mark_visual = "<leader>mc",
        remove_mark = "<leader>md",
        cr = "<leader>s<cr>",
        interrupt = "<leader>s<space>",
        exit = "<leader>sq",
        clear = "<leader>cl",
        toggle_repl = "<leader>rr",
        restart_repl = "<leader>rR",
      },
      highlight = { italic = true },
      ignore_blank_lines = true,
    }

    local map = vim.keymap.set
    map("n", "<leader>rf", "<cmd>IronFocus<CR>", { desc = "Iron focus REPL" })
    map("n", "<leader>rh", "<cmd>IronHide<CR>", { desc = "Iron hide REPL" })
  end,
}