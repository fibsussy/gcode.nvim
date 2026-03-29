# WHILE

While loop condition.

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
```