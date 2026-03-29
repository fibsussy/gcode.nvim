# P Parameter

P parameter for various operations.

**Summary**
P is used as a parameter in multiple contexts:
- Dwell time in seconds (G4 P<n>)
- Subroutine number (M98 P<n>)
- Line number for calls (O call P<n>)
- WCS number (G54.1 P<n>)
- Canned cycle repeat count

**Format**
`P<value>`

**Example**
```
G4 P1.5 (dwell 1.5 seconds)
M98 P100 (call subroutine O100)
```
