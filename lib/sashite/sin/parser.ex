defmodule Sashite.Sin.Parser do
  @moduledoc """
  Parses SIN (Style Identifier Notation) strings.

  The parser uses byte-level validation to ensure security against
  malformed input, Unicode lookalikes, and injection attacks.

  ## Examples

      iex> Sashite.Sin.Parser.parse("C")
      {:ok, %{abbr: :C, side: :first}}

      iex> Sashite.Sin.Parser.parse("c")
      {:ok, %{abbr: :C, side: :second}}

      iex> Sashite.Sin.Parser.parse("")
      {:error, :empty_input}

      iex> Sashite.Sin.Parser.parse("CC")
      {:error, :input_too_long}

  See: https://sashite.dev/specs/sin/1.0.0/
  """

  alias Sashite.Sin.Constants

  @doc """
  Parses a SIN string into its components.

  ## Parameters

  - `input` - The SIN string to parse

  ## Returns

  - `{:ok, %{abbr: atom, side: atom}}` on success
  - `{:error, reason}` on failure

  ## Error Reasons

  - `:empty_input` - String length is 0
  - `:input_too_long` - String exceeds 1 character
  - `:must_be_letter` - Character is not A-Z or a-z

  ## Examples

      iex> Sashite.Sin.Parser.parse("C")
      {:ok, %{abbr: :C, side: :first}}

      iex> Sashite.Sin.Parser.parse("s")
      {:ok, %{abbr: :S, side: :second}}

      iex> Sashite.Sin.Parser.parse("")
      {:error, :empty_input}

      iex> Sashite.Sin.Parser.parse("CC")
      {:error, :input_too_long}

      iex> Sashite.Sin.Parser.parse("1")
      {:error, :must_be_letter}
  """
  @spec parse(String.t()) :: {:ok, %{abbr: atom(), side: atom()}} | {:error, atom()}
  def parse(input) when is_binary(input) do
    with :ok <- validate_not_empty(input),
         :ok <- validate_length(input),
         {:ok, byte} <- extract_byte(input) do
      parse_byte(byte)
    end
  end

  def parse(_), do: {:error, :must_be_letter}

  @doc """
  Reports whether the input is a valid SIN string.

  ## Examples

      iex> Sashite.Sin.Parser.valid?("C")
      true

      iex> Sashite.Sin.Parser.valid?("c")
      true

      iex> Sashite.Sin.Parser.valid?("")
      false

      iex> Sashite.Sin.Parser.valid?("CC")
      false

      iex> Sashite.Sin.Parser.valid?("1")
      false

      iex> Sashite.Sin.Parser.valid?(nil)
      false
  """
  @spec valid?(term()) :: boolean()
  def valid?(input) do
    case parse(input) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  # ==========================================================================
  # Private Validation
  # ==========================================================================

  defp validate_not_empty(""), do: {:error, :empty_input}
  defp validate_not_empty(_), do: :ok

  defp validate_length(input) do
    if byte_size(input) > Constants.max_string_length() do
      {:error, :input_too_long}
    else
      :ok
    end
  end

  defp extract_byte(<<byte>>), do: {:ok, byte}
  defp extract_byte(_), do: {:error, :must_be_letter}

  # ==========================================================================
  # Private Parsing
  # ==========================================================================

  # Uppercase letter (A-Z): 0x41-0x5A
  defp parse_byte(byte) when byte >= 0x41 and byte <= 0x5A do
    abbr = <<byte>> |> String.to_atom()
    {:ok, %{abbr: abbr, side: :first}}
  end

  # Lowercase letter (a-z): 0x61-0x7A
  defp parse_byte(byte) when byte >= 0x61 and byte <= 0x7A do
    abbr = <<byte>> |> String.upcase() |> String.to_atom()
    {:ok, %{abbr: abbr, side: :second}}
  end

  # Any other byte
  defp parse_byte(_), do: {:error, :must_be_letter}
end
