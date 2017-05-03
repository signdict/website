defmodule SignDict.PermalinkTest do
  use SignDict.ConnCase

  describe "cast/1" do
    test "cast a string to an int" do
      assert SignDict.Permalink.cast("1-hello") == {:ok, 1}
    end

    test "cast an int to an int" do
      assert SignDict.Permalink.cast(1) == {:ok, 1}
    end

    test "fails if string has no number" do
      assert SignDict.Permalink.cast("hello") == :error
    end

    test "fails if not binary or integer" do
      assert SignDict.Permalink.cast(%{}) == :error
    end
  end

  describe "dump/1" do
    test "dumps integer" do
      assert SignDict.Permalink.dump(1) == {:ok, 1}
    end
  end

  describe "load/1" do
    test "loads integer" do
      assert SignDict.Permalink.load(1) == {:ok, 1}
    end
  end

end
