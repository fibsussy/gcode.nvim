if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "gcode"

syntax case ignore

" ============================================================
" COMMENTS
" ============================================================

syntax match gcodeLineComment /;.*$/ display
syntax match gcodeDebugKeyword /DEBUG/ contained display
syntax match gcodeDebugText /,\s*\zs[^)]*/  contained display
syntax region gcodeDebugStmt start=/(\s*DEBUG/ end=/)\|$/ transparent contains=gcodeDebugKeyword,gcodeDebugText display
syntax match gcodeParenComment /([^)]*)/ contains=gcodeDebugStmt display
" ============================================================
" ERRORS
" ============================================================

syntax match gcodeErr /^\s*[^%;GMT(]\S.*$/ display

" Program marker - defined after gcodeErr so it takes priority at same position
syntax match gcodeProgramMarker /^\s*%.*$/ display

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
syntax region gcodeFuncArg start=/\[/ end=/\]\|$/ contained display

" ============================================================
" OPERATORS
" ============================================================

syntax keyword gcodeOperator EQ NE LT GT LE GE AND OR XOR DOT contained display

" ============================================================
" G-CODES - Rapid traverse (G0)
" ============================================================

syntax match gcodeGRapid /G0*0\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Cutting motion (G1/G2/G3)
" ============================================================

syntax match gcodeGMotion /G0*[1-3]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Dwell/Exact stop (cyan)
" ============================================================

syntax match gcodeGDwell /G0*[49]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - WCS select (G54-G59, G54.1)
" ============================================================

syntax match gcodeGWCS /G0*5[4-9]\(\.\d\+\)\?\|G0*54\.1\(\s\+P\d\+\)\?/ display

" ============================================================
" G-CODES - Coordinate systems / Setup (purple)
" ============================================================

syntax match gcodeGCoord /G0*10\|G0*2[89]\(\.\d\+\)\?\|G0*3[0-9]\(\.\d\+\)\?\|G0*5[23]\|G0*9[2-9]\(\.\d\+\)\?\|G110\|G11[1-9]\|G12[0-9]\|G13[0-9]\|G14[0-9]\|G15[0-4]/ display

" ============================================================
" G-CODES - Plane select / Units (brown)
" ============================================================

syntax match gcodeGPlane /G0*1[789]\(\.\d\+\)\?\|G0*2[01]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Cutter comp (yellow)
" ============================================================

syntax match gcodeGCutter /G0*4[0-3]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Tool length (magenta)
" ============================================================

syntax match gcodeGTool /G0*4[3-9]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Modal motion / Feed mode (red)
" ============================================================

syntax match gcodeGModal /G0*6[1-9]\|G0*9[0-9]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Canned cycles (orange)
" ============================================================

syntax match gcodeGCycle /G0*8[0-9]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Spline / NURBS (light green)
" ============================================================

syntax match gcodeGSpline /G5[.][1-3]/ display

" ============================================================
" G-CODES - Lathe mode (light blue)
" ============================================================

syntax match gcodeGLathe /G0*[78]\(\.\d\+\)\?/ display

" ============================================================
" G-CODES - Probe (light yellow)
" ============================================================

syntax match gcodeGProbe /G0*3[1-9]\(\.\d\+\)\?/ display

" ============================================================
" M-CODES - Program flow (blue)
" ============================================================

syntax match gcodeMFlow /M0*30\|M0*[0-2]\(\.\d\+\)\?\(\D\|$\)/ display

" ============================================================
" M-CODES - Spindle (bright blue)
" ============================================================

syntax match gcodeMSpindle /M0*[3-5]\(\.\d\+\)\?\(\D\|$\)/ display

" ============================================================
" M-CODES - Coolant (teal)
" ============================================================

syntax match gcodeMCoolantOn /M0*[78]\(\.\d\+\)\?/ display
syntax match gcodeMCoolantOff /M0*9\(\.\d\+\)\?/ display

" ============================================================
" M-CODES - Tool change (orange)
" ============================================================

syntax match gcodeMTool /M0*6\|M0*61/ display

" ============================================================
" M-CODES - Spindle special (pink)
" ============================================================

syntax match gcodeMSpindleSpec /M0*19\|M0*29/ display

" ============================================================
" M-CODES - I/O control (brown)
" ============================================================

syntax match gcodeMIO /M0*10\|M0*11\|M0*4[89]\|M0*5[0-2]\|M0*6[4-6]/ display

" ============================================================
" M-CODES - Subprograms (yellow)
" ============================================================

syntax match gcodeMSub /M0*9[789]/ display

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

" Arc IJK offsets
syntax match gcodeAxisI /I-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisJ /J-*\d\+\(\.\d*\)\?/ display
syntax match gcodeAxisK /K-*\d\+\(\.\d*\)\?/ display

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
hi def gcodeDebugStmt guifg=NONE gui=NONE
hi def gcodeDebugKeyword guifg=#E06C75 gui=bold
hi def gcodeDebugComma guifg=#5C6370 gui=none
hi def gcodeDebugText guifg=#E5C07B gui=none
hi def gcodeProgramMarker guifg=#7A8A6A gui=none
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

" G0: rapid traverse - bright yellow, bold (fast non-cutting move, stands out from cutting)
hi def gcodeGRapid guifg=#E5C07B gui=bold
" G1/G2/G3: cutting motion - bright cyan, bold (the actual work)
hi def gcodeGMotion guifg=#56B6C2 gui=bold
" G4/G9: dwell/exact stop - muted steel blue (pausing, calm)
hi def gcodeGDwell guifg=#6A8FAF gui=none
" G54-G59/G54.1: WCS select - vivid violet bold (which fixture? critical to know)
hi def gcodeGWCS guifg=#C678DD gui=bold
" G10/G28/G30 etc: coordinate system setup - soft violet (setup commands, less frequent)
hi def gcodeGCoord guifg=#9B7EC8 gui=none
" G17/G18/G19/G20/G21: plane select/units - dim slate (background modal state)
hi def gcodeGPlane guifg=#7A8A9A gui=none
" G40-G42: cutter comp - warm amber (modifies cutting path, notable)
hi def gcodeGCutter guifg=#C9945C gui=none
" G43-G49: tool length offset - golden yellow (tool geometry, pay attention)
hi def gcodeGTool guifg=#D4A843 gui=none
" G61-G99: modal/feed mode - muted teal (background motion mode)
hi def gcodeGModal guifg=#4E9F8E gui=none
" G80-G89: canned cycles - bright orange, bold (complex canned ops, high importance)
hi def gcodeGCycle guifg=#E07B39 gui=bold
" G5.1-G5.3: spline/NURBS - light mint (exotic, rare)
hi def gcodeGSpline guifg=#7EC8A0 gui=none
" G7/G8: lathe diameter/radius - soft rose (lathe-specific mode)
hi def gcodeGLathe guifg=#C47F9A gui=none
" G31-G38: probing - bright yellow, bold (careful! machine is probing)
hi def gcodeGProbe guifg=#E5C07B gui=bold

" M0/M1/M2/M30: program stop/end - hot red, bold (STOP, most important M-code)
hi def gcodeMFlow guifg=#E06C75 gui=bold
" M3/M4/M5: spindle on/off/reverse - bright coral, bold (spinning metal, dangerous)
hi def gcodeMSpindle guifg=#FF8059 gui=bold
" M7/M8: coolant on - neon blue (active, fluid flowing)
hi def gcodeMCoolantOn guifg=#00D4FF gui=bold
" M9: coolant off - dim blue (off, quieted)
hi def gcodeMCoolantOff guifg=#3A6A7A gui=none
" M6/M61: tool change - vivid orange, bold (critical: machine changes tool)
hi def gcodeMTool guifg=#FF9F43 gui=bold
" M19/M29: spindle orient/rigid tap - muted salmon (spindle special state)
hi def gcodeMSpindleSpec guifg=#C47A5A gui=none
" M10/M11/M48-M66: I/O control - dim olive (background I/O, low urgency)
hi def gcodeMIO guifg=#8A9A5A gui=none
" M97/M98/M99: subprogram calls - soft cyan (flow control, like function calls)
hi def gcodeMSub guifg=#56B6C2 gui=none
" M100+: user macros - dim gray-white (unknown/custom, intentionally subtle)
hi def gcodeMUser guifg=#8A95A0 gui=none

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
hi def gcodeAxisI guifg=#98C379 gui=none
hi def gcodeAxisJ guifg=#98C379 gui=none
hi def gcodeAxisK guifg=#98C379 gui=none

hi def gcodeExec guifg=#61AFEF gui=none

let b:current_syntax = "gcode"
let b:commentstring = "; %s"
