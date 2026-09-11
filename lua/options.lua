require "nvchad.options"

local custom = {
  g = {
    dap_virtual_text = true,
    bookmark_sign = "",
    tabufline_visible = true,
    clipboard = {
      name = "wl-clipboard",
      copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
      paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
      cache_enabled = 1,
    },
    showtabline = 1,

    -- Python provider for pynvim
    python3_host_prog = "/home/ismail/.local/share/nvim/venv/bin/python3",
  },
  opt = {
    encoding = "utf-8",
    fileencoding = "utf-8",
    -- Folds
    foldenable = true,
    foldmethod = "expr",
    foldexpr = "v:lua.vim.treesitter.foldexpr()",
    foldcolumn = "1",
    foldtext = "",
    foldlevel = 99,
    foldlevelstart = 5,
    foldnestmax = 5,
    fillchars = {
      eob = " ",
      fold = " ",
      foldopen = "",
      foldsep = " ",
      foldclose = "",
      lastline = " ",
    },
    -- Prevent issues with some language servers
    backup = false,
    swapfile = false,
    -- Always show minimum n lines after/before current line
    scrolloff = 10,
    -- True color support
    termguicolors = true,
    emoji = false,
    relativenumber = true,
    -- Line break/wrap behaviours
    wrap = true,
    linebreak = true,
    textwidth = 0,
    -- wrapmargin = 0,
    colorcolumn = "+1",
    -- Indentation values
    tabstop = 2,
    shiftwidth = 0, -- 0 forces same value as tabstop
    expandtab = true,
    autoindent = true,
    cursorline = true,
    cursorlineopt = "both",
    inccommand = "split",
    ignorecase = true,
    updatetime = 100,
    lazyredraw = false,
    iskeyword = vim.opt.iskeyword:append { "_", "@", ".", "-" },
    path = vim.opt.path:append { "**", "lua", "src" },
  },
}

for i, opts in pairs(custom) do
  for k, v in pairs(opts) do
    vim[i][k] = v
  end
end
