# BREAK

Break out of loop.

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
```