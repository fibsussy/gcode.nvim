; G-code treesitter highlights
; Maps to specific highlight groups registered in Lua

; Content outside % markers — dimmed
(outside_program) @gcode.outside_program

; Program markers
(program_marker) @gcode.program_marker

; EOL comments
(eol_comment) @gcode.comment

; All inline comments default to gray
(inline_comment) @gcode.paren_comment

; keyword_comment base color - Lua walk handles exact keyword/message ranges
(keyword_comment) @gcode.paren_comment

; Line numbers handled via extmarks in Lua (needs line_hl_group for full bg)

; G-codes
(word (g_word (number))) @gcode.g

; M-codes
(word (m_word)) @gcode.m

; Tooling
(word (t_word)) @gcode.tool

; Spindle & Feed
(word (s_word)) @gcode.spindle
(word (f_word)) @gcode.feed

; Parameters
(parameter_word) @gcode.param
(parameter_variable) @gcode.param

; Axes (Z overridden to @gcode.axis_z via extmarks in Lua)
(word (axis_word)) @gcode.axis_xy
(indexed_axis_word) @gcode.axis_xy

; O-words
(word (o_word)) @gcode.subroutine

; Arc offset words (I, J, K), radius (R), and tool height (H)
(word (arc_word)) @gcode.ijk
(word (r_word)) @gcode.r_word
(word (h_word)) @gcode.h_word

; Other
(checksum) @gcode.checksum
(word (polar_distance)) @gcode.other
(word (polar_angle)) @gcode.other
(word (spindle_select)) @gcode.other
(word (other_word)) @gcode.other
