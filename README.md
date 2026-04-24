# review.nvim 🧐

Code review annotations for codediff.nvim, optimized for AI feedback loops.

Inspired by [tuicr](https://github.com/agavra/tuicr).

## What this fork adds

Changes over [upstream](https://github.com/georgeguimaraes/review.nvim):

### Features

- **Source context in exports** — each comment carries the actual line(s) being commented on, so the LLM anchors on real code instead of bare line numbers.
- **LLM-oriented comment types** — `NOTE` (general feedback, LLM has leeway), `ISSUE` (definitive, must address), `QUESTION` (clarification; answer inline, no code changes). Replaces the human-review set (note/suggestion/issue/praise).
- **Leaner export preamble** — drops the "I reviewed your code" intro; just the type legend.

### Bug fixes

- **Wrapped comment text** — both the input popup and the rendered comment boxes word-wrap at the window width instead of clipping long comments off the right edge.

## Features

- Add comments to specific lines in diff view (Note, Issue, Question)
- Multi-line comment support with box-style virtual text display
- Comments displayed as signs, line highlights, and virtual text
- Comments persist per branch (stored in Neovim's XDG data directory: `~/.local/share/nvim/review/`)
- Auto-export comments to clipboard when closing
- Export format optimized for AI conversations
- Send comments directly to [sidekick.nvim](https://github.com/folke/sidekick.nvim) for AI chat
- Commit picker modal to select specific commits to review
- Built on top of codediff.nvim

## Requirements

- Neovim >= 0.9
- [codediff.nvim](https://github.com/esmuellert/codediff.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

## Installation

This plugin uses [semantic versioning](https://semver.org/). Pin to a tag to avoid breaking changes.

Using lazy.nvim:

```lua
{
  "jeanlucthumm/review.nvim",
  dependencies = {
    "esmuellert/codediff.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = { "Review" },
  keys = {
    { "<leader>r", "<cmd>Review<cr>", desc = "Review" },
    { "<leader>R", "<cmd>Review commits<cr>", desc = "Review commits" },
  },
  opts = {},
}
```

## Usage

```vim
:Review              " Open codediff with comment keymaps (default)
:Review open         " Same as above
:Review commits      " Select commits to review (picker modal)
:Review commits SHA  " Review a single commit (diffs SHA^ against SHA)
:Review commits REV1 REV2  " Review specific revision range (skips picker)
:Review close        " Close and export comments to clipboard
:Review export       " Export comments to clipboard
:Review preview      " Preview exported markdown in split
:Review sidekick     " Send comments to sidekick.nvim
:Review list         " List all comments
:Review clear        " Clear all comments
:Review toggle       " Toggle readonly/edit mode
```

## Workflow

Open a review with `:Review` to see your staged and unstaged changes in a side-by-side diff, or `:Review commits` if you want to pick specific commits to review. The diff opens in a new tab with a file panel on the left.

Navigate between files with `<Tab>` and `<S-Tab>`. Toggle the file panel with `f`. Press `t` to toggle between side-by-side and inline layout. Switch between the old (left) and new (right) panes with `<C-w>h` and `<C-w>l`. When you spot something worth commenting on, press `i` on the line and pick a comment type from the menu (note, issue, question). The comment renders inline as a box below the line with a sign icon in the gutter.

For multi-line comments, visually select the range first then press `i`. For file-level comments that apply to the whole file, press `F`. Comments on the left (old) side of the diff only show on that side, and same for the right (new) side.

Use `]n` and `[n` to jump between comments, `e` to edit one, `d` to delete. Press `c` to see a list of all comments across files and jump to any of them.

When you're done, press `q` to close the review. This automatically copies all your comments to the clipboard as structured markdown and shows a preview. Paste it into Claude Code, sidekick.nvim (`S`), or wherever you're chatting with an AI. The format looks like this:

```
1. **[ISSUE]** `src/api.ts:23` `const response = fetch(url);` - This endpoint doesn't handle errors
2. **[QUESTION]** `src/utils.ts:~10` `return legacy(value);` - Is this still used anywhere?
```

Lines prefixed with `~` refer to the old (left) side of the diff. Comments persist per branch, so you can close Neovim and come back to the same review later. Sessions auto-expire after 7 days.

## Keybindings (in diff view)

**Readonly mode** (default):
| Key | Action |
|-----|--------|
| `i` | Add comment (pick type from menu) |
| `d` | Delete comment at cursor |
| `e` | Edit comment at cursor |
| `c` | List all comments |
| `f` | Toggle file panel visibility |
| `R` | Toggle readonly/edit mode |
| `<Tab>` | Next file |
| `<S-Tab>` | Previous file |
| `]n` | Jump to next comment |
| `[n` | Jump to previous comment |
| `C` | Export to clipboard and show preview |
| `S` | Send comments to sidekick.nvim |
| `<C-r>` | Clear all comments |
| `q` | Close and export comments to clipboard |
| `t` | Toggle side-by-side/inline layout |
| `g?` | Show codediff help |

**Edit mode** (when `readonly = false`):
| Key | Action |
|-----|--------|
| `<localleader>cc` | Add comment (pick type from menu) |
| `<localleader>c<key>` | Add specific comment type (`<key>` is each type's configured `key`; defaults: `cn` note, `ci` issue, `cq` question) |
| `<localleader>cf` | File-level comment |
| `<localleader>cd` | Delete comment |
| `<localleader>ce` | Edit comment |

**Comment popup** (when adding/editing):
| Key | Action |
|-----|--------|
| `Enter` | Insert newline (multi-line comments supported) |
| `Ctrl+s` | Submit comment |
| `Tab` | Cycle comment type |
| `Esc` / `q` | Cancel (normal mode) |

## Configuration

All keymaps can be set to `false` to disable them.

**Keymap options**

Per-type add keymaps (`<localleader>cn`, `<localleader>ci`, `<localleader>cq` by default) are derived from each entry's `key` field in `comment_types` — they don't appear here.

| Option | Default | Action |
|--------|---------|--------|
| `add_comment` | `<localleader>cc` | Add comment, pick type (edit mode) |
| `add_file_comment` | `<localleader>cf` | Add file-level comment (edit mode) |
| `delete_comment` | `<localleader>cd` | Delete comment (edit mode) |
| `edit_comment` | `<localleader>ce` | Edit comment (edit mode) |
| `next_comment` | `]n` | Next comment |
| `prev_comment` | `[n` | Previous comment |
| `next_file` | `<Tab>` | Next file |
| `prev_file` | `<S-Tab>` | Previous file |
| `toggle_file_panel` | `f` | Toggle file panel |
| `list_comments` | `c` | List all comments |
| `export_clipboard` | `C` | Export to clipboard |
| `send_sidekick` | `S` | Send comments to sidekick |
| `clear_comments` | `<C-r>` | Clear all comments |
| `close` | `q` | Close and export |
| `toggle_readonly` | `R` | Toggle readonly/edit mode |
| `readonly_add` | `i` | Add comment (readonly mode) |
| `readonly_delete` | `d` | Delete comment (readonly mode) |
| `readonly_edit` | `e` | Edit comment (readonly mode) |
| `readonly_add_file` | `F` | File-level comment (readonly mode) |
| `show_help` | `?` | Show keymap help |
| `popup_submit` | `<C-s>` | Submit comment (popup, insert & normal) |
| `popup_cancel` | `q` | Cancel comment (popup, normal mode) |
| `popup_cycle_type` | `<Tab>` | Cycle comment type (popup) |

`comment_types` is an ordered array — the order determines both how the type picker cycles and how the legend appears in the exported markdown. Each entry needs `id`, `key`, `name`, `icon`, `description`, `hl`, `hl_link`, `line_hl`, and `line_bg`.

```lua
require("review").setup({
  comment_types = {
    {
      id = "note", key = "n", name = "Note", icon = "📝",
      description = "general feedback; you have leeway and may include suggested changes",
      hl = "ReviewNote", hl_link = "DiagnosticInfo",
      line_hl = "ReviewNoteLine", line_bg = "#0d1f28",
    },
    {
      id = "issue", key = "i", name = "Issue", icon = "⚠️",
      description = "definitive, must be addressed",
      hl = "ReviewIssue", hl_link = "DiagnosticWarn",
      line_hl = "ReviewIssueLine", line_bg = "#28250d",
    },
    {
      id = "question", key = "q", name = "Question", icon = "❓",
      description = "clarification request; answer inline, do not change code",
      hl = "ReviewQuestion", hl_link = "DiagnosticHint",
      line_hl = "ReviewQuestionLine", line_bg = "#15152a",
    },
  },
  keymaps = {
    delete_comment = "<localleader>cd",
    edit_comment = "<localleader>ce",
    next_comment = "]n",
    prev_comment = "[n",
    toggle_file_panel = "f",
  },
  codediff = {
    readonly = true,
  },
})
```

## Export Format

Comments are exported as Markdown optimized for AI consumption. Each entry carries the actual source line(s) being commented on — inline in backticks for a single line, as a blockquote block for a range — so the LLM anchors on real code instead of bare line numbers.

```markdown
Comment types: NOTE (general feedback; you have leeway and may include suggested changes), ISSUE (definitive, must be addressed), QUESTION (clarification request; answer inline, do not change code)
Lines prefixed with ~ refer to the old (left) side of the diff.

1. **[ISSUE]** `src/components/Button.tsx:23` `<button onClick={() => doThing()}>` - Wrapping onClick creates a new function every render
2. **[QUESTION]** `src/utils/api.ts:~45` `return legacyTransform(payload);` - Is this branch still reachable?
3. **[NOTE]** `src/hooks/useAuth.ts:12-18` - Consider splitting this into smaller hooks
   > function useAuth() {
   >   const [user, setUser] = useState(null);
   >   // ...
   > }
```

Lines prefixed with `~` (e.g. `:~45`) refer to the old (left) side of the diff. Range comments use `start-end` notation.

## Running Tests

```bash
make test
```

## License

Copyright 2025 George Guimarães

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
