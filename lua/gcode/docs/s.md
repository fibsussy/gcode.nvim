# S Spindle

S parameter for spindle speed.

**Summary**
Sets the spindle rotation speed in RPM (revolutions per minute). Used with M3 (CW), M4 (CCW), or M5 (stop).

**Format**
`S<rpm>`

**Example**
```
M3 S1000 (start spindle CW at 1000 RPM)
G96 S200 M3 (constant surface speed mode)
```
