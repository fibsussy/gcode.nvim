local gcode = {}
local dict = require("gcode.dictionary")

-- ============================================================
-- HIGHLIGHT SETUP: register all highlight groups
-- ============================================================

local function setup_highlights()
  -- All named groups from dictionary
  for group, opts in pairs(dict.groups) do
    vim.api.nvim_set_hl(0, "@gcode." .. group, opts)
  end

  -- Baseline fallback groups
  vim.api.nvim_set_hl(0, "@gcode.g", dict.g_default)
  vim.api.nvim_set_hl(0, "@gcode.m", dict.m_default)

  -- Per-code G/M groups (strip doc_file before passing to nvim_set_hl)
  for ival, entry in pairs(dict.g_codes) do
    vim.api.nvim_set_hl(0, "@gcode.g" .. ival, { fg = entry.fg, bg = entry.bg, bold = entry.bold, italic = entry.italic })
  end
  for ival, entry in pairs(dict.m_codes) do
    vim.api.nvim_set_hl(0, "@gcode.m" .. ival, { fg = entry.fg, bg = entry.bg, bold = entry.bold, italic = entry.italic })
  end
end

-- ============================================================
-- PARSER AUTO-INSTALL: clone and build from fork
-- ============================================================

local PARSER_VERSION  = "v0.6.0"
local RELEASE_URL     = "https://github.com/fibsussy/tree-sitter-gcode/releases/download/"
local VERSION_FILE    = vim.fn.stdpath("data") .. "/gcode_parser_version"

local function installed_version()
  if vim.fn.filereadable(VERSION_FILE) == 1 then
    return vim.fn.readfile(VERSION_FILE)[1]
  end
  return nil
end

local function save_version(ver)
  vim.fn.writefile({ ver }, VERSION_FILE)
end

local function ensure_parser_and_queries()
  local data_dir    = vim.fn.stdpath("data")
  local parser_dir  = data_dir .. "/site/parser"
  local queries_dir = data_dir .. "/site/queries/gcode"
  local parser_path = parser_dir .. "/gcode.so"

  -- Download parser if missing or version changed
  if vim.fn.filereadable(parser_path) == 0 or installed_version() ~= PARSER_VERSION then
    vim.fn.mkdir(parser_dir, "p")
    local url = RELEASE_URL .. PARSER_VERSION .. "/gcode.so"
    local result = vim.fn.system({ "curl", "-fsSL", "-o", parser_path, url })
    if vim.v.shell_error ~= 0 then
      vim.notify("gcode.nvim: failed to download parser from " .. url .. "\n" .. result, vim.log.levels.ERROR)
      return
    end
    save_version(PARSER_VERSION)
    vim.notify("gcode.nvim: parser " .. PARSER_VERSION .. " installed", vim.log.levels.INFO)
  end

  -- Install queries from plugin directory (always keep up to date)
  local plugin_dir    = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h:h:h")
  local plugin_queries = plugin_dir .. "/queries/highlights.scm"
  if vim.fn.filereadable(plugin_queries) == 0 then
    plugin_queries = data_dir .. "/lazy/gcode.nvim/queries/highlights.scm"
  end
  if vim.fn.filereadable(plugin_queries) == 1 then
    vim.fn.mkdir(queries_dir, "p")
    vim.fn.system({ "cp", plugin_queries, queries_dir .. "/highlights.scm" })
  end
end

-- ============================================================
-- SETUP
-- ============================================================

local ns = vim.api.nvim_create_namespace("gcode_specific")

local function get_child(node, type_name)
  for i = 0, node:named_child_count() - 1 do
    local child = node:named_child(i)
    if child and child:type() == type_name then
      return child
    end
  end
  return nil
end

-- G codes where R is an arc/cycle parameter (same color as IJK)
local R_AS_IJK = {}
for _, n in ipairs({2, 3, 81, 82, 83, 84, 85, 86, 87, 88, 89}) do R_AS_IJK[n] = true end

