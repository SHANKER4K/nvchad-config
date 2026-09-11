---@type NvPluginSpec
return {
  "numToStr/Comment.nvim",
  init = function()
    local map = vim.keymap.set
    local api = require "Comment.api"

    -- gcc / gbc commentary-style mappings
    map("n", "gcc", function()
      api.toggle.linewise.current()
    end, { desc = "Toggle line comment" })

    map("n", "gbc", function()
      api.toggle.blockwise.current()
    end, { desc = "Toggle block comment" })

    map("n", "gc", "<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@", {
      desc = "Comment motion (context-aware)",
    })

    map("x", "gc", "<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@", {
      desc = "Comment selection (context-aware)",
    })

    map("x", "gb", function()
      api.toggle.blockwise("v")
    end, { desc = "Block comment selection" })

    -- leader-based mappings
    map("n", "<leader>_", function()
      api.toggle.blockwise.current()
    end, { desc = "Comment toggle (block) in single line" })

    map("n", "<leader>/", function()
      api.toggle.linewise.current()
    end, { desc = "Comment toggle" })

    map(
      "x",
      "<leader>/",
      "<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@",
      { desc = "Comment toggle (aware of context)" }
    )
  end,
  ---@param opts CommentConfig
  config = function(_, opts)
    -- Return commentstring directly to skip ft.calculate (crashes on langs without treesitter parser)
    opts.pre_hook = function()
      return vim.bo.commentstring
    end
    -- Disable default mappings so they don't override our init mappings
    opts.mappings = { basic = false, extra = false }
    require("Comment").setup(opts)
  end,
}
