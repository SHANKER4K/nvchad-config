---@class Utils
--- Add an alias to any existing command
---@field add_alias fun(target_cmd: string, alias: string)
--- Check if any value is a table
---@field is_tbl fun(v: any): boolean
--- Create a global keymap
---@field glb_map fun(mode: string | table, lhs: string | table, rhs: string | fun(), opts?: table | nil)
--- Create a keymap local to buffer
---@field buf_map fun(buf?: integer, mode: string | table, lhs: string | table, rhs: string | fun(), opts?: table)
--- Format a file based on its path, using conform
---@field format_file fun(file_path: string)
--- Helper function to match valid "words" in a line
---@field word_iterator fun(line: string): function
--- Helper function to count valid "words" in a line
---@field count_with_exclude fun(line: string, opts?: table): integer
--- Return count of valid "words" in a line as a string
---@field count_words_in_line fun(): string
--- Return count of valid "words" in a buffer as a string
---@field count_words_in_buffer fun(): string
--- Debounce a function by timeout
---@field debounce fun(func: function, timeout: integer): function
--- Combine two lists of strings
---@field combine_lists fun()
--- Fix single line json content
---@field fix_json_content fun()
local M = {}

M.add_alias = function(target_cmd, alias)
  vim.cmd("ca " .. alias .. " " .. target_cmd)
end

M.is_tbl = function(v)
  if type(v) == "table" then
    return true
  else
    return false
  end
end

M.glb_map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }

  if opts then
    options = vim.tbl_extend("force", options, opts)
  end

  if M.is_tbl(lhs) then
    ---@cast lhs table
    for _, trigger in ipairs(lhs) do
      vim.keymap.set(mode, trigger, rhs, options)
    end
  else
    ---@cast lhs string
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

M.buf_map = function(bufnr, mode, lhs, rhs, opts)
  opts = opts or {}
  opts.buffer = bufnr and bufnr or 0
  M.glb_map(mode, lhs, rhs, opts)
end

local is_inspect_tree_open = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if buf_name and buf_name == "query" then
      return true, win
    end
  end
  return false, nil
end

--- Toggle treesitter inspection tree
M.toggle_inspect_tree = function()
  local open, win = is_inspect_tree_open()
  if open then
    ---@cast win integer
    local bufnr = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  else
    vim.cmd "InspectTree"
  end
end

--- Navigate to plugin repo if valid string name under cursor
M.go_to_github_link = function()
  local ts = vim.treesitter
  local node = ts.get_node()

  if not node then
    return
  end

  local string = ts.get_node_text(node, 0)

  local is_github_string = function(str)
    local _, count = str:gsub("/", "")
    return count == 1
  end

  if string then
    local is_valid_string = is_github_string(string)

    if is_valid_string then
      local gh_link = string.format("https://github.com/%s.git", string)
      vim.ui.open(gh_link)
    else
      vim.notify.dismiss() ---@diagnostic disable-line
      vim.notify(" Not a valid GitHub string", vim.log.levels.ERROR, { icon = "" })
      return
    end
  else
    vim.notify.dismiss() ---@diagnostic disable-line
    vim.notify(" Not a string", vim.log.levels.ERROR, { icon = "" })
    return
  end
end

M.format_file = function(file_path)
  local bufnr = vim.fn.bufadd(file_path)
  vim.fn.bufload(bufnr)

  require("conform").format {
    lsp_fallback = true,
    bufnr = bufnr,
  }

  if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd "w"
    end)
  end

  vim.api.nvim_buf_delete(bufnr, { force = true })
end

M.handle_copy = function()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    if vim.fn.line "'<" == vim.fn.line "'>" and vim.fn.col "'<" == vim.fn.col "'>" then
      vim.cmd.normal '"+yy'
    else
      vim.cmd.normal '"+y'
    end
  else
    vim.cmd.normal '"+yy'
  end
end

M.handle_paste = function()
  vim.cmd.normal '"+p'
end

