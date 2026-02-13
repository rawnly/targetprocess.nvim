# targetprocess.nvim

Neovim plugin to view TargetProcess user stories directly from your editor.
Automatically detects the ticket ID from your current git branch.

## Requirements

- Neovim >= 0.10
- `curl`
- A [TargetProcess](https://www.targetprocess.com/) account with an API access token

## Installation

```lua
-- lazy.nvim
{
    "rawnly/targetprocess.nvim",
    cmd = { "TargetProcessView", "TargetProcessOpen" },
    opts = {
        base_url = "https://yourcompany.tpondemand.com",
        token = vim.env.TARGET_PROCESS_ACCESS_TOKEN,
    },
}
```

## Configuration

```lua
require("targetprocess").setup({
    -- Required: your TargetProcess instance URL
    base_url = "https://yourcompany.tpondemand.com",

    -- Required: API access token
    -- Tip: use an env var to keep it out of your dotfiles
    token = vim.env.TARGET_PROCESS_ACCESS_TOKEN,
})
```

## Commands

| Command | Description |
| --- | --- |
| `:TargetProcessView [id]` | View the user story in a floating window |
| `:TargetProcessOpen [id]` | Open the user story in your browser |

Both commands accept an optional ticket ID or TargetProcess URL. When no
argument is provided, the ticket ID is extracted from the current git branch.

### Branch name detection

The plugin extracts the ticket ID from branch names matching these patterns
(checked in order):

1. `prefix/12345_description` (e.g. `feature/12345_add_login`)
2. Any sequence of 4+ digits in the branch name

### Floating window keymaps

| Key | Action |
| --- | --- |
| `q` | Close the floating window |
| `<Esc>` | Close the floating window |

## License

MIT
