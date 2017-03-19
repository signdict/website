defmodule SignDict.EntryTest do
  use SignDict.ModelCase
  import SignDict.Factory

  alias SignDict.Entry

  @valid_attrs %{description: "some content", text: "some content", type: "word"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    language = insert :language_dgs
    changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs,  %{language_id: language.id}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Entry.changeset(%Entry{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid value for type attribute" do
    changeset = Entry.changeset(%Entry{}, Map.merge(@valid_attrs, %{type: "somthing_invalid"}))
    refute changeset.valid?
  end
end
