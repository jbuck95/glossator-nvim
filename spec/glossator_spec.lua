describe("glossator-nvim", function()
  it("module loads without error", function()
    assert.has.no.errors(function()
      require("glossator-nvim")
    end)
  end)

  it("has public API functions", function()
    local m = require("glossator-nvim")
    assert.is_function(m.setup)
    assert.is_function(m.load_highlights)
    assert.is_function(m.open_toolbar)
    assert.is_function(m.open_glossator)
    assert.is_function(m.close_glossator)
  end)

  it("defaults are returned by config module", function()
    local defaults = require("glossator-nvim.config.defaults")
    assert.is_table(defaults.hl_tags)
    assert.are.equal(5, #defaults.hl_tags)
    assert.is_table(defaults.ul_tags)
    assert.are.equal(5, #defaults.ul_tags)
    assert.is_table(defaults.toolbar_hl)
    assert.is_table(defaults.fmt_actions)
    assert.are.equal(3, #defaults.fmt_actions)
    assert.is_table(defaults.par_actions)
    assert.are.equal(5, #defaults.par_actions)
    assert.is_string(defaults.notes_dir)
  end)

  describe("setup", function()
    it("accepts empty opts", function()
      local m = require("glossator-nvim")
      assert.has.no.errors(function()
        m.setup({})
      end)
    end)

    it("merges user config with defaults", function()
      local m = require("glossator-nvim")
      m.setup({
        hl_tags = {
          { key = "x", tag = "[hx]", group = "ETCustom", hl = { bg = "#ff0000", fg = "#ffffff" } },
        },
      })
      -- After setup, open_toolbar should work
      assert.has.no.errors(function()
        vim.cmd("enew")
        vim.cmd("set ft=markdown")
        m.load_highlights()
      end)
    end)
  end)

  describe("pane management", function()
    local temp_file

    before_each(function()
      temp_file = vim.fn.tempname() .. ".md"
      vim.cmd("edit " .. temp_file)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# Title", "Some content" })
      vim.cmd("write")
    end)

    after_each(function()
      local m = require("glossator-nvim")
      m.close_glossator()
      vim.cmd("silent! bwipeout! " .. temp_file)
      vim.fn.delete(temp_file)
    end)

    it("opens glossator notes pane alongside main buffer", function()
      local m = require("glossator-nvim")
      local main_win = vim.api.nvim_get_current_win()
      m.open_glossator()

      local wins = vim.api.nvim_tabpage_list_wins(0)
      assert.are.equal(2, #wins)
      assert.are.equal(main_win, vim.api.nvim_get_current_win())
    end)

    it("switches to notes pane when open_glossator called from main buffer while open", function()
      local m = require("glossator-nvim")
      local main_win = vim.api.nvim_get_current_win()
      m.open_glossator()
      assert.are.equal(main_win, vim.api.nvim_get_current_win())

      m.open_glossator()
      local current_win = vim.api.nvim_get_current_win()
      assert.are_not.equal(main_win, current_win)
    end)

    it("closes notes pane and returns to main buffer when open_glossator called from notes buffer", function()
      local m = require("glossator-nvim")
      local main_win = vim.api.nvim_get_current_win()
      m.open_glossator()
      -- Switch to notes pane
      m.open_glossator()
      assert.are_not.equal(main_win, vim.api.nvim_get_current_win())

      -- Calling open_glossator from inside the notes pane should close it
      m.open_glossator()

      local wins = vim.api.nvim_tabpage_list_wins(0)
      assert.are.equal(1, #wins)
      assert.are.equal(main_win, vim.api.nvim_get_current_win())
    end)

    it("close_glossator closes the notes window and returns to main window", function()
      local m = require("glossator-nvim")
      local main_win = vim.api.nvim_get_current_win()
      m.open_glossator()
      assert.are.equal(2, #vim.api.nvim_tabpage_list_wins(0))

      m.close_glossator()
      assert.are.equal(1, #vim.api.nvim_tabpage_list_wins(0))
      assert.are.equal(main_win, vim.api.nvim_get_current_win())
    end)

    it("does not create a nested notes pane for a notes file", function()
      local m = require("glossator-nvim")
      local notes_file = vim.fn.tempname() .. ".notes.md"
      vim.cmd("edit " .. notes_file)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Note content" })

      local win_count_before = #vim.api.nvim_tabpage_list_wins(0)
      m.open_glossator()
      local win_count_after = #vim.api.nvim_tabpage_list_wins(0)

      assert.are.equal(win_count_before, win_count_after)
      vim.cmd("silent! bwipeout! " .. notes_file)
      vim.fn.delete(notes_file)
    end)
  end)

  describe("health check", function()
    it("runs without error", function()
      local health = require("glossator-nvim.health")
      assert.has.no.errors(function()
        health.check()
      end)
    end)
  end)
end)
