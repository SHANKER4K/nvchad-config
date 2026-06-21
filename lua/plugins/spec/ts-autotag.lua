---@type NvPluginSpec
return {
  "windwp/nvim-ts-autotag",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local status, autotag = pcall(require, "nvim-ts-autotag")
    if status then
      autotag.setup { autotag = { enable = true } }
    end
  end,
}
