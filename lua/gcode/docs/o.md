# O

Subroutine label - Identifies a subroutine.

**Summary**
O-words label subroutines. Can be numeric (O100) or named (O<mysub>). Labels must be unique within a program.

**Format**
`O<number>` or `O<name>`

**Example**
```
O100 sub
  G53 G00 X0 Y0 Z0
O100 endsub
```