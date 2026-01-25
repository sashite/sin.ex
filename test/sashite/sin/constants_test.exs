defmodule Sashite.Sin.ConstantsTest do
  use ExUnit.Case, async: true

  alias Sashite.Sin.Constants

  doctest Constants

  # ============================================================================
  # valid_abbrs/0
  # ============================================================================

  describe "valid_abbrs/0" do
    test "returns a list of 26 atoms" do
      assert length(Constants.valid_abbrs()) == 26
    end

    test "contains :A through :Z" do
      abbrs = Constants.valid_abbrs()

      assert :A in abbrs
      assert :M in abbrs
      assert :Z in abbrs
    end

    test "does not contain lowercase atoms" do
      abbrs = Constants.valid_abbrs()

      refute :a in abbrs
      refute :z in abbrs
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
  # valid_abbr?/1
  # ============================================================================

  describe "valid_abbr?/1" do
    test "returns true for valid uppercase abbr atoms" do
      assert Constants.valid_abbr?(:A)
      assert Constants.valid_abbr?(:C)
      assert Constants.valid_abbr?(:Z)
    end

    test "returns false for lowercase abbr atoms" do
      refute Constants.valid_abbr?(:a)
      refute Constants.valid_abbr?(:c)
      refute Constants.valid_abbr?(:z)
    end

    test "returns false for non-atom values" do
      refute Constants.valid_abbr?("C")
      refute Constants.valid_abbr?(67)
      refute Constants.valid_abbr?(nil)
    end

    test "returns false for invalid atoms" do
      refute Constants.valid_abbr?(:invalid)
      refute Constants.valid_abbr?(:first)
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
