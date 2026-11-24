local H = dofile("tests/helpers.lua")
local eq, expect_truthy = H.eq, H.expect_truthy

local marks = require("review.marks")
local wrap_paragraph = marks._test.wrap_paragraph
local build_comment_box = marks._test.build_comment_box

local T = MiniTest.new_set()

T["wrap_paragraph"] = MiniTest.new_set()

T["wrap_paragraph"]["keeps short text on one line"] = function()
  eq(wrap_paragraph("hello world", 40), { "hello world" })
end

T["wrap_paragraph"]["packs words greedily up to max_width"] = function()
  eq(wrap_paragraph("aaa bbb ccc", 7), { "aaa bbb", "ccc" })
end

T["wrap_paragraph"]["lets a word longer than max_width overflow"] = function()
  eq(wrap_paragraph("short thisWordIsLongerThanTheLimit end", 10), { "short", "thisWordIsLongerThanTheLimit", "end" })
end

T["wrap_paragraph"]["empty input is one empty line"] = function()
  eq(wrap_paragraph("", 20), { "" })
end

T["wrap_paragraph"]["collapses runs of whitespace"] = function()
  eq(wrap_paragraph("alpha    beta", 40), { "alpha beta" })
end

T["build_comment_box"] = MiniTest.new_set()

local function content_rows(virt_lines)
  local rows = {}
  for i = 2, #virt_lines - 1 do
    table.insert(rows, (virt_lines[i][1][1]:match("^│ (.-) │$"):gsub("%s+$", "")))
  end
  return rows
end

T["build_comment_box"]["wraps long text within the box"] = function()
  local long = "This is a fairly long comment that should span more than one row inside the box when the wrap width is tight."
  local rows = content_rows(build_comment_box(long, "Note", "ReviewNote", 30))
  expect_truthy(#rows >= 2)
  for _, row in ipairs(rows) do
    expect_truthy(#row <= 30)
  end
  eq(table.concat(rows, " "), long)
end

T["build_comment_box"]["wraps each paragraph independently"] = function()
  local rows = content_rows(build_comment_box("short first line\nThis second paragraph is longer and wraps on its own.", "Issue", "ReviewIssue", 25))
  eq(rows[1], "short first line")
  expect_truthy(#rows >= 3)
end

T["build_comment_box"]["keeps a minimum content width of 20"] = function()
  local inner = build_comment_box("hi", "Note", "ReviewNote", 80)[1][1][1]:match("^╭─(.-)╮$")
  expect_truthy(vim.fn.strdisplaywidth(inner) >= 20)
end

return T
