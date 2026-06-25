local M = {}

local config

function M.set_config(cfg)
  config = cfg
end

local function db_path()
  return config.db_file or vim.fn.expand("~/Documents/glossator.sqlite3")
end

local function esc(s)
  if not s then return "NULL" end
  return "'" .. s:gsub("'", "''") .. "'"
end

local function sqlite(sql)
  local path = db_path()
  local cmd = string.format('sqlite3 -json -bail "%s" %s', path, vim.fn.shellescape(sql))
  local result = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("[glossator] sqlite3 error (exit " .. vim.v.shell_error .. ")", vim.log.levels.WARN)
  end
  return result:gsub("^%s+", ""):gsub("%s+$", "")
end

function M.is_available()
  local result = vim.fn.system("which sqlite3 2>/dev/null"):gsub("%s+$", "")
  return result ~= ""
end

function M.init()
  if not M.is_available() then
    vim.notify("[glossator] sqlite3 CLI not found", vim.log.levels.ERROR)
    return false
  end

  sqlite([[
CREATE TABLE IF NOT EXISTS links (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    glossator_id TEXT NOT NULL UNIQUE,
    notes_path   TEXT NOT NULL,
    markdown_path TEXT,
    created_at   TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at   TEXT
);
  ]])

  return true
end

function M.get_notes_path(glossator_id)
  local json = sqlite("SELECT notes_path FROM links WHERE glossator_id = " .. esc(glossator_id) .. ";")
  if json == "" then return nil end
  local ok, data = pcall(vim.json.decode, json)
  if not ok or not data or #data == 0 then return nil end
  return data[1].notes_path
end

function M.upsert_link(glossator_id, notes_path, markdown_path)
  local escaped_notes = esc(notes_path)
  local escaped_md = esc(markdown_path)
  sqlite(string.format(
    "INSERT INTO links (glossator_id, notes_path, markdown_path) VALUES (%s, %s, %s) "
    .. "ON CONFLICT(glossator_id) DO UPDATE SET notes_path = %s, markdown_path = %s, updated_at = datetime('now');",
    esc(glossator_id), escaped_notes, escaped_md, escaped_notes, escaped_md
  ))
end

return M
