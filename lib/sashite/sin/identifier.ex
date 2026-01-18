defmodule Sashite.Sin.Identifier do
  @moduledoc """
  Represents a parsed SIN (Style Identifier Notation) identifier.

  An Identifier encodes two attributes:
  - `style`: the piece style (A-Z as uppercase atom)
  - `side`: the player side (`:first` or `:second`)

  Identifier structs are immutable. All transformation functions return
  new Identifier structs, leaving the original unchanged.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin.style
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

  @enforce_keys [:style, :side]
  defstruct [:style, :side]

  @typedoc "A SIN identifier struct"
  @type t :: %__MODULE__{
          style: atom(),
          side: :first | :second
        }

  # ==========================================================================
  # Constructor
  # ==========================================================================

  @doc """
  Creates a new Identifier with the given style and side.

  ## Parameters

  - `style` - The piece style (`:A` through `:Z`)
  - `side` - The player side (`:first` or `:second`)

  ## Returns

  A new `%Identifier{}` struct.

  ## Raises

  - `ArgumentError` if style or side is invalid

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin.style
      :C

      iex> sin = Sashite.Sin.Identifier.new(:S, :second)
      iex> sin.side
      :second

      iex> Sashite.Sin.Identifier.new(:invalid, :first)
      ** (ArgumentError) invalid style

      iex> Sashite.Sin.Identifier.new(:C, :invalid)
      ** (ArgumentError) invalid side
  """
  @spec new(atom(), atom()) :: t()
  def new(style, side) do
    validate_style!(style)
    validate_side!(side)

    %__MODULE__{style: style, side: side}
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
  def to_string(%__MODULE__{} = identifier) do
    letter(identifier)
  end

  @doc """
  Returns the letter component of the SIN.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> Sashite.Sin.Identifier.letter(sin)
      "C"

      iex> sin = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.letter(sin)
      "c"
  """
  @spec letter(t()) :: String.t()
  def letter(%__MODULE__{style: style, side: :first}) do
    Atom.to_string(style)
  end

  def letter(%__MODULE__{style: style, side: :second}) do
    style
    |> Atom.to_string()
    |> String.downcase()
  end

  # ==========================================================================
  # Side Transformations
  # ==========================================================================

  @doc """
  Returns a new Identifier with the opposite side.

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> flipped = Sashite.Sin.Identifier.flip(sin)
      iex> flipped.side
      :second

      iex> sin = Sashite.Sin.Identifier.new(:C, :second)
      iex> flipped = Sashite.Sin.Identifier.flip(sin)
      iex> flipped.side
      :first
  """
  @spec flip(t()) :: t()
  def flip(%__MODULE__{style: style, side: :first}) do
    %__MODULE__{style: style, side: :second}
  end

  def flip(%__MODULE__{style: style, side: :second}) do
    %__MODULE__{style: style, side: :first}
  end

  # ==========================================================================
  # Attribute Transformations
  # ==========================================================================

  @doc """
  Returns a new Identifier with a different style.

  ## Parameters

  - `identifier` - The source identifier
  - `new_style` - The new piece style (`:A` through `:Z`)

  ## Raises

  - `ArgumentError` if the style is invalid

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> changed = Sashite.Sin.Identifier.with_style(sin, :S)
      iex> changed.style
      :S

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> same = Sashite.Sin.Identifier.with_style(sin, :C)
      iex> same.style
      :C
  """
  @spec with_style(t(), atom()) :: t()
  def with_style(%__MODULE__{style: style} = identifier, new_style) when style == new_style do
    identifier
  end

  def with_style(%__MODULE__{side: side}, new_style) do
    new(new_style, side)
  end

  @doc """
  Returns a new Identifier with a different side.

  ## Parameters

  - `identifier` - The source identifier
  - `new_side` - The new side (`:first` or `:second`)

  ## Raises

  - `ArgumentError` if the side is invalid

  ## Examples

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> changed = Sashite.Sin.Identifier.with_side(sin, :second)
      iex> changed.side
      :second

      iex> sin = Sashite.Sin.Identifier.new(:C, :first)
      iex> same = Sashite.Sin.Identifier.with_side(sin, :first)
      iex> same.side
      :first
  """
  @spec with_side(t(), atom()) :: t()
  def with_side(%__MODULE__{side: side} = identifier, new_side) when side == new_side do
    identifier
  end

  def with_side(%__MODULE__{style: style}, new_side) do
    new(style, new_side)
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
  Checks if two Identifiers have the same style.

  ## Examples

      iex> sin1 = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin2 = Sashite.Sin.Identifier.new(:C, :second)
      iex> Sashite.Sin.Identifier.same_style?(sin1, sin2)
      true

      iex> sin1 = Sashite.Sin.Identifier.new(:C, :first)
      iex> sin2 = Sashite.Sin.Identifier.new(:S, :first)
      iex> Sashite.Sin.Identifier.same_style?(sin1, sin2)
      false
  """
  @spec same_style?(t(), t()) :: boolean()
  def same_style?(%__MODULE__{style: style}, %__MODULE__{style: style}), do: true
  def same_style?(%__MODULE__{}, %__MODULE__{}), do: false

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

  defp validate_style!(style) do
    unless Constants.valid_style?(style) do
      raise ArgumentError, "invalid style"
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
