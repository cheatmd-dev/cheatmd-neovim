local config = require("cheatmd.config")
local workspace = require("cheatmd.workspace")
local diagnostics = require("cheatmd.diagnostics")

local M = {}

local ns_id = vim.api.nvim_create_namespace("cheatmd")

-- Run cheatmd --lint asynchronously and apply the parsed findings as buffer
-- diagnostics. No-op for non-markdown buffers or unnamed buffers.
function M.run(bufnr)
  if not M._is_lintable(bufnr) then
    return
  end
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local lint_dir = workspace.find_root(bufnr)
  local args = M._build_args(lint_dir)
  local accumulator = { stdout = {}, stderr = {} }

  vim.fn.jobstart({ config.values.executable_path, unpack(args) }, {
    cwd = lint_dir,
    on_stdout = function(_, data) M._collect(accumulator.stdout, data) end,
    on_stderr = function(_, data) M._collect(accumulator.stderr, data) end,
    on_exit = function(_, exit_code)
      M._handle_exit(bufnr, file_path, accumulator, exit_code)
    end,
  })
end

function M._is_lintable(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if vim.bo[bufnr].filetype ~= "markdown" then
    return false
  end
  return vim.api.nvim_buf_get_name(bufnr) ~= ""
end

function M._build_args(lint_dir)
  local args = { "--lint" }
  if config.values.strict then
    table.insert(args, "--strict")
  end
  table.insert(args, lint_dir)
  return args
end

function M._collect(lines, data)
  if not data then
    return
  end
  for _, line in ipairs(data) do
    if line ~= "" then
      table.insert(lines, line)
    end
  end
end

function M._handle_exit(bufnr, file_path, accumulator, exit_code)
  -- exit_code 127 = command not found; -1 with stderr = launch failure.
  if exit_code == 127 or (exit_code == -1 and #accumulator.stderr > 0) then
    return
  end
  -- vim.diagnostic.set replaces the namespace's existing diagnostics, so an
  -- explicit clear is redundant — an empty parsed list still resets state.
  local all_lines = vim.list_extend(accumulator.stdout, accumulator.stderr)
  vim.diagnostic.set(ns_id, bufnr, diagnostics.parse_output(all_lines, file_path, bufnr))
end

return M
