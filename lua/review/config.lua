local M = {}

---@class ReviewConfig
---@field comment_types CommentType[] ordered; a configured list replaces the default one
---@field keymaps ReviewKeymaps
---@field branch { base: string|nil, pick_base: boolean }
---@field export ReviewExportConfig
---@field codediff ReviewCodediffConfig

---@class ReviewExportConfig
---@field header string|nil header block prepended to exported markdown; nil derives it from comment_types
---@field clipboard boolean copy the markdown to the + and * registers
---@field on_export nil|fun(markdown: string, comments: Comment[]) called on every export
---@field clear_on_close boolean archive and clear comments when the review closes (q)

---@class CommentType
---@field id string stored on comments
---@field key string single-char keymap suffix (`<localleader>c<key>`)
---@field name string display name
---@field icon string
---@field description string one-line purpose, rendered in the export header
---@field hl string highlight group for virt text / sign
---@field hl_link string group that `hl` links to by default
---@field line_hl string highlight group for the line background
---@field line_bg string default line background color

---@class ReviewKeymaps
---@field add_comment string|false
---@field delete_comment string|false
---@field edit_comment string|false
---@field next_comment string|false
---@field prev_comment string|false
---@field list_comments string|false
---@field export_clipboard string|false
---@field send_sidekick string|false
---@field clear_comments string|false
---@field close string|false
---@field toggle_readonly string|false
---@field next_file string|false
---@field prev_file string|false
---@field toggle_file_panel string|false
---@field readonly_add string|false
---@field readonly_delete string|false
---@field readonly_edit string|false
---@field readonly_add_file string|false
---@field add_file_comment string|false
---@field popup_submit string|false
---@field popup_cancel string|false
---@field show_help string|false
---@field popup_cycle_type string|false
---@field toggle_reviewed string|false
---@field readonly_toggle_reviewed string|false

---@class ReviewCodediffConfig
---@field readonly boolean

---@type ReviewConfig
M.defaults = {
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
    -- Edit mode (leader-based). Per-type add keymaps are derived from
    -- `comment_types[i].key` as `<localleader>c<key>`.
    add_comment = "<localleader>cc",
    add_file_comment = "<localleader>cf",
    toggle_reviewed = "<localleader>cr",
    delete_comment = "<localleader>cd",
    edit_comment = "<localleader>ce",
    -- Navigation
    next_comment = "]n",
    prev_comment = "[n",
    next_file = "<Tab>",
    prev_file = "<S-Tab>",
    toggle_file_panel = "f",
    -- Common actions
    list_comments = "c",
    export_clipboard = "C",
    send_sidekick = "S",
    clear_comments = "<C-r>",
    close = "q",
    toggle_readonly = "R",
    -- Readonly mode (simple keys)
    readonly_add = "i",
    readonly_delete = "d",
    readonly_edit = "e",
    readonly_add_file = "F",
    readonly_toggle_reviewed = "r",
    -- Help
    show_help = "?",
    -- Popup keymaps
    popup_submit = "<C-s>",
    popup_cancel = "q",
    popup_cycle_type = "<Tab>",
  },
  branch = {
    base = nil, -- automatic base for :Review branch; nil detects origin/HEAD, main, or master
    pick_base = false, -- open a second branch picker for the base
  },
  export = {
    header = nil, -- nil lists comment_types with their descriptions
    clipboard = true, -- copy exported markdown to the clipboard
    on_export = nil, -- function(markdown, comments) for tmux, an agent, a file...
    clear_on_close = true, -- q exports, archives and clears; C only exports
  },
  codediff = {
    readonly = true,
  },
}

---@type ReviewConfig
M.config = vim.deepcopy(M.defaults)

---@param opts? ReviewConfig
function M.setup(opts)
  -- deepcopy: tbl_deep_extend assigns nested tables by reference when only
  -- one side has them, so edits to config.get() would leak into the defaults
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  -- Lists merge by index under tbl_deep_extend; a configured type list replaces the default
  if opts and opts.comment_types then
    M.config.comment_types = vim.deepcopy(opts.comment_types)
  end
end

---@return ReviewConfig
function M.get()
  return M.config
end

---@param id string
---@return CommentType|nil
function M.get_type(id)
  return M.config.comment_types[M.get_type_index(id)]
end

---@param id string
---@return number|nil position in comment_types
function M.get_type_index(id)
  for i, t in ipairs(M.config.comment_types) do
    if t.id == id then
      return i
    end
  end
  return nil
end

return M
