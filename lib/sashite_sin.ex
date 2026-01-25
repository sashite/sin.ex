defmodule Sashite.Sin do
  @moduledoc """
  SIN (Style Identifier Notation) implementation for Elixir.

  SIN provides a compact, ASCII-based format for encoding Player Style
  with Player Side assignment in abstract strategy board games.

  A SIN token is exactly one ASCII letter:
  - Uppercase (A-Z) indicates first player
  - Lowercase (a-z) indicates second player

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
  alias Sashite.Sin.Parser

  @doc """
  Parses a SIN string into an Identifier.

  ## Parameters

  - `input` - The SIN string to parse

  ## Returns

  - `{:ok, %Identifier{}}` on success
  - `{:error, reason}` on failure

  ## Error Reasons

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
  """
  @spec parse(String.t()) :: {:ok, Identifier.t()} | {:error, atom()}
  def parse(input) do
    case Parser.parse(input) do
      {:ok, %{abbr: abbr, side: side}} ->
        {:ok, Identifier.new(abbr, side)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Parses a SIN string into an Identifier, raising on error.

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
  """
  @spec parse!(String.t()) :: Identifier.t()
  def parse!(input) do
    case parse(input) do
      {:ok, identifier} ->
        identifier

      {:error, reason} ->
        raise ArgumentError, error_message(reason)
    end
  end

  @doc """
  Reports whether the input is a valid SIN string.

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
    Parser.valid?(input)
  end

  # ==========================================================================
  # Private Helpers
  # ==========================================================================

  defp error_message(:empty_input), do: "empty input"
  defp error_message(:input_too_long), do: "input too long"
  defp error_message(:must_be_letter), do: "must be letter"
end
