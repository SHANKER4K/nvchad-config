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
    { "<leader>mc", ":MoltenEvaluate<CR>", desc = "Molten: evaluate cell" },
    { "<leader>ms", ":<C-u>MoltenSend<CR>", mode = "v", desc = "Molten: send selection" },
  },
}
