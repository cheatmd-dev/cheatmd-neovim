local config = require("cheatmd.config")
local linter = require("cheatmd.linter")
local runner = require("cheatmd.runner")

local M = {}

-- Plugin entry. Users call `require('cheatmd').setup({ ... })` from their
-- init.lua to override defaults and register autocommands/user commands.
function M.setup(opts)
  config.apply(opts)
  if config.values.enable_linter then
    M._register_linter_autocmds()
  end
  M._register_completion()
  M._register_run_command()
end

function M._register_linter_autocmds()
  local group = vim.api.nvim_create_augroup("CheatMDLinter", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "BufEnter" }, {
    group = group,
    pattern = "*.md",
    callback = function(args) linter.run(args.buf) end,
  })
end

function M._register_run_command()
  vim.api.nvim_create_user_command("CheatMDRun", function()
    runner.run_current_cheat()
  end, {})
end

function M._register_completion()
  local group = vim.api.nvim_create_augroup("CheatMDCompletion", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = "markdown",
    callback = function()
      vim.bo.omnifunc = "v:lua.require'cheatmd.completion'.complete"
    end,
  })
end

return M
