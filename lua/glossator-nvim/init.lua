local M = {}

local api = vim.api
local fn = vim.fn

-- ── 1. Toolbar: Definitionen & Config ─────────────────────────────────────────

local ns_toolbar = api.nvim_create_namespace("glossator")

local hl_tags = {}
local ul_tags = {}
local toolbar_hl = {}
local fmt_actions = {}
local par_actions = {}
local tag_to_group = {}

local cs_state = {
  main_buf = nil,
  notes_buf = nil,
  main_win = nil,
  notes_win = nil,
  syncing = false
}

-- ── 2. Toolbar: Rendering & Logik ─────────────────────────────────────────────

local function set_highlights()
  for _, t in ipairs(hl_tags) do api.nvim_set_hl(0, t.group, t.hl) end
  for _, t in ipairs(ul_tags) do api.nvim_set_hl(0, t.group, t.hl) end
  for group, hl in pairs(toolbar_hl) do api.nvim_set_hl(0, group, hl) end
end

function M.load_highlights()
  set_highlights()
  local bufnr = api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then return end
  
  api.nvim_buf_clear_namespace(bufnr, ns_toolbar, 0, -1)

  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text  = table.concat(lines, "\n")

  local function byte_to_pos(byte_pos)
    local line_num = 0
    local col = byte_pos - 1
    local acc = 0
    for i, line in ipairs(lines) do
      local line_len = #line + 1
      if acc + line_len > byte_pos - 1 then
        line_num = i - 1
        col = byte_pos - 1 - acc
        break
      end
      acc = acc + line_len
    end
    return line_num, col
  end

  local pos = 1
  while true do
    local s1, e1 = text:find("%[[hu][rgybp]%]", pos)
    local s2, e2 = text:find("%[a%d+%]", pos)
    
    local os, oe, is_anno
    
    if s1 and s2 then
      if s1 < s2 then os, oe, is_anno = s1, e1, false else os, oe, is_anno = s2, e2, true end
    elseif s1 then
      os, oe, is_anno = s1, e1, false
    elseif s2 then
      os, oe, is_anno = s2, e2, true
    else
      break
    end
    
    local tag_content = text:sub(os, oe)
    local cs, ce = text:find(tag_content, oe + 1, true)
    
    if not cs then break end

    if is_anno then
        local ol, oc   = byte_to_pos(os)
        local oel, oec = byte_to_pos(oe + 1)
        local cl, cc   = byte_to_pos(cs)
        local cel, cec = byte_to_pos(ce + 1)
        
        local group = "ETAnnotate"

        if oel == cl then
            api.nvim_buf_set_extmark(bufnr, ns_toolbar, oel, oec, { end_line = cl, end_col = cc, hl_group = group, priority = 200 })
        else
            api.nvim_buf_set_extmark(bufnr, ns_toolbar, oel, oec, { end_line = oel, end_col = #lines[oel + 1], hl_group = group, priority = 200 })
            for l = oel + 1, cl - 1 do
                api.nvim_buf_set_extmark(bufnr, ns_toolbar, l, 0, { end_line = l, end_col = #lines[l + 1], hl_group = group, priority = 200 })
            end
            api.nvim_buf_set_extmark(bufnr, ns_toolbar, cl, 0, { end_line = cl, end_col = cc, hl_group = group, priority = 200 })
        end

        api.nvim_buf_set_extmark(bufnr, ns_toolbar, ol, oc, { end_line = oel, end_col = oec, conceal = "", priority = 201 })
        api.nvim_buf_set_extmark(bufnr, ns_toolbar, cl, cc, { end_line = cel, end_col = cec, conceal = "", priority = 201 })

    else
        local group = tag_to_group[tag_content]
        if group then
            local ol, oc   = byte_to_pos(os)
            local oel, oec = byte_to_pos(oe + 1)
            local cl, cc   = byte_to_pos(cs)
            local cel, cec = byte_to_pos(ce + 1)

            if oel == cl then
                api.nvim_buf_set_extmark(bufnr, ns_toolbar, oel, oec, { end_line = cl, end_col = cc, hl_group = group, priority = 200 })
            else
                api.nvim_buf_set_extmark(bufnr, ns_toolbar, oel, oec, { end_line = oel, end_col = #lines[oel + 1], hl_group = group, priority = 200 })
                for l = oel + 1, cl - 1 do
                api.nvim_buf_set_extmark(bufnr, ns_toolbar, l, 0, { end_line = l, end_col = #lines[l + 1], hl_group = group, priority = 200 })
                end
                api.nvim_buf_set_extmark(bufnr, ns_toolbar, cl, 0, { end_line = cl, end_col = cc, hl_group = group, priority = 200 })
            end

            api.nvim_buf_set_extmark(bufnr, ns_toolbar, ol, oc, { end_line = oel, end_col = oec, conceal = "", priority = 201 })
            api.nvim_buf_set_extmark(bufnr, ns_toolbar, cl, cc, { end_line = cel, end_col = cec, conceal = "", priority = 201 })
        end
    end
    pos = ce + 1
  end

  -- Kommentare highlighten
  local c_pos = 1
  while true do
    local s, e = text:find("%( ✐ .- %)", c_pos)
    if not s then break end
    local sl, sc = byte_to_pos(s)
    local el, ec = byte_to_pos(e + 1)
    api.nvim_buf_set_extmark(bufnr, ns_toolbar, sl, sc, { end_line = el, end_col = ec, hl_group = "ETComment", priority = 190 })
    c_pos = e + 1
  end
end

local function get_sel()
  local s = fn.getpos("'<")
  local e = fn.getpos("'>")
  return s[2], e[2], s[3], e[3]
end

local function apply_tag(tag)
  local bufnr = api.nvim_get_current_buf()
  local sl, el, sc, ec = get_sel()
  if ec == 2147483647 then local line = api.nvim_buf_get_lines(bufnr, el - 1, el, false)[1]; ec = #line end

  if sl == el then
    local line = api.nvim_buf_get_lines(bufnr, sl - 1, sl, false)[1]
    ec = math.min(ec, #line)
    api.nvim_buf_set_lines(bufnr, sl - 1, sl, false, { line:sub(1, sc - 1) .. tag .. line:sub(sc, ec) .. tag .. line:sub(ec + 1) })
  else
    local ls = api.nvim_buf_get_lines(bufnr, sl - 1, el, false)
    ec = math.min(ec, #ls[#ls])
    ls[1] = ls[1]:sub(1, sc - 1) .. tag .. ls[1]:sub(sc)
    ls[#ls] = ls[#ls]:sub(1, ec) .. tag .. ls[#ls]:sub(ec + 1)
    api.nvim_buf_set_lines(bufnr, sl - 1, el, false, ls)
  end
  vim.defer_fn(M.load_highlights, 10)
end

local function get_next_id(bufnr)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local text = table.concat(lines, "\n")
    local max_id = 0
    for id in text:gmatch("%[a(%d+)%]") do
        local n = tonumber(id)
        if n > max_id then max_id = n end
    end
    return max_id + 1
end

local function apply_annotate()
  local bufnr = api.nvim_get_current_buf()
  local sl, el, sc, ec = get_sel()
  if ec == 2147483647 then local line = api.nvim_buf_get_lines(bufnr, el - 1, el, false)[1]; ec = #line end

  vim.ui.input({ prompt = "Annotation (to Glossator): " }, function(input)
    if not input or input == "" then return end
    
    local new_id = get_next_id(bufnr)
    local tag = "[a" .. new_id .. "]"
    
    if sl == el then
      local line = api.nvim_buf_get_lines(bufnr, sl - 1, sl, false)[1]
      local new_line = line:sub(1, sc - 1) .. tag .. line:sub(sc, ec) .. tag .. line:sub(ec + 1)
      api.nvim_buf_set_lines(bufnr, sl - 1, sl, false, { new_line })
    else
      local ls = api.nvim_buf_get_lines(bufnr, sl - 1, el, false)
      ec = math.min(ec, #ls[#ls])
      ls[1] = ls[1]:sub(1, sc - 1) .. tag .. ls[1]:sub(sc)
      ls[#ls] = ls[#ls]:sub(1, ec) .. tag .. ls[#ls]:sub(ec + 1)
      api.nvim_buf_set_lines(bufnr, sl - 1, el, false, ls)
    end
    
    if cs_state.notes_buf and api.nvim_buf_is_valid(cs_state.notes_buf) then
        local target_line_idx = sl - 1
        local notes_count = api.nvim_buf_line_count(cs_state.notes_buf)
        if target_line_idx >= notes_count then
             local diff = target_line_idx - notes_count + 1
             local empty_lines = {}
             for _ = 1, diff do table.insert(empty_lines, "") end
             api.nvim_buf_set_lines(cs_state.notes_buf, notes_count, notes_count, false, empty_lines)
        end
        local current_note_line = api.nvim_buf_get_lines(cs_state.notes_buf, target_line_idx, target_line_idx + 1, false)[1] or ""
        local separator = (current_note_line:match("%S")) and " " or ""
        local new_note_line = current_note_line .. separator .. tag .. " ( ✐ " .. input .. " )"
        api.nvim_buf_set_lines(cs_state.notes_buf, target_line_idx, target_line_idx + 1, false, { new_note_line })
    end
    vim.defer_fn(M.load_highlights, 10)
  end)
end

local function apply_wrap(o, c)
  local bufnr = api.nvim_get_current_buf()
  local sl, el, sc, ec = get_sel()
  if ec == 2147483647 then local line = api.nvim_buf_get_lines(bufnr, el - 1, el, false)[1]; ec = #line end
  if sl == el then
    local line = api.nvim_buf_get_lines(bufnr, sl - 1, sl, false)[1]
    ec = math.min(ec, #line)
    api.nvim_buf_set_lines(bufnr, sl - 1, sl, false, { line:sub(1, sc - 1) .. o .. line:sub(sc, ec) .. c .. line:sub(ec + 1) })
  else
    local ls = api.nvim_buf_get_lines(bufnr, sl - 1, el, false)
    ec = math.min(ec, #ls[#ls])
    ls[1] = ls[1]:sub(1, sc - 1) .. o .. ls[1]:sub(sc)
    ls[#ls] = ls[#ls]:sub(1, ec) .. c .. ls[#ls]:sub(ec + 1)
    api.nvim_buf_set_lines(bufnr, sl - 1, el, false, ls)
  end
end

local function strip_all_marks()
  local bufnr = api.nvim_get_current_buf()
  local filepath = api.nvim_buf_get_name(bufnr)

  vim.ui.select({ "Yes", "No" }, { prompt = "Strip ALL marks & annotations? " }, function(choice)
    if choice ~= "Yes" then return end

    if filepath ~= "" then
      local backup = filepath .. ".bak"
      local src = io.open(filepath, "rb")
      if src then
        local data = src:read("*a"); src:close()
        local dst = io.open(backup, "wb")
        if dst then dst:write(data); dst:close()
          vim.notify("Backup: " .. backup, vim.log.levels.INFO)
        end
      end
    end

    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local new_lines = {}
    for _, line in ipairs(lines) do
      line = line:gsub("%[[hu][rgybp]%]", "")
      line = line:gsub("%[a%d+%]", "")
      table.insert(new_lines, line)
    end
    api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
    vim.defer_fn(M.load_highlights, 10)
  end)
end

local function open_toolbar()
  local target_buf = api.nvim_get_current_buf()
  local buf = api.nvim_create_buf(false, true)
  local sep = " │ "
  local pad = " "
  local l1, l2 = pad, pad
  local highlights = {}

  local function add_section(header, items, is_color, is_ul)
    local keys_str = ""
    local col_map = {}
    for i, item in ipairs(items) do
      local k = item.key
      local start_byte = #keys_str
      keys_str = keys_str .. k
      if is_color then
        table.insert(col_map, { s=start_byte, e=start_byte+#k, g=item.group })
      elseif is_ul then
        local solid_group = item.group:gsub("UL", "")
        table.insert(col_map, { s=start_byte, e=start_byte+#k, g=solid_group })
      else
        table.insert(col_map, { s=start_byte, e=start_byte+#k, g="ETKey" })
      end
      if i < #items then keys_str = keys_str .. " " end
    end
    local max_len = math.max(#header, #keys_str)
    local h_pad = max_len - #header
    local k_pad = max_len - #keys_str
    local h_left = math.floor(h_pad / 2)
    local k_left = math.floor(k_pad / 2)
    l1 = l1 .. string.rep(" ", h_left) .. header .. string.rep(" ", h_pad - h_left)
    l2 = l2 .. string.rep(" ", k_left)
    local current_k_pos = #l2
    l2 = l2 .. keys_str
    for _, map in ipairs(col_map) do
        table.insert(highlights, { map.g, 1, current_k_pos + map.s, current_k_pos + map.e })
    end
    l2 = l2 .. string.rep(" ", k_pad - k_left)
  end

  add_section("FMT", fmt_actions, false, false); l1 = l1 .. sep; l2 = l2 .. sep
  add_section("WRAP", par_actions, false, false); l1 = l1 .. sep; l2 = l2 .. sep
  add_section("HIGHLIGHT", hl_tags, true, false); l1 = l1 .. sep; l2 = l2 .. sep
  add_section("UNDERLINE", ul_tags, false, true); l1 = l1 .. sep; l2 = l2 .. sep

  l1 = l1 .. " NOTE  │  DEL "
  l2 = l2 .. "  a    │   d  "

  api.nvim_buf_set_lines(buf, 0, -1, false, { l1, l2 })
  api.nvim_buf_add_highlight(buf, -1, "ETHeader", 0, 0, -1)
  for _, h in ipairs(highlights) do
    api.nvim_buf_add_highlight(buf, -1, h[1], h[2], h[3], h[4])
  end

  local win = api.nvim_open_win(buf, true, {
    relative = "editor", row = 0, col = 0, width = vim.o.columns, height = 2,
    style = "minimal", border = "none", zindex = 1000
  })
  api.nvim_set_option_value("winblend", 0, { win = win })
  api.nvim_set_option_value("winhl", "Normal:NormalFloat", { win = win })

  local function close_and_run(func)
    if api.nvim_win_is_valid(win) then api.nvim_win_close(win, true) end
    api.nvim_set_current_buf(target_buf)
    func()
  end
  local opts = { buffer = buf, nowait = true }

  local all_actions = {}
  for _, t in ipairs(fmt_actions) do table.insert(all_actions, { k=t.key, f=function() apply_wrap(t.wrap[1], t.wrap[2]) end }) end
  for _, t in ipairs(par_actions) do table.insert(all_actions, { k=t.key, f=function() apply_wrap(t.wrap[1], t.wrap[2]) end }) end
  for _, t in ipairs(hl_tags)     do table.insert(all_actions, { k=t.key, f=function() apply_tag(t.tag) end }) end
  for _, t in ipairs(ul_tags)     do table.insert(all_actions, { k=t.key, f=function() apply_tag(t.tag) end }) end

  for _, action in ipairs(all_actions) do
    vim.keymap.set("n", action.k, function() close_and_run(action.f) end, opts)
  end
  vim.keymap.set("n", "a", function() close_and_run(apply_annotate) end, opts)
  vim.keymap.set("n", "d", function() close_and_run(strip_all_marks) end, opts)
  vim.keymap.set("n", "q", function() api.nvim_win_close(win, true) end, opts)
  vim.keymap.set("n", "<Esc>", function() api.nvim_win_close(win, true) end, opts)
end

M.open_toolbar = open_toolbar

-- ── 3. Glossator Definitionen & State ──────────────────────────────────────────

local ns_glossator = api.nvim_create_namespace("glossatorHeaderTracking")

-- Wird in setup() mit opts befüllt
local resolve

local function is_valid_sync_context()
  local curr_win = api.nvim_get_current_win()
  local curr_buf = api.nvim_get_current_buf()
  if curr_win == cs_state.main_win and curr_buf == cs_state.main_buf then return true end
  if curr_win == cs_state.notes_win and curr_buf == cs_state.notes_buf then return true end
  return false
end

-- ── 4. glossator: Logik ─────────────────────────────────────────────────────────

local function align_by_headers()
  if not cs_state.notes_buf or not api.nvim_buf_is_valid(cs_state.notes_buf) then return end

  api.nvim_buf_clear_namespace(cs_state.notes_buf, ns_glossator, 0, -1)
  local notes_lines = api.nvim_buf_get_lines(cs_state.notes_buf, 0, -1, false)
  local note_header_map = {}

  for i, line in ipairs(notes_lines) do
    if line:match("^#+%s+") then
      local id = api.nvim_buf_set_extmark(cs_state.notes_buf, ns_glossator, i - 1, 0, {})
      note_header_map[line] = id
    end
  end

  local main_lines = api.nvim_buf_get_lines(cs_state.main_buf, 0, -1, false)
  local changed = false

  for i, line in ipairs(main_lines) do
    if line:match("^#+%s+") then
      local target_row = i - 1
      local mark_id = note_header_map[line]

      if mark_id then
        local mark_pos = api.nvim_buf_get_extmark_by_id(cs_state.notes_buf, ns_glossator, mark_id, {})

        if mark_pos and #mark_pos > 0 then
          local current_note_row = mark_pos[1]
          local diff = target_row - current_note_row

          if diff > 0 then
            local empty_lines = {}
            for _ = 1, diff do table.insert(empty_lines, "") end
            api.nvim_buf_set_lines(cs_state.notes_buf, current_note_row, current_note_row, false, empty_lines)
            changed = true
          elseif diff < 0 then
            local count = math.abs(diff)
            local start_del = math.max(0, current_note_row - count)
            local check_lines = api.nvim_buf_get_lines(cs_state.notes_buf, start_del, current_note_row, false)
            local safe_to_delete = true
            for _, l in ipairs(check_lines) do
              if l ~= "" then safe_to_delete = false; break end
            end
            if safe_to_delete then
              api.nvim_buf_set_lines(cs_state.notes_buf, start_del, current_note_row, false, {})
              changed = true
            end
          end
        end
      end
    end
  end
end

local function sync_notes_reorder()
  if not cs_state.notes_buf or not api.nvim_buf_is_valid(cs_state.notes_buf) then return end

  local main_lines = api.nvim_buf_get_lines(cs_state.main_buf, 0, -1, false)
  local notes_lines = api.nvim_buf_get_lines(cs_state.notes_buf, 0, -1, false)

  local id_to_content = {}
  for _, line in ipairs(notes_lines) do
    local id = line:match("%[a(%d+)%]")
    if id then
      id_to_content[tonumber(id)] = line
    end
  end

  local new_notes_lines = {}
  local seen_ids = {} 

  for i, m_line in ipairs(main_lines) do
    local id_str = m_line:match("%[a(%d+)%]")
    
    if id_str then
      local id = tonumber(id_str)
      if not seen_ids[id] then
          seen_ids[id] = true 
          
          local content = id_to_content[id]
          if not content then
            content = "[a" .. id .. "] ( ✐ )"
          end

          while #new_notes_lines < i - 1 do
            table.insert(new_notes_lines, "")
          end
          new_notes_lines[i] = content
      else
          local existing_note = notes_lines[i] or ""
          if existing_note:match("%[a%d+%]") then
            new_notes_lines[i] = ""
          else
            new_notes_lines[i] = existing_note
          end
      end
    else
      local existing_note = notes_lines[i] or ""
      if existing_note:match("%[a%d+%]") then
        new_notes_lines[i] = ""
      else
        new_notes_lines[i] = existing_note
      end
    end
  end

  if #new_notes_lines > 0 then
      local current_len = api.nvim_buf_line_count(cs_state.notes_buf)
      if #new_notes_lines > current_len then
        local empty = {}
        for _ = 1, (#new_notes_lines - current_len) do table.insert(empty, "") end
        api.nvim_buf_set_lines(cs_state.notes_buf, current_len, current_len, false, empty)
      end
      
      for i, line in ipairs(new_notes_lines) do
        local old_line = notes_lines[i] or ""
        if line ~= old_line then
            api.nvim_buf_set_lines(cs_state.notes_buf, i - 1, i, false, { line })
        end
      end
  end
end

local function sync_cursor()
  if cs_state.syncing then return end
  if not is_valid_sync_context() then return end

  local curr_win = api.nvim_get_current_win()
  local target_win = (curr_win == cs_state.main_win) and cs_state.notes_win or cs_state.main_win

  if target_win and api.nvim_win_is_valid(target_win) then
    if api.nvim_win_get_buf(target_win) ~= (target_win == cs_state.main_win and cs_state.main_buf or cs_state.notes_buf) then
      return
    end
    local cursor = api.nvim_win_get_cursor(curr_win)
    pcall(api.nvim_win_set_cursor, target_win, cursor)
  end
end

local function sync_scroll()
  if not api.nvim_win_is_valid(cs_state.main_win) or not api.nvim_win_is_valid(cs_state.notes_win) then return end
  if not is_valid_sync_context() then return end

  local curr_win = api.nvim_get_current_win()
  local target_win = (curr_win == cs_state.main_win) and cs_state.notes_win or cs_state.main_win
  
  local target_buf = api.nvim_win_get_buf(target_win)
  local expected_target_buf = (target_win == cs_state.main_win) and cs_state.main_buf or cs_state.notes_buf
  
  if target_buf ~= expected_target_buf then return end

  local info = fn.getwininfo(curr_win)[1]
  if info then
    api.nvim_win_call(target_win, function()
      fn.winrestview({ topline = info.topline })
    end)
  end
end

local function adjust_length_on_edit()
  if cs_state.syncing or not api.nvim_buf_is_valid(cs_state.main_buf) then return end
  if api.nvim_buf_get_lines(cs_state.notes_buf, 0, 1, false) == nil then return end

  cs_state.syncing = true
  local main_count = api.nvim_buf_line_count(cs_state.main_buf)
  local notes_count = api.nvim_buf_line_count(cs_state.notes_buf)

  if main_count > notes_count then
    local diff = main_count - notes_count
    local empty_lines = {}
    for _ = 1, diff do table.insert(empty_lines, "") end
    api.nvim_buf_set_lines(cs_state.notes_buf, notes_count, notes_count, false, empty_lines)
  end
  cs_state.syncing = false
end

function M.open_glossator()
  local current_file = api.nvim_buf_get_name(0)
  if current_file == "" then
    vim.notify("glossator: Cannot sync an unnamed buffer.", vim.log.levels.WARN)
    return
  end

  local notes_file = resolve(current_file)

  cs_state.main_win = api.nvim_get_current_win()
  cs_state.main_buf = api.nvim_get_current_buf()

  vim.cmd("rightbelow vsplit " .. fn.fnameescape(notes_file))
  cs_state.notes_win = api.nvim_get_current_win()
  cs_state.notes_buf = api.nvim_get_current_buf()

  api.nvim_buf_set_option(cs_state.notes_buf, 'filetype', 'markdown')
  api.nvim_win_set_option(cs_state.notes_win, 'wrap', true) 

  local opts = { buffer = cs_state.notes_buf, noremap = true, silent = true }

  vim.keymap.set('i', '<CR>', function()
    local line = fn.line('.')
    local last_line = api.nvim_buf_line_count(cs_state.main_buf)
    return line < last_line and '<Esc>jA' or '<CR>'
  end, { buffer = cs_state.notes_buf, expr = true })

  vim.keymap.set('n', 'dd', function()
    api.nvim_set_current_line('')
  end, opts)

  align_by_headers()
  adjust_length_on_edit()

  local group = api.nvim_create_augroup("glossator_Session", { clear = true })
  api.nvim_create_autocmd("WinScrolled", { group = group, callback = sync_scroll })
  api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, { group = group, callback = sync_cursor })
  
  api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, { 
    group = group, 
    buffer = cs_state.main_buf, 
    callback = adjust_length_on_edit 
  })
  
  api.nvim_create_autocmd("BufWritePost", {
    group = group,
    buffer = cs_state.main_buf,
    callback = function()
      adjust_length_on_edit()
      align_by_headers()
      sync_notes_reorder()
    end
  })

  api.nvim_set_current_win(cs_state.main_win)
end

-- ── 5. Setup & Init ───────────────────────────────────────────────────────────

function M.setup(opts)
  opts = opts or {}

  -- resolve aufbauen: notes_dir > custom resolve > hardcoded default
  local default_dir = opts.notes_dir
    and fn.expand(opts.notes_dir)
    or fn.expand("~/Documents/glossator")

  resolve = function(filepath)
    if fn.isdirectory(default_dir) == 0 then fn.mkdir(default_dir, "p") end
    local safe_name = filepath:gsub("[^%w%.]", "_")
    return default_dir .. "/" .. safe_name .. ".notes.md"
  end

  if opts.resolve then resolve = opts.resolve end

  -- Farb-Tags (überschreibbar via glossator-nvim.lua)
  hl_tags = opts.hl_tags or {
    { key = "r", tag = "[hr]", group = "ETRed",    hl = { bg = "#a02b2b", fg = "#ffffff" } },
    { key = "g", tag = "[hg]", group = "ETGreen",  hl = { bg = "#0f700c", fg = "#ffffff" } },
    { key = "b", tag = "[hb]", group = "ETBlue",   hl = { bg = "#2b6ba0", fg = "#ffffff" } },
    { key = "y", tag = "[hy]", group = "ETYellow", hl = { bg = "#b5a40c", fg = "#ffffff" } },
    { key = "p", tag = "[hp]", group = "ETPurple", hl = { bg = "#25184c", fg = "#ffffff" } },
  }

  ul_tags = opts.ul_tags or {
    { key = "R", tag = "[ur]", group = "ETRedUL",    hl = { underline = true, sp = "#a02b2b" } },
    { key = "G", tag = "[ug]", group = "ETGreenUL",  hl = { underline = true, sp = "#0f700c" } },
    { key = "B", tag = "[ub]", group = "ETBlueUL",   hl = { underline = true, sp = "#2b6ba0" } },
    { key = "Y", tag = "[uy]", group = "ETYellowUL", hl = { underline = true, sp = "#ddce23" } },
    { key = "P", tag = "[up]", group = "ETPurpleUL", hl = { underline = true, sp = "#7c5cbf" } },
    { key = "a", tag = "ANT",  group = "ETAnnotate", hl = { underline = true, sp = "#00ffff" } },
  }

  toolbar_hl = opts.toolbar_hl or {
    ETHeader     = { fg = "#7f849c", bold = true },
    ETKey        = { fg = "#cdd6f4", bold = true },
    ETSep        = { fg = "#45475a" },
    ETAnnotateID = { fg = "#00ffff", bold = true },
    ETComment    = { fg = "#6c7086", italic = true },
  }

  fmt_actions = opts.fmt_actions or {
    { key = "i", label = "Italic", wrap = { "*",  "*"  } },
    { key = "f", label = "Bold",   wrap = { "**", "**" } },
    { key = "s", label = "Strike", wrap = { "~~", "~~" } },
  }

  par_actions = opts.par_actions or {
    { key = '"', label = '""', wrap = { '"', '"' } },
    { key = "'", label = "''", wrap = { "'", "'" } },
    { key = "(", label = "()", wrap = { "(", ")" } },
    { key = "[", label = "[]", wrap = { "[", "]" } },
    { key = "{", label = "{}", wrap = { "{", "}" } },
  }

  -- tag_to_group neu aufbauen
  tag_to_group = {}
  for _, t in ipairs(hl_tags) do tag_to_group[t.tag] = t.group end
  for _, t in ipairs(ul_tags) do tag_to_group[t.tag] = t.group end

  set_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
  vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI", "BufEnter", "InsertLeave" }, {
    pattern = "*.md", callback = M.load_highlights,
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown", callback = function() vim.opt_local.conceallevel = 2 end,
  })
  vim.keymap.set("v", "<Plug>(GlossatorToolbar)", function()
    local esc = api.nvim_replace_termcodes("<Esc>", true, false, true)
    api.nvim_feedkeys(esc, "x", false)
    vim.schedule(open_toolbar)
  end, { desc = "Glossator: open toolbar" })
  vim.keymap.set("n", "<Plug>(GlossatorPane)", M.open_glossator, { desc = "Glossator: open pane" })

  api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(ev)
      if not vim.fn.hasmapto("<Plug>(GlossatorToolbar)", "v") then
        vim.keymap.set("v", "<leader>e",  "<Plug>(GlossatorToolbar)", { buffer = ev.buf, desc = "Glossator: toolbar" })
      end
      if not vim.fn.hasmapto("<Plug>(GlossatorPane)", "n") then
        vim.keymap.set("n", "<leader>gs", "<Plug>(GlossatorPane)",    { buffer = ev.buf, desc = "Glossator: pane" })
      end
    end,
  })
end

return M
