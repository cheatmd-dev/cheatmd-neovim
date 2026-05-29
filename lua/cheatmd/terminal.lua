local M = {}

-- Open `argv` in an integrated terminal using the configured split style.
function M.open(argv, split_style)
  if split_style == "vertical" then
    M._open_vertical(argv)
  elseif split_style == "float" then
    M._open_float(argv)
  else
    M._open_horizontal(argv)
  end
end

function M._open_horizontal(argv)
  vim.cmd("split")
  M._start(argv)
end

function M._open_vertical(argv)
  vim.cmd("vsplit")
  M._start(argv)
end

function M._open_float(argv)
  local geometry = M._float_geometry()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, vim.tbl_extend("force", geometry, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
  }))
  M._start(argv)
end

function M._start(argv)
  local job_id = vim.fn.termopen(argv)
  if job_id <= 0 then
    vim.notify("CheatMD: Failed to start terminal command.", vim.log.levels.ERROR)
    return
  end
  vim.cmd("startinsert")
end

function M._float_geometry()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  return {
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
  }
end

return M
