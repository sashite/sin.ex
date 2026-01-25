# sin.ex

[![Hex.pm](https://img.shields.io/hexpm/v/sashite_sin.svg)](https://hex.pm/packages/sashite_sin)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/sashite_sin)
[![License](https://img.shields.io/hexpm/l/sashite_sin.svg)](https://github.com/sashite/sin.ex/blob/main/LICENSE)

> **SIN** (Style Identifier Notation) implementation for Elixir.

## Overview

This library implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/).

## Installation

Add `sashite_sin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sashite_sin, "~> 2.1"}
  ]
end
```

## Usage

### Parsing (String → Identifier)

Convert a SIN string into an `Identifier` struct.

```elixir
alias Sashite.Sin.Identifier

# Standard parsing (returns {:ok, _} or {:error, _})
{:ok, sin} = Sashite.Sin.parse("C")
sin.abbr  # => :C
sin.side  # => :first

# Lowercase indicates second player
{:ok, sin} = Sashite.Sin.parse("c")
sin.abbr  # => :C
sin.side  # => :second

# Bang version (raises on error)
sin = Sashite.Sin.parse!("C")

# Invalid input returns error tuple
{:error, :empty_input} = Sashite.Sin.parse("")
{:error, :input_too_long} = Sashite.Sin.parse("CC")
```

### Formatting (Identifier → String)

Convert an `Identifier` back to a SIN string.

```elixir
alias Sashite.Sin.Identifier

# From Identifier struct
sin = Identifier.new(:C, :first)
Identifier.to_string(sin)  # => "C"

sin = Identifier.new(:C, :second)
Identifier.to_string(sin)  # => "c"
```

### Validation

```elixir
# Boolean check
Sashite.Sin.valid?("C")   # => true
Sashite.Sin.valid?("c")   # => true
Sashite.Sin.valid?("")    # => false
Sashite.Sin.valid?("CC")  # => false
Sashite.Sin.valid?("1")   # => false
```

### Queries

```elixir
alias Sashite.Sin.Identifier

sin = Sashite.Sin.parse!("C")

# Side queries
Identifier.first_player?(sin)   # => true
Identifier.second_player?(sin)  # => false

# Comparison queries
other = Sashite.Sin.parse!("c")
Identifier.same_abbr?(sin, other)  # => true
Identifier.same_side?(sin, other)  # => false
```

## API Reference

### Types

```elixir
# Identifier represents a parsed SIN identifier with abbreviation and side.
%Sashite.Sin.Identifier{
  abbr: :A..:Z,           # Style abbreviation (always uppercase atom)
  side: :first | :second  # Player side
}

# Create an Identifier from abbreviation and side.
# Raises ArgumentError if attributes are invalid.
Sashite.Sin.Identifier.new(abbr, side)
```

### Constants

```elixir
Sashite.Sin.Constants.valid_abbrs()  # => [:A, :B, ..., :Z]
Sashite.Sin.Constants.valid_sides()  # => [:first, :second]
Sashite.Sin.Constants.max_string_length()  # => 1
```

### Parsing

```elixir
# Parses a SIN string into an Identifier.
# Returns {:ok, identifier} or {:error, reason}.
@spec Sashite.Sin.parse(String.t()) :: {:ok, Identifier.t()} | {:error, atom()}

# Parses a SIN string into an Identifier.
# Raises ArgumentError if the string is not valid.
@spec Sashite.Sin.parse!(String.t()) :: Identifier.t()
```

### Validation

```elixir
# Reports whether string is a valid SIN identifier.
@spec Sashite.Sin.valid?(String.t()) :: boolean()
```

### Queries

```elixir
# Side queries
@spec Identifier.first_player?(Identifier.t()) :: boolean()
@spec Identifier.second_player?(Identifier.t()) :: boolean()

# Comparison queries
@spec Identifier.same_abbr?(Identifier.t(), Identifier.t()) :: boolean()
@spec Identifier.same_side?(Identifier.t(), Identifier.t()) :: boolean()
```

### Errors

Parsing errors are returned as atoms:

| Atom | Cause |
|------|-------|
| `:empty_input` | String length is 0 |
| `:input_too_long` | String exceeds 1 character |
| `:must_be_letter` | Character is not A-Z or a-z |

## Design Principles

- **Bounded values**: Explicit validation of abbreviations and sides
- **Struct-based**: `Identifier` struct enables pattern matching and encapsulation
- **Elixir idioms**: `{:ok, _}` / `{:error, _}` tuples, `parse!` bang variant
- **Immutable data**: Structs are immutable by design
- **No dependencies**: Pure Elixir standard library only

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Official specification
- [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
