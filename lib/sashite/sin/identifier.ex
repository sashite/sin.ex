defmodule Sashite.Sin.Identifier do
  @moduledoc """
  Represents a parsed SIN (Style Identifier Notation) identifier.

  An Identifier encodes two attributes:
  - `abbr`: the style abbreviation (A-Z as uppercase atom)
  - `side`: the player side (`:first` or `:second`)

  Identifier structs are immutable.

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

  alias Sashite.Sin.Constants

  @enforce_keys [:abbr, :side]
  defstruct [:abbr, :side]

  @typedoc "A SIN identifier struct"
  @type t :: %__MODULE__{
          abbr: atom(),
          side: :first | :second
        }

  # ==========================================================================
  # Constructor
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
    validate_abbr!(abbr)
    validate_side!(side)

    %__MODULE__{abbr: abbr, side: side}
  end

  # ==========================================================================
  # String Conversion
  # ==========================================================================

  @doc """
  Returns the SIN string representation.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> Sashite.Sin.Identifier.to_string(sin)
      "C"

      iex> sin = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.to_string(sin)
      "c"
  """
  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{abbr: abbr, side: :first}) do
    Atom.to_string(abbr)
  end

  def to_string(%__MODULE__{abbr: abbr, side: :second}) do
    abbr
    |> Atom.to_string()
    |> String.downcase()
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

  # ==========================================================================
  # Private Validation
  # ==========================================================================

  defp validate_abbr!(abbr) do
    unless Constants.valid_abbr?(abbr) do
      raise ArgumentError, "invalid abbr"
    end
  end

  defp validate_side!(side) do
    unless Constants.valid_side?(side) do
      raise ArgumentError, "invalid side"
    end
  end
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
