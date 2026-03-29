# CONTINUE

Continue to next iteration.

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
```