if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "gcode"

syntax case ignore

" ============================================================
" COMMENTS
" ============================================================

syntax match gcodeLineComment /;.*$/ display
syntax match gcodeOpenParen /(/ display
syntax match gcodeDebugKeyword /DEBUG/ contained display
syntax match gcodeDebugText /,\s*[^)]*/ contained display
syntax region gcodeParenComment start=/(/ end=/)/ contains=gcodeDebugKeyword,gcodeDebugText display
syntax match gcodeProgramMarker /^%$/ display

" ============================================================
" ERRORS
" ============================================================

syntax match gcodeErr /^\s*[^%;GMT]\S.*$/ display

" ============================================================
" O-WORD SUBROUTINES - region with contained parts
" ============================================================

syntax region gcodeSubLine start=/^[oO]/ end=/$/ contains=gcodeSubName,gcodeSubBrace,gcodeSubKeyword transparent display keepend
syntax match gcodeSubName /[^<>[:space:]]\+/ contained display
syntax match gcodeSubBrace /[oO<>]/ contained display
syntax keyword gcodeSubKeyword sub endsub call do while endwhile repeat endrepeat display
syntax keyword gcodeCondKeyword if elseif else endif break continue return display

" ============================================================
" PARAMETERS - # is one color, number/name is different
" ============================================================

syntax match gcodeParamHash /#/ nextgroup=gcodeParamNum,gcodeNamedBrace1 display
syntax match gcodeParamNum /\d\+/ contained display
syntax match gcodeNamedBrace1 /</ contained nextgroup=gcodeNamedName display
syntax match gcodeNamedName /[^<>]\+/ contained nextgroup=gcodeNamedBrace2 display
syntax match gcodeNamedBrace2 />/ contained display

" ============================================================
" MATH FUNCTIONS
" ============================================================

syntax keyword gcodeFunction ABS ACOS ASIN ATAN COS EXISTS EXP FIX FUP LN ROUND SIN SQRT TAN contained display
syntax region gcodeFuncArg start=/\[/ end=/\]/ contained display

" ============================================================
" OPERATORS
" ============================================================

syntax keyword gcodeOperator EQ NE LT GT LE GE AND OR XOR DOT contained display

" ============================================================
" G-CODES - Motion (green)
" ============================================================

syntax match gcodeGMotion /G[0-3]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Dwell/Exact stop (cyan)
" ============================================================

syntax match gcodeGDwell /G[49]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Coordinate systems / Setup (purple)
" ============================================================

syntax match gcodeGCoord /G10\|G2[89]\(\.\d\+\)\?\|G3[0-9]\(\.\d\+\)\?\|G5[23]\|G9[2-9]\(\.\d\+\)\?\|G110\|G111\|G112\|G113\|G114\|G115\|G116\|G117\|G118\|G119\|G12[0-9]\|G13[0-9]\|G14[0-9]\|G15[0-4]\|G54[01]\.\d\?/ display

" ============================================================
" G-CODES - Plane select / Units (brown)
" ============================================================

syntax match gcodeGPlane /G1[789]\(\.\d\+\)\?\|G2[01]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Cutter comp (yellow)
" ============================================================

syntax match gcodeGCutter /G4[0-3]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Tool length (magenta)
" ============================================================

syntax match gcodeGTool /G4[3-9]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Modal motion / Feed mode (red)
" ============================================================

syntax match gcodeGModal /G6[1-9]\|G9[0-9]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Canned cycles (orange)
" ============================================================

syntax match gcodeGCycle /G8[0-9]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Spline / NURBS (light green)
" ============================================================

syntax match gcodeGSpline /G5[.][1-3]/ display

" ============================================================
" G-CODES - Lathe mode (light blue)
" ============================================================

syntax match gcodeGLathe /G[78]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Probe (light yellow)
" ============================================================

syntax match gcodeGProbe /G3[1-9]\(\.\d\+\)\?/ display

" ============================================================
" M-CODES - Program flow (blue)
" ============================================================

syntax match gcodeMFlow /M30\|M[0-2]\(\.\d\+\)\?\(\D\|$\)/ display

" ============================================================
" M-CODES - Spindle (bright blue)
" ============================================================

syntax match gcodeMSpindle /M[3-5]\(\.\d\+\)\?\(\D\|$\)/ display

" ============================================================
" M-CODES - Coolant (teal)
" ============================================================

syntax match gcodeMCoolant /M[789]\(\.\d\+\)\?/ display

" ============================================================
" M-CODES - Tool change (orange)
" ============================================================

syntax match gcodeMTool /M6\|M61/ display

" ============================================================
" M-CODES - Spindle special (pink)
" ============================================================

syntax match gcodeMSpindleSpec /M19\|M29/ display

" ============================================================
" M-CODES - I/O control (brown)
" ============================================================

syntax match gcodeMIO /M10\|M11\|M4[89]\|M5[0-2]\|M6[4-6]/ display

" ============================================================
" M-CODES - Subprograms (yellow)
" ============================================================

syntax match gcodeMSub /M9[789]/ display

" ============================================================
" M-CODES - User macros (white)
" ============================================================

syntax match gcodeMUser /M1[0-9]\d\|M[2-9]\d\d/ display

" ============================================================
" TOOLING (T, H) - yellow
" ============================================================

syntax match gcodeTool /T\d\+/ display
syntax match gcodeHWord /H\d\+/ display

" ============================================================
" SPINDLE (S) - yellow letter, purple number
" ============================================================

syntax region gcodeSpindleRegion start=/S/ end=/\s\|$/ contains=gcodeSpindleLetter,gcodeSpindleNumber display keepend
syntax match gcodeSpindleLetter /S/ contained display
syntax match gcodeSpindleNumber /\d\+\(\.\d*\)\?/ contained display

