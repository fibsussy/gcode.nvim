# #

Parameter prefix - Accesses or assigns to parameters.

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
```