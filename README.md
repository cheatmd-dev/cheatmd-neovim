# cheatmd.nvim

A lightweight Neovim plugin for **[CheatMD](https://github.com/cheatmd-dev/cheatmd)** cheatsheets. Written in Lua and Vim syntax, with editor integration, diagnostic linting, and interactive execution.

## Features

- **Asynchronous Linting**: Runs `cheatmd --lint` in the background on buffer save and load, then reports syntax errors and undeclared variables through Neovim's `vim.diagnostic` API.
- **Syntax Highlighting**: Highlights CheatMD DSL blocks inside Markdown `<!-- cheat -->` comments, shell fragments in variables, and variable references inside code fences.
- **Variable Completion**: Provides Markdown buffer completion for local CheatMD variables with `$name` and `<name>` references.
- **TUI Execution**: The `:CheatMDRun` command extracts the active heading and code block description under the cursor, then runs CheatMD inside a split or floating terminal with `--auto`.

## Requirements

cheatmd.nvim requires the `cheatmd` command-line tool for linting and interactive execution.

- Website: https://cheatmd.dev
- GitHub: https://github.com/cheatmd-dev/cheatmd

After installing, make sure `cheatmd` is available in your system path. You can also set an absolute path in plugin setup.

## Disclosures

cheatmd.nvim starts the local `cheatmd` binary for linting and interactive execution. It passes the current workspace path to that local command. The plugin does not send telemetry, show ads, require an account, or make network requests.

## Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

Add the following to your plugin config files:

```lua
return {
  "cheatmd-dev/cheatmd.nvim",
  ft = "markdown",
  config = function()
    require("cheatmd").setup({
      -- Custom binary path (defaults to "cheatmd" in PATH)
      executable_path = "cheatmd",
      -- Enable/disable background job linting
      enable_linter = true,
      -- Treat warnings as errors
      strict = false,
      -- Integrated terminal layout: "horizontal", "vertical", or "float"
      terminal_split = "float",
    })

    -- Optional: Register keymap to execute cheat under cursor
    vim.keymap.set("n", "<leader>cr", "<cmd>CheatMDRun<CR>", {
      desc = "Run current CheatMD block",
      silent = true,
    })
  end,
}
```

## Settings & Mappings

The plugin registers:
- **`:CheatMDRun`**: Parse and execute the cheat block under the cursor inside Neovim's integrated terminal.
- Markdown buffer completion through Neovim's `omnifunc`. Use your normal omnifunc mapping, usually `Ctrl-X Ctrl-O`, after `$` or `<`.
