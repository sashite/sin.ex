defmodule Sashite.Sin.IdentifierTest do
  use ExUnit.Case, async: true

  alias Sashite.Sin.Identifier

  doctest Identifier

  # ============================================================================
  # new/2
  # ============================================================================

  describe "new/2" do
    test "creates identifier with style and side" do
      sin = Identifier.new(:C, :first)

      assert sin.style == :C
      assert sin.side == :first
    end

    test "creates identifier for second player" do
      sin = Identifier.new(:S, :second)

      assert sin.style == :S
      assert sin.side == :second
    end

    test "creates identifier for all styles A-Z" do
      for style <- ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a do
        sin = Identifier.new(style, :first)
        assert sin.style == style
      end
    end

    test "raises on invalid style (lowercase atom)" do
      assert_raise ArgumentError, "invalid style", fn ->
        Identifier.new(:c, :first)
      end
    end

    test "raises on invalid style (string)" do
      assert_raise ArgumentError, "invalid style", fn ->
        Identifier.new("C", :first)
      end
    end

    test "raises on invalid style (integer)" do
      assert_raise ArgumentError, "invalid style", fn ->
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

    test "works for all styles first player" do
      for style <- ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a do
        sin = Identifier.new(style, :first)
        assert Identifier.to_string(sin) == Atom.to_string(style)
      end
    end

    test "works for all styles second player" do
      for style <- ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a do
        sin = Identifier.new(style, :second)
        assert Identifier.to_string(sin) == String.downcase(Atom.to_string(style))
      end
    end
  end

  # ============================================================================
  # letter/1
  # ============================================================================

  describe "letter/1" do
    test "returns uppercase for first player" do
      sin = Identifier.new(:S, :first)
      assert Identifier.letter(sin) == "S"
    end

    test "returns lowercase for second player" do
      sin = Identifier.new(:S, :second)
      assert Identifier.letter(sin) == "s"
    end
  end

  # ============================================================================
  # flip/1
  # ============================================================================

  describe "flip/1" do
    test "changes first to second" do
      sin = Identifier.new(:C, :first)
      flipped = Identifier.flip(sin)

      assert flipped.side == :second
      assert sin.side == :first
    end

    test "changes second to first" do
      sin = Identifier.new(:C, :second)
      flipped = Identifier.flip(sin)

      assert flipped.side == :first
      assert sin.side == :second
    end

    test "preserves style" do
      sin = Identifier.new(:S, :first)
      flipped = Identifier.flip(sin)

      assert flipped.style == :S
    end
  end

  # ============================================================================
  # with_style/2
  # ============================================================================

  describe "with_style/2" do
    test "changes style" do
      sin = Identifier.new(:C, :first)
      changed = Identifier.with_style(sin, :S)

      assert changed.style == :S
      assert sin.style == :C
    end

    test "preserves side" do
      sin = Identifier.new(:C, :first)
      changed = Identifier.with_style(sin, :S)

      assert changed.side == :first
    end

    test "returns same struct if same style" do
      sin = Identifier.new(:C, :first)
      same = Identifier.with_style(sin, :C)

      assert sin == same
    end

    test "raises on invalid style" do
      sin = Identifier.new(:C, :first)

      assert_raise ArgumentError, "invalid style", fn ->
        Identifier.with_style(sin, :invalid)
      end
    end
  end

  # ============================================================================
  # with_side/2
  # ============================================================================

  describe "with_side/2" do
    test "changes side" do
      sin = Identifier.new(:C, :first)
      changed = Identifier.with_side(sin, :second)

      assert changed.side == :second
      assert sin.side == :first
    end

    test "preserves style" do
      sin = Identifier.new(:C, :first)
      changed = Identifier.with_side(sin, :second)

      assert changed.style == :C
    end

    test "returns same struct if same side" do
      sin = Identifier.new(:C, :first)
      same = Identifier.with_side(sin, :first)

      assert sin == same
    end

    test "raises on invalid side" do
      sin = Identifier.new(:C, :first)

      assert_raise ArgumentError, "invalid side", fn ->
        Identifier.with_side(sin, :invalid)
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
  # same_style?/2
  # ============================================================================

  describe "same_style?/2" do
    test "returns true for same style" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:C, :second)

      assert Identifier.same_style?(sin1, sin2)
    end

    test "returns false for different style" do
      sin1 = Identifier.new(:C, :first)
      sin2 = Identifier.new(:S, :first)

      refute Identifier.same_style?(sin1, sin2)
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

    test "identifiers with different style are not equal" do
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
