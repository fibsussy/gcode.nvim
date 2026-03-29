# F Feed

F parameter for feed rate.

**Summary**
Sets the feed rate for linear and circular interpolation moves. Units depend on G94 (mm/min or in/min) or G95 (mm/rev or in/rev).

**Format**
`F<rate>`

**Example**
```
G1 X10 F100 (linear move at 100 mm/min)
G95 (feed per revolution mode)
F0.1 (0.1 mm per revolution)
```
