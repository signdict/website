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

  describe "to_string/1" do
    test "returns only the text if no description is given" do
      assert Entry.to_string(%Entry{text: "Example"}) == "Example"
    end

    test "returns only the text if description is empty" do
      assert Entry.to_string(%Entry{text: "Example", description: ""}) == "Example"
    end

    test "returns name and description if description is given" do
      assert Entry.to_string(%Entry{text: "Example", description: "This is it"}) == "Example (This is it)"
    end
  end

  describe "Phoenix.Param" do
    test "it creates a nice permalink for the entry" do
      assert Phoenix.Param.to_param(%Entry{id: 1, text: "My name is my castle!"}) == "1-my-name-is-my-castle"
    end
  end
end
