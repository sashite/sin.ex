defmodule Sashite.Sin.IdentifierTest do
  use ExUnit.Case, async: true

  alias Sashite.Sin.Identifier

  doctest Identifier

  # ============================================================================
  # build/2 (safe constructor)
  # ============================================================================

  describe "build/2" do
    test "returns {:ok, identifier} for valid abbr and first side" do
      assert {:ok, %Identifier{abbr: :C, side: :first}} = Identifier.build(:C, :first)
    end

    test "returns {:ok, identifier} for valid abbr and second side" do
      assert {:ok, %Identifier{abbr: :S, side: :second}} = Identifier.build(:S, :second)
    end

    test "builds all 26 abbreviations with first side" do
      for letter <- ?A..?Z do
        abbr = List.to_atom([letter])
        assert {:ok, %Identifier{abbr: ^abbr, side: :first}} = Identifier.build(abbr, :first)
      end
    end

    test "builds all 26 abbreviations with second side" do
      for letter <- ?A..?Z do
        abbr = List.to_atom([letter])
        assert {:ok, %Identifier{abbr: ^abbr, side: :second}} = Identifier.build(abbr, :second)
      end
    end

    test "returns {:error, :invalid_abbr} for lowercase atom" do
      assert {:error, :invalid_abbr} = Identifier.build(:c, :first)
    end

    test "returns {:error, :invalid_abbr} for multi-letter atom" do
      assert {:error, :invalid_abbr} = Identifier.build(:CC, :first)
    end

    test "returns {:error, :invalid_abbr} for non-letter atom" do
      assert {:error, :invalid_abbr} = Identifier.build(:invalid, :first)
    end

    test "returns {:error, :invalid_abbr} for string" do
      assert {:error, :invalid_abbr} = Identifier.build("C", :first)
    end

    test "returns {:error, :invalid_abbr} for integer" do
      assert {:error, :invalid_abbr} = Identifier.build(67, :first)
    end

    test "returns {:error, :invalid_side} for invalid side atom" do
      assert {:error, :invalid_side} = Identifier.build(:C, :third)
    end

    test "returns {:error, :invalid_side} for string side" do
      assert {:error, :invalid_side} = Identifier.build(:C, "first")
    end

    test "returns {:error, :invalid_side} for integer side" do
      assert {:error, :invalid_side} = Identifier.build(:C, 1)
    end
  end

  # ============================================================================
  # new/2 (raising constructor)
  # ============================================================================

  describe "new/2" do
    test "creates identifier with abbr and side" do
      sin = Identifier.new(:C, :first)

      assert sin.abbr == :C
      assert sin.side == :first
    end

    test "creates identifier for second player" do
      sin = Identifier.new(:S, :second)

      assert sin.abbr == :S
      assert sin.side == :second
    end

    test "creates identifier for all abbrs A-Z" do
      for abbr <- ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a do
        sin = Identifier.new(abbr, :first)
        assert sin.abbr == abbr
      end
    end

    test "raises on invalid abbr (lowercase atom)" do
      assert_raise ArgumentError, "invalid abbr", fn ->
        Identifier.new(:c, :first)
      end
    end

    test "raises on invalid abbr (string)" do
      assert_raise ArgumentError, "invalid abbr", fn ->
        Identifier.new("C", :first)
      end
    end

    test "raises on invalid abbr (integer)" do
      assert_raise ArgumentError, "invalid abbr", fn ->
        Identifier.new(67, :first)
      end
    end

    test "raises on invalid side" do
      assert_raise ArgumentError, "invalid side", fn ->
        Identifier.new(:C, :invalid)
      end
    end

    test "raises on invalid side (string)" do
      assert_raise ArgumentError, "invalid side", fn ->
        Identifier.new(:C, "first")
      end
    end
  end

  # ============================================================================
  # to_string/1
  # ============================================================================

  describe "to_string/1" do
    test "returns uppercase for first player" do
      sin = Identifier.new(:C, :first)
      assert Identifier.to_string(sin) == "C"
    end

    test "returns lowercase for second player" do
      sin = Identifier.new(:C, :second)
      assert Identifier.to_string(sin) == "c"
    end

    test "works for all abbrs first player" do
      for abbr <- ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a do
        sin = Identifier.new(abbr, :first)
        assert Identifier.to_string(sin) == Atom.to_string(abbr)
      end
    end

    test "works for all abbrs second player" do
      for abbr <- ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a do
        sin = Identifier.new(abbr, :second)
        assert Identifier.to_string(sin) == String.downcase(Atom.to_string(abbr))
      end
    end
  end

  # ============================================================================
  # first_player?/1
  # ============================================================================

  describe "first_player?/1" do
    test "returns true for first" do
      sin = Identifier.new(:C, :first)
      assert Identifier.first_player?(sin)
    end

    test "returns false for second" do
      sin = Identifier.new(:C, :second)
      refute Identifier.first_player?(sin)
    end
  end

  # ============================================================================
  # second_player?/1
  # ============================================================================

  describe "second_player?/1" do
    test "returns true for second" do
      sin = Identifier.new(:C, :second)
      assert Identifier.second_player?(sin)
    end

    test "returns false for first" do
      sin = Identifier.new(:C, :first)
      refute Identifier.second_player?(sin)
    end
  end

  # ============================================================================
  # same_abbr?/2
  # ============================================================================

  describe "same_abbr?/2" do
    test "returns true for same abbr" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:C, :second)

      assert Identifier.same_abbr?(sin1, sin2)
    end

    test "returns false for different abbr" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:S, :first)

      refute Identifier.same_abbr?(sin1, sin2)
    end
  end

  # ============================================================================
  # same_side?/2
  # ============================================================================

  describe "same_side?/2" do
    test "returns true for same side" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:S, :first)

      assert Identifier.same_side?(sin1, sin2)
    end

    test "returns false for different side" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:C, :second)

      refute Identifier.same_side?(sin1, sin2)
    end
  end

  # ============================================================================
  # Struct Equality
  # ============================================================================

  describe "struct equality" do
    test "identifiers with same attributes are equal" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:C, :first)

      assert sin1 == sin2
    end

    test "identifiers with different abbr are not equal" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:S, :first)

      refute sin1 == sin2
    end

    test "identifiers with different side are not equal" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:C, :second)

      refute sin1 == sin2
    end
  end

  # ============================================================================
  # String.Chars Protocol
  # ============================================================================

  describe "String.Chars protocol" do
    test "to_string/1 works via protocol" do
      sin = Identifier.new(:C, :first)
      assert to_string(sin) == "C"
    end

    test "string interpolation works" do
      sin = Identifier.new(:C, :second)
      assert "SIN: #{sin}" == "SIN: c"
    end
  end

  # ============================================================================
  # Inspect Protocol
  # ============================================================================

  describe "Inspect protocol" do
    test "inspect returns readable representation" do
      sin = Identifier.new(:C, :first)
      assert inspect(sin) == "#Sashite.Sin.Identifier<C>"
    end

    test "inspect for second player" do
      sin = Identifier.new(:C, :second)
      assert inspect(sin) == "#Sashite.Sin.Identifier<c>"
    end
  end

  # ============================================================================
  # Consistency: build/2 and new/2 produce identical results
  # ============================================================================

  describe "build/2 and new/2 consistency" do
    test "produce identical structs for all 52 valid combinations" do
      for letter <- ?A..?Z do
        abbr = List.to_atom([letter])

        {:ok, from_build} = Identifier.build(abbr, :first)
        from_new = Identifier.new(abbr, :first)
        assert from_build == from_new

        {:ok, from_build} = Identifier.build(abbr, :second)
        from_new = Identifier.new(abbr, :second)
        assert from_build == from_new
      end
    end
  end
end
