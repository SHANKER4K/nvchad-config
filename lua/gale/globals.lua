-- Automatically detect context for comment string
_G.__toggle_contextual = function(vmode)
  local api = require "Comment.api"
  local U = require "Comment.utils"
  local ft = require "Comment.ft"

  local range = U.get_region(vmode)
  local same_line = range.srow == range.erow

  -- Does this filetype have a block comment?
  -- Comment.ft stores:
  --   - string: only line comments
  --   - { line, block }: line + block
  local cstr = ft.get(vim.bo.filetype)
  local has_block = type(cstr) == "table" and cstr[2] ~= nil

  if same_line or not has_block then
    api.toggle.linewise(vmode)
  else
    api.toggle.blockwise(vmode)
  end
end
