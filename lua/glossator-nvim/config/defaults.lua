---@class GlossatorConfig
---@field notes_dir?     string  Directory for annotation files (default: "~/Documents/glossator")
---@field resolve?       fun(filepath:string):string  Custom function to resolve annotation file paths
---@field hl_tags?       GlossatorTag[]   Highlight tags (background color)
---@field ul_tags?       GlossatorTag[]   Underline tags
---@field toolbar_hl?    { [string]: vim.api.keyset.highlight }  Toolbar highlight groups
---@field fmt_actions?   GlossatorAction[]  Formatting actions
---@field par_actions?   GlossatorAction[]  Wrapping actions

---@class GlossatorTag
---@field key   string   Keyboard key in toolbar
---@field tag   string   Inline tag string (e.g. "[hr]")
---@field group string   Highlight group name
---@field hl    table    Highlight definition

---@class GlossatorAction
---@field key   string     Keyboard key in toolbar
---@field label string     Display label
---@field wrap  string[]   Opening and closing tag pair

local M = {}

M.notes_dir = vim.fn.expand("~/Documents/glossator")
M.db_file = vim.fn.expand("~/Documents/glossator.sqlite3")

M.hl_tags = {
  { key = "r", tag = "[hr]", group = "ETRed",    hl = { bg = "#a02b2b", fg = "#ffffff" } },
  { key = "g", tag = "[hg]", group = "ETGreen",  hl = { bg = "#0f700c", fg = "#ffffff" } },
  { key = "b", tag = "[hb]", group = "ETBlue",   hl = { bg = "#2b6ba0", fg = "#ffffff" } },
  { key = "y", tag = "[hy]", group = "ETYellow", hl = { bg = "#b5a40c", fg = "#ffffff" } },
  { key = "p", tag = "[hp]", group = "ETPurple", hl = { bg = "#25184c", fg = "#ffffff" } },
}

M.ul_tags = {
  { key = "R", tag = "[ur]", group = "ETRedUL",    hl = { underline = true, sp = "#a02b2b" } },
  { key = "G", tag = "[ug]", group = "ETGreenUL",  hl = { underline = true, sp = "#0f700c" } },
  { key = "B", tag = "[ub]", group = "ETBlueUL",   hl = { underline = true, sp = "#2b6ba0" } },
  { key = "Y", tag = "[uy]", group = "ETYellowUL", hl = { underline = true, sp = "#ddce23" } },
  { key = "P", tag = "[up]", group = "ETPurpleUL", hl = { underline = true, sp = "#7c5cbf" } },
}

M.toolbar_hl = {
  ETHeader     = { fg = "#7f849c", bold = true },
  ETKey        = { fg = "#cdd6f4", bold = true },
  ETSep        = { fg = "#45475a" },
  ETAnnotateID = { fg = "#00ffff", bold = true },
  ETComment    = { fg = "#6c7086", italic = true },
  ETAnnotate   = { underline = true, sp = "#00ffff" },
}

M.fmt_actions = {
  { key = "i", label = "Italic", wrap = { "*",  "*"  } },
  { key = "f", label = "Bold",   wrap = { "**", "**" } },
  { key = "s", label = "Strike", wrap = { "~~", "~~" } },
}

M.par_actions = {
  { key = '"', label = '""', wrap = { '"', '"' } },
  { key = "'", label = "''", wrap = { "'", "'" } },
  { key = "(", label = "()", wrap = { "(", ")" } },
  { key = "[", label = "[]", wrap = { "[", "]" } },
  { key = "{", label = "{}", wrap = { "{", "}" } },
}

return M