-- Skip subtrees that can't contain highlight targets
local SKIP = {
  expression = true, parameter_word = true, parameter_variable = true,
  unary_expression = true, binary_expression = true,
}

local function extmark(bufnr, sr, sc, ec, hl, pri)
  vim.api.nvim_buf_set_extmark(bufnr, ns, sr, sc, { end_col = ec, hl_group = hl, priority = pri or 100 })
end

local function apply_highlights(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "gcode")
  if not ok or not parser then return end
  local tree = parser:parse()[1]
  if not tree then return end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  -- ── per-line context walk ────────────────────────────────────────────────
  -- For each line node, collect G/M codes first, then color P and R words.

  local function collect_line_gcodes(line_node)
    -- Use the FIRST known G and first known M — parameters argue the primary
    -- command, not the last one. e.g. "M3 M8 P0 R0.5": P/R argue M3 not M8.
    local first_g, first_m
    for word_node in line_node:iter_children() do
      if word_node:type() == "word" then
        local inner = word_node:named_child(0)
        if inner then
          local it = inner:type()
          if it == "g_word" and not first_g then
            local num = get_child(inner, "number")
            if num then
              local ival = math.floor(tonumber(vim.treesitter.get_node_text(num, bufnr)) or 0)
              if dict.g_codes[ival] then first_g = ival end
            end
          elseif it == "m_word" and not first_m then
            local num = get_child(inner, "number")
            if num then
              local ival = math.floor(tonumber(vim.treesitter.get_node_text(num, bufnr)) or 0)
              if dict.m_codes[ival] then first_m = ival end
            end
          end
        end
      end
    end
    return first_g, first_m
  end

  local function handle_line(line_node)
    local first_g, first_m = collect_line_gcodes(line_node)

    -- P and R inherit the first G code (primary command), else first M code.
    local param_hl = nil
    if first_g then
      param_hl = "@gcode.g" .. first_g
    elseif first_m then
      param_hl = "@gcode.m" .. first_m
    end

    -- R: green if arc/cycle G is present, otherwise inherits like P
    local r_hl = param_hl or "@gcode.other"
    if first_g and R_AS_IJK[first_g] then
      r_hl = "@gcode.ijk"
    end

    -- Line number (N10): highlight token + paint bg to end of line content
    local has_line_number = false
    for child in line_node:iter_children() do
      if child:type() == "line_number" then
        has_line_number = true
        local sr, sc, _, ec = child:range()
        extmark(bufnr, sr, sc, ec, "@gcode.n_word")
        local line_text = vim.api.nvim_buf_get_lines(bufnr, sr, sr + 1, false)[1] or ""
        local line_end = #line_text
        if line_end > 0 then
          vim.api.nvim_buf_set_extmark(bufnr, ns, sr, 0, {
            end_col = line_end,
            hl_group = "@gcode.n_word_line",
            priority = 90,
          })
        end
        break
      end
    end
    -- On N-word lines, make comments white so they're readable on the red bg
    if has_line_number then
      for child in line_node:iter_children() do
        local ct = child:type()
        if ct == "inline_comment" or ct == "eol_comment" then
          local sr, sc, _, ec = child:range()
          extmark(bufnr, sr, sc, ec, "@gcode.n_word_comment", 102)
        end
      end
    end

    for word_node in line_node:iter_children() do
      if word_node:type() == "word" then
        local inner = word_node:named_child(0)
        if inner then
          local it = inner:type()
          local sr, sc, _, ec = word_node:range()

          if it == "g_word" then
            local num = get_child(inner, "number")
            if num then
              local ival = math.floor(tonumber(vim.treesitter.get_node_text(num, bufnr)) or 0)
              if dict.g_codes[ival] then
                extmark(bufnr, sr, sc, ec, "@gcode.g" .. ival)
              end
            end

          elseif it == "m_word" then
            local num = get_child(inner, "number")
            if num then
              local ival = math.floor(tonumber(vim.treesitter.get_node_text(num, bufnr)) or 0)
              if dict.m_codes[ival] then
                extmark(bufnr, sr, sc, ec, "@gcode.m" .. ival)
              end
            end

          elseif it == "arc_word" then
            extmark(bufnr, sr, sc, ec, "@gcode.ijk")

          elseif it == "r_word" then
            extmark(bufnr, sr, sc, ec, r_hl)

          elseif it == "h_word" then
            extmark(bufnr, sr, sc, ec, "@gcode.h_word")

          elseif it == "axis_word" then
            local axis = get_child(inner, "axis_identifier")
            if axis then
              local letter = vim.treesitter.get_node_text(axis, bufnr):upper()
              extmark(bufnr, sr, sc, ec, letter == "Z" and "@gcode.axis_z" or "@gcode.axis_xy")
            end

          elseif it == "parameter_word" then
            -- P words: inherit first G/M color on the line
            local id = get_child(inner, "parameter_identifier")
            if id and vim.treesitter.get_node_text(id, bufnr):lower() == "p" and param_hl then
              extmark(bufnr, sr, sc, ec, param_hl)
            end
          end
        end
      end
    end
  end

  -- ── comment walk (unchanged logic, global) ───────────────────────────────
  local function walk_comments(node)
    local t = node:type()
    if SKIP[t] then return end

    if t == "ic_debug_keyword" or t == "ic_msg_keyword" then
      local txt = vim.treesitter.get_node_text(node, bufnr)
      local sr, sc = node:range()
      local kw = (t == "ic_debug_keyword") and "DEBUG" or "MSG"
      local hl = (t == "ic_debug_keyword") and "@gcode.debug_keyword" or "@gcode.msg_keyword"
      local offset = txt:lower():find(kw:lower(), 1, true)
      if offset then
        extmark(bufnr, sr, sc + offset - 1, sc + offset - 1 + #kw, hl, 101)
      end

    elseif t == "ic_message" then
      local parent = node:parent()
      local kw_node = parent and (get_child(parent, "ic_debug_keyword") or get_child(parent, "ic_msg_keyword"))
      if kw_node then
        local hl = (kw_node:type() == "ic_debug_keyword") and "@gcode.debug_message" or "@gcode.msg_message"
        local sr, sc, _, ec = node:range()
        extmark(bufnr, sr, sc, ec, hl, 101)
      end

    elseif t == "eol_comment_content" then
      local txt = vim.treesitter.get_node_text(node, bufnr)
      local kw, msg = txt:match("^%s*(DEBUG)%s*,%s*(.*%S)")
      if not kw then kw, msg = txt:match("^%s*(MSG)%s*,%s*(.*%S)") end
      if kw and msg then
        local sr, sc = node:range()
        local kw_off  = txt:lower():find(kw:lower(), 1, true)
        local msg_off = txt:find(msg, 1, true)
        extmark(bufnr, sr, sc + kw_off - 1,  sc + kw_off  - 1 + #kw,  (kw == "DEBUG") and "@gcode.debug_keyword" or "@gcode.msg_keyword",  101)
        extmark(bufnr, sr, sc + msg_off - 1, sc + msg_off - 1 + #msg, (kw == "DEBUG") and "@gcode.debug_message"  or "@gcode.msg_message",  101)
      end
    end

    for child in node:iter_children() do walk_comments(child) end
  end

  -- Walk the whole tree looking for line nodes (handles ERROR wrapper and nested structure)
  local function walk_tree(node)
    local t = node:type()
    if t == "line" then
      handle_line(node)
      walk_comments(node)
    elseif t == "outside_program" then
      -- Don't recurse — highlighted via scm query as dimmed text
      return
    elseif t == "program_marker" then
      -- % marker: bold bright red, just the % character itself
      local sr, sc = node:range()
      extmark(bufnr, sr, sc, sc + 1, "@gcode.program_marker")
    else
      for child in node:iter_children() do
        walk_tree(child)
      end
      walk_comments(node)
    end
  end

  walk_tree(tree:root())
end

local function attach(bufnr)
  pcall(vim.treesitter.start, bufnr, "gcode")
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = bufnr,
    callback = function()
      vim.schedule(function() apply_highlights(bufnr) end)
    end,
  })
  apply_highlights(bufnr)
end

function gcode.debug_line()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  -- Show extmarks on current line
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, {row, 0}, {row, -1}, {details=true})
  if #marks == 0 then
    print("NO extmarks on line " .. row .. " in gcode ns")
  else
    for _, m in ipairs(marks) do
      print(("extmark col=%d-%d hl=%s"):format(m[3], m[4].end_col, tostring(m[4].hl_group)))
    end
  end

  -- Walk tree for this line
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "gcode")
  if not ok or not parser then print("no parser"); return end
  local tree = parser:parse()[1]
  if not tree then print("no tree"); return end

  local function find_lines(node)
    local t = node:type()
    local sr = node:range()
    if t == "line" and sr == row then
      print("TREE line found at row " .. row)
      for word_node in node:iter_children() do
        if word_node:type() == "word" then
          local inner = word_node:named_child_count() > 0 and word_node:named_child(0) or nil
          local it = inner and inner:type() or "nil"
          if it == "g_word" then
            local num = get_child(inner, "number")
            local txt = num and vim.treesitter.get_node_text(num, bufnr) or "nil"
            local ival = tonumber(txt) and math.floor(tonumber(txt)) or nil
            print(("  g_word num=%s ival=%s in_dict=%s R_AS_IJK=%s"):format(txt, tostring(ival), tostring(ival and dict.g_codes[ival] ~= nil), tostring(ival and R_AS_IJK[ival])))
          elseif it == "r_word" then
            local _, sc, _, ec = word_node:range()
            print(("  r_word at col %d-%d"):format(sc, ec))
          else
            print("  word inner=" .. it)
          end
        end
      end
      return true
    end
    for child in node:iter_children() do
      if find_lines(child) then return true end
    end
  end
  if not find_lines(tree:root()) then
    print("No line node found at row " .. row .. " (check for ERROR wrapper)")
    -- dump root children types
    for child in tree:root():iter_children() do
      local t = child:type()
      local sr, sc, er, ec = child:range()
      print(("  root child: type=%s rows=%d-%d"):format(t, sr, er))
    end
  end
