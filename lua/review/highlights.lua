local M = {}

local config = require("review.config")

function M.setup()
  local links = {
    ReviewSign = "Comment",
    ReviewVirtText = "Comment",
    ReviewPickerHash = "Identifier",
    ReviewPickerMeta = "Comment",
    ReviewPickerSelected = "String",
    ReviewReviewed = "DiagnosticOk",
  }

  for group, link in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end

  -- Per-type groups; line highlights are a darker background, no underline
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
