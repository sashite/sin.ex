defmodule Sashite.Sin.Constants do
  @moduledoc """
  Constants for the SIN (Style Identifier Notation) specification.

  Defines valid values for styles and sides, as well as formatting constants.

  ## Examples

      iex> :C in Sashite.Sin.Constants.valid_styles()
      true

      iex> Sashite.Sin.Constants.valid_sides()
      [:first, :second]

      iex> Sashite.Sin.Constants.max_string_length()
      1

  See: https://sashite.dev/specs/sin/1.0.0/
  """

  @valid_styles ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a
  @valid_sides ~w(first second)a
  @max_string_length 1

  @doc """
  Returns the list of valid style atoms (A-Z).

  ## Examples

      iex> Sashite.Sin.Constants.valid_styles() |> length()
      26

      iex> :C in Sashite.Sin.Constants.valid_styles()
      true

      iex> :c in Sashite.Sin.Constants.valid_styles()
      false
  """
  @spec valid_styles() :: [atom()]
  def valid_styles, do: @valid_styles

  @doc """
  Returns the list of valid side atoms.

  ## Examples

      iex> Sashite.Sin.Constants.valid_sides()
      [:first, :second]
  """
  @spec valid_sides() :: [atom()]
  def valid_sides, do: @valid_sides

  @doc """
  Returns the maximum length of a valid SIN string.

  ## Examples

      iex> Sashite.Sin.Constants.max_string_length()
      1
  """
  @spec max_string_length() :: pos_integer()
  def max_string_length, do: @max_string_length

  @doc """
  Checks if the given style is valid.

  ## Examples

      iex> Sashite.Sin.Constants.valid_style?(:C)
      true

      iex> Sashite.Sin.Constants.valid_style?(:c)
      false

      iex> Sashite.Sin.Constants.valid_style?("C")
      false
  """
  @spec valid_style?(term()) :: boolean()
  def valid_style?(style) when is_atom(style), do: style in @valid_styles
  def valid_style?(_), do: false

  @doc """
  Checks if the given side is valid.

  ## Examples

      iex> Sashite.Sin.Constants.valid_side?(:first)
      true

      iex> Sashite.Sin.Constants.valid_side?(:second)
      true

      iex> Sashite.Sin.Constants.valid_side?(:third)
      false
  """
  @spec valid_side?(term()) :: boolean()
  def valid_side?(side) when is_atom(side), do: side in @valid_sides
  def valid_side?(_), do: false
end
