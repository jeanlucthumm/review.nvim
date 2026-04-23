local M = {}

local config = require("review.config")

function M.setup()
  -- Shared (non-per-type) highlight groups
  local shared = {
    ReviewSign = "Comment",
    ReviewVirtText = "Comment",
    ReviewPickerHash = "Identifier",
    ReviewPickerMeta = "Comment",
    ReviewPickerSelected = "String",
  }
  for group, link in pairs(shared) do
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end

  -- Per-type highlights driven from the configured comment_types list
  for _, t in ipairs(config.get().comment_types) do
    vim.api.nvim_set_hl(0, t.hl, { link = t.hl_link, default = true })
    vim.api.nvim_set_hl(0, t.line_hl, { bg = t.line_bg, underline = false, default = true })
  end

  vim.fn.sign_define("ReviewComment", {
    text = "●",
    texthl = "ReviewSign",
  })
end

return M
