local H = dofile("tests/helpers.lua")
local eq, expect_match = H.eq, H.expect_match

local store = require("review.store")
local storage = require("review.storage")
local config = require("review.config")
local export = require("review.export")
local review = require("review")

local codediff_args

local function read(path)
  return table.concat(vim.fn.readfile(path), "\n")
end

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      store.clear()
      config.setup()
      vim.env.REVIEW_BASE = nil
      vim.env.REVIEW_EXPORT_FILE = nil
      -- Stand-ins for codediff so opening a review records its :CodeDiff args
      codediff_args = nil
      package.loaded["codediff"] = {}
      vim.api.nvim_create_user_command("CodeDiff", function(opts)
        codediff_args = opts.fargs
      end, { nargs = "*" })
    end,
    post_case = function()
      package.loaded["codediff"] = nil
      pcall(vim.api.nvim_del_user_command, "CodeDiff")
      vim.env.REVIEW_BASE = nil
      vim.env.REVIEW_EXPORT_FILE = nil
      vim.fn.delete(storage.archive_dir(), "rf")
    end,
  },
})

T["export.to_file"] = MiniTest.new_set()

T["export.to_file"]["writes the comments as markdown"] = function()
  store.add("src/main.lua", 10, "issue", "Fix this bug")
  local path = vim.fn.tempname()
  eq(export.to_file(path), true)
  expect_match(read(path), "`src/main.lua:10` - Fix this bug", true)
end

T["export.to_file"]["writes a clean-review marker when there are no comments"] = function()
  local path = vim.fn.tempname()
  eq(export.to_file(path), true)
  expect_match(read(path), "No comments")
end

T[":Review workspace"] = MiniTest.new_set()

T[":Review workspace"]["errors without a base revision"] = function()
  local notified = {}
  local orig_notify = vim.notify
  vim.notify = function(msg, level)
    table.insert(notified, { msg = msg, level = level })
  end
  review.open_workspace()
  vim.notify = orig_notify
  eq(#notified, 1)
  expect_match(notified[1].msg, "No base revision")
  eq(codediff_args, nil)
end

T[":Review workspace"]["diffs the working tree against $REVIEW_BASE"] = function()
  vim.env.REVIEW_BASE = "abc123"
  review.open_workspace()
  eq(codediff_args, { "abc123" })
end

T["export file"] = MiniTest.new_set()

T["export file"]["is not written before a review opened"] = function()
  local path = vim.fn.tempname()
  vim.env.REVIEW_EXPORT_FILE = path
  package.loaded["review"] = nil -- fresh instance: no review opened yet
  require("review")._write_export_file()
  package.loaded["review"] = review
  eq(vim.fn.filereadable(path), 0)
end

T["export file"]["is written once, then the comments are archived and cleared"] = function()
  local path = vim.fn.tempname()
  vim.env.REVIEW_EXPORT_FILE = path
  vim.env.REVIEW_BASE = "abc123"
  review.open_workspace()
  store.add("src/main.lua", 10, "issue", "Fix this bug")

  review._write_export_file()
  expect_match(read(path), "Fix this bug", true)
  eq(store.count(), 0)
  eq(vim.fn.filereadable(storage.get_storage_path()), 0)

  -- A later exit (VimLeavePre) must not overwrite the handoff with "No comments"
  review._write_export_file()
  expect_match(read(path), "Fix this bug", true)
end

return T
