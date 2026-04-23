local marks = require("review.marks")
local wrap_paragraph = marks._test.wrap_paragraph
local build_comment_box = marks._test.build_comment_box

describe("marks wrap_paragraph", function()
  it("keeps short text on a single line", function()
    local lines = wrap_paragraph("hello world", 40)
    assert.same({ "hello world" }, lines)
  end)

  it("wraps at word boundaries when exceeding max_width", function()
    local lines = wrap_paragraph("the quick brown fox jumps over the lazy dog", 20)
    for _, line in ipairs(lines) do
      assert.is_true(#line <= 20, "line too long: " .. line)
      assert.is_nil(line:match("^%s"), "leading whitespace: " .. line)
      assert.is_nil(line:match("%s$"), "trailing whitespace: " .. line)
    end
    assert.equals("the quick brown fox jumps over the lazy dog", table.concat(lines, " "))
  end)

  it("preserves words that are longer than max_width (overflow)", function()
    local lines = wrap_paragraph("short thisWordIsLongerThanTheLimit end", 10)
    -- The long word should not be broken apart
    local joined = table.concat(lines, " ")
    assert.equals("short thisWordIsLongerThanTheLimit end", joined)
    local found_long = false
    for _, line in ipairs(lines) do
      if line == "thisWordIsLongerThanTheLimit" then
        found_long = true
      end
    end
    assert.is_true(found_long)
  end)

  it("returns a single empty line for empty input", function()
    local lines = wrap_paragraph("", 20)
    assert.same({ "" }, lines)
  end)

  it("collapses runs of whitespace between words", function()
    local lines = wrap_paragraph("alpha    beta", 40)
    assert.same({ "alpha beta" }, lines)
  end)

  it("packs words greedily up to max_width", function()
    -- "aaa bbb ccc" → widths 3+1+3+1+3 = 11; limit 7 → "aaa bbb" then "ccc"
    local lines = wrap_paragraph("aaa bbb ccc", 7)
    assert.same({ "aaa bbb", "ccc" }, lines)
  end)
end)

describe("marks build_comment_box", function()
  local function content_rows(virt_lines)
    -- Strip top/bottom borders, return inner text lines with borders removed.
    local rows = {}
    for i = 2, #virt_lines - 1 do
      local chunk = virt_lines[i][1][1]
      -- "│ <content> │" → <content> (trimmed of box-aligned trailing spaces)
      local inner = chunk:match("^│ (.-) │$")
      table.insert(rows, inner)
    end
    return rows
  end

  it("wraps long comment text into multiple rows within the box", function()
    local long = "This is a fairly long comment that should definitely span more than one row inside the rendered box when the wrap width is tight."
    local virt_lines = build_comment_box(long, "Note", "ReviewNote", 30)

    -- At least 3 virtual lines: top border + >=2 content rows + bottom border
    assert.is_true(#virt_lines >= 4, "expected multiple content rows, got " .. #virt_lines)

    local rows = content_rows(virt_lines)
    assert.is_true(#rows >= 2, "expected at least 2 wrapped rows")
    for _, r in ipairs(rows) do
      -- Inner trimmed text must fit within the wrap width
      local trimmed = r:gsub("%s+$", "")
      assert.is_true(#trimmed <= 30, "row exceeds wrap width: '" .. trimmed .. "'")
    end
    -- Rows joined with spaces should reconstruct the original (modulo collapsed whitespace)
    local joined = table.concat(vim.tbl_map(function(r) return (r:gsub("%s+$", "")) end, rows), " ")
    assert.equals(long, joined)
  end)

  it("preserves explicit newlines and wraps each paragraph independently", function()
    local text = "short first line\nThis second paragraph is longer and should wrap on its own."
    local virt_lines = build_comment_box(text, "Issue", "ReviewIssue", 25)
    local rows = content_rows(virt_lines)

    assert.equals("short first line", (rows[1]:gsub("%s+$", "")))
    assert.is_true(#rows >= 2, "expected at least 2 rows for a second paragraph")
  end)

  it("keeps a minimum content width of 20 even for short text", function()
    local virt_lines = build_comment_box("hi", "Note", "ReviewNote", 80)
    -- Top border includes "╭─[NOTE]" prefix then dashes then "╮"
    local top = virt_lines[1][1][1]
    -- Width check: top border length should reflect content_width >= 20
    -- inner content width = count of ─ and header chars between ╭─ and ╮
    local inner = top:match("^╭─(.-)╮$")
    assert.is_not_nil(inner)
    assert.is_true(vim.fn.strdisplaywidth(inner) >= 20, "box too narrow: " .. vim.fn.strdisplaywidth(inner))
  end)
end)
