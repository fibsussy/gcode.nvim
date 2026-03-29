# R Parameter

R parameter for various operations.

**Summary**
R is used as a parameter in multiple contexts:
- Retract height in canned cycles (G81-G89 R<height>)
- Radius for circular pocket (G12/G13 R<radius>)
- Arc radius for G2/G3 when not using IJK
- Return level in subroutines

**Format**
`R<value>`

**Example**
```
G81 X10 Y10 Z-5 R2 F100 (drill cycle, retract to Z=2)
G2 X10 Y0 R5 (CW arc with radius 5)
```