end

function gcode.setup()
  local ok, _ = pcall(require, "nvim-treesitter")
  if not ok then return end

  if gcode._setup_done then return end
  gcode._setup_done = true

  setup_highlights()
  ensure_parser_and_queries()

  local parser_path = vim.fn.stdpath("data") .. "/site/parser/gcode.so"
  if vim.fn.filereadable(parser_path) == 0 then return end

  pcall(vim.treesitter.language.register, "gcode", "gcode")

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "gcode" then attach(ev.buf) end
    end,
  })

  attach(vim.api.nvim_get_current_buf())
end

-- ============================================================
-- HOVER
-- ============================================================

local WORD_TYPES = {
  g_word = true, m_word = true, f_word = true, s_word = true,
  t_word = true, h_word = true, arc_word = true, r_word = true,
  axis_word = true, other_word = true,
  o_word = true,
  line_number = true,
  parameter_word = true, parameter_variable = true,
  regular_comment = true, keyword_comment = true,
  eol_comment = true, eol_comment_content = true,
  ["%"] = true,
}

function gcode.hover()
  local ok, err = pcall(function()
    local bufnr = vim.api.nvim_get_current_buf()
    local row = vim.fn.line(".") - 1
    local col = vim.fn.col(".") - 1
    local docs = require("gcode.docs")

    local parser = vim.treesitter.get_parser(bufnr, "gcode")
    if not parser then
      vim.notify("gcode hover: no treesitter parser", vim.log.levels.WARN)
      return
    end
    local tree = parser:parse()[1]
    if not tree then
      vim.notify("gcode hover: no parse tree", vim.log.levels.WARN)
      return
    end

    -- Find the node under cursor, then walk up/down to find the inner word type
    local node = tree:root():named_descendant_for_range(row, col, row, col)
    if not node then
      vim.notify("gcode hover: no node at cursor", vim.log.levels.WARN)
      return
    end

    -- Walk up the tree to find a known word type
    local inner = node
    while inner and not WORD_TYPES[inner:type()] do
      inner = inner:parent()
    end

    if not inner then
      -- Try children of the node (cursor might be on 'word' wrapper)
      for child in node:iter_children() do
        if WORD_TYPES[child:type()] then
          inner = child
          break
        end
      end
    end

    if not inner then
      vim.notify("gcode hover: not on a word (node=" .. node:type() .. ")", vim.log.levels.INFO)
      return
    end

    local t = inner:type()
    local doc_key = nil

    if t == "g_word" then
      local num = get_child(inner, "number")
      if not num then
        vim.notify("gcode hover: g_word has no number child", vim.log.levels.WARN)
        return
      end
      local txt = vim.treesitter.get_node_text(num, bufnr)
      local ival = math.floor(tonumber(txt) or 0)
      local entry = dict.g_codes[ival]
      -- Prefer decimal-variant file (g54_1), then entry's doc_file, then plain integer
      local decimal_file = "g" .. txt:gsub("%.", "_"):lower()
      if docs.get(decimal_file) then
        doc_key = decimal_file
      elseif entry and entry.doc_file then
        doc_key = entry.doc_file
      else
        doc_key = "g" .. ival
      end

    elseif t == "m_word" then
      local num = get_child(inner, "number")
      if not num then
        vim.notify("gcode hover: m_word has no number child", vim.log.levels.WARN)
        return
      end
      local txt = vim.treesitter.get_node_text(num, bufnr)
      local ival = math.floor(tonumber(txt) or 0)
      local entry = dict.m_codes[ival]
      doc_key = (entry and entry.doc_file) or ("m" .. ival)

    elseif t == "f_word" then  doc_key = "f"
    elseif t == "s_word" then  doc_key = "s"
    elseif t == "t_word" then  doc_key = "t"
    elseif t == "h_word" then  doc_key = "h"
    elseif t == "r_word" then  doc_key = "r"

    elseif t == "arc_word" then
      local txt = vim.treesitter.get_node_text(inner, bufnr)
      doc_key = txt:sub(1, 1):lower()

    elseif t == "axis_word" then
      local axis = get_child(inner, "axis_identifier")
      if axis then
        doc_key = vim.treesitter.get_node_text(axis, bufnr):lower()
      end

    elseif t == "o_word" then
      doc_key = "o"

    elseif t == "line_number" then
      doc_key = "n"

    elseif t == "parameter_word" or t == "parameter_variable" then
      -- P words: try to show the doc for the first G/M on this line (context hover)
      -- Walk up to find the containing line node
      local id = get_child(inner, "parameter_identifier")
      if id and vim.treesitter.get_node_text(id, bufnr):lower() == "p" then
        local line_node = inner:parent()
        while line_node and line_node:type() ~= "line" do
          line_node = line_node:parent()
        end
        if line_node then
          -- Find first G/M on the line
          for wn in line_node:iter_children() do
            if wn:type() == "word" then
              local winn = wn:named_child(0)
              if winn then
                local wt = winn:type()
                if wt == "g_word" then
                  local num = get_child(winn, "number")
                  if num then
                    local txt = vim.treesitter.get_node_text(num, bufnr)
                    local ival = math.floor(tonumber(txt) or 0)
                    local entry = dict.g_codes[ival]
                    local decimal_file = "g" .. txt:gsub("%.", "_"):lower()
                    if docs.get(decimal_file) then
                      doc_key = decimal_file
                    elseif entry and entry.doc_file then
                      doc_key = entry.doc_file
                    end
                  end
                  break
                elseif wt == "m_word" then
                  local num = get_child(winn, "number")
                  if num then
                    local ival = math.floor(tonumber(vim.treesitter.get_node_text(num, bufnr)) or 0)
                    local entry = dict.m_codes[ival]
                    if entry and entry.doc_file then doc_key = entry.doc_file end
                  end
                  break
                end
              end
            end
          end
        end
      end
      -- Fallback: show parameter/hash doc
      if not doc_key then doc_key = "hash" end

    elseif t == "regular_comment" or t == "keyword_comment"
        or t == "eol_comment" or t == "eol_comment_content" then
      return  -- no hover on comments

    elseif t == "%" then
      doc_key = "percent"
    end

    if not doc_key then
      vim.notify("gcode hover: no doc_key for node type " .. t, vim.log.levels.INFO)
      return
    end

    local content = docs.get(doc_key)
    if not content or content == "" then return end

    -- Determine the highlight group for the hovered word (same color it has in the buffer)
    local word_hl = nil
    if t == "g_word" then
      local num = get_child(inner, "number")
      if num then
        local ival = math.floor(tonumber(vim.treesitter.get_node_text(num, bufnr)) or 0)
        if dict.g_codes[ival] then
          word_hl = "@gcode.g" .. ival
        else
          word_hl = "@gcode.g"
        end
      end
    elseif t == "m_word" then
      local num = get_child(inner, "number")
      if num then
        local ival = math.floor(tonumber(vim.treesitter.get_node_text(num, bufnr)) or 0)
        if dict.m_codes[ival] then
          word_hl = "@gcode.m" .. ival
        else
          word_hl = "@gcode.m"
        end
      end
    elseif t == "f_word"             then word_hl = "@gcode.feed"
    elseif t == "s_word"             then word_hl = "@gcode.spindle"
    elseif t == "t_word"             then word_hl = "@gcode.tool"
    elseif t == "h_word"             then word_hl = "@gcode.h_word"
    elseif t == "arc_word"           then word_hl = "@gcode.ijk"
    elseif t == "r_word"             then word_hl = "@gcode.r_word"
    elseif t == "o_word"             then word_hl = "@gcode.subroutine"
    elseif t == "line_number"        then word_hl = "@gcode.n_word"
    elseif t == "parameter_word"
        or t == "parameter_variable" then word_hl = "@gcode.param"
    elseif t == "%"                  then word_hl = "@gcode.program_marker"
    elseif t == "axis_word" then
      local axis = get_child(inner, "axis_identifier")
      if axis then
        local letter = vim.treesitter.get_node_text(axis, bufnr):upper()
        word_hl = (letter == "Z") and "@gcode.axis_z" or "@gcode.axis_xy"
      end
    end

    local lines = vim.split(content, "\n")
    local float_bufnr, _ = vim.lsp.util.open_floating_preview(
      lines,
      "markdown",
      { focusable = false, border = "rounded" }
    )

    -- Color the first markdown heading to match the word's highlight
    if word_hl and float_bufnr and vim.api.nvim_buf_is_valid(float_bufnr) then
      local float_ns = vim.api.nvim_create_namespace("gcode_hover")
      for i, line in ipairs(lines) do
        if line:match("^#+ ") then
          -- Color everything after the leading `# ` markers
          local hashes, rest = line:match("^(#+%s)(.*)")
          if rest then
            local start_col = #hashes
            vim.api.nvim_buf_set_extmark(float_bufnr, float_ns, i - 1, start_col, {
              end_col = #line,
              hl_group = word_hl,
              priority = 200,
            })
          end
          break
        end
      end
    end
  end)

  if not ok then
    vim.notify("gcode hover error: " .. tostring(err), vim.log.levels.ERROR)
  end
end

return gcode