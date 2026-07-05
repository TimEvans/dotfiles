-- Incremental selection using native Treesitter.
--
-- nvim-treesitter's `main` branch removed the built-in `incremental_selection`
-- module, so this reimplements the subset used in this config:
--   init_selection   -> select the node under the cursor
--   node_incremental -> grow the selection outward to the parent node
--   node_decremental -> shrink back to the previously selected node
--
-- Selection history is kept per buffer as a stack of nodes growing outward.

local M = {}

-- [bufnr] = { TSNode, TSNode, ... }, innermost first
local selection_stack = {}

local function ranges_equal(a, b)
  local a1, a2, a3, a4 = a:range()
  local b1, b2, b3, b4 = b:range()
  return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
end

-- Visually select a 0-indexed, end-exclusive range as a charwise selection.
local function select_range(srow, scol, erow, ecol)
  -- Leave any active visual mode so we can build a fresh selection.
  if vim.fn.mode():match("[vV\022]") then
    vim.cmd("normal! \027")
  end
  vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
  vim.cmd("normal! v")
  if ecol == 0 then
    -- An exclusive end at column 0 means the selection stops at the end of
    -- the previous line.
    vim.api.nvim_win_set_cursor(0, { erow, 0 })
    vim.cmd("normal! $")
  else
    vim.api.nvim_win_set_cursor(0, { erow + 1, ecol - 1 })
  end
end

local function select_node(node)
  select_range(node:range())
end

function M.init_selection()
  local node = vim.treesitter.get_node()
  if not node then
    return
  end
  selection_stack[vim.api.nvim_get_current_buf()] = { node }
  select_node(node)
end

function M.node_incremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selection_stack[buf]
  if not stack or #stack == 0 then
    return M.init_selection()
  end
  local current = stack[#stack]
  local parent = current:parent()
  -- Skip ancestors that cover the exact same range as the current node.
  while parent and ranges_equal(parent, current) do
    parent = parent:parent()
  end
  if parent then
    table.insert(stack, parent)
    select_node(parent)
  else
    select_node(current)
  end
end

function M.node_decremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selection_stack[buf]
  if not stack or #stack <= 1 then
    return
  end
  table.remove(stack)
  select_node(stack[#stack])
end

return M
