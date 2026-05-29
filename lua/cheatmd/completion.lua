local M = {}

local VAR_DEF = "^%s*var%s+([%a_][%w_]*)"
-- Captures the start column and the trigger char (`$` or `<`) in a single
-- pass so findstart and the completion call don't each rescan the line.
local TRIGGER_PATTERN = "()([%$<])[%w_]*$"

-- Omnifunc entry point. Completes local CheatMD variables after `$` and `<`.
function M.complete(findstart, base)
  local ctx = M._context()
  if findstart == 1 then
    return ctx and (ctx.start - 1) or -2
  end
  return M._complete(base, ctx and ctx.trigger or "$")
end

-- Read the current line/cursor once and extract both the start column and the
-- trigger char in a single regex pass.
function M._context()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".") - 1
  local prefix = line:sub(1, col)
  local start_col, trigger = prefix:match(TRIGGER_PATTERN)
  if not start_col then
    return nil
  end
  return { start = start_col, trigger = trigger }
end

function M._complete(base, trigger)
  local results = {}
  local seen = {}
  for _, name in ipairs(M._collect_vars(0)) do
    if name:sub(1, #base) == base and not seen[name] then
      seen[name] = true
      table.insert(results, {
        word = trigger == "<" and (name .. ">") or name,
        abbr = name,
        kind = "v",
        menu = "CheatMD variable",
      })
    end
  end
  return results
end

function M._collect_vars(bufnr)
  local vars = {}
  local in_cheat_block = false
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, line in ipairs(lines) do
    if line:match("<!%-%-%s*cheat") then
      in_cheat_block = true
    end
    if in_cheat_block then
      local name = line:match(VAR_DEF)
      if name then
        table.insert(vars, name)
      end
    end
    if line:find("%-%->", 1, false) then
      in_cheat_block = false
    end
  end
  return vars
end

return M
