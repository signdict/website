defmodule SignDict.ListEntryTest do
  use SignDict.ModelCase

  alias SignDict.ListEntry

  @valid_attrs %{sort_order: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ListEntry.changeset(%ListEntry{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ListEntry.changeset(%ListEntry{}, @invalid_attrs)
    refute changeset.valid?
  end
end
