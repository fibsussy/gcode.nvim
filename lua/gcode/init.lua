local gcode = {}

gcode.docs = {
  ["%"] = [[Program marker - Denotes program start or end.

**Summary**
A `%` on its own line marks the beginning or end of a G-code program. Some machines require this format for file transfer.

**Format**
```
%
(program code)
%
```]],

  ["O"] = [[Subroutine label - Identifies a subroutine.

**Summary**
O-words label subroutines. Can be numeric (O100) or named (O<mysub>). Labels must be unique within a program.

**Format**
`O<number>` or `O<name>`

**Example**
```
O100 sub
  G53 G00 X0 Y0 Z0
O100 endsub
```]],

  SUB = [[Begin subroutine definition.

**Summary**
Marks the start of a subroutine body. Must be paired with ENDSUB.

**Format**
`O<label> sub`

**Example**
```
O100 sub
  G53 G00 X0 Y0 Z0
O100 endsub
```]],

  ENDSUB = [[End subroutine definition.

**Summary**
Marks the end of a subroutine body. Must follow SUB.

**Format**
`O<label> endsub`
]],

  CALL = [[Call subroutine.

**Summary**
Executes a subroutine. Arguments passed as #1, #2, etc.

**Format**
`O<label> call` or `O<label> call [arg1] [arg2]...`

**Example**
```
O100 call (no args)
O200 call [1.5] [2.0] (pass 2 args)
```]],

  DO = [[Begin do-while loop.

**Summary**
Starts a loop that continues while condition is true. Must end with ENDWHILE.

**Format**
`DO`
  (loop body)
`ENDWHILE`

**Example**
```
O100 do
  G91 X1
  #1 = [#1 + 1]
O100 endwhile [#1 LT 10]
```]],

  ENDWHILE = [[End do-while loop.

**Summary**
Ends a DO loop. Can include condition for WHILE-style behavior.

**Format**
`ENDWHILE` or `ENDWHILE [condition]`]],

  WHILE = [[While loop condition.

**Summary**
Evaluates condition at start of loop. Loop continues while true.

**Format**
`WHILE [condition]`
  (loop body)
`ENDWHILE`

**Example**
```
O100 while [#1 LT 10]
  G91 X1
  #1 = [#1 + 1]
O100 endwhile
```]],

  REPEAT = [[Repeat loop.

**Summary**
Executes loop body L times.

**Format**
`REPEAT L<count>`
  (loop body)
`ENDREPEAT`

**Example**
```
O100 repeat L5
  G91 X1
O100 endrepeat
```]],

  ENDREPEAT = [[End repeat loop.

**Summary**
Ends a REPEAT loop.]],

  IF = [[If condition.

**Summary**
Conditionally executes code block. Can be followed by ELSEIF, ELSE, and must end with ENDIF.

**Format**
`IF [condition]`
  (code if true)
`ELSEIF [condition]` (optional)
  (code if elseif true)
`ELSE` (optional)
  (code if false)
`ENDIF`

**Example**
```
O100 if [#1 GT 0]
  G90
O100 elseif [#1 LT 0]
  G91
O100 else
  G80
O100 endif
```]],

  ELSEIF = [[Else if condition.

**Summary**
Additional condition in IF block. Only evaluated if previous IF/ELSEIF conditions were false.

**Format**
`ELSEIF [condition]`]],

  ELSE = [[Else clause.

**Summary**
Code block executed if all previous IF/ELSEIF conditions were false.

**Format**
`ELSE`]],

  ENDIF = [[End if block.

**Summary**
Ends an IF/ELSEIF/ELSE block.

**Format**
`ENDIF`]],

  BREAK = [[Break out of loop.

**Summary**
Exits immediately from DO/WHILE or IF block.

**Format**
`BREAK`

**Example**
```
O100 while [1]
  G91 X1
  O100 break [#1 GT 5]
O100 endwhile
```]],

  CONTINUE = [[Continue to next iteration.

**Summary**
Skips remaining code in loop and starts next iteration.

**Format**
`CONTINUE`

**Example**
```
O100 while [#1 LT 10]
  #1 = [#1 + 1]
  O100 continue [#1 EQ 5]
  G4 P0.1
O100 endwhile
```]],

  RETURN = [[Return from subroutine.

**Summary**
Exits subroutine early. Returns to calling code.

**Format**
`RETURN [value]` (optional)]],
  ABS = [[Absolute value function.

**Format**
`ABS[value]`

**Example**
`#1 = ABS[#2]`]],
  ACOS = [[Inverse cosine function.

**Format**
`ACOS[value]`

**Example**
`#1 = ACOS[#2]`]],
  ASIN = [[Inverse sine function.

**Format**
`ASIN[value]`

**Example**
`#1 = ASIN[#2]`]],
  ATAN = [[Four quadrant inverse tangent.

**Format**
`ATAN[Y]/[X]` (both arguments required)

**Example**
`#1 = ATAN[#2]/[#3]`]],
  COS = [[Cosine function (degrees).

**Format**
`COS[angle]`

**Example**
`#1 = COS[#2]`]],
  EXISTS = [=[Check if named parameter exists.

**Format**
`EXISTS[parameter]`

**Example**
```
O100 if [EXISTS[#<tool>]]
```]=],
  EXP = [[e raised to power.

**Format**
`EXP[value]`

**Example**
`#1 = EXP[#2]`]],
  FIX = [[Round down (floor).

**Format**
`FIX[value]`

**Example**
`#1 = FIX[#2]` → 3.7 → 3]],
  FUP = [[Round up (ceiling).

**Format**
`FUP[value]`

**Example**
`#1 = FUP[#2]` → 3.2 → 4]],
  LN = [[Natural logarithm.

**Format**
`LN[value]`

**Example**
`#1 = LN[#2]`]],
  ROUND = [[Round to nearest integer.

**Format**
`ROUND[value]`

**Example**
`#1 = ROUND[#2]` → 3.7 → 4]],
  SIN = [[Sine function (degrees).

**Format**
`SIN[angle]`

**Example**
`#1 = SIN[#2]`]],
  SQRT = [[Square root.

**Format**
`SQRT[value]`

**Example**
`#1 = SQRT[#2]`]],
  TAN = [[Tangent function (degrees).

**Format**
`TAN[angle]`

**Example**
`#1 = TAN[#2]`]],
  EQ = [[Equal operator.

**Summary**
Comparison: returns true if values are equal.

**Format**
`[value1] EQ [value2]`]],
  NE = [[Not equal operator.

**Summary**
Comparison: returns true if values are not equal.

**Format**
`[value1] NE [value2]`]],
  LT = [[Less than operator.

**Summary**
Comparison: returns true if left is less than right.

**Format**
`[value1] LT [value2]`]],
  GT = [[Greater than operator.

**Summary**
Comparison: returns true if left is greater than right.

**Format**
`[value1] GT [value2]`]],
  LE = [[Less than or equal operator.

**Summary**
Comparison: returns true if left is less than or equal to right.

**Format**
`[value1] LE [value2]`]],
  GE = [[Greater than or equal operator.

**Summary**
Comparison: returns true if left is greater than or equal to right.

**Format**
`[value1] GE [value2]`]],
  AND = [[Logical AND operator.

**Summary**
Returns true if both operands are non-zero.

**Format**
`[cond1] AND [cond2]`

**Example**
`IF [#1 GT 0 AND #2 LT 10]`]],
  OR = [[Logical OR operator.

**Summary**
Returns true if either operand is non-zero.

**Format**
`[cond1] OR [cond2]`

**Example**
`IF [#1 EQ 0 OR #2 EQ 0]`]],
  XOR = [[Logical XOR operator.

**Summary**
Returns true if exactly one operand is non-zero.

**Format**
`[cond1] XOR [cond2]`]],
  DOT = [[Dot product operator.

**Summary**
Used for 3D vector dot product calculations.

**Format**
`[vec1] DOT [vec2]`]],

  ["#"] = [[Parameter prefix - Accesses or assigns to parameters.

**Summary**
# prefix accesses numeric variables. Parameters can be numbered (#1-#5000) or named (#<name>).

**Types:**
- `#<number>` - Numbered parameter (#100, #711, #5401)
- `#<name>` - Named parameter (#<tool_offset>, #<work_z>)

**Common ranges:**
- `#1-#30` - Local subroutine parameters
- `#100-#199` - Local variables
- `#500-#599` - Persistent settings
- `#5161-#5169` - G28 home position
- `#5400-#5409` - Tool table values
- `#<name>` - User-defined named variables

**Example**
```
#1 = 5 (set local param)
#<tool> = 2 (set named param)
#100 = [#1 + 10] (expression)
G10 L1 P1 Z[#<work_z>] (use in G-code)
```]],

  T = [[Tool selection - Selects tool for next tool change.

**Summary**
T word selects the tool to be loaded on next M6. Does not initiate change.

**Format**
`T<number>`

**Example**
```
T2 (select tool 2)
M6 (perform tool change)
G43 H2 (apply tool 2 offsets)
```]],

  H = [[Tool length offset index - References tool table entry.

**Summary**
H word selects the tool length offset from the tool table. Used with G43.

**Format**
`H<number>`

**Example**
```
T2 M6 (change to tool 2)
G43 H2 (apply tool 2 length offset)
```]],

  S = [[Spindle speed - Sets spindle RPM or surface speed.

**Summary**
In G97 mode: direct RPM. In G96 mode: surface feet/meters per minute.

**Format**
`S<RPM>` or `S<sfm>` (with G96)

**Example**
```
G97 S2500 (2500 RPM)
G96 S500 D3000 (500 sfm, max 3000 RPM)
```]],

  F = [[Feed rate - Sets cutting feed speed.

**Summary**
In G94 mode: units per minute. In G95 mode: units per revolution. In G93 mode: inverse time.

**Format**
`F<rate>`

**Example**
```
G94 F10 (10 units per minute)
G95 F0.01 (0.01 units per revolution)
G93 F2 (2 second move)
```]],

  N = [[Line number - Optional sequence number for program lines.

**Summary**
N-words are optional line numbers used for reference and subprogram calls (M97). They do not affect program execution order.

**Format**
`N<number>`

**Example**
```
N1 G90 G54 (line 1)
N2 T1 M6 (line 2)
M97 P1 L3 (call subroutine at line 1, 3 times)
```]],

  M10 = [[Automatic collet closer on.

**Summary**
Activates automatic collet clamping.

**Format**
`M10`]],
  M11 = [[Automatic collet closer off.

**Summary**
Deactivates automatic collet clamping.

**Format**
`M11`]],
  M64 = [[Set output state (immediate).

**Summary**
Sets digital output to ON immediately.

**Format**
`M64 P<port>`]],
  M65 = [[Clear output state (immediate).

**Summary**
Sets digital output to OFF immediately.

**Format**
`M65 P<port>`]],
  M66 = [[Wait on input.

**Summary**
Pauses until digital or analog input meets condition.

**Format**
`M66 P<port> L<mode> E<timeout>`

**Modes:**
- L0: Wait for low
- L1: Wait for high
- L2: Wait for pulse low
- L3: Wait for pulse high

**Example**
`M66 P1 L1 E5 (wait for input 1 high, 5 sec timeout)`]],
  G0 = [[Rapid move - Coordinated motion at maximum rapid rate.

**Summary**
Non-cutting positioning move. Moves all axes simultaneously at maximum velocity defined by MAX_VELOCITY in INI file.

**Format**
`G0 <axes>`

**Example**
```
G90 (absolute mode)
G0 X1 Y-2.3 (rapid to position)
```]],
  G1 = [[Linear feed move - Coordinated motion at current feed rate.

**Summary**
Straight-line cutting move at the programmed feed rate (F word). Required before any cutting motion.

**Format**
`G1 <axes> F<feedrate>`

**Example**
```
G90
G1 X1.2 Y-3 F10 (feed at 10 units/min)
Z-2.3 (continue at same feed)
Z1 F25 (new feed rate)
```]],
  G2 = [[Clockwise arc/helix - Circular arc in clockwise direction.

**Summary**
Circular interpolation clockwise as viewed from positive axis of rotation. Can produce helical motion by adding Z word. Use G17/G18/G19 to select plane.

**Center Format** (preferred)
`G2 <axes> I<offset> J<offset>`

**Radius Format**
`G2 <axes> R<radius>`

**Example**
```
G17 (XY plane)
G0 X0 Y0
G2 X1 Y1 I1 F10 (clockwise arc, I = X offset to center)
G2 X10 Y16 I3 J4 Z-1 (helix with Z motion)
```]],
  G3 = [[Counter-clockwise arc/helix - Circular arc in CCW direction.

**Summary**
Same as G2 but counter-clockwise. IJK offsets are relative from start point unless G90.1 is active.

**Format**
`G3 <axes> I J K` or `G3 <axes> R<radius>`

**Example**
```
G0 X0 Y1
G3 X0 Y0 I1 J-0.5 F25 (CCW arc)
```]],
  G4 = [[Dwell - Pause motion for specified time.

**Summary**
All axes remain stationary for the specified duration. Does not affect spindle, coolant, or I/O.

**Format**
`G4 P<seconds>` (P accepts floating point)

**Example**
```
G4 P0.5 (dwell 0.5 seconds)
```]],
  G5 = [[Cubic spline - Creates cubic B-spline in XY plane.

**Summary**
Smooth curve through control points. First command needs I,J, subsequent ones can omit them to continue direction.

**Format**
`G5 X Y I J P Q`

**Example**
```
G90 G17
G0 X0 Y0
G5 I0 J3 P0 Q-3 X1 Y1 (first spline)
G5 P0 Q-3 X2 Y2 (continues smoothly)
```]],
  ["G5.1"] = [[Quadratic B-spline - Creates quadratic spline via control point.

**Format**
`G5.1 X Y I J`

**Example**
```
G90 G17
G0 X-2 Y4
G5.1 X2 I2 J-8 (parabola through origin)
```]],
  ["G5.2"] = [[NURBS block start - Opens Non-Uniform Rational B-Spline data block.

**Summary**
Experimental feature for complex curved surfaces. Control points defined between G5.2 and G5.3.

**Format**
`G5.2 <P<weight>> <L<order>> <X Y>`

**Example**
```
G0 X0 Y0
F10
G5.2 P1 L3
     X0 Y1 P1
     X2 Y2 P1
     X2 Y0 P1
     X0 Y0 P2
G5.3
```]],
  ["G5.3"] = "NURBS block end - Closes NURBS data block.",
  G7 = [[Lathe diameter mode - X axis moves at 1/2 programmed value.

**Summary**
For lathe diameter programming. X1 moves cutter to 0.5" from center = 1" diameter part.

**Format**
`G7`]],
  G8 = [[Lathe radius mode - X axis moves at programmed value (default).

**Summary**
Default lathe mode. X1 = 1" from center = 2" diameter part.

**Format**
`G8`]],
  ["G10 L0"] = [[Reload tool table - Reloads all tool table data.

**Summary**
Requires no tool in spindle. Updates #5401-#5413 immediately.

**Format**
`G10 L0`]],
  ["G10 L1"] = [[Set tool table entry - Programs tool table values.

**Format**
`G10 L1 P<tool#> <axes R I J Q>`

**Example**
```
G10 L1 P1 Z1.5 (set tool 1 Z offset to 1.5)
G10 L1 P2 R0.015 Q3 (set radius and orientation)
```]],
  ["G10 L2"] = [[Set coordinate system origin - Offsets WCS origin.

**Summary**
Replaces current offsets for specified WCS. R rotates XY plane around Z.

**Format**
`G10 L2 P<0-9> <axes R<rotation>>`

**Example**
```
G10 L2 P1 X3.5 Y17.2 (set G54 origin)
G10 L2 P0 X0 Y0 Z0 (clear active offsets)
```]],
  ["G10 L10"] = [[Set tool table calculated - Sets offset based on current position.

**Summary**
Useful with probe moves. Sets tool table so current coords become specified values.

**Format**
`G10 L10 P<tool#> <axes>`

**Example**
```
T1 M6 G43 (load tool 1)
G10 L10 P1 Z1.5 (set Z to 1.5)
G43 (reload to verify)
```]],
  ["G10 L11"] = [[Set tool table fixture - Like L10 but uses G59.3 without offsets.

**Format**
`G10 L11 P<tool#> <axes>`]],
  ["G10 L20"] = [[Set coordinate system calculated - Sets WCS so current coords = specified.

**Format**
`G10 L20 P<0-9> <axes>`

**Example**
```
G10 L20 P1 X1.5 (current position becomes X=1.5 in G54)
```]],
  G12 = [[Circular pocket clockwise (Haas) - Machines circular pocket in clockwise spiral.

**Format**
`G12 I<radius>`

**Example**
```
G0 X2 Y0
G12 I0.5 F10 (clockwise spiral pocket)
```]],
  G13 = [[Circular pocket counter-clockwise (Haas).

**Format**
`G13 I<radius>`]],
  G17 = [[Plane select XY - Sets XY plane for arcs and canned cycles (default).

**Format**
`G17`]],
  ["G17.1"] = "Plane select UV.",
  G18 = "Plane select XZ.",
  ["G18.1"] = "Plane select WU.",
  G19 = "Plane select YZ.",
  ["G19.1"] = "Plane select VW.",
  G20 = [[Inch mode - Use inches for all units.

**Summary**
Must be included in preamble. Affects all subsequent coordinates and feed rates.

**Format**
`G20`]],
  G21 = [[Millimeter mode - Use millimeters for all units.

**Summary**
Must be included in preamble. Use at least 3 decimal places for accuracy.

**Format**
`G21`]],
  G28 = [[Return to home - Rapid move to G28 position.

**Summary**
Position must be stored with G28.1 first. If no position stored, goes to machine origin.

**Format**
`G28` or `G28 <axes>`

**Example**
```
G28 Z2.5 (rapid to Z2.5, then to home Z)
```]],
  ["G28.1"] = [[Store home position - Saves current absolute position.

**Summary**
Stores to #5161-#5169. Must home machine first.

**Format**
`G28.1`]],
  G29 = [[Return from home - Returns to position after G28 intermediate point.

**Format**
`G29 <axes>`]],
  G30 = [[Return to 2nd home - Uses position stored with G30.1.

**Summary**
Often used for tool change position.

**Format**
`G30` or `G30 <axes>`]],
  ["G30.1"] = [[Store 2nd home position - Saves to #5181-#5189.

**Format**
`G30.1`]],
  G31 = [[Probe touch - Straight probe move, outputs distance.

**Summary**
Sets #5061-#5069 with coordinates on contact. Sets #5070 to 1 (success) or 0 (fail).

**Format**
`G31 <axes>`

**Example**
```
G49 (cancel offsets)
G38.2 Z-100 F100 (probe down)
#<z_height> = #[5203 + #5220 * 20]
```]],
  ["G38.2"] = [[Probe toward workpiece, stop on contact, signal error if fails.

**Summary**
Requires motion.probe-input HAL pin. Tool must be probe or contact switch.

**Format**
`G38.2 <axes>`]],
  ["G38.3"] = [[Probe toward workpiece, stop on contact.

**Format**
`G38.3 <axes>`]],
  ["G38.4"] = [[Probe away from workpiece, error on fail.

**Format**
`G38.4 <axes>`]],
  ["G38.5"] = [[Probe away from workpiece.

**Format**
`G38.5 <axes>`]],
  G40 = [[Cancel cutter compensation.

**Summary**
Must be followed by linear move longer than tool diameter. Turns off G41/G42.

**Format**
`G40`

**Example**
```
G40
G0 X1.6 (linear move longer than cutter diameter)
```]],
  G41 = [[Cutter compensation left - Tool offsets left of programmed path.

**Summary**
Offsets tool perpendicular to feed direction. Lead-in must be longer than tool radius.

**Format**
`G41 <D<tool#>>` (D optional, uses current tool if omitted)

**Example**
```
G41 D1 (use tool 1 radius)
G1 X0 Y0.5
```]],
  G42 = [[Cutter compensation right - Tool offsets right of programmed path.

**Format**
`G42 <D<tool#>>`]],
  ["G41.1"] = [[Dynamic cutter comp left - Program diameter directly.

**Format**
`G41.1 D<diameter> <L<orientation>>`]],
  ["G42.1"] = [[Dynamic cutter comp right - Program diameter directly.

**Format**
`G42.1 D<diameter> <L<orientation>>`]],
  G43 = [[Tool length offset - Applies tool table offsets.

**Summary**
Does not cause motion. Next compensated axis move uses offset.

**Format**
`G43` or `G43 H<tool#>`

**Example**
```
T1 M6 G43 (load tool 1 with offsets)
G43 H2 (apply tool 2 offsets instead)
```]],
  ["G43.1"] = [[Dynamic tool length offset - Replaces current offsets.

**Summary**
New offsets take effect immediately without table reference.

**Format**
`G43.1 <axes>`]],
  ["G43.2"] = [[Apply additional tool length offset - Adds to existing offsets.

**Summary**
Can stack multiple offsets. Useful for wear compensation.

**Format**
`G43.2 H<tool#>` or `G43.2 <axes>`

**Example**
```
G43 (base offset)
G43.2 H10 (add tool 10 offset)
G43.2 X0.01 Z0.02 (add custom offsets)
```]],
  G49 = [[Cancel tool length compensation.

**Format**
`G49`]],
  G53 = [[Move in machine coordinates - Non-modal.

**Summary**
Moves in absolute machine coords, ignores WCS offsets. Must have G0 or G1 active.

**Format**
`G53 G0 <axes>` or `G53 G1 <axes>`

**Example**
```
G53 G0 X0 Y0 Z0 (move to machine home)
G53 X2 (move to absolute X=2)
```]],
  G54 = [[Work coordinate system 1 - First/primary WCS.

**Summary**
Most commonly used for part zero. Origin set by G10 L2 or by touching off.

**Format**
`G54`]],
  G55 = "Work coordinate system 2.",
  G56 = "Work coordinate system 3.",
  G57 = "Work coordinate system 4.",
  G58 = "Work coordinate system 5.",
  G59 = "Work coordinate system 6.",
  ["G59.1"] = "Work coordinate system 7.",
  ["G59.2"] = "Work coordinate system 8.",
  ["G59.3"] = "Work coordinate system 9.",
  G61 = [[Exact path mode - Movement exactly as programmed.

**Summary**
Slows to reach each point. No rounding at direction changes.

**Format**
`G61`]],
  ["G61.1"] = [[Exact stop mode - Stops at end of each segment.

**Summary**
More precise but slower than G64. Good for sharp corners.

**Format**
`G61.1`]],
  G64 = [[Path blending - Best possible speed with optional tolerance.

**Summary**
Rounds corners slightly for smoother motion. Default mode.

**Format**
`G64` (best speed) or `G64 P<tolerance>` or `G64 P<blend> Q<naive_cam>`

**Example**
```
G64 P0.005 (5 thou tolerance)
G64 P0.001 Q0.0005 (blend + naive cam tolerance)
```]],
  G80 = [[Cancel canned cycle - Cancels all G81-G89.

**Summary**
Required before switching canned cycles or making other moves.

**Format**
`G80`]],
  G81 = [[Simple drilling cycle - Drill with rapid retract.

**Summary**
Drills to Z depth at current R level, rapid retract.

**Format**
`G81 <axes> R<retract_z> Z<depth>`

**Example**
```
G81 X1 Y1 R0.1 Z-0.5 F10
X2 Y1 (repeat at new location)
X3 Y1
G80 (cancel)
```]],
  G82 = [[Drilling with dwell - Drill with dwell at bottom.

**Summary**
Same as G81 but dwells at bottom before retract. Good for spot drilling.

**Format**
`G82 <axes> R<retract> Z<depth> P<dwell_seconds>`

**Example**
```
G82 X0 Y0 R0.1 Z-0.25 P0.5 F10 (dwell 0.5 sec at bottom)
```]],
  G83 = [[Peck drilling - Full retract between pecks.

**Summary**
Clears chips and cools between peck cycles. Recommended for deep holes.

**Format**
`G83 <axes> R<retract> Z<depth> Q<increment>`

**Example**
```
G83 X0 Y0 R0.1 Z-1.5 Q0.25 F10 (peck every 0.25")
```]],
  G84 = [[Right-hand tapping - Synchronized feed in, spindle reverse out.

**Summary**
Spindle and Z feed synchronized. Requires rigid tapping capable machine.

**Format**
`G84 <axes> R<retract> Z<depth> F<pitch> S<RPM>`]],
  G85 = [[Boring (feed in/out) - Bores and feeds out at feed rate.

**Summary**
Leaves finished hole surface. Spindle continues during retract.

**Format**
`G85 <axes> R<retract> Z<depth>`]],
  G86 = [[Boring (spindle stop, rapid out) - Stops spindle, rapid retract.

**Summary**
Spindle stops at bottom, rapid retract. May leave tool mark.

**Format**
`G86 <axes> R<retract> Z<depth>`]],
  G87 = [[Back boring - Bores from opposite side.

**Summary**
Complex cycle for bores you cannot reach from top.

**Format**
`G87 <axes> R Z I J`]],
  G88 = [[Boring (spindle stop, manual out).

**Format**
`G88 <axes> R<retract> Z<depth> P<dwell>`]],
  G89 = [[Boring (dwell, feed out) - Dwell at bottom, feed retract.

**Format**
`G89 <axes> R<retract> Z<depth> P<dwell>`]],
  G90 = [[Absolute positioning - All coordinates from workpiece zero.

**Summary**
Default mode. All axis values are distances from part zero.

**Format**
`G90`]],
  G91 = [[Incremental positioning - Coordinates relative to current position.

**Summary**
Each move is delta from current position.

**Example**
```
G91 X1 Y1 (move +1 in X and +1 in Y from current)
```]],
  G92 = [[Coordinate system offset - Temporarily shifts origin.

**Summary**
Not persistent. Cancel with G92.1 before program end. Non-modal.

**Format**
`G92 <axes>`

**Example**
```
G92 X0 Y0 (set current position as origin)
G92.1 (cancel offsets)
```]],
  ["G92.1"] = [[Cancel G92 offsets and clear parameters #5211-5219.

**Format**
`G92.1`]],
  ["G92.2"] = [[Suspend G92 offsets (can be restored with G92.3).

**Format**
`G92.2`]],
  ["G92.3"] = [[Restore G92 offsets from suspended state.

**Format**
`G92.3`]],
  G93 = [[Inverse time feed mode - F specifies time for move.

**Summary**
Good for moves involving rotary axes where XYZ feed varies.

**Format**
`G93 F<seconds>`

**Example**
```
G93 F2 (2 second move)
G1 X10 A45 (moves in 2 seconds regardless of distance)
```]],
  G94 = [[Units per minute (default) - Feed rate in units/minute.

**Format**
`G94 F<feedrate>`]],
  G95 = [[Units per revolution - Feed rate in units/revolution.

**Summary**
Requires spindle encoder. F = distance per spindle revolution.

**Format**
`G95 F<feedrate>`]],
  G96 = [[Constant surface speed - Spindle RPM varies with position.

**Summary**
Maintains constant cutting speed. S is surface feet/meters per minute.

**Format**
`G96 S<sfm> D<max_rpm>` or `G96 D<max_rpm>`

**Example**
```
G96 S500 D3000 (500 sfm, max 3000 RPM)
```]],
  G97 = [[RPM mode - Fixed spindle speed.

**Summary**
Default mode. S specifies direct RPM.

**Format**
`G97 S<RPM>`

**Example**
```
G97 S2500 (2500 RPM)
```]],
  G98 = [[Initial plane return - Returns to start Z before next move.

**Summary**
Default. Safe for multi-depth operations.

**Format**
`G98`]],
  G99 = [[R-plane return - Returns to R level before next move.

**Summary**
Faster than G98. Use when all depths clear obstacles.

**Format**
`G99`]],
  G110 = "Work coordinate system 10 (G54.1 P1).",
  G111 = "Work coordinate system 11 (G54.1 P2).",
  G112 = "Work coordinate system 12 (G54.1 P3).",
  G113 = "Work coordinate system 13 (G54.1 P4).",
  G114 = "Work coordinate system 14 (G54.1 P5).",
  G115 = "Work coordinate system 15 (G54.1 P6).",
  G116 = "Work coordinate system 16 (G54.1 P7).",
  G117 = "Work coordinate system 17 (G54.1 P8).",
  G118 = "Work coordinate system 18 (G54.1 P9).",
  G119 = "Work coordinate system 19 (G54.1 P10).",
  G120 = "Work coordinate system 20 (G54.1 P11).",
  G121 = "Work coordinate system 21 (G54.1 P12).",
  G122 = "Work coordinate system 22 (G54.1 P13).",
  G123 = "Work coordinate system 23 (G54.1 P14).",
  G124 = "Work coordinate system 24 (G54.1 P15).",
  G125 = "Work coordinate system 25 (G54.1 P16).",
  G126 = "Work coordinate system 26 (G54.1 P17).",
  G127 = "Work coordinate system 27 (G54.1 P18).",
  G128 = "Work coordinate system 28 (G54.1 P19).",
  G129 = "Work coordinate system 29 (G54.1 P20).",
  G154 = [[Work coordinate systems 1-99.

**Summary**
Extended WCS selection. G154 P1 = WCS1, G154 P15 = WCS15, etc.

**Format**
`G154 P<n>`]],
  M0 = [[Program stop - Stops all motion until CYCLE START pressed.

**Summary**
Does not reset modal state. Optional stop if option enabled.

**Format**
`M0`]],
  M1 = [[Optional program stop - Stops only if OPT STOP switch on.

**Format**
`M1`]],
  M2 = [[End of program - Ends program and resets modal state.

**Summary**
Does not rewind. Position unchanged.

**Format**
`M2`]],
  M3 = [[Spindle clockwise - Starts spindle CW at current S speed.

**Format**
`M3 S<RPM>`

**Example**
```
M3 S2000 (start spindle CW at 2000 RPM)
```]],
  M4 = [[Spindle counter-clockwise.

**Format**
`M4 S<RPM>`]],
  M5 = [[Spindle stop - Stops spindle immediately.

**Format**
`M5`]],
  M6 = [[Tool change - Initiates tool change sequence.

**Summary**
T word selects tool before M6. On random changer machines, may move to tool rack.

**Format**
`T<tool#> M6`

**Example**
```
T2 (select tool 2)
M6 (perform change)
G43 H2 (apply offsets)
```]],
  M7 = [[Mist coolant on - Turns on mist (M8 can also be on).

**Format**
`M7`]],
  M8 = [[Flood coolant on.

**Format**
`M8`]],
  M9 = [[Coolant off (all).

**Format**
`M9`]],
  M19 = [[Orient spindle - Stops spindle at specific angle.

**Summary**
Used before tool changes on some machines.

**Format**
`M19 S<degrees>` or `M19 R<degrees> P<direction>`

**Example**
```
M19 S0 (orient to 0 degrees)
```]],
  M29 = [[Rigid tap mode set - Enables synchronized feed/spindle for tapping.

**Format**
`M29 S<RPM>`]],
  M30 = [[End of program and rewind - Ends program and returns to start.

**Summary**
Resets all modal state to defaults.

**Format**
`M30`]],
  M48 = [[Enable overrides - Allows M50/M51/M52 controls.

**Format**
`M48`]],
  M49 = [[Disable overrides - Locks out override controls.

**Format**
`M49`]],
  M50 = [[Feed override enable - Allows feed rate adjustment.

**Format**
`M50 P1` (enable) or `M50 P0` (disable)]],
  M51 = [[Spindle override enable.

**Format**
`M51 P1` or `M51 P0`]],
  M52 = [[Adaptive feed control - Enables load-based feed modification.

**Format**
`M52 P1` or `M52 P0`]],
  M61 = [[Set tool number (no move) - Sets current tool without change motion.

**Format**
`M61 Q<tool#>`]],
  M97 = [[Subprogram call (local) - Calls local subroutine.

**Summary**
P = line number or O-word label. L = repeat count.

**Format**
`M97 P<line> L<reps>` or `M97 P<label>`

**Example**
```
M97 P100 L3 (run subroutine at line 100, 3 times)
```]],
  M98 = [[Subprogram call - Calls external subroutine file.

**Summary**
Calls O-word subroutine or external file.

**Format**
`M98 P<o-word>` or `M98 P<filename>`

**Example**
```
M98 P100 (call o100 subroutine)
M98 P"subroutine.ngc" (call external file)
```]],
  M99 = [[Subprogram return - Returns from subroutine.

**Summary**
If P specified, loops back to call point P times.

**Format**
`M99` or `M99 P<count>`]],
  M100 = [[User-defined macro - Calls external file with parameters.

**Summary**
M100-M199 are user-defined. External file accepts parameters.

**Format**
`M100 <parameters>`]],
  ["M200-M299"] = "Extended user-defined macros.",
}

-- Strip leading zeros from G/M codes: "M03" -> "M3", "G001" -> "G1"
local function canonical(word)
  return word:gsub("^([GgMm])0+(%d)", "%1%2")
end

function gcode.lookup(word)
  -- Normalize: uppercase + strip leading zeros on G/M codes
  local norm = canonical(word:upper())

  local doc = gcode.docs[norm]
  if doc then
    return "**" .. norm .. "**\n\n" .. doc
  end

  -- Fallback: original word as-is (handles non-G/M keys)
  local upper = word:upper()
  if upper ~= norm and gcode.docs[upper] then
    return "**" .. upper .. "**\n\n" .. gcode.docs[upper]
  end

  if word:match("^G1[12]%d$") then
    local wcs = tonumber(word:match("%d+$")) or 0
    local pnum = wcs - 109
    return "**" .. word .. "**\n\nWCS " .. wcs .. " (G54.1 P" .. pnum .. ")"
  end

  if word:match("^#$") then
    return "**#**\n\nParameter prefix. Use #<number> or #<name> for parameters."
  end

  if word:match("^#[0-9]+$") then
    return "**" .. word .. "**\n\nNumbered parameter. Use #1-#30 for local subroutine parameters, #100+ for global parameters."
  end

  if word:match("^#<[^>]+>$") then
    return "**" .. word .. "**\n\nNamed parameter. Used for user-defined variables with descriptive names."
  end
  if param then
    if param:match("^#%d+$") then
      local num = tonumber(param:match("%d+"))
      if num and num >= 1 and num <= 30 then
        return "**" .. param .. "**\n\nLocal subroutine parameter #" .. num
      else
        return "**" .. param .. "**\n\nNumbered parameter"
      end
    else
      return "**" .. param .. "**\n\nNamed parameter"
    end
  end

  return ""
end

function gcode.hover()
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".")
  local word = vim.fn.expand("<cword>")
  local result = ""

  if col > 1 and line:sub(col, col):match("[#]") then
    word = line:sub(col, col) .. word
  elseif col > 1 and line:sub(col - 1, col - 1) == "#" then
    word = "#" .. word
  end

  if word == "" or word == nil then
    return
  end

  local before = line:sub(1, col - 1)
  local after = line:sub(col)
  local current_char = line:sub(col, col)

  if current_char == "#" then
    if after:sub(1, 1) == "<" then
      word = "#" .. after:match("<[^>]*>")
    else
      word = "#" .. (after:match("^%d+") or "")
    end
  elseif current_char == "<" then
    if before:match("#$") then
      word = "#" .. after:match("<[^>]*>")
    end
  elseif current_char == ">" and before:match("#<[^>]*$") then
    word = before:match("#<[^>]*") .. ">"
  elseif before:match("#<[^>]*$") then
    word = before:match("#<[^>]*") .. after:match("^[^>]*>")
  elseif current_char:match("%d") and before:match("#%d+$") then
    word = before:match("#%d+") .. after:match("^%d+")
  end

  local sub_call_pattern = "O%d%s+call"
  if line:match(sub_call_pattern) then
    local match_start, match_end = line:find("O%d+%s+call")
    if match_start and col >= match_start and col <= match_end then
      local label = line:match("O%d+")
      if label then
        result = gcode.lookup("CALL")
        if result == "" then
          result = "**" .. label .. " call**\n\nSubroutine call: " .. label
        end
      end
    end
  end

  if result == "" then
    result = gcode.lookup(word)
  end

  if result == "" then
    local upper = word:upper()
    result = gcode.lookup(upper)
  end

  if result == "" then
    local partial = word:match("^[gmGMCc]%d+%.?%d*")
    if partial then
      result = gcode.lookup(canonical(partial:upper()))
    end
  end

  if result == "" then
    local first_char = word:sub(1, 1)
    if word:match("^[THSFthsf]%d+") and gcode.docs[first_char:upper()] then
      result = gcode.lookup(first_char:upper())
    end
  end

  if result == "" then
    local n_word = word:match("^N%d+$")
    if n_word then
      result = gcode.lookup("N")
    end
  end

  if result == "" then
    local o_word = word:match("^O%d+$") or word:match("^O<.+>$") or word:match("^o%d+$") or word:match("^o<.+>$")
    if o_word then
      result = gcode.lookup("O")
    end
  end

  if result == "" then
  local param = word:match("^#%d+$") or word:match("^#<[^>]+>$")
    if param then
      if param:match("^#%d+$") then
        local num = tonumber(param:match("%d+"))
        if num and num >= 1 and num <= 30 then
          result = "**" .. param .. "**\n\nLocal subroutine parameter #" .. num
        else
          result = "**" .. param .. "**\n\nNumbered parameter"
        end
      else
        result = "**" .. param .. "**\n\nNamed parameter"
      end
    end
  end

  if result == "" then
    local func = word:match("^[A-Z]+$")
    if func and gcode.docs[func] then
      result = gcode.lookup(func)
    end
  end

  if result == "" and word == "%" then
    result = gcode.lookup("%")
  end

  if result ~= "" then
    vim.lsp.util.open_floating_preview(vim.split(result, "\n"), "markdown", { focusable = false })
  end
end

function gcode.math(opts, input_arg)
  local input = input_arg

  if not input then
    local success
    success, input = pcall(vim.fn.input, "Enter axis operations (e.g. Y+1 Z*2 A-2.69): ")
    if not success or input == "" then
      return
    end
  end

  local operations = {}
  for axis, op, num in input:gmatch("([XYZABCUVW])([%+%*%/%-])([%d%.%-]+)") do
    table.insert(operations, { axis = axis, op = op, val = tonumber(num) })
  end

  if #operations == 0 then
    vim.notify("No valid operations found (e.g. Y+1 Z*2 A-2.69)", vim.log.levels.ERROR)
    return
  end

  if not vim.bo.modifiable then
    vim.notify("Buffer is not modifiable", vim.log.levels.ERROR)
    return
  end

  local line1, line2
  if opts and opts.range and opts.range ~= 0 then
    line1, line2 = opts.line1, opts.line2
  else
    line1, line2 = 1, vim.fn.line("$")
  end

  local any_changed = false
  local missing_axes = {}

  for _, op in ipairs(operations) do
    local found = false
    for i = line1, line2 do
      local line = vim.fn.getline(i)
      if line:match(op.axis) then
        found = true
        break
      end
    end
    if not found then
      table.insert(missing_axes, op.axis)
    end
  end

  if #missing_axes > 0 then
    vim.notify("No " .. table.concat(missing_axes, ", ") .. " coordinates found", vim.log.levels.WARN)
  end

  for i = line1, line2 do
    local line = vim.fn.getline(i)
    local changed = false

    for _, op in ipairs(operations) do
      local pattern = op.axis .. "(-?%d+%.?%d*)"
      line = line:gsub(pattern, function(full_match)
        local num = tonumber(full_match)
        local result
        if op.op == "+" then
          result = num + op.val
        elseif op.op == "-" then
          result = num - op.val
        elseif op.op == "*" then
          result = num * op.val
        elseif op.op == "/" then
          result = num / op.val
        elseif op.op == "%" then
          result = num % op.val
        end
        if result then
          changed = true
          any_changed = true
          return op.axis .. string.format("%.4f", result):gsub("%.0+$", "")
        end
        return full_match
      end)
    end

    if changed then
      vim.fn.setline(i, line)
    end
  end

  if not any_changed and #missing_axes == 0 then
    vim.notify("No changes made", vim.log.levels.INFO)
  end
end

function gcode.jump_to_sub(direction)
  local current_line = vim.fn.line(".")

  local matches = {}
  for i = 1, vim.fn.line("$") do
    local line = vim.fn.getline(i):lower()
    if line:match("o%d+%s+sub") or line:match("o<[^>]+>%s*sub") then
      local orig_line = vim.fn.getline(i)
      local orig_name = orig_line:match("O%d+") or orig_line:match("O<[^>]*>")
      table.insert(matches, { line = i, type = "sub", name = orig_name })
    elseif line:match("o%d+%s+endsub") or line:match("o<[^>]+>%s*endsub") then
      local orig_line = vim.fn.getline(i)
      local orig_name = orig_line:match("O%d+") or orig_line:match("O<[^>]*>")
      table.insert(matches, { line = i, type = "endsub", name = orig_name })
    end
  end

  if #matches == 0 then
    vim.notify("No subroutines found", vim.log.levels.WARN)
    return
  end

  local target = nil
  if direction == "next" then
    for _, m in ipairs(matches) do
      if m.line > current_line then
        target = m
        break
      end
    end
    if not target then
      target = matches[1]
    end
  else
    for i = #matches, 1, -1 do
      if matches[i].line < current_line then
        target = matches[i]
        break
      end
    end
    if not target then
      target = matches[#matches]
    end
  end

  if target then
    vim.fn.cursor(target.line, 1)
    vim.cmd("normal! zv")
  end
end

function gcode.jump_to_percent()
  local current_line = vim.fn.line(".")
  local line = vim.fn.getline(".")
  local line_lower = line:lower()

  local is_sub = line_lower:match("o%s*<[^>]+>%s+sub%s*$") or line_lower:match("o%s*%d+%s+sub%s*$")
  local is_endsub = line_lower:match("o%s*<[^>]+>%s+endsub%s*$") or line_lower:match("o%s*%d+%s+endsub%s*$")
  local is_if = line_lower:match("o%s*<[^>]+>%s+if%s+") or line_lower:match("o%s*%d+%s+if%s+")
  local is_endif = line_lower:match("o%s*<[^>]+>%s+endif%s*$") or line_lower:match("o%s*%d+%s+endif%s*$")

  if not (is_sub or is_endsub or is_if or is_endif) then
    vim.cmd("normal! %")
    return
  end

  local search_up, search_down
  if is_sub then
    search_up, search_down = "endsub", "sub"
  elseif is_endsub then
    search_up, search_down = "sub", "endsub"
  elseif is_if then
    search_up, search_down = "endif", "if"
  else
    search_up, search_down = "if", "endif"
  end

  for i = current_line - 1, 1, -1 do
    local l = vim.fn.getline(i):lower()
    if l:match(search_up) then
      vim.fn.cursor(i, 1)
      return
    end
  end

  for i = current_line + 1, vim.fn.line("$") do
    local l = vim.fn.getline(i):lower()
    if l:match(search_down) then
      vim.fn.cursor(i, 1)
      return
    end
  end

  vim.cmd("normal! %")
end

return gcode
