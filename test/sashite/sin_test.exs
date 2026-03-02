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

    test "returns {:error, :input_too_long} for many characters" do
      assert {:error, :input_too_long} = Sin.parse("invalid")
    end

    test "returns {:error, :must_be_letter} for digit" do
      assert {:error, :must_be_letter} = Sin.parse("1")
    end

    test "returns {:error, :must_be_letter} for plus sign" do
      assert {:error, :must_be_letter} = Sin.parse("+")
    end

    test "returns {:error, :must_be_letter} for minus sign" do
      assert {:error, :must_be_letter} = Sin.parse("-")
    end

    test "returns {:error, :must_be_letter} for caret" do
      assert {:error, :must_be_letter} = Sin.parse("^")
    end

    test "returns {:error, :must_be_letter} for space" do
      assert {:error, :must_be_letter} = Sin.parse(" ")
    end

    test "returns {:error, :not_a_string} for non-string input" do
      assert {:error, :not_a_string} = Sin.parse(nil)
      assert {:error, :not_a_string} = Sin.parse(123)
      assert {:error, :not_a_string} = Sin.parse([?C])
      assert {:error, :not_a_string} = Sin.parse(:C)
      assert {:error, :not_a_string} = Sin.parse(%{abbr: :C})
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

    test "raises ArgumentError for non-string input" do
      assert_raise ArgumentError, "not a string", fn ->
        Sin.parse!(nil)
      end
    end
  end

  # ============================================================================
  # fetch/2
  # ============================================================================

  describe "fetch/2" do
    test "returns {:ok, identifier} for valid abbr and first side" do
      assert {:ok, %Identifier{abbr: :C, side: :first}} = Sin.fetch(:C, :first)
    end

    test "returns {:ok, identifier} for valid abbr and second side" do
      assert {:ok, %Identifier{abbr: :C, side: :second}} = Sin.fetch(:C, :second)
    end

    test "fetches all 26 abbreviations with both sides" do
      for letter <- ?A..?Z do
        abbr = List.to_atom([letter])

        assert {:ok, %Identifier{abbr: ^abbr, side: :first}} = Sin.fetch(abbr, :first)
        assert {:ok, %Identifier{abbr: ^abbr, side: :second}} = Sin.fetch(abbr, :second)
      end
    end

    test "returns {:error, :invalid_abbr} for invalid abbreviation" do
      assert {:error, :invalid_abbr} = Sin.fetch(:CC, :first)
      assert {:error, :invalid_abbr} = Sin.fetch(:c, :first)
      assert {:error, :invalid_abbr} = Sin.fetch(:invalid, :first)
    end

    test "returns {:error, :invalid_side} for invalid side" do
      assert {:error, :invalid_side} = Sin.fetch(:C, :third)
      assert {:error, :invalid_side} = Sin.fetch(:C, "first")
    end
  end

  # ============================================================================
  # fetch!/2
  # ============================================================================

  describe "fetch!/2" do
    test "returns identifier for valid abbr and side" do
      sin = Sin.fetch!(:C, :first)

      assert sin.abbr == :C
      assert sin.side == :first
    end

    test "returns identifier for second side" do
      sin = Sin.fetch!(:S, :second)

      assert sin.abbr == :S
      assert sin.side == :second
    end

    test "raises ArgumentError for invalid abbr" do
      assert_raise ArgumentError, "invalid abbr", fn ->
        Sin.fetch!(:CC, :first)
      end
    end

    test "raises ArgumentError for invalid side" do
      assert_raise ArgumentError, "invalid side", fn ->
        Sin.fetch!(:C, :third)
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
      refute Sin.valid?("0")
    end

    test "returns false for symbols" do
      refute Sin.valid?("+")
      refute Sin.valid?("-")
      refute Sin.valid?("^")
    end

    test "returns false for nil" do
      refute Sin.valid?(nil)
    end
  end

  # ============================================================================
  # Security — Null Byte Injection
  # ============================================================================

  describe "security - null byte injection" do
    test "rejects null byte alone" do
      refute Sin.valid?(<<0>>)
    end

    test "rejects letter followed by null byte" do
      refute Sin.valid?("C" <> <<0>>)
    end

    test "rejects null byte followed by letter" do
      refute Sin.valid?(<<0>> <> "C")
    end
  end

  # ============================================================================
  # Security — Control Characters
  # ============================================================================

  describe "security - control characters" do
    test "rejects newline" do
      refute Sin.valid?("\n")
      refute Sin.valid?("C\n")
    end

    test "rejects carriage return" do
      refute Sin.valid?("\r")
      refute Sin.valid?("C\r")
    end

    test "rejects tab" do
      refute Sin.valid?("\t")
      refute Sin.valid?("C\t")
    end

    test "rejects other control characters" do
      # SOH
      refute Sin.valid?(<<1>>)
      # ESC
      refute Sin.valid?(<<27>>)
      # DEL
      refute Sin.valid?(<<127>>)
    end
  end

  # ============================================================================
  # Security — Unicode Lookalikes
  # ============================================================================

  describe "security - Unicode lookalikes" do
    test "rejects Cyrillic lookalikes" do
      # Cyrillic 'К' (U+041A) looks like Latin 'K'
      refute Sin.valid?(<<0xD0, 0x9A>>)
      # Cyrillic 'а' (U+0430) looks like Latin 'a'
      refute Sin.valid?(<<0xD0, 0xB0>>)
      # Cyrillic 'С' (U+0421) looks like Latin 'C'
      refute Sin.valid?(<<0xD0, 0xA1>>)
    end

    test "rejects Greek lookalikes" do
      # Greek 'Α' (U+0391) looks like Latin 'A'
      refute Sin.valid?(<<0xCE, 0x91>>)
    end

    test "rejects full-width characters" do
      # Full-width 'C' (U+FF23)
      refute Sin.valid?(<<0xEF, 0xBC, 0xA3>>)
      # Full-width 'c' (U+FF43)
      refute Sin.valid?(<<0xEF, 0xBD, 0x83>>)
    end
  end

  # ============================================================================
  # Security — Combining Characters
  # ============================================================================

  describe "security - combining characters" do
    test "rejects combining acute accent" do
      # 'C' + combining acute accent (U+0301)
      refute Sin.valid?("C" <> <<0xCC, 0x81>>)
    end

    test "rejects combining diaeresis" do
      # 'C' + combining diaeresis (U+0308)
      refute Sin.valid?("C" <> <<0xCC, 0x88>>)
    end
  end

  # ============================================================================
  # Security — Zero-Width Characters
  # ============================================================================

  describe "security - zero-width characters" do
    test "rejects zero-width space" do
      # Zero-width space (U+200B)
      refute Sin.valid?(<<0xE2, 0x80, 0x8B>>)
      refute Sin.valid?("C" <> <<0xE2, 0x80, 0x8B>>)
    end

    test "rejects zero-width non-joiner" do
      # Zero-width non-joiner (U+200C)
      refute Sin.valid?(<<0xE2, 0x80, 0x8C>>)
    end

    test "rejects BOM" do
      # Byte order mark (U+FEFF)
      refute Sin.valid?(<<0xEF, 0xBB, 0xBF>>)
      refute Sin.valid?(<<0xEF, 0xBB, 0xBF>> <> "C")
    end
  end

  # ============================================================================
  # Integration
  # ============================================================================

  describe "integration" do
    test "parse! then query" do
      sin = Sin.parse!("S")

      assert Identifier.first_player?(sin)
      refute Identifier.second_player?(sin)
    end

    test "round-trip parse and to_string for representative tokens" do
      for input <- ~w(A B C S X Z a b c s x z) do
        {:ok, sin} = Sin.parse(input)
        assert Identifier.to_string(sin) == input
      end
    end

    test "round-trip all 52 uppercase tokens" do
      for letter <- ?A..?Z do
        input = <<letter>>
        {:ok, sin} = Sin.parse(input)
        assert Identifier.to_string(sin) == input
      end
    end

    test "round-trip all 52 lowercase tokens" do
      for letter <- ?a..?z do
        input = <<letter>>
        {:ok, sin} = Sin.parse(input)
        assert Identifier.to_string(sin) == input
      end
    end
  end

  # ============================================================================
  # Consistency: parse/1 and fetch/2 produce identical results
  # ============================================================================

  describe "parse/1 and fetch/2 consistency" do
    test "produce identical structs for all 52 valid tokens" do
      for letter <- ?A..?Z do
        abbr = List.to_atom([letter])

        {:ok, from_parse} = Sin.parse(<<letter>>)
        {:ok, from_fetch} = Sin.fetch(abbr, :first)
        assert from_parse == from_fetch

        {:ok, from_parse} = Sin.parse(<<letter + 32>>)
        {:ok, from_fetch} = Sin.fetch(abbr, :second)
        assert from_parse == from_fetch
      end
    end
  end
end
