local M = {}

-- Scan upwards from `cursor_line` for the nearest markdown heading.
-- Returns the heading text with `#` markers stripped, or nil if none found.
function M.find_heading(bufnr, cursor_line)
  for l = cursor_line, 1, -1 do
    local text = M._line(bufnr, l)
    if text:match("^#") then
      return text:gsub("^#+%s*", ""):gsub("%s*$", "")
    end
  end
  return nil
end

-- Scan downwards from `cursor_line` for the opening fence of the next code
-- block, stopping at the next heading.
function M.find_fence(bufnr, cursor_line)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for l = cursor_line, line_count do
    local text = M._line(bufnr, l)
    if text:match("^#") and l > cursor_line then
      return nil
    end
    if text:match("^```") then
      return {
        line = l,
        title = M._parse_title_attr(text),
      }
    end
  end
  return nil
end

function M.has_cheat_block_after_fence(bufnr, fence_line)
  local fence_end = M._find_fence_end(bufnr, fence_line)
  if not fence_end then
    return false
  end

  local in_cheat_block = false
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for l = fence_end + 1, line_count do
    local text = vim.trim(M._line(bufnr, l))
    if text:match("^#") or text:match("^```") then
      return false
    end
    if text:match("<!%-%-%s*cheat") then
      in_cheat_block = true
    end
    if in_cheat_block and text:find("%-%->") then
      return true
    end
  end
  return false
end

function M._find_fence_end(bufnr, fence_line)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for l = fence_line + 1, line_count do
    if vim.trim(M._line(bufnr, l)):match("^```") then
      return l
    end
  end
  return nil
end

function M._line(bufnr, l)
  return vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
end

function M._parse_title_attr(line)
  local title = line:match('title:%s*"([^"]*)"') or line:match("title:%s*'([^']*)'")
  if not title then
    return nil
  end
  return title:gsub("^%s*", ""):gsub("%s*$", "")
end

-- Combine a heading and an optional fence title into a cheatmd `-q` query.
function M.build_query(heading, fence_title)
  if fence_title and fence_title ~= "" then
    return heading .. " " .. fence_title
  end
  return heading
end

return M
