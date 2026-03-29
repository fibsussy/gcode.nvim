# IF

If condition.

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
```