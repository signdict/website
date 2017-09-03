defmodule SignDict.ListTest do
  use SignDict.ModelCase

  alias SignDict.List

  @valid_attrs %{
    name: "some content", description: "some description",
    sort_order: "manual", type: "categorie-list"
  }
  @invalid_attrs %{}

  describe "admin_changeset" do
    test "admin_changeset with valid attributes" do
      changeset = List.admin_changeset(%List{}, @valid_attrs)
      assert changeset.valid?
    end

    test "admin_changeset with invalid attributes" do
      changeset = List.admin_changeset(%List{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
