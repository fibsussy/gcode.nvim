local gcode = {}
local treesitter = require("gcode.treesitter")

function gcode.setup_treesitter()
  treesitter.setup()
end

function gcode.hover()
  treesitter.hover()
end

function gcode.debug_line()
  treesitter.debug_line()
end

return gcode