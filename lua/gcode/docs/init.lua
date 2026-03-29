local M = {}

local function get_docs_dir()
  -- Always resolve relative to this file's location — works regardless of cwd or install path
  local this_file = debug.getinfo(1, "S").source:sub(2)  -- strip leading @
  local dir = vim.fn.fnamemodify(this_file, ":p:h")
  if vim.fn.isdirectory(dir) == 1 then
    return dir
  end
  return nil
end

local function load_docs()
  local docs = {}
  local docs_dir = get_docs_dir()
  if not docs_dir then
    return docs
  end

  local key_map = {
    percent = "%",
    hash = "#",
  }

  local files = vim.fn.globpath(docs_dir, "*.md", false, true)
  for _, filepath in ipairs(files) do
    local filename = vim.fn.fnamemodify(filepath, ":t:r")
    local key = key_map[filename] or filename:upper()
    local content = table.concat(vim.fn.readfile(filepath), "\n")
    docs[key] = content
  end

  return docs
end

local function add_aliases(docs)
  local aliases = {
    -- G10 variants: map G10 to L0 (most common: work coord setting)
    G10 = "G10_L0",
    -- WCS extended variants
    G54_1 = "G54",  -- Extended WCS just uses G54 as base
    G55_1 = "G55",
    G56_1 = "G56",
    -- G92 variants
    G92_1 = "G92",
    G92_2 = "G92",
    G92_3 = "G92",
    -- M codes variants
    M97 = "M98",
    M100 = "M99",
  }

  for alias, target in pairs(aliases) do
    if not docs[alias] and docs[target] then
      docs[alias] = docs[target]
    end
  end
end

M.all = load_docs()
add_aliases(M.all)

M.get = function(key)
  return M.all[key:upper()]
end

return M
