# CALL

Call subroutine.

**Summary**
Executes a subroutine. Arguments passed as #1, #2, etc.

**Format**
`O<label> call` or `O<label> call [arg1] [arg2]...`

**Example**
```
O100 call (no args)
O200 call [1.5] [2.0] (pass 2 args)
```