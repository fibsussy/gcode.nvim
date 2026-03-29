# DO

Begin do-while loop.

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
```