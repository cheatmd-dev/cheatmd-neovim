local M = {}

-- Default configuration. Users override via `require('cheatmd').setup({...})`.
M.defaults = {
  executable_path = "cheatmd",
  enable_linter = true,
  strict = false,
  terminal_split = "horizontal", -- "horizontal" | "vertical" | "float"
}

M.values = vim.deepcopy(M.defaults)

function M.apply(opts)
  M.values = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