M.menus = {
  main = {
    { name = "  Copy", cmd = M.handle_copy },
    { name = "  Paste", cmd = M.handle_paste },
    { name = "separator" },
    { name = "󰉁 Lsp Actions", hl = "Exblue", items = "lsp" },
    { name = "separator" },
    { name = "  Color Picker", hl = "Exred", cmd = function()
      require("minty.huefy").open()
    end },
  },
}

M.word_iterator = function(line)
  local pattern = "[%w_%-%.]+"
  return function()
    return string.gmatch(line, pattern)
  end
end

M.count_with_exclude = function(line, opts)
  opts = opts or {}
  local word_count = 0
  for word in M.word_iterator(line)() do
    if word ~= opts.exclude then
      word_count = word_count + 1
    end
  end
  return word_count
end

vim.g.st_words_in_line = true
M.count_words_in_line = function()
  local line = vim.api.nvim_get_current_line()
  local word_count = M.count_with_exclude(line, { exclude = ".." })
  if vim.g.st_words_in_line then
    return string.format(" %%#St_GitBranch#%d ", word_count)
  else
    return ""
  end
end

M.count_words_in_buffer = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local total_word_count = 0
  for _, line in ipairs(lines) do
    total_word_count = total_word_count + M.count_with_exclude(line, { exclude = ".." })
  end
  if vim.g.st_words_in_buffer then
    return string.format(" %d ", total_word_count)
  else
    return ""
  end
end

M.harpoon_menu = function()
  local harpoon = require "harpoon"
  harpoon.ui:toggle_quick_menu(harpoon:list(), {
    title = " Harpoon btw ",
    title_pos = "center",
    border = "rounded",
    ui_width_ratio = 0.40,
  })
end

M.debounce = function(func, timeout)
  local timer = vim.uv.new_timer()
  return function(...)
    timer:stop()
    local args = { ... }
    timer:start(timeout, 0, function()
      vim.schedule_wrap(func)(unpack(args))
    end)
  end
end

M.combine_lists = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local separator_index = nil
  for i, line in ipairs(lines) do
    if line:match "^%s*$" then
      separator_index = i
      break
    end
  end
  if not separator_index then
    vim.notify("Separator (empty line) not found!", vim.log.levels.ERROR)
    return
  end
  local list1 = {}
  local list2 = {}
  for i = 1, separator_index - 1 do
    table.insert(list1, lines[i])
  end
  for i = separator_index + 1, #lines do
    table.insert(list2, lines[i])
  end
  if #list1 ~= #list2 then
    vim.notify("The lists have different lengths!", vim.log.levels.ERROR)
    return
  end
  local combined = {}
  for i = 1, #list1 do
    table.insert(combined, list1[i] .. " - " .. list2[i])
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, combined)
  vim.notify "Lists combined successfully!"
end

M.fix_json_content = function()
  local view = vim.fn.winsaveview()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local modified = false
  local open_idx, close_idx
  for i, line in ipairs(lines) do
    if line:match "^%s*%[" then
      open_idx = i
    end
    if line:match "^%s*%]" then
      close_idx = i
    end
  end
  if open_idx and close_idx then
    if open_idx > close_idx then
      table.remove(lines, open_idx)
      table.remove(lines, close_idx)
    else
      table.remove(lines, close_idx)
      table.remove(lines, open_idx)
    end
    table.insert(lines, 1, "[")
    table.insert(lines, "]")
    modified = true
  end
  for i = 2, #lines - 1 do
    local line = lines[i]
    if line:match "}%s*$" then
      lines[i] = line:gsub("}%s*$", "},")
      modified = true
    end
    if i == #lines - 1 then
      if lines[i]:match "},%s*$" then
        lines[i] = lines[i]:gsub("},%s*$", "}")
        modified = true
      end
    end
  end
  if modified then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    print "JSON Fixed: Brackets re-sandwiched & commas normalized"
  end
  vim.fn.winrestview(view)
end

return M