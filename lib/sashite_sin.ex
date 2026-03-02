defmodule Sashite.Sin do
  @moduledoc """
  SIN (Style Identifier Notation) implementation for Elixir.

  SIN provides a compact, ASCII-based format for encoding Player Style
  with Player Side assignment in abstract strategy board games.

  A SIN token is exactly one ASCII letter:
  - Uppercase (A-Z) indicates first player
  - Lowercase (a-z) indicates second player

  All 52 valid inputs are resolved at compile time via generated function
  clauses. At runtime, parsing is a single pattern match on the raw byte —
  no branching, no map lookups, no string conversions.

  ## Examples

      iex> {:ok, sin} = Sashite.Sin.parse("C")
      iex> sin.abbr
      :C
      iex> sin.side
      :first

      iex> sin = Sashite.Sin.parse!("c")
      iex> sin.abbr
      :C
      iex> sin.side
      :second

      iex> Sashite.Sin.valid?("C")
      true

      iex> Sashite.Sin.valid?("CC")
      false

  See: https://sashite.dev/specs/sin/1.0.0/
  """

  alias Sashite.Sin.Identifier

  # ============================================================================
  # Parsing (String → Identifier)
  # ============================================================================

  @doc """
  Parses a SIN string into an Identifier.

  Each valid byte value has its own function clause, generated at compile
  time. The BEAM dispatches directly to the correct clause — no runtime
  branching, no intermediate data structures.

  ## Parameters

  - `input` - The SIN string to parse

  ## Returns

  - `{:ok, %Identifier{}}` on success
  - `{:error, reason}` on failure

  ## Error Reasons

  - `:not_a_string` - Input is not a binary (e.g., nil, integer, atom, list)
  - `:empty_input` - String length is 0
  - `:input_too_long` - String exceeds 1 character
  - `:must_be_letter` - Character is not A-Z or a-z

  ## Examples

      iex> {:ok, sin} = Sashite.Sin.parse("C")
      iex> sin.abbr
      :C
      iex> sin.side
      :first

      iex> {:ok, sin} = Sashite.Sin.parse("s")
      iex> sin.abbr
      :S
      iex> sin.side
      :second

      iex> Sashite.Sin.parse("")
      {:error, :empty_input}

      iex> Sashite.Sin.parse("CC")
      {:error, :input_too_long}

      iex> Sashite.Sin.parse("1")
      {:error, :must_be_letter}

      iex> Sashite.Sin.parse(nil)
      {:error, :not_a_string}
  """
  @spec parse(String.t()) :: {:ok, Identifier.t()} | {:error, atom()}

  # -- 52 compile-time generated clauses (26 uppercase + 26 lowercase) ---------

  for letter <- ?A..?Z do
    abbr = List.to_atom([letter])
    upper_bin = <<letter>>
    lower_bin = <<letter + 32>>

    def parse(unquote(upper_bin)) do
      {:ok, %Identifier{abbr: unquote(abbr), side: :first}}
    end

    def parse(unquote(lower_bin)) do
      {:ok, %Identifier{abbr: unquote(abbr), side: :second}}
    end
  end

  # -- Error clauses (evaluated only when no valid clause matched) -------------

  def parse(""), do: {:error, :empty_input}
  def parse(<<_byte>>), do: {:error, :must_be_letter}
  def parse(input) when is_binary(input), do: {:error, :input_too_long}
  def parse(_), do: {:error, :not_a_string}

  # ============================================================================
  # Parsing — bang variant
  # ============================================================================

  @doc """
  Parses a SIN string into an Identifier, raising on error.

  Delegates to `parse/1`. Raises `ArgumentError` only at the boundary.

  ## Parameters

  - `input` - The SIN string to parse

  ## Returns

  An `%Identifier{}` struct.

  ## Raises

  - `ArgumentError` if the input is invalid

  ## Examples

      iex> sin = Sashite.Sin.parse!("C")
      iex> sin.abbr
      :C

      iex> sin = Sashite.Sin.parse!("c")
      iex> sin.side
      :second

      iex> Sashite.Sin.parse!("")
      ** (ArgumentError) empty input

      iex> Sashite.Sin.parse!("CC")
      ** (ArgumentError) input too long

      iex> Sashite.Sin.parse!("1")
      ** (ArgumentError) must be letter

      iex> Sashite.Sin.parse!(nil)
      ** (ArgumentError) not a string
  """
  @spec parse!(String.t()) :: Identifier.t()
  def parse!(input) do
    case parse(input) do
      {:ok, identifier} -> identifier
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  # ============================================================================
  # Fetching by components (Atom, Atom → Identifier)
  # ============================================================================

  @doc """
  Retrieves an Identifier by abbreviation and side.

  Bypasses string parsing entirely — validates components and builds
  the struct directly via `Identifier.build/2`.

  ## Parameters

  - `abbr` - The style abbreviation (`:A` through `:Z`)
  - `side` - The player side (`:first` or `:second`)

  ## Returns

  - `{:ok, %Identifier{}}` on success
  - `{:error, reason}` on failure

  ## Examples

      iex> {:ok, sin} = Sashite.Sin.fetch(:C, :first)
      iex> sin.abbr
      :C
      iex> sin.side
      :first

      iex> {:ok, sin} = Sashite.Sin.fetch(:C, :second)
      iex> sin.side
      :second

      iex> Sashite.Sin.fetch(:CC, :first)
      {:error, :invalid_abbr}

      iex> Sashite.Sin.fetch(:C, :third)
      {:error, :invalid_side}
  """
  @spec fetch(atom(), atom()) :: {:ok, Identifier.t()} | {:error, atom()}
  def fetch(abbr, side) do
    Identifier.build(abbr, side)
  end

  # ============================================================================
  # Fetching — bang variant
  # ============================================================================

  @doc """
  Retrieves an Identifier by abbreviation and side, raising on error.

  Delegates to `fetch/2`. Raises `ArgumentError` only at the boundary.

  ## Parameters

  - `abbr` - The style abbreviation (`:A` through `:Z`)
  - `side` - The player side (`:first` or `:second`)

  ## Returns

  An `%Identifier{}` struct.

  ## Raises

  - `ArgumentError` if components are invalid

  ## Examples

      iex> sin = Sashite.Sin.fetch!(:C, :first)
      iex> sin.abbr
      :C

      iex> sin = Sashite.Sin.fetch!(:S, :second)
      iex> sin.side
      :second

      iex> Sashite.Sin.fetch!(:CC, :first)
      ** (ArgumentError) invalid abbr

      iex> Sashite.Sin.fetch!(:C, :third)
      ** (ArgumentError) invalid side
  """
  @spec fetch!(atom(), atom()) :: Identifier.t()
  def fetch!(abbr, side) do
    case fetch(abbr, side) do
      {:ok, identifier} -> identifier
      {:error, reason} -> raise ArgumentError, error_message(reason)
    end
  end

  # ============================================================================
  # Validation
  # ============================================================================

  @doc """
  Reports whether the input is a valid SIN string.

  Never raises. Returns `false` for any invalid input including `nil`.

  ## Examples

      iex> Sashite.Sin.valid?("C")
      true

      iex> Sashite.Sin.valid?("c")
      true

      iex> Sashite.Sin.valid?("")
      false

      iex> Sashite.Sin.valid?("CC")
      false

      iex> Sashite.Sin.valid?("1")
      false

      iex> Sashite.Sin.valid?(nil)
      false
  """
  @spec valid?(term()) :: boolean()
  def valid?(input) do
    case parse(input) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  # ============================================================================
  # Private
  # ============================================================================

  defp error_message(:not_a_string), do: "not a string"
  defp error_message(:empty_input), do: "empty input"
  defp error_message(:input_too_long), do: "input too long"
  defp error_message(:must_be_letter), do: "must be letter"
  defp error_message(:invalid_abbr), do: "invalid abbr"
  defp error_message(:invalid_side), do: "invalid side"
end
