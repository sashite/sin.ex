defmodule Sashite.Sin.IdentifierTest do
  use ExUnit.Case, async: true

  alias Sashite.Sin.Identifier

  doctest Identifier

  # ============================================================================
  # new/2
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
end
