local gcode = require("gcode")

local function setup_gcode()
  vim.keymap.set({ "n", "x" }, "K", function()
    gcode.hover()
  end, { buffer = true, desc = "G-code hover documentation" })

  vim.api.nvim_create_user_command("GcodeMath", function(opts)
    gcode.math(opts, opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", range = true })

  vim.keymap.set({ "n", "x" }, "[o", function()
    gcode.jump_to_sub("prev")
  end, { buffer = true, desc = "Jump to previous subroutine" })

  vim.keymap.set({ "n", "x" }, "]o", function()
    gcode.jump_to_sub("next")
  end, { buffer = true, desc = "Jump to next subroutine" })

  vim.keymap.set({ "n", "x" }, "%", function()
    gcode.jump_to_percent()
  end, { buffer = true, desc = "Jump matching (extends % for G-code)" })

  vim.keymap.set("n", "gd", function()
    gcode.goto_def()
  end, { buffer = true, desc = "Go to subroutine definition" })
end

if vim.bo.filetype == "gcode" then
  setup_gcode()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gcode",
  callback = setup_gcode,
})
