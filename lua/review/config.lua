local M = {}

---@class ReviewConfig
---@field comment_types CommentType[]
---@field keymaps ReviewKeymaps
---@field codediff ReviewCodediffConfig

---@class CommentType
---@field id string unique identifier stored on comments
---@field key string single-char keymap suffix (`<localleader>c<key>`)
---@field name string display name
---@field icon string
---@field description string one-line purpose, rendered in the export preamble
---@field hl string highlight group name for virt text / sign
---@field hl_link string highlight group that `hl` links to by default
---@field line_hl string highlight group name for line background
---@field line_bg string line background color

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
    -- Help
    show_help = "?",
    -- Popup keymaps
    popup_submit = "<C-s>",
    popup_cancel = "q",
    popup_cycle_type = "<Tab>",
  },
  codediff = {
    readonly = true,
  },
}

---@type ReviewConfig
M.config = vim.deepcopy(M.defaults)

---@param opts? ReviewConfig
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

---@return ReviewConfig
function M.get()
  return M.config
end

---Look up a comment type by id.
---@param id string
---@return CommentType|nil
function M.get_type(id)
  for _, t in ipairs(M.config.comment_types) do
    if t.id == id then
      return t
    end
  end
  return nil
end

---Look up a comment type's position (1-indexed) in `comment_types` by id.
---@param id string
---@return number|nil
function M.get_type_index(id)
  for i, t in ipairs(M.config.comment_types) do
    if t.id == id then
      return i
    end
  end
  return nil
end

return M
