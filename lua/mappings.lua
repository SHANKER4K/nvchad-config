local utils = require "gale.utils"
local map = utils.glb_map

map("n", ";", ":", { desc = "General enter CMD mode" })
map("i", "jk", "<ESC>", { desc = "General exit insert mode" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "General copy file content" })
map({ "n", "i" }, "<C-s>", "<cmd>w<CR>", { desc = "General save file" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "General clear search highlights" })
map("n", "<leader><F4>", "<cmd>stop<CR>", { desc = "General stop NVIM" })
map("n", "<leader>cm", "<cmd>mes clear<CR>", { desc = "General clear messages" })
map("i", "<A-BS>", "<C-w>", { desc = "General remove word" })

map("n", "<leader>ol", function()
  vim.ui.open(vim.fn.expand "%:p:h")
end, { desc = "General open file location in file explorer" })

-- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
map("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
map("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })

-- Buffer motions
map("i", "<C-b>", "<ESC>^i", { desc = "Go to beginning of line" })
map("i", "<C-e>", "<End>", { desc = "Go to end of line" })
map("i", "<C-A-h>", "<Left>", { desc = "Go to left" })
map("i", "<C-A-l>", "<Right>", { desc = "Go to right" })
map("i", "<C-A-j>", "<Down>", { desc = "Go down" })
map("v", "<Tab>", ">gv", { desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent selection" })
-- Font zoom (kitty)
map("n", "<C-=>", function()
  vim.fn.system "kitty @ set-font-size +0.5"
end, { desc = "Zoom in" })
map("n", "<C-->", function()
  vim.fn.system "kitty @ set-font-size -0.5"
end, { desc = "Zoom out" })
map("i", "<C-A-k>", "<Up>", { desc = "Go up" })
map("n", "<leader>gm", "<cmd>exe 'normal! ' . line('$')/2 . 'G'<CR>", { desc = "Go to middle of the file" })

-- Move lines up/down (<A-j> / <A-k> only, deduplicated)
map("n", "<A-j>", ":m .+1<CR>", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>", { desc = "Move line up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })

-- Quick resize pane
map("n", "<C-A-h>", "5<C-w>>", { desc = "Window increase width by 5" })
map("n", "<C-A-l>", "5<C-w><", { desc = "Window decrease width by 5" })
map("n", "<C-A-k>", "5<C-w>+", { desc = "Window increase height by 5" })
map("n", "<C-A-j>", "5<C-w>-", { desc = "Window decrease height by 5" })

-- Togglers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" })
map("n", "<leader>ih", "<cmd>ToggleInlayHints<CR>", { desc = "Toggle inlay hints" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "Toggle nvcheatsheet" })

-- Python / REPL
map("n", "<leader>vp", "<cmd>PyrightSetPythonPath<CR>", { desc = "Python set pyright interpreter" })
map("n", "<leader>r", ":w<bar>terminal python3 %<CR>", { desc = "Run current Python file", noremap = true })
map("n", "<S-CR>", function()
  require("iron.core").send_line()
end, { desc = "Send line to REPL" })
map("v", "<S-CR>", function()
  require("iron.core").visual_send()
end, { desc = "Send selection to REPL" })

-- LSP
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- Minty color picker
map("n", "<leader>cp", function()
  require("minty.huefy").open()
end, { desc = "Open color picker" })

-- NvChad
map("n", "<leader>th", function()
  require("nvchad.themes").open { style = "flat" }
end, { desc = "Open theme picker" })

-- NvMenu
local menus = utils.menus
map({ "n", "v" }, "<C-t>", function()
  require("menu").open(menus.main)
end, { desc = "Open NvChad menu" })
map({ "n", "v" }, "<RightMouse>", function()
  vim.cmd.exec '"normal! \\<RightMouse>"'
  require("menu").open(menus.main, { mouse = true })
end, { desc = "Open NvChad menu" })

-- Term (NvChad)
local term = require "nvchad.term"
map("t", "<C-x>", "<C-\\><C-N>", { desc = "Term escape terminal mode" })
map({ "n", "t" }, "<A-v>", function()
  term.toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "Term toggle vertical split" })
map({ "n", "t" }, "<A-h>", function()
  term.toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Term toggle horizontal split" })
map({ "n", "t" }, "<A-i>", function()
  term.toggle { pos = "float", id = "floatTerm" }
end, { desc = "Term toggle floating" })

-- TreeSitter
map({ "n", "v" }, "<leader>it", function()
  utils.toggle_inspect_tree()
end, { desc = "TreeSitter toggle inspect tree" })
map("n", "<leader>ii", "<cmd>Inspect<CR>", { desc = "TreeSitter inspect under cursor" })

--- Tabufline
local tabufline = require "nvchad.tabufline"
map("n", "<Tab>", function()
  tabufline.next()
end, { desc = "Buffer go to next" })
map("n", "<S-Tab>", function()
  tabufline.prev()
end, { desc = "Buffer go to prev" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "Buffer new" })
map("n", "<leader>x", function()
  tabufline.close_buffer()
end, { desc = "Buffer close" })
map("n", "<A-Left>", function()
  tabufline.move_buf(-1)
end, { desc = "Tabufline move buffer left" })
map("n", "<A-Right>", function()
  tabufline.move_buf(1)
end, { desc = "Tabufline move buffer right" })
map("n", "<A-|>", "<cmd>TabuflineToggle<CR>", { desc = "Tabufline toggle visibility" })
for i = 1, 9 do
  map("n", "<A-" .. i .. ">", i .. "gt", { desc = "Tab go to tab " .. i })
end

-- Utils
map("n", "gh", function()
  utils.go_to_github_link()
end, { desc = "Go to GitHub link generated from string" })
map({ "v", "n" }, "<leader>fj", "<cmd>sort i<CR><cmd>FixJson<CR>", {
  desc = "Sort JSON lines and fix commas",
})
