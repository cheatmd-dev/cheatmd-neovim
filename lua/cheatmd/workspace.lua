local M = {}

-- Resolve the workspace root by walking upward looking for `.obsidian` or
-- `.git`. Falls back to the buffer's directory, then cwd. The order matters:
-- obsidian vaults are checked first so a vault nested inside a larger git
-- repo still resolves to the vault root.
function M.find_root(bufnr)
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  if file_path == "" then
    return vim.fn.getcwd()
  end
  local start_dir = vim.fn.fnamemodify(file_path, ":h")
  return M._find_marker(start_dir, ".obsidian")
    or M._find_marker(start_dir, ".git")
    or start_dir
end

function M._find_marker(start_dir, marker)
  local found = vim.fn.finddir(marker, start_dir .. ";")
  if found == "" then
    return nil
  end
  return vim.fn.fnamemodify(found, ":h:p")
end

return M
