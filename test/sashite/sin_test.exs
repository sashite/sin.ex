defmodule Sashite.SinTest do
  use ExUnit.Case, async: true

  doctest Sashite.Sin

  describe "new/2" do
    test "creates a SIN struct with valid style and side" do
      sin = Sashite.Sin.new(:C, :first)

      assert sin.style == :C
      assert sin.side == :first
    end

    test "creates SIN for all valid styles" do
      for style <- ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)a do
        sin = Sashite.Sin.new(style, :first)
        assert sin.style == style
      end
    end

    test "creates SIN for both sides" do
      first = Sashite.Sin.new(:C, :first)
      second = Sashite.Sin.new(:C, :second)

      assert first.side == :first
      assert second.side == :second
    end

    test "raises ArgumentError for invalid style" do
      assert_raise ArgumentError, ~r/Style must be an atom from :A to :Z/, fn ->
        Sashite.Sin.new(:invalid, :first)
      end

      assert_raise ArgumentError, ~r/Style must be an atom from :A to :Z/, fn ->
        Sashite.Sin.new(:a, :first)
      end

      assert_raise ArgumentError, ~r/Style must be an atom from :A to :Z/, fn ->
        Sashite.Sin.new("C", :first)
      end
    end

    test "raises ArgumentError for invalid side" do
      assert_raise ArgumentError, ~r/Side must be :first or :second/, fn ->
        Sashite.Sin.new(:C, :third)
      end

      assert_raise ArgumentError, ~r/Side must be :first or :second/, fn ->
        Sashite.Sin.new(:C, "first")
      end
    end
  end

  describe "parse/1" do
    test "parses uppercase letter as first player" do
      assert {:ok, sin} = Sashite.Sin.parse("C")
      assert sin.style == :C
      assert sin.side == :first
    end

    test "parses lowercase letter as second player" do
      assert {:ok, sin} = Sashite.Sin.parse("c")
      assert sin.style == :C
      assert sin.side == :second
    end

    test "parses all uppercase letters" do
      for letter <- ?A..?Z do
        char = <<letter>>
        assert {:ok, sin} = Sashite.Sin.parse(char)
        assert sin.style == String.to_atom(char)
        assert sin.side == :first
      end
    end

    test "parses all lowercase letters" do
      for letter <- ?a..?z do
        char = <<letter>>
        assert {:ok, sin} = Sashite.Sin.parse(char)
        assert sin.style == char |> String.upcase() |> String.to_atom()
        assert sin.side == :second
      end
    end

    test "returns error for empty string" do
      assert {:error, "Invalid SIN string: "} = Sashite.Sin.parse("")
    end

    test "returns error for multiple characters" do
      assert {:error, "Invalid SIN string: CC"} = Sashite.Sin.parse("CC")
      assert {:error, "Invalid SIN string: ab"} = Sashite.Sin.parse("ab")
    end

    test "returns error for digits" do
      assert {:error, "Invalid SIN string: 1"} = Sashite.Sin.parse("1")
      assert {:error, "Invalid SIN string: 9"} = Sashite.Sin.parse("9")
    end

    test "returns error for special characters" do
      assert {:error, "Invalid SIN string: +"} = Sashite.Sin.parse("+")
      assert {:error, "Invalid SIN string: -"} = Sashite.Sin.parse("-")
      assert {:error, "Invalid SIN string: ^"} = Sashite.Sin.parse("^")
      assert {:error, "Invalid SIN string: @"} = Sashite.Sin.parse("@")
    end

    test "returns error for whitespace" do
      assert {:error, "Invalid SIN string:  "} = Sashite.Sin.parse(" ")
      assert {:error, "Invalid SIN string:  C"} = Sashite.Sin.parse(" C")
      assert {:error, "Invalid SIN string: C "} = Sashite.Sin.parse("C ")
    end

    test "returns error for non-ASCII characters" do
      assert {:error, "Invalid SIN string: é"} = Sashite.Sin.parse("é")
      assert {:error, "Invalid SIN string: ñ"} = Sashite.Sin.parse("ñ")
    end

    test "returns error for non-string input" do
      assert {:error, _} = Sashite.Sin.parse(nil)
      assert {:error, _} = Sashite.Sin.parse(123)
      assert {:error, _} = Sashite.Sin.parse(:C)
    end
  end

  describe "parse!/1" do
    test "returns SIN struct for valid input" do
      sin = Sashite.Sin.parse!("C")
      assert sin.style == :C
      assert sin.side == :first
    end

    test "raises ArgumentError for invalid input" do
      assert_raise ArgumentError, ~r/Invalid SIN string: CC/, fn ->
        Sashite.Sin.parse!("CC")
      end

      assert_raise ArgumentError, ~r/Invalid SIN string: /, fn ->
        Sashite.Sin.parse!("")
      end
    end
  end

  describe "valid?/1" do
    test "returns true for valid single uppercase letter" do
      for letter <- ?A..?Z do
        assert Sashite.Sin.valid?(<<letter>>) == true
      end
    end

    test "returns true for valid single lowercase letter" do
      for letter <- ?a..?z do
        assert Sashite.Sin.valid?(<<letter>>) == true
      end
    end

    test "returns false for empty string" do
      refute Sashite.Sin.valid?("")
    end

    test "returns false for multiple characters" do
      refute Sashite.Sin.valid?("CC")
      refute Sashite.Sin.valid?("abc")
    end

    test "returns false for digits" do
      refute Sashite.Sin.valid?("1")
      refute Sashite.Sin.valid?("0")
    end

    test "returns false for special characters" do
      refute Sashite.Sin.valid?("+")
      refute Sashite.Sin.valid?("-")
      refute Sashite.Sin.valid?("^")
    end

    test "returns false for whitespace" do
      refute Sashite.Sin.valid?(" ")
      refute Sashite.Sin.valid?(" C")
      refute Sashite.Sin.valid?("C ")
    end

    test "returns false for non-string input" do
      refute Sashite.Sin.valid?(nil)
      refute Sashite.Sin.valid?(123)
      refute Sashite.Sin.valid?(:C)
      refute Sashite.Sin.valid?([?C])
    end
  end

  describe "to_string/1" do
    test "converts first player SIN to uppercase string" do
      sin = Sashite.Sin.new(:C, :first)
      assert Sashite.Sin.to_string(sin) == "C"
    end

    test "converts second player SIN to lowercase string" do
      sin = Sashite.Sin.new(:C, :second)
      assert Sashite.Sin.to_string(sin) == "c"
    end

    test "round-trips through parse and to_string" do
      for letter <- ?A..?Z do
        upper = <<letter>>
        lower = String.downcase(upper)

        assert upper == Sashite.Sin.parse!(upper) |> Sashite.Sin.to_string()
        assert lower == Sashite.Sin.parse!(lower) |> Sashite.Sin.to_string()
      end
    end
  end

  describe "letter/1" do
    test "returns uppercase letter for first player" do
      sin = Sashite.Sin.new(:S, :first)
      assert Sashite.Sin.letter(sin) == "S"
    end

    test "returns lowercase letter for second player" do
      sin = Sashite.Sin.new(:S, :second)
      assert Sashite.Sin.letter(sin) == "s"
    end
  end

  describe "flip/1" do
    test "flips first to second" do
      sin = Sashite.Sin.new(:C, :first)
      flipped = Sashite.Sin.flip(sin)

      assert flipped.side == :second
      assert flipped.style == :C
    end

    test "flips second to first" do
      sin = Sashite.Sin.new(:C, :second)
      flipped = Sashite.Sin.flip(sin)

      assert flipped.side == :first
      assert flipped.style == :C
    end

    test "double flip returns to original side" do
      sin = Sashite.Sin.new(:X, :first)
      double_flipped = sin |> Sashite.Sin.flip() |> Sashite.Sin.flip()

      assert double_flipped.side == :first
    end
  end

  describe "with_style/2" do
    test "changes style" do
      sin = Sashite.Sin.new(:C, :first)
      changed = Sashite.Sin.with_style(sin, :S)

      assert changed.style == :S
      assert changed.side == :first
    end

    test "returns same struct when style unchanged" do
      sin = Sashite.Sin.new(:C, :first)
      same = Sashite.Sin.with_style(sin, :C)

      assert same == sin
    end

    test "raises ArgumentError for invalid style" do
      sin = Sashite.Sin.new(:C, :first)

      assert_raise ArgumentError, ~r/Style must be an atom from :A to :Z/, fn ->
        Sashite.Sin.with_style(sin, :invalid)
      end
    end
  end

  describe "with_side/2" do
    test "changes side" do
      sin = Sashite.Sin.new(:C, :first)
      changed = Sashite.Sin.with_side(sin, :second)

      assert changed.side == :second
      assert changed.style == :C
    end

    test "returns same struct when side unchanged" do
      sin = Sashite.Sin.new(:C, :first)
      same = Sashite.Sin.with_side(sin, :first)

      assert same == sin
    end

    test "raises ArgumentError for invalid side" do
      sin = Sashite.Sin.new(:C, :first)

      assert_raise ArgumentError, ~r/Side must be :first or :second/, fn ->
        Sashite.Sin.with_side(sin, :third)
      end
    end
  end

  describe "first_player?/1" do
    test "returns true for first player" do
      sin = Sashite.Sin.new(:C, :first)
      assert Sashite.Sin.first_player?(sin) == true
    end

    test "returns false for second player" do
      sin = Sashite.Sin.new(:C, :second)
      assert Sashite.Sin.first_player?(sin) == false
    end
  end

  describe "second_player?/1" do
    test "returns true for second player" do
      sin = Sashite.Sin.new(:C, :second)
      assert Sashite.Sin.second_player?(sin) == true
    end

    test "returns false for first player" do
      sin = Sashite.Sin.new(:C, :first)
      assert Sashite.Sin.second_player?(sin) == false
    end
  end

  describe "same_style?/2" do
    test "returns true for same style different sides" do
      sin1 = Sashite.Sin.new(:C, :first)
      sin2 = Sashite.Sin.new(:C, :second)

      assert Sashite.Sin.same_style?(sin1, sin2) == true
    end

    test "returns true for same style same side" do
      sin1 = Sashite.Sin.new(:C, :first)
      sin2 = Sashite.Sin.new(:C, :first)

      assert Sashite.Sin.same_style?(sin1, sin2) == true
    end

    test "returns false for different styles" do
      sin1 = Sashite.Sin.new(:C, :first)
      sin2 = Sashite.Sin.new(:S, :first)

      assert Sashite.Sin.same_style?(sin1, sin2) == false
    end
  end

  describe "same_side?/2" do
    test "returns true for same side different styles" do
      sin1 = Sashite.Sin.new(:C, :first)
      sin2 = Sashite.Sin.new(:S, :first)

      assert Sashite.Sin.same_side?(sin1, sin2) == true
    end

    test "returns true for same side same style" do
      sin1 = Sashite.Sin.new(:C, :first)
      sin2 = Sashite.Sin.new(:C, :first)

      assert Sashite.Sin.same_side?(sin1, sin2) == true
    end

    test "returns false for different sides" do
      sin1 = Sashite.Sin.new(:C, :first)
      sin2 = Sashite.Sin.new(:C, :second)

      assert Sashite.Sin.same_side?(sin1, sin2) == false
    end
  end

  describe "String.Chars protocol" do
    test "converts to string using to_string/1" do
      sin = Sashite.Sin.new(:C, :first)
      assert "#{sin}" == "C"

      sin = Sashite.Sin.new(:S, :second)
      assert "#{sin}" == "s"
    end
  end

  describe "Inspect protocol" do
    test "inspects with custom format" do
      sin = Sashite.Sin.new(:C, :first)
      assert inspect(sin) == "#Sashite.Sin<C>"

      sin = Sashite.Sin.new(:S, :second)
      assert inspect(sin) == "#Sashite.Sin<s>"
    end
  end

  describe "common game styles (informative)" do
    test "chess style" do
      chess_first = Sashite.Sin.parse!("C")
      chess_second = Sashite.Sin.parse!("c")

      assert chess_first.style == :C
      assert chess_first.side == :first
      assert chess_second.style == :C
      assert chess_second.side == :second
    end

    test "shogi style" do
      shogi_first = Sashite.Sin.parse!("S")
      shogi_second = Sashite.Sin.parse!("s")

      assert shogi_first.style == :S
      assert shogi_first.side == :first
      assert shogi_second.style == :S
      assert shogi_second.side == :second
    end

    test "xiangqi style" do
      xiangqi_first = Sashite.Sin.parse!("X")
      xiangqi_second = Sashite.Sin.parse!("x")

      assert xiangqi_first.style == :X
      assert xiangqi_first.side == :first
      assert xiangqi_second.style == :X
      assert xiangqi_second.side == :second
    end

    test "makruk style" do
      makruk_first = Sashite.Sin.parse!("M")
      makruk_second = Sashite.Sin.parse!("m")

      assert makruk_first.style == :M
      assert makruk_first.side == :first
      assert makruk_second.style == :M
      assert makruk_second.side == :second
    end
  end
end
