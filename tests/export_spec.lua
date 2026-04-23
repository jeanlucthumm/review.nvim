local store = require("review.store")
local export = require("review.export")

describe("review.export", function()
  before_each(function()
    store.clear()
  end)

  describe("generate_markdown", function()
    it("returns empty message when no comments", function()
      local md = export.generate_markdown()
      assert.matches("No comments yet", md)
    end)

    it("includes file and comment in output", function()
      store.add("src/main.lua", 10, "issue", "Fix this bug")

      local md = export.generate_markdown()
      assert.matches("src/main.lua:10", md)
      assert.matches("%[ISSUE%]", md)
      assert.matches("Fix this bug", md)
    end)

    it("formats comments as numbered list", function()
      store.add("a.lua", 1, "note", "Note A")
      store.add("b.lua", 1, "issue", "Issue B")
      store.add("a.lua", 5, "suggestion", "Suggestion A")

      local md = export.generate_markdown()
      assert.matches("1%. %*%*%[NOTE%]%*%*", md)
      assert.matches("2%. %*%*%[SUGGESTION%]%*%*", md)
      assert.matches("3%. %*%*%[ISSUE%]%*%*", md)
    end)

    it("uses tilde notation for old-side comments", function()
      store.add("src/main.lua", 10, "issue", "Removed bug", nil, "old")

      local md = export.generate_markdown()
      assert.matches("src/main.lua:~10", md)
    end)

    it("uses tilde on both ends for old-side range", function()
      store.add("src/main.lua", 10, "issue", "Old range", 15, "old")

      local md = export.generate_markdown()
      assert.matches("src/main.lua:~10%-~15", md)
    end)

    it("uses normal notation for new-side comments", function()
      store.add("src/main.lua", 10, "issue", "New side", nil, "new")

      local md = export.generate_markdown()
      assert.matches("src/main.lua:10", md)
      assert.not_matches("~10", md)
    end)

    it("inlines single source line with backticks", function()
      store.add("src/main.lua", 10, "issue", "Fix this", nil, "new", { "local x = 1" })

      local md = export.generate_markdown()
      assert.matches("`src/main.lua:10` `local x = 1` %- Fix this", md)
    end)

    it("renders multi-line source as blockquote continuation", function()
      store.add("src/main.lua", 10, "issue", "Fix this", 12, "new",
        { "line one", "line two", "line three" })

      local md = export.generate_markdown()
      assert.matches("`src/main.lua:10%-12` %- Fix this", md)
      assert.matches("   > line one", md)
      assert.matches("   > line two", md)
      assert.matches("   > line three", md)
    end)

    it("falls back to legacy format when source_lines missing", function()
      store.add("src/main.lua", 10, "issue", "No source")

      local md = export.generate_markdown()
      assert.matches("`src/main.lua:10` %- No source", md)
      assert.not_matches(">", md)
    end)
  end)
end)
