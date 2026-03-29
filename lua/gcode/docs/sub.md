# SUB

Begin subroutine definition.

**Summary**
Marks the start of a subroutine body. Must be paired with ENDSUB.

**Format**
`O<label> sub`

**Example**
```
O100 sub
  G53 G00 X0 Y0 Z0
O100 endsub
```