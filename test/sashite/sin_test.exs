defmodule Sashite.SinTest do
  use ExUnit.Case, async: true

  alias Sashite.Sin
  alias Sashite.Sin.Identifier

  doctest Sin

  # ============================================================================
  # parse/1
  # ============================================================================

  describe "parse/1" do
    test "returns {:ok, identifier} for valid uppercase" do
      assert {:ok, %Identifier{abbr: :C, side: :first}} = Sin.parse("C")
    end

    test "returns {:ok, identifier} for valid lowercase" do
      assert {:ok, %Identifier{abbr: :C, side: :second}} = Sin.parse("c")
    end

    test "returns identifier with correct attributes" do
      {:ok, sin} = Sin.parse("S")

      assert sin.abbr == :S
      assert sin.side == :first
    end

    test "parses all uppercase letters" do
      for letter <- ?A..?Z do
        input = <<letter>>
        expected_abbr = String.to_atom(input)

        assert {:ok, %Identifier{abbr: ^expected_abbr, side: :first}} = Sin.parse(input)
      end
    end

    test "parses all lowercase letters" do
      for letter <- ?a..?z do
        input = <<letter>>
        expected_abbr = input |> String.upcase() |> String.to_atom()

        assert {:ok, %Identifier{abbr: ^expected_abbr, side: :second}} = Sin.parse(input)
      end
    end

    test "returns {:error, :empty_input} for empty string" do
      assert {:error, :empty_input} = Sin.parse("")
    end

    test "returns {:error, :input_too_long} for multiple characters" do
      assert {:error, :input_too_long} = Sin.parse("CC")
    end

    test "returns {:error, :must_be_letter} for non-letter" do
      assert {:error, :must_be_letter} = Sin.parse("1")
    end
  end

  # ============================================================================
  # parse!/1
  # ============================================================================

  describe "parse!/1" do
    test "returns identifier for valid uppercase" do
      sin = Sin.parse!("C")

      assert sin.abbr == :C
      assert sin.side == :first
    end

    test "returns identifier for valid lowercase" do
      sin = Sin.parse!("c")

      assert sin.abbr == :C
      assert sin.side == :second
    end

    test "raises ArgumentError for empty string" do
      assert_raise ArgumentError, "empty input", fn ->
        Sin.parse!("")
      end
    end

    test "raises ArgumentError for input too long" do
      assert_raise ArgumentError, "input too long", fn ->
        Sin.parse!("CC")
      end
    end

    test "raises ArgumentError for non-letter" do
      assert_raise ArgumentError, "must be letter", fn ->
        Sin.parse!("1")
      end
    end
  end

  # ============================================================================
  # valid?/1
  # ============================================================================

  describe "valid?/1" do
    test "returns true for valid uppercase letters" do
      for letter <- ?A..?Z do
        assert Sin.valid?(<<letter>>)
      end
    end

    test "returns true for valid lowercase letters" do
      for letter <- ?a..?z do
        assert Sin.valid?(<<letter>>)
      end
    end

    test "returns false for empty string" do
      refute Sin.valid?("")
    end

    test "returns false for multiple characters" do
      refute Sin.valid?("CC")
    end

    test "returns false for digits" do
      refute Sin.valid?("1")
    end

    test "returns false for nil" do
      refute Sin.valid?(nil)
    end
  end

  # ============================================================================
  # Integration Tests
  # ============================================================================

  describe "integration" do
    test "parse! then query" do
      sin = Sin.parse!("S")

      assert Identifier.first_player?(sin)
      refute Identifier.second_player?(sin)
    end

    test "round-trip parse and to_string" do
      for input <- ~w(A B C S X Z a b c s x z) do
        {:ok, sin} = Sin.parse(input)
        assert Identifier.to_string(sin) == input
      end
    end
  end
end
