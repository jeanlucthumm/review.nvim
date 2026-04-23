local M = {}

---Normalize a file path for consistent storage/lookup
---@param path string
---@return string
function M.normalize_path(path)
  if not path then
    return path
  end
  path = path:gsub("^%./", "")
  path = path:gsub("/+$", "")
  return path
end

---Format a comment's source location as displayed in pickers and exports:
---  "path" for file-level, "path:~N" for old side, "path:N-M" for ranges, etc.
---@param comment Comment
---@return string
function M.format_location(comment)
  if comment.line == 0 then
    return comment.file
  end
  local is_old = (comment.side or "new") == "old"
  local prefix = is_old and "~" or ""
  if comment.line_end and comment.line_end ~= comment.line then
    return string.format("%s:%s%d-%s%d", comment.file, prefix, comment.line, prefix, comment.line_end)
  end
  return string.format("%s:%s%d", comment.file, prefix, comment.line)
end

return M
