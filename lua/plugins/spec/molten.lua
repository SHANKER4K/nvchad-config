---@type NvPluginSpec
return {
  "benlubas/molten-nvim",
  build = ":UpdateRemotePlugins",
  init = function()
    vim.g.molten_image_provider = "none"
    vim.g.molten_output_win_border = { "", "", "", " ", "", "", "", "" }
    vim.g.molten_auto_open_output = true

    -- Create keymaps directly (plugin is rplugin-based, no lua entry point)
    vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { desc = "Molten: init kernel" })
    vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<CR>", { desc = "Molten: re-run cell" })
    vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "Molten: delete cell output" })
    vim.keymap.set("n", "<leader>mo", ":MoltenShowOutput<CR>", { desc = "Molten: show output" })
    vim.keymap.set("n", "<leader>mc", ":MoltenEvaluate<CR>", { desc = "Molten: evaluate cell" })
    vim.keymap.set("v", "<leader>ms", ":<C-u>MoltenSend<CR>", { desc = "Molten: send selection" })
  end,
}
