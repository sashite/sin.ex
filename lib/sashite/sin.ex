defmodule Sashite.Sin do
  @moduledoc """
  SIN (Style Identifier Notation) implementation for Elixir.

  SIN provides a compact, ASCII-based format for encoding **Piece Style** with an
  associated **Side** in abstract strategy board games. It serves as a minimal
  building block that can be embedded in higher-level notations.

  ## Format

      <letter>

  A SIN token is **exactly one** ASCII letter (`A-Z` or `a-z`).

  ## Attributes

  A SIN token encodes exactly two attributes:

  - **Piece Style** → the base letter (case-insensitive): `C` and `c` represent the same style
  - **Side** → the case of that letter (uppercase = first, lowercase = second)

  ## Examples

      iex> Sashite.Sin.parse("C")
      {:ok, %Sashite.Sin{style: :C, side: :first}}

      iex> Sashite.Sin.parse!("s")
      %Sashite.Sin{style: :S, side: :second}

      iex> Sashite.Sin.valid?("X")
      true

      iex> Sashite.Sin.valid?("CC")
      false

  See the [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) for details.
  """

  @type piece_style ::
          :A | :B | :C | :D | :E | :F | :G | :H | :I | :J | :K | :L | :M
          | :N | :O | :P | :Q | :R | :S | :T | :U | :V | :W | :X | :Y | :Z

  @type side :: :first | :second

  @type t :: %__MODULE__{
          style: piece_style(),
          side: side()
        }

  @enforce_keys [:style, :side]
  defstruct [:style, :side]

  @valid_styles ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a
  @valid_sides [:first, :second]

  @sin_pattern ~r/\A[a-zA-Z]\z/

  # ==========================================================================
  # Creation and Parsing
  # ==========================================================================

  @doc """
  Creates a new SIN struct.

  ## Parameters

  - `style` - Piece style (`:A` to `:Z`)
  - `side` - Player side (`:first` or `:second`)

  ## Examples

      iex> Sashite.Sin.new(:C, :first)
      %Sashite.Sin{style: :C, side: :first}

      iex> Sashite.Sin.new(:S, :second)
      %Sashite.Sin{style: :S, side: :second}

  """
  @spec new(piece_style(), side()) :: t()
  def new(style, side) do
    validate_style!(style)
    validate_side!(side)

    %__MODULE__{
      style: style,
      side: side
    }
  end

  @doc """
  Parses a SIN string into a SIN struct.

  Returns `{:ok, sin}` on success, `{:error, reason}` on failure.

  ## Examples

      iex> Sashite.Sin.parse("C")
      {:ok, %Sashite.Sin{style: :C, side: :first}}

      iex> Sashite.Sin.parse("s")
      {:ok, %Sashite.Sin{style: :S, side: :second}}

      iex> Sashite.Sin.parse("CC")
      {:error, "Invalid SIN string: CC"}

      iex> Sashite.Sin.parse("")
      {:error, "Invalid SIN string: "}

  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(sin_string) when is_binary(sin_string) do
    if Regex.match?(@sin_pattern, sin_string) do
      style = sin_string |> String.upcase() |> String.to_atom()
      side = if sin_string == String.upcase(sin_string), do: :first, else: :second

      {:ok, %__MODULE__{style: style, side: side}}
    else
      {:error, "Invalid SIN string: #{sin_string}"}
    end
  end

  def parse(sin_string) do
    {:error, "Invalid SIN string: #{inspect(sin_string)}"}
  end

  @doc """
  Parses a SIN string into a SIN struct.

  Returns the SIN struct on success, raises `ArgumentError` on failure.

  ## Examples

      iex> Sashite.Sin.parse!("C")
      %Sashite.Sin{style: :C, side: :first}

      iex> Sashite.Sin.parse!("CC")
      ** (ArgumentError) Invalid SIN string: CC

  """
  @spec parse!(String.t()) :: t()
  def parse!(sin_string) do
    case parse(sin_string) do
      {:ok, sin} -> sin
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @doc """
  Checks if a string is a valid SIN notation.

  ## Examples

      iex> Sashite.Sin.valid?("C")
      true

      iex> Sashite.Sin.valid?("s")
      true

      iex> Sashite.Sin.valid?("CC")
      false

      iex> Sashite.Sin.valid?("")
      false

      iex> Sashite.Sin.valid?("1")
      false

  """
  @spec valid?(String.t()) :: boolean()
  def valid?(sin_string) when is_binary(sin_string) do
    Regex.match?(@sin_pattern, sin_string)
  end

  def valid?(_), do: false

  # ==========================================================================
  # Conversion
  # ==========================================================================

  @doc """
  Converts a SIN struct to its string representation.

  ## Examples

      iex> sin = Sashite.Sin.new(:C, :first)
      iex> Sashite.Sin.to_string(sin)
      "C"

      iex> sin = Sashite.Sin.new(:S, :second)
      iex> Sashite.Sin.to_string(sin)
      "s"

  """
  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{} = sin) do
    letter(sin)
  end

  @doc """
  Returns the letter representation of the SIN.

  ## Examples

      iex> sin = Sashite.Sin.new(:C, :first)
      iex> Sashite.Sin.letter(sin)
      "C"

      iex> sin = Sashite.Sin.new(:C, :second)
      iex> Sashite.Sin.letter(sin)
      "c"

  """
  @spec letter(t()) :: String.t()
  def letter(%__MODULE__{style: style, side: :first}) do
    Atom.to_string(style)
  end

  def letter(%__MODULE__{style: style, side: :second}) do
    style |> Atom.to_string() |> String.downcase()
  end

  # ==========================================================================
  # Side Transformations
  # ==========================================================================

  @doc """
  Returns a new SIN with the opposite side.

  ## Examples

      iex> sin = Sashite.Sin.new(:C, :first)
      iex> flipped = Sashite.Sin.flip(sin)
      iex> flipped.side
      :second

      iex> sin = Sashite.Sin.new(:S, :second)
      iex> flipped = Sashite.Sin.flip(sin)
      iex> flipped.side
      :first

  """
  @spec flip(t()) :: t()
  def flip(%__MODULE__{side: :first} = sin), do: %{sin | side: :second}
  def flip(%__MODULE__{side: :second} = sin), do: %{sin | side: :first}

  # ==========================================================================
  # Attribute Transformations
  # ==========================================================================

  @doc """
  Returns a new SIN with a different style.

  ## Examples

      iex> sin = Sashite.Sin.new(:C, :first)
      iex> shogi = Sashite.Sin.with_style(sin, :S)
      iex> shogi.style
      :S

  """
  @spec with_style(t(), piece_style()) :: t()
  def with_style(%__MODULE__{style: style} = sin, style), do: sin

  def with_style(%__MODULE__{} = sin, new_style) do
    validate_style!(new_style)
    %{sin | style: new_style}
  end

  @doc """
  Returns a new SIN with a different side.

  ## Examples

      iex> sin = Sashite.Sin.new(:C, :first)
      iex> second = Sashite.Sin.with_side(sin, :second)
      iex> second.side
      :second

  """
  @spec with_side(t(), side()) :: t()
  def with_side(%__MODULE__{side: side} = sin, side), do: sin

  def with_side(%__MODULE__{} = sin, new_side) do
    validate_side!(new_side)
    %{sin | side: new_side}
  end

  # ==========================================================================
  # Side Queries
  # ==========================================================================

  @doc """
  Checks if the SIN belongs to the first player.

  ## Examples

      iex> sin = Sashite.Sin.new(:C, :first)
      iex> Sashite.Sin.first_player?(sin)
      true

      iex> sin = Sashite.Sin.new(:C, :second)
      iex> Sashite.Sin.first_player?(sin)
      false

  """
  @spec first_player?(t()) :: boolean()
  def first_player?(%__MODULE__{side: :first}), do: true
  def first_player?(%__MODULE__{}), do: false

  @doc """
  Checks if the SIN belongs to the second player.

  ## Examples

      iex> sin = Sashite.Sin.new(:C, :second)
      iex> Sashite.Sin.second_player?(sin)
      true

      iex> sin = Sashite.Sin.new(:C, :first)
      iex> Sashite.Sin.second_player?(sin)
      false

  """
  @spec second_player?(t()) :: boolean()
  def second_player?(%__MODULE__{side: :second}), do: true
  def second_player?(%__MODULE__{}), do: false

  # ==========================================================================
  # Comparison
  # ==========================================================================

  @doc """
  Checks if two SINs have the same style.

  ## Examples

      iex> sin1 = Sashite.Sin.parse!("C")
      iex> sin2 = Sashite.Sin.parse!("c")
      iex> Sashite.Sin.same_style?(sin1, sin2)
      true

      iex> sin1 = Sashite.Sin.parse!("C")
      iex> sin2 = Sashite.Sin.parse!("S")
      iex> Sashite.Sin.same_style?(sin1, sin2)
      false

  """
  @spec same_style?(t(), t()) :: boolean()
  def same_style?(%__MODULE__{style: style}, %__MODULE__{style: style}), do: true
  def same_style?(%__MODULE__{}, %__MODULE__{}), do: false

  @doc """
  Checks if two SINs have the same side.

  ## Examples

      iex> sin1 = Sashite.Sin.parse!("C")
      iex> sin2 = Sashite.Sin.parse!("S")
      iex> Sashite.Sin.same_side?(sin1, sin2)
      true

      iex> sin1 = Sashite.Sin.parse!("C")
      iex> sin2 = Sashite.Sin.parse!("c")
      iex> Sashite.Sin.same_side?(sin1, sin2)
      false

  """
  @spec same_side?(t(), t()) :: boolean()
  def same_side?(%__MODULE__{side: side}, %__MODULE__{side: side}), do: true
  def same_side?(%__MODULE__{}, %__MODULE__{}), do: false

  # ==========================================================================
  # Private Validation
  # ==========================================================================

  defp validate_style!(style) do
    unless style in @valid_styles do
      raise ArgumentError, "Style must be an atom from :A to :Z, got: #{inspect(style)}"
    end
  end

  defp validate_side!(side) do
    unless side in @valid_sides do
      raise ArgumentError, "Side must be :first or :second, got: #{inspect(side)}"
    end
  end
end

defimpl String.Chars, for: Sashite.Sin do
  def to_string(sin) do
    Sashite.Sin.to_string(sin)
  end
end

defimpl Inspect, for: Sashite.Sin do
  def inspect(sin, _opts) do
    "#Sashite.Sin<#{Sashite.Sin.to_string(sin)}>"
  end
end
