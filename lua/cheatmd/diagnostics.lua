local M = {}

-- GCC format: filepath:line:col: severity: message
local DIAGNOSTIC_PATTERN = "^(.-):(%d+):(%d+):%s+(%w+):%s+(.*)$"

-- Parse a single linter line into a diagnostic record, or nil if the line is
-- not a diagnostic. Filters diagnostics for other files.
function M.parse_line(line, current_file_path, bufnr)
  local file, lnum_str, col_str, severity, msg = line:match(DIAGNOSTIC_PATTERN)
  if not file then
    return nil
  end
  if vim.fn.fnamemodify(file, ":p") ~= vim.fn.fnamemodify(current_file_path, ":p") then
    return nil
  end

  local lnum = tonumber(lnum_str) - 1
  local col = tonumber(col_str) - 1
  return {
    lnum = lnum,
    col = col,
    end_col = M._compute_end_col(bufnr, lnum, col),
    severity = M._severity(severity),
    message = msg,
    source = "cheatmd",
  }
end

-- Expand single-character ranges to the full line when the finding lands on
-- a heading marker or whitespace, so the highlight is meaningful.
function M._compute_end_col(bufnr, lnum, col)
  if col ~= 0 then
    return col + 1
  end
  local line_text = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
  local first = line_text:sub(1, 1)
  if first == "#" or first == " " or line_text == "" then
    return #line_text
  end
  return col + 1
end

function M._severity(severity)
  if severity == "error" then
    return vim.diagnostic.severity.ERROR
  end
  return vim.diagnostic.severity.WARN
end

-- Convert raw linter output lines to a diagnostics list.
function M.parse_output(lines, current_file_path, bufnr)
  local diagnostics = {}
  for _, line in ipairs(lines) do
    local diag = M.parse_line(line, current_file_path, bufnr)
    if diag then
      table.insert(diagnostics, diag)
    end
  end
  return diagnostics
end

return M