" ============================================================
" FEED (F) - yellow letter, purple number
" ============================================================

syntax region gcodeFeedRegion start=/F/ end=/\s\|$/ contains=gcodeFeedLetter,gcodeFeedNumber display keepend
syntax match gcodeFeedLetter /F/ contained display
syntax match gcodeFeedNumber /\d\+\(\.\d*\)\?/ contained display

" ============================================================
" COORDINATES - atomic tokens (letter + number including negatives)
" ============================================================

syntax match gcodeAxisX /X-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisY /Y-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisZ /Z-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisU /U-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisV /V-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisW /W-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisA /A-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisB /B-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisC /C-*\d\+\(\.\d*\)\?/ display

" ============================================================
" SPECIAL PATTERNS
" ============================================================

syntax match gcodeExec /[;]@execute\|[;]@pause\|[;]@info\|[;]@sound\|[;]@isathome/ display

" ============================================================
" CUSTOM RGB COLOR DEFINITIONS (theme-independent)
" ============================================================

" Comments: dim gray
hi def gcodeLineComment guifg=#5C6370 gui=none
hi def gcodeParenComment guifg=#5C6370 gui=none
hi def gcodeOpenParen guifg=#5C6370 gui=none
hi def gcodeDebugKeyword guifg=#E06C75 gui=bold
hi def gcodeDebugText guifg=#E5C07B gui=none
hi def gcodeProgramMarker guifg=#E06C75 gui=bold
hi def gcodeErr guifg=#E06C75 guibg=#3E4451 gui=bold

" Subroutines: o<> and name same color (yellow), sub green
hi def gcodeSubLine guifg=NONE gui=NONE
hi def gcodeSubBrace guifg=#E5C07B gui=bold
hi def gcodeSubName guifg=#E5C07B gui=bold
hi def gcodeSubKeyword guifg=#98C379 gui=bold
hi def gcodeCondKeyword guifg=#61AFEF gui=none

" Parameters: # gray, number/name cyan, <> gray
hi def gcodeParamHash guifg=#ABB2BF gui=none
hi def gcodeParamNum guifg=#61AFEF gui=bold
hi def gcodeNamedHash guifg=#ABB2BF gui=none
hi def gcodeNamedFull guifg=NONE gui=NONE
hi def gcodeNamedBrace1 guifg=#ABB2BF gui=none
hi def gcodeNamedBrace2 guifg=#ABB2BF gui=none
hi def gcodeNamedName guifg=#61AFEF gui=bold

" Functions: blue
hi def gcodeFunction guifg=#61AFEF gui=none
hi def gcodeFuncArg guifg=#ABB2BF gui=none
hi def gcodeOperator guifg=#ABB2BF gui=none

" G-codes: DULL ORANGE - pronounced but not attention-grabbing
hi def gcodeGMotion guifg=#61AFEF gui=none
hi def gcodeGDwell guifg=#D19A66 gui=none
hi def gcodeGCoord guifg=#D19A66 gui=none
hi def gcodeGPlane guifg=#D19A66 gui=none
hi def gcodeGCutter guifg=#D19A66 gui=none
hi def gcodeGTool guifg=#D19A66 gui=none
hi def gcodeGModal guifg=#D19A66 gui=none
hi def gcodeGCycle guifg=#D19A66 gui=none
hi def gcodeGSpline guifg=#D19A66 gui=none
hi def gcodeGLathe guifg=#D19A66 gui=none
hi def gcodeGProbe guifg=#D19A66 gui=none

" M-codes: dull orange
hi def gcodeMFlow guifg=#D19A66 gui=none
hi def gcodeMSpindle guifg=#D19A66 gui=none
hi def gcodeMCoolant guifg=#D19A66 gui=none
hi def gcodeMTool guifg=#D19A66 gui=none
hi def gcodeMSpindleSpec guifg=#D19A66 gui=none
hi def gcodeMIO guifg=#D19A66 gui=none
hi def gcodeMSub guifg=#D19A66 gui=none
hi def gcodeMUser guifg=#D19A66 gui=none

" Tooling T, H: orange
hi def gcodeTool guifg=#FF9F43 gui=bold
hi def gcodeHWord guifg=#FF9F43 gui=bold

" Spindle S: RED (atomic with number)
hi def gcodeSpindleRegion guifg=#FF3B3B gui=bold gui=NONE
hi def gcodeSpindleLetter guifg=#FF3B3B gui=bold
hi def gcodeSpindleNumber guifg=#FF3B3B gui=bold

" Feed F: MAGENTA (atomic with number)
hi def gcodeFeedRegion guifg=#FF4FD8 gui=bold gui=NONE
hi def gcodeFeedLetter guifg=#FF4FD8 gui=bold
hi def gcodeFeedNumber guifg=#FF4FD8 gui=bold

" Coordinates: X/Y dull purple, Z dull red
hi def gcodeAxisX guifg=#A67DB8 gui=none
hi def gcodeAxisY guifg=#A67DB8 gui=none
hi def gcodeAxisZ guifg=#B87A7A gui=none
hi def gcodeAxisU guifg=#A67DB8 gui=none
hi def gcodeAxisV guifg=#A67DB8 gui=none
hi def gcodeAxisW guifg=#A67DB8 gui=none
hi def gcodeAxisA guifg=#A67DB8 gui=none
hi def gcodeAxisB guifg=#A67DB8 gui=none
hi def gcodeAxisC guifg=#A67DB8 gui=none

hi def gcodeExec guifg=#61AFEF gui=none

let b:current_syntax = "gcode"
let b:commentstring = "; %s"
