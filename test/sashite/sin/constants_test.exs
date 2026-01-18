defmodule Sashite.Sin.ConstantsTest do
  use ExUnit.Case, async: true

  alias Sashite.Sin.Constants

  doctest Constants

  # ============================================================================
  # valid_styles/0
  # ============================================================================

  describe "valid_styles/0" do
    test "returns a list of 26 atoms" do
      assert length(Constants.valid_styles()) == 26
    end

    test "contains :A through :Z" do
      styles = Constants.valid_styles()

      assert :A in styles
      assert :M in styles
      assert :Z in styles
    end

    test "does not contain lowercase atoms" do
      styles = Constants.valid_styles()

      refute :a in styles
      refute :z in styles
    end
  end

  # ============================================================================
  # valid_sides/0
  # ============================================================================

  describe "valid_sides/0" do
    test "returns [:first, :second]" do
      assert Constants.valid_sides() == [:first, :second]
    end
  end

  # ============================================================================
  # max_string_length/0
  # ============================================================================

  describe "max_string_length/0" do
    test "returns 1" do
      assert Constants.max_string_length() == 1
    end
  end

  # ============================================================================
  # valid_style?/1
  # ============================================================================

  describe "valid_style?/1" do
    test "returns true for valid uppercase style atoms" do
      assert Constants.valid_style?(:A)
      assert Constants.valid_style?(:C)
      assert Constants.valid_style?(:Z)
    end

    test "returns false for lowercase style atoms" do
      refute Constants.valid_style?(:a)
      refute Constants.valid_style?(:c)
      refute Constants.valid_style?(:z)
    end

    test "returns false for non-atom values" do
      refute Constants.valid_style?("C")
      refute Constants.valid_style?(67)
      refute Constants.valid_style?(nil)
    end

    test "returns false for invalid atoms" do
      refute Constants.valid_style?(:invalid)
      refute Constants.valid_style?(:first)
    end
  end

  # ============================================================================
  # valid_side?/1
  # ============================================================================

  describe "valid_side?/1" do
    test "returns true for :first" do
      assert Constants.valid_side?(:first)
    end

    test "returns true for :second" do
      assert Constants.valid_side?(:second)
    end

    test "returns false for other atoms" do
      refute Constants.valid_side?(:third)
      refute Constants.valid_side?(:C)
    end

    test "returns false for non-atom values" do
      refute Constants.valid_side?("first")
      refute Constants.valid_side?(1)
      refute Constants.valid_side?(nil)
    end
  end
end
