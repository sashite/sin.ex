# Sashite.Sin

[![Hex.pm](https://img.shields.io/hexpm/v/sashite_sin.svg)](https://hex.pm/packages/sashite_sin)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/sashite_sin)
[![License](https://img.shields.io/hexpm/l/sashite_sin.svg)](https://github.com/sashite/sin.ex/blob/main/LICENSE.md)

> **SIN** (Style Identifier Notation) implementation for Elixir.

## What is SIN?

SIN (Style Identifier Notation) provides a compact, ASCII-based format for encoding **Piece Style** with an associated **Side** in abstract strategy board games. It serves as a minimal building block that can be embedded in higher-level notations.

This library implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/).

## Installation

Add `sashite_sin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sashite_sin, "~> 1.0"}
  ]
end
```

## Usage

```elixir
# Parse SIN strings
{:ok, sin} = Sashite.Sin.parse("C")
sin.style  # => :C
sin.side   # => :first

Sashite.Sin.to_string(sin)  # => "C"

# Parse with pattern matching
{:ok, chess_first} = Sashite.Sin.parse("C")   # Chess-style, first player
{:ok, chess_second} = Sashite.Sin.parse("c")  # Chess-style, second player
{:ok, shogi_first} = Sashite.Sin.parse("S")   # Shogi-style, first player

# Bang version for direct access
sin = Sashite.Sin.parse!("C")

# Create identifiers directly
sin = Sashite.Sin.new(:C, :first)
sin = Sashite.Sin.new(:S, :second)

# Validation
Sashite.Sin.valid?("C")        # => true
Sashite.Sin.valid?("s")        # => true
Sashite.Sin.valid?("CC")       # => false (more than one character)
Sashite.Sin.valid?("1")        # => false (digit instead of letter)
Sashite.Sin.valid?("")         # => false (empty string)

# Side transformation
flipped = Sashite.Sin.flip(sin)
Sashite.Sin.to_string(flipped)  # => "c"

# Attribute changes
shogi = Sashite.Sin.with_style(sin, :S)
Sashite.Sin.to_string(shogi)  # => "S"

second = Sashite.Sin.with_side(sin, :second)
Sashite.Sin.to_string(second)  # => "c"

# Side queries
Sashite.Sin.first_player?(sin)     # => true
Sashite.Sin.second_player?(sin)    # => false

# Comparison
chess1 = Sashite.Sin.parse!("C")
chess2 = Sashite.Sin.parse!("c")

Sashite.Sin.same_style?(chess1, chess2)  # => true
Sashite.Sin.same_side?(chess1, chess2)   # => false
```

## Format Specification

### Structure

```
<letter>
```

A SIN token is **exactly one** ASCII letter (`A-Z` or `a-z`).

### Attribute Mapping

| Attribute | Encoding |
|-----------|----------|
| Piece Style | Base letter (case-insensitive): `C` and `c` represent the same style |
| Side | Letter case: uppercase → `first`, lowercase → `second` |

### Side Convention

- **Uppercase** (`A-Z`): First player (Side `first`)
- **Lowercase** (`a-z`): Second player (Side `second`)

### Common Conventions

| SIN | Side | Typical Piece Style |
|-----|------|---------------------|
| `C` | First | Chess-style |
| `c` | Second | Chess-style |
| `S` | First | Shogi-style |
| `s` | Second | Shogi-style |
| `X` | First | Xiangqi-style |
| `x` | Second | Xiangqi-style |
| `M` | First | Makruk-style |
| `m` | Second | Makruk-style |

### Invalid Token Examples

| String | Reason |
|--------|--------|
| `""` | Empty string |
| `CC` | More than one character |
| `c1` | Contains a digit |
| `+C` | Contains a prefix character |
| ` C` | Leading whitespace |
| `C ` | Trailing whitespace |
| `1` | Digit instead of letter |
| `é` | Non-ASCII character |

## API Reference

### Parsing

```elixir
Sashite.Sin.parse(sin_string)   # => {:ok, %Sashite.Sin{}} | {:error, reason}
Sashite.Sin.parse!(sin_string)  # => %Sashite.Sin{} | raises ArgumentError
Sashite.Sin.valid?(sin_string)  # => boolean
```

### Creation

```elixir
Sashite.Sin.new(style, side)
```

### Conversion

```elixir
Sashite.Sin.to_string(sin)  # => String.t()
Sashite.Sin.letter(sin)     # => String.t() (the single character)
```

### Transformations

All transformations return new `%Sashite.Sin{}` structs:

```elixir
# Side
Sashite.Sin.flip(sin)

# Attribute changes
Sashite.Sin.with_style(sin, new_style)
Sashite.Sin.with_side(sin, new_side)
```

### Queries

```elixir
# Side
Sashite.Sin.first_player?(sin)
Sashite.Sin.second_player?(sin)

# Comparison
Sashite.Sin.same_style?(sin1, sin2)
Sashite.Sin.same_side?(sin1, sin2)
```

## Data Structure

```elixir
%Sashite.Sin{
  style: :A..:Z,          # Piece style (always uppercase atom)
  side: :first | :second  # Player side
}
```

## Protocol Mapping

Following the [Game Protocol](https://sashite.dev/game-protocol/):

| Protocol Attribute | SIN Encoding |
|-------------------|--------------|
| Piece Style | Base letter (case-insensitive) |
| Side | Letter case |

## Relationship with SNN

**Style Name Notation (SNN)** and SIN are **independent primitives** that serve complementary roles:

- **SIN** — compact, single-character style identifiers (`C`, `s`, `X`)
- **SNN** — human-readable style names (`CHESS`, `shogi`, `XIANGQI`)

Converting between SIN and SNN requires external, context-specific mapping.

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [PIN](https://sashite.dev/specs/pin/1.0.0/) — Piece Identifier Notation
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Official specification

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
