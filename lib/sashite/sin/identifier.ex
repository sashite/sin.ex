defmodule Sashite.Sin.Identifier do
  @moduledoc """
  Represents a parsed SIN (Style Identifier Notation) identifier.

  An Identifier encodes two attributes:
  - `abbr`: the style abbreviation (A-Z as uppercase atom)
  - `side`: the player side (`:first` or `:second`)

  Identifier structs are immutable. All string conversions and constructors
  use compile-time generated function clauses for zero-overhead dispatch.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin.abbr
      :C
      iex> sin.side
      :first

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> Sashite.Sin.Identifier.to_string(sin)
      "C"

      iex> sin = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.to_string(sin)
      "c"

  See: https://sashite.dev/specs/sin/1.0.0/
  """

  @enforce_keys [:abbr, :side]
  defstruct [:abbr, :side]

  @typedoc "A SIN identifier struct"
  @type t :: %__MODULE__{
          abbr: atom(),
          side: :first | :second
        }

  # ==========================================================================
  # Constructor (raising)
  # ==========================================================================

  @doc """
  Creates a new Identifier with the given abbreviation and side.

  ## Parameters

  - `abbr` - The style abbreviation (`:A` through `:Z`)
  - `side` - The player side (`:first` or `:second`)

  ## Returns

  A new `%Identifier{}` struct.

  ## Raises

  - `ArgumentError` if abbr or side is invalid

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin.abbr
      :C

      iex> sin = Sashite.Sin.Identifier.new(:S, :second)
      iex> sin.side
      :second

      iex> Sashite.Sin.Identifier.new(:invalid, :first)
      ** (ArgumentError) invalid abbr

      iex> Sashite.Sin.Identifier.new(:C, :invalid)
      ** (ArgumentError) invalid side
  """
  @spec new(atom(), atom()) :: t()
  def new(abbr, side) do
    case build(abbr, side) do
      {:ok, identifier} -> identifier
      {:error, :invalid_abbr} -> raise ArgumentError, "invalid abbr"
      {:error, :invalid_side} -> raise ArgumentError, "invalid side"
    end
  end

  # ==========================================================================
  # Constructor (safe)
  # ==========================================================================

  @doc """
  Creates a new Identifier with the given abbreviation and side.

  Returns `{:ok, identifier}` on success, `{:error, reason}` on failure.
  Never raises. Never allocates exception objects.

  ## Parameters

  - `abbr` - The style abbreviation (`:A` through `:Z`)
  - `side` - The player side (`:first` or `:second`)

  ## Examples

      iex> {:ok, sin} = Sashite.Sin.Identifier.build(:C, :first)
      iex> sin.abbr
      :C

      iex> {:ok, sin} = Sashite.Sin.Identifier.build(:S, :second)
      iex> sin.side
      :second

      iex> Sashite.Sin.Identifier.build(:invalid, :first)
      {:error, :invalid_abbr}

      iex> Sashite.Sin.Identifier.build(:C, :invalid)
      {:error, :invalid_side}
  """
  @spec build(atom(), atom()) :: {:ok, t()} | {:error, :invalid_abbr | :invalid_side}

  # -- 52 compile-time generated clauses (26 letters × 2 sides) ---------------

  for letter <- ?A..?Z do
    abbr = List.to_atom([letter])

    def build(unquote(abbr), :first) do
      {:ok, %__MODULE__{abbr: unquote(abbr), side: :first}}
    end

    def build(unquote(abbr), :second) do
      {:ok, %__MODULE__{abbr: unquote(abbr), side: :second}}
    end
  end

  # -- Catch-all: determine which component is invalid -------------------------

  def build(_abbr, side) when side in [:first, :second], do: {:error, :invalid_abbr}
  def build(_abbr, _side), do: {:error, :invalid_side}

  # ==========================================================================
  # String Conversion — 52 compile-time generated clauses
  # ==========================================================================

  @doc """
  Returns the SIN string representation.

  Each clause returns a pre-computed binary literal. No `Atom.to_string/1`
  or `String.downcase/1` is called at runtime.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> Sashite.Sin.Identifier.to_string(sin)
      "C"

      iex> sin = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.to_string(sin)
      "c"
  """
  @spec to_string(t()) :: String.t()

  for letter <- ?A..?Z do
    abbr = List.to_atom([letter])
    upper = <<letter>>
    lower = <<letter + 32>>

    def to_string(%__MODULE__{abbr: unquote(abbr), side: :first}), do: unquote(upper)
    def to_string(%__MODULE__{abbr: unquote(abbr), side: :second}), do: unquote(lower)
  end

  # ==========================================================================
  # Side Queries
  # ==========================================================================

  @doc """
  Checks if the Identifier belongs to the first player.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> Sashite.Sin.Identifier.first_player?(sin)
      true

      iex> sin = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.first_player?(sin)
      false
  """
  @spec first_player?(t()) :: boolean()
  def first_player?(%__MODULE__{side: :first}), do: true
  def first_player?(%__MODULE__{side: :second}), do: false

  @doc """
  Checks if the Identifier belongs to the second player.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.second_player?(sin)
      true

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> Sashite.Sin.Identifier.second_player?(sin)
      false
  """
  @spec second_player?(t()) :: boolean()
  def second_player?(%__MODULE__{side: :second}), do: true
  def second_player?(%__MODULE__{side: :first}), do: false

  # ==========================================================================
  # Comparison Queries
  # ==========================================================================

  @doc """
  Checks if two Identifiers have the same abbreviation.

  ## Examples

      iex> sin1 = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin2 = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.same_abbr?(sin1, sin2)
      true

      iex> sin1 = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin2 = Sashite.Sin.Identifier.new(:S, :first)
      iex> Sashite.Sin.Identifier.same_abbr?(sin1, sin2)
      false
  """
  @spec same_abbr?(t(), t()) :: boolean()
  def same_abbr?(%__MODULE__{abbr: abbr}, %__MODULE__{abbr: abbr}), do: true
  def same_abbr?(%__MODULE__{}, %__MODULE__{}), do: false

  @doc """
  Checks if two Identifiers have the same side.

  ## Examples

      iex> sin1 = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin2 = Sashite.Sin.Identifier.new(:S, :first)
      iex> Sashite.Sin.Identifier.same_side?(sin1, sin2)
      true

      iex> sin1 = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin2 = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.same_side?(sin1, sin2)
      false
  """
  @spec same_side?(t(), t()) :: boolean()
  def same_side?(%__MODULE__{side: side}, %__MODULE__{side: side}), do: true
  def same_side?(%__MODULE__{}, %__MODULE__{}), do: false
end

defimpl String.Chars, for: Sashite.Sin.Identifier do
  def to_string(identifier) do
    Sashite.Sin.Identifier.to_string(identifier)
  end
end

defimpl Inspect, for: Sashite.Sin.Identifier do
  def inspect(identifier, _opts) do
    "#Sashite.Sin.Identifier<#{Sashite.Sin.Identifier.to_string(identifier)}>"
  end
end
