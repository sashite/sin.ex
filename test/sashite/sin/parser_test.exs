defmodule Sashite.Sin.ParserTest do
  use ExUnit.Case, async: true

  alias Sashite.Sin.Parser

  doctest Parser

  # ============================================================================
  # Valid Inputs - Uppercase Letters
  # ============================================================================

  describe "parse/1 with uppercase letters" do
    test "parses uppercase letter 'C'" do
      assert {:ok, %{style: :C, side: :first}} = Parser.parse("C")
    end

    test "parses uppercase letter 'S'" do
      assert {:ok, %{style: :S, side: :first}} = Parser.parse("S")
    end

    test "parses all uppercase letters A-Z" do
      for letter <- ?A..?Z do
        input = <<letter>>
        expected_style = String.to_atom(input)

        assert {:ok, %{style: ^expected_style, side: :first}} = Parser.parse(input)
      end
    end
  end

  # ============================================================================
  # Valid Inputs - Lowercase Letters
  # ============================================================================

  describe "parse/1 with lowercase letters" do
    test "parses lowercase letter 'c'" do
      assert {:ok, %{style: :C, side: :second}} = Parser.parse("c")
    end

    test "parses lowercase letter 's'" do
      assert {:ok, %{style: :S, side: :second}} = Parser.parse("s")
    end

    test "parses all lowercase letters a-z" do
      for letter <- ?a..?z do
        input = <<letter>>
        expected_style = input |> String.upcase() |> String.to_atom()

        assert {:ok, %{style: ^expected_style, side: :second}} = Parser.parse(input)
      end
    end
  end

  # ============================================================================
  # valid?/1
  # ============================================================================

  describe "valid?/1" do
    test "returns true for valid uppercase letters" do
      for letter <- ?A..?Z do
        assert Parser.valid?(<<letter>>)
      end
    end

    test "returns true for valid lowercase letters" do
      for letter <- ?a..?z do
        assert Parser.valid?(<<letter>>)
      end
    end

    test "returns false for empty string" do
      refute Parser.valid?("")
    end

    test "returns false for multiple characters" do
      refute Parser.valid?("CC")
      refute Parser.valid?("abc")
    end

    test "returns false for digits" do
      refute Parser.valid?("1")
      refute Parser.valid?("0")
    end

    test "returns false for symbols" do
      refute Parser.valid?("+")
      refute Parser.valid?("-")
      refute Parser.valid?("^")
    end

    test "returns false for nil" do
      refute Parser.valid?(nil)
    end
  end

  # ============================================================================
  # Error Cases - Empty Input
  # ============================================================================

  describe "parse/1 with empty input" do
    test "returns error for empty string" do
      assert {:error, :empty_input} = Parser.parse("")
    end
  end

  # ============================================================================
  # Error Cases - Input Too Long
  # ============================================================================

  describe "parse/1 with input too long" do
    test "returns error for two characters" do
      assert {:error, :input_too_long} = Parser.parse("CC")
    end

    test "returns error for many characters" do
      assert {:error, :input_too_long} = Parser.parse("invalid")
    end
  end

  # ============================================================================
  # Error Cases - Must Be Letter
  # ============================================================================

  describe "parse/1 with invalid characters" do
    test "returns error for digit" do
      assert {:error, :must_be_letter} = Parser.parse("1")
    end

    test "returns error for plus sign" do
      assert {:error, :must_be_letter} = Parser.parse("+")
    end

    test "returns error for minus sign" do
      assert {:error, :must_be_letter} = Parser.parse("-")
    end

    test "returns error for caret" do
      assert {:error, :must_be_letter} = Parser.parse("^")
    end

    test "returns error for space" do
      assert {:error, :must_be_letter} = Parser.parse(" ")
    end
  end

  # ============================================================================
  # Security - Null Byte Injection
  # ============================================================================

  describe "security - null byte injection" do
    test "rejects null byte alone" do
      refute Parser.valid?(<<0>>)
    end

    test "rejects letter followed by null byte" do
      refute Parser.valid?("C" <> <<0>>)
    end

    test "rejects null byte followed by letter" do
      refute Parser.valid?(<<0>> <> "C")
    end
  end

  # ============================================================================
  # Security - Control Characters
  # ============================================================================

  describe "security - control characters" do
    test "rejects newline" do
      refute Parser.valid?("\n")
      refute Parser.valid?("C\n")
    end

    test "rejects carriage return" do
      refute Parser.valid?("\r")
      refute Parser.valid?("C\r")
    end

    test "rejects tab" do
      refute Parser.valid?("\t")
      refute Parser.valid?("C\t")
    end

    test "rejects other control characters" do
      refute Parser.valid?(<<1>>)    # SOH
      refute Parser.valid?(<<27>>)   # ESC
      refute Parser.valid?(<<127>>)  # DEL
    end
  end

  # ============================================================================
  # Security - Unicode Lookalikes
  # ============================================================================

  describe "security - Unicode lookalikes" do
    test "rejects Cyrillic lookalikes" do
      # Cyrillic 'К' (U+041A) looks like Latin 'K'
      refute Parser.valid?(<<0xD0, 0x9A>>)
      # Cyrillic 'а' (U+0430) looks like Latin 'a'
      refute Parser.valid?(<<0xD0, 0xB0>>)
      # Cyrillic 'С' (U+0421) looks like Latin 'C'
      refute Parser.valid?(<<0xD0, 0xA1>>)
    end

    test "rejects Greek lookalikes" do
      # Greek 'Α' (U+0391) looks like Latin 'A'
      refute Parser.valid?(<<0xCE, 0x91>>)
    end

    test "rejects full-width characters" do
      # Full-width 'C' (U+FF23)
      refute Parser.valid?(<<0xEF, 0xBC, 0xA3>>)
      # Full-width 'c' (U+FF43)
      refute Parser.valid?(<<0xEF, 0xBD, 0x83>>)
    end
  end

  # ============================================================================
  # Security - Combining Characters
  # ============================================================================

  describe "security - combining characters" do
    test "rejects combining acute accent" do
      # 'C' + combining acute accent (U+0301)
      refute Parser.valid?("C" <> <<0xCC, 0x81>>)
    end

    test "rejects combining diaeresis" do
      # 'C' + combining diaeresis (U+0308)
      refute Parser.valid?("C" <> <<0xCC, 0x88>>)
    end
  end

  # ============================================================================
  # Security - Zero-Width Characters
  # ============================================================================

  describe "security - zero-width characters" do
    test "rejects zero-width space" do
      # Zero-width space (U+200B)
      refute Parser.valid?(<<0xE2, 0x80, 0x8B>>)
      refute Parser.valid?("C" <> <<0xE2, 0x80, 0x8B>>)
    end

    test "rejects zero-width non-joiner" do
      # Zero-width non-joiner (U+200C)
      refute Parser.valid?(<<0xE2, 0x80, 0x8C>>)
    end

    test "rejects BOM" do
      # Byte order mark (U+FEFF)
      refute Parser.valid?(<<0xEF, 0xBB, 0xBF>>)
      refute Parser.valid?(<<0xEF, 0xBB, 0xBF>> <> "C")
    end
  end

  # ============================================================================
  # Security - Non-String Input
  # ============================================================================

  describe "security - non-string input" do
    test "rejects nil" do
      refute Parser.valid?(nil)
    end

    test "rejects integer" do
      refute Parser.valid?(123)
    end

    test "rejects list" do
      refute Parser.valid?([?C])
    end

    test "rejects atom" do
      refute Parser.valid?(:C)
    end

    test "rejects map" do
      refute Parser.valid?(%{style: :C})
    end
  end

  # ============================================================================
  # Round-Trip Tests
  # ============================================================================

  describe "round-trip" do
    test "round-trip uppercase letters" do
      for letter <- ?A..?Z do
        input = <<letter>>
        {:ok, result} = Parser.parse(input)

        identifier = Sashite.Sin.Identifier.new(result.style, result.side)
        assert Sashite.Sin.Identifier.to_string(identifier) == input
      end
    end

    test "round-trip lowercase letters" do
      for letter <- ?a..?z do
        input = <<letter>>
        {:ok, result} = Parser.parse(input)

        identifier = Sashite.Sin.Identifier.new(result.style, result.side)
        assert Sashite.Sin.Identifier.to_string(identifier) == input
      end
    end
  end
end
