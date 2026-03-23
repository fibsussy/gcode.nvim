# gcode.nvim

> [!WARNING]
> This plugin was developed with AI, but is always function-tested by me before anything goes out.

G-code syntax highlighting and documentation for Neovim with support for Tormach machines.

## Installation

### lazy.nvim

```lua
return {
  "fibsussy/gcode.nvim",
}
```

That's it. The plugin auto-detects G-code files and sets up keybindings automatically.

## Supported File Extensions

| Extension | Description |
|-----------|-------------|
| `.nc` | Standard G-code |
| `.ngc` | LinuxCNC G-code |
| `.torm`, `.tormach` | Tormach G-code |

## Features

### Syntax Highlighting

G-code files are highlighted with semantic coloring by category:

#### Comments
| Pattern | Example |
|---------|---------|
| Line comments | `; This is a comment` |
| Parenthesis comments | `(comment)` or `(DEBUG,message)` |
| Program markers | `%` on its own line |

#### Subroutines (O-words)
| Pattern | Example |
|---------|---------|
| Subroutine labels | `O100`, `O<mysub>` |
| Keywords | `sub`, `endsub`, `call`, `do`, `while`, `if`, `elseif`, `else`, `endif`, `break`, `continue`, `return`, `repeat`, `endrepeat` |

#### Parameters
| Pattern | Example |
|---------|---------|
| Numbered parameters | `#1`, `#5220` |
| Named parameters | `#<tool_x>` |

#### Functions
| Pattern | Example |
|---------|---------|
| Math functions | `ABS[...]`, `SIN[...]`, `COS[...]`, `SQRT[...]`, `ATAN[...]`, `ROUND[...]`, `ACOS[...]`, `ASIN[...]`, `EXP[...]`, `LN[...]`, `TAN[...]`, `FIX[...]`, `FUP[...]`, `EXISTS[...]` |

#### Operators
| Pattern | Example |
|---------|---------|
| Comparison | `EQ`, `NE`, `LT`, `GT`, `LE`, `GE` |
| Logical | `AND`, `OR`, `XOR` |

#### Syntax Colors

| Element | Color | Example |
|---------|-------|---------|
| G-codes | Cyan | `G0`, `G1`, `G81` |
| M-codes | Orange | `M3`, `M6`, `M30` |
| Subroutines | Yellow | `O100`, `sub`, `call` |
| Tooling (T, H) | Orange | `T2`, `H2` |
| Spindle (S) | Red | `S7000` |
| Feed (F) | Magenta | `F100` |
| Axis letters | Purple | `X`, `Y`, `Z` |
| Numbers | Dim gray | `1.5`, `-2.3`, `1000` |
| Comments | Gray | `; comment`, `(comment)` |
| Parameters | Cyan | `#1`, `#711=` |
| Functions | Cyan | `ABS[...]`, `SIN[...]` |

### Hover Documentation (`K`)

Press `K` on any G/M code, subroutine, function, or parameter to view detailed documentation:

```
K on "G0"     → Rapid move documentation
K on "M3"    → Spindle CW documentation
K on "O100"  → Subroutine label documentation
K on "SUB"   → Begin subroutine docs
K on "ABS"   → Absolute value function docs
K on "#1"    → Parameter #1 documentation
K on "%"     → Program marker documentation
```

### Subroutine Navigation

Jump between subroutines and matching control flow keywords:

| Key | Action |
|-----|--------|
| `%` | Jump to matching keyword (`sub`/`endsub`, `if`/`endif`) |
| `[o` | Jump to previous `sub` or `endsub` |
| `]o` | Jump to next `sub` or `endsub` |

This works with:
- `sub` / `endsub`
- `if` / `endif`

### Axis Math (`:GcodeMath`)

Perform arithmetic operations on axis coordinates across your entire buffer or visual selection.

#### Commands

```vim
:GcodeMath Y+1          " Add 1 to all Y values
:GcodeMath Z*2          " Multiply all Z values by 2
:GcodeMath Y+1 Z-2.69   " Multiple operations at once
:GcodeMath A/3          " Divide all A values by 3
```

#### Visual Mode

Select lines in visual mode, then run:

```vim
:'<,'>GcodeMath X+5
```

#### Operations

| Operator | Description |
|----------|-------------|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo |

#### Examples

```vim
:GcodeMath Y+69.42      " Y0.5000 → Y69.9200
:GcodeMath Z-2.5        " Z-1.0000 → Z-3.5000
:GcodeMath X*2          " X10.0000 → X20.0000
```

#### Supported Axes

Handles up to 9-axis machines: **X, Y, Z, A, B, C, U, V, W**

#### Error Handling

- Warns if specified axis not found in buffer
- Validates input format
- Checks buffer is modifiable

## G/M Code Documentation

Comprehensive documentation for:
- **G0-G154**: Motion, positioning, canned cycles, coordinate systems
- **M0-M299**: Program control, spindle, coolant, subprograms, I/O
- **Subroutines**: SUB, ENDSUB, CALL, DO, WHILE, IF, etc.
- **Functions**: ABS, SIN, COS, SQRT, ATAN, etc.
- **Operators**: EQ, NE, LT, GT, AND, OR, XOR

Documentation sourced from [LinuxCNC](https://linuxcnc.org/docs/html/gcode/) and [Tormach](https://tormach.com/machine-codes).

## Credits

- **Original Plugin**: [dlmarquis/gcode.vim](https://github.com/dlmarquis/gcode.vim) - This plugin is inspired by and builds upon the original Vimscript version
- **Documentation**: [LinuxCNC](https://linuxcnc.org/docs/html/gcode/) and [Tormach](https://tormach.com/machine-codes)

## License

GPL-3.0
