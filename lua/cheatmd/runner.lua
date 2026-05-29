local block = require("cheatmd.block")
local config = require("cheatmd.config")
local terminal = require("cheatmd.terminal")
local workspace = require("cheatmd.workspace")

local M = {}

-- Locate the cheat heading and fence around the cursor, then start cheatmd in
-- an integrated terminal using the configured split style.
function M.run_current_cheat()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  local heading = block.find_heading(bufnr, cursor_line)
  if not heading then
    vim.notify(
      "CheatMD: No Markdown header found above current cursor position.",
      vim.log.levels.WARN
    )
    return
  end

  local fence = block.find_fence(bufnr, cursor_line)
  if not fence or not block.has_cheat_block_after_fence(bufnr, fence.line) then
    vim.notify(
      "CheatMD: No CheatMD metadata block found below current code block.",
      vim.log.levels.WARN
    )
    return
  end

  local query = block.build_query(heading, fence.title)
  local exec_dir = workspace.find_root(bufnr)
  terminal.open(M._build_args(query, exec_dir), config.values.terminal_split)
end

function M._build_args(query, exec_dir)
  return { config.values.executable_path, "-a", "-q", query, exec_dir }
end

return M
