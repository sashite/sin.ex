# sin.ex

[![Hex.pm](https://img.shields.io/hexpm/v/sashite_sin.svg)](https://hex.pm/packages/sashite_sin)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/sashite_sin)
[![CI](https://github.com/sashite/sin.ex/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/sashite/sin.ex/actions)
[![License](https://img.shields.io/hexpm/l/sashite_sin.svg)](https://github.com/sashite/sin.ex/blob/main/LICENSE)

> **SIN** (Style Identifier Notation) implementation for Elixir.

## Overview

This library implements the [SIN Specification v1.0.0](https://sashite.dev/specs/sin/1.0.0/).

SIN is a single-character, ASCII-only token format encoding a **Player Identity**: the tuple (**Player Side**, **Player Style**). Uppercase indicates the first player, lowercase indicates the second player.

### Implementation Constraints

| Constraint | Value | Rationale |
|------------|-------|-----------|
| Token length | Exactly 1 | Single ASCII letter per spec |
| Character space | A–Z, a–z | 52 total tokens (26 abbreviations × 2 sides) |
| Function clauses | 52 + reject | All valid inputs resolved by compile-time pattern matching |

The closed domain of 52 possible values enables a compile-time generated architecture with zero branching overhead on the hot path.

## Installation

```elixir
# In your mix.exs
def deps do
  [
    {:sashite_sin, "~> 3.0"}
  ]
end
```

## Usage

### Parsing (String → Identifier)

Convert a SIN string into an `Identifier` struct.

```elixir
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
{:error, reason} = Sashite.Sin.parse("")
{:error, reason} = Sashite.Sin.parse("CC")
```

### Safe Fetching by Components (Atom, Atom → Identifier)

Retrieve an identifier directly by abbreviation and side, bypassing string parsing entirely.

```elixir
# Direct lookup — no string parsing
sin = Sashite.Sin.fetch!(:C, :first)
sin.abbr  # => :C
sin.side  # => :first

# Safe variant
{:ok, sin} = Sashite.Sin.fetch(:C, :second)
sin.side  # => :second

# Invalid components return error / raise
{:error, reason} = Sashite.Sin.fetch(:CC, :first)
Sashite.Sin.fetch!(:C, :third)  # => raises ArgumentError
```

### Formatting (Identifier → String)

Convert an `Identifier` back to a SIN string.

```elixir
sin = Sashite.Sin.parse!("C")
to_string(sin)  # => "C"

sin = Sashite.Sin.parse!("c")
to_string(sin)  # => "c"
```

### Validation

```elixir
# Boolean check (never raises)
Sashite.Sin.valid?("C")   # => true
Sashite.Sin.valid?("c")   # => true
Sashite.Sin.valid?("")    # => false
Sashite.Sin.valid?("CC")  # => false
Sashite.Sin.valid?("1")   # => false
Sashite.Sin.valid?(nil)   # => false
```

### Queries

```elixir
sin = Sashite.Sin.parse!("C")

# Side queries
Sashite.Sin.Identifier.first_player?(sin)   # => true
Sashite.Sin.Identifier.second_player?(sin)  # => false

# Comparison queries
other = Sashite.Sin.parse!("c")
Sashite.Sin.Identifier.same_abbr?(sin, other)  # => true
Sashite.Sin.Identifier.same_side?(sin, other)  # => false
```

## API Reference

### Module Methods

```elixir
# Parses a SIN string into an Identifier.
# Returns {:ok, identifier} or {:error, reason}.
@spec Sashite.Sin.parse(String.t()) :: {:ok, Identifier.t()} | {:error, atom()}

# Parses a SIN string into an Identifier.
# Raises ArgumentError if the string is not valid.
@spec Sashite.Sin.parse!(String.t()) :: Identifier.t()

# Retrieves an Identifier by abbreviation and side.
# Bypasses string parsing entirely.
# Returns {:ok, identifier} or {:error, reason}.
@spec Sashite.Sin.fetch(atom(), atom()) :: {:ok, Identifier.t()} | {:error, atom()}

# Retrieves an Identifier by abbreviation and side.
# Raises ArgumentError if components are invalid.
@spec Sashite.Sin.fetch!(atom(), atom()) :: Identifier.t()

# Reports whether string is a valid SIN identifier.
# Never raises; returns false for any invalid input.
@spec Sashite.Sin.valid?(term()) :: boolean()
```

### Identifier

```elixir
# Identifier represents a parsed SIN identifier with abbreviation and side.
%Sashite.Sin.Identifier{
  abbr: :A..:Z,           # Style abbreviation (always uppercase atom)
  side: :first | :second  # Player side
}
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

Parsing errors are returned as atoms in `{:error, reason}` tuples:

| Atom | Cause |
|------|-------|
| `:empty_input` | String length is 0 |
| `:input_too_long` | String exceeds 1 character |
| `:must_be_letter` | Character is not A-Z or a-z |
| `:invalid_abbr` | Abbreviation is not :A through :Z |
| `:invalid_side` | Side is not :first or :second |

## Design Principles

- **Spec conformance**: Strict adherence to SIN v1.0.0
- **Compile-time code generation**: All 52 valid parse clauses are generated at compile time via metaprogramming — no runtime lookup tables, no branching chains
- **Binary pattern matching on the hot path**: The BEAM resolves `<<byte>>` pattern matches at native speed; no intermediate string operations
- **Elixir idioms**: `{:ok, _}` / `{:error, _}` tuples, `parse!` / `fetch!` bang variants, `String.Chars` protocol
- **Immutable structs**: `Identifier` structs are immutable by design
- **No dependencies**: Pure Elixir standard library only

### Performance Architecture

SIN has a closed domain of exactly 52 valid tokens (26 letters × 2 cases). This implementation exploits that constraint through three complementary strategies.

**Compile-time clause generation** — A macro iterates over the 26 letters at compile time and emits 52 explicit function clauses for `parse/1` (one per valid byte value). At runtime, the BEAM's pattern matching engine dispatches directly to the correct clause. There are no conditional branches, no map lookups, and no `Enum` traversals on the hot path — just a single function call resolved by the VM's optimized dispatch table.

**Raw binary matching** — Parsing operates on the raw binary `<<byte>>` rather than on string-level abstractions. This avoids `String.length/1`, `String.to_atom/1`, and other UTF-8-aware functions that carry overhead unnecessary for an ASCII-only specification. Each valid clause destructures the single byte directly and returns pre-computed atoms.

**Dual-path API** — Parsing is split into two layers to avoid using exceptions for control flow:

- **Safe layer** — `parse/1` and `fetch/2` perform all validation and return `{:ok, identifier}` on success or `{:error, reason}` on failure, without raising, without allocating exception objects, and without capturing backtraces.
- **Bang layer** — `parse!/1` and `fetch!/2` call the safe variants internally. On failure, they raise `ArgumentError` exactly once, at the boundary. `valid?/1` calls `parse/1` and returns a boolean directly, never raising.

**Direct component lookup** — `fetch/2` bypasses string parsing entirely. Given atoms `(:C, :first)`, it validates the components and builds the struct directly. This is the fastest path for callers that already have structured data (e.g., FEEN's parser reconstructing a style–turn field from internal attributes).

This architecture ensures that SIN never becomes a bottleneck when called from higher-level parsers like FEEN, where it may be invoked multiple times per position.

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Official specification
- [SIN Examples](https://sashite.dev/specs/sin/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
