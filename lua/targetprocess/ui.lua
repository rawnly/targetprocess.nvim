local M = {}

---@param lines string[]
---@param opts? { title?: string }
function M.open_float(lines, opts)
  opts = opts or {}

  -- 1. Determine constraints
  local max_width = math.floor(vim.o.columns * 0.7)
  local max_height = math.floor(vim.o.lines * 0.7)

  -- 2. Calculate content width (clamped between 40 and 70% of screen)
  local content_width = 0
  for _, line in ipairs(lines) do
    content_width = math.max(content_width, vim.fn.strdisplaywidth(line))
  end
  local final_width = math.min(math.max(content_width, 40), max_width)

  -- 3. Calculate content height (accounting for WRAPPING)
  local wrapped_height = 0
  for _, line in ipairs(lines) do
    local line_width = vim.fn.strdisplaywidth(line)
    -- If line is empty, it still takes 1 row.
    -- Otherwise, calculate how many rows it occupies based on final_width.
    local rows = math.max(1, math.ceil(line_width / final_width))
    wrapped_height = wrapped_height + rows
  end

  -- Apply a reasonable floor (like 5) so it doesn't look too cramped,
  -- but keep the ceiling at 70% of screen.
  local final_height = math.min(math.max(wrapped_height, 5), max_height)

  -- 4. Calculate Centering
  local col = math.floor((vim.o.columns - final_width) / 2)
  local row = math.floor((vim.o.lines - final_height) / 2)

  -- 5. Create Buffer and Window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = final_width,
    height = final_height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = opts.title and (" " .. opts.title .. " ") or nil,
    title_pos = opts.title and "center" or nil,
  })

  -- 6. Options & Mappings
  vim.api.nvim_set_option_value('wrap', true, { win = win })
  vim.api.nvim_set_option_value('linebreak', true, { win = win })
  vim.api.nvim_set_option_value('breakindent', true, { win = win })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

  vim.keymap.set("n", "q", '<cmd>close<cr>', { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", '<cmd>close<cr>', { buffer = buf, nowait = true, silent = true })

  return buf, win
end

return M
