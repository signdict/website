defmodule SignDict.LanguageTest do
  use SignDict.ModelCase

  alias SignDict.Language

  @valid_attrs %{
    default_locale: "some content",
    iso6393: "some content",
    long_name: "some content",
    short_name: "some content"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Language.changeset(%Language{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Language.changeset(%Language{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "Language.name/1" do
    test "returns the name from the struct if no translation is found" do
      assert Language.name(%Language{iso6393: "gsg"}) == "German Sign Language"
    end

    test "returns the translated name if possible" do
      assert Language.name(%Language{iso6393: "nop", long_name: "Not existing"}) == "Not existing"
    end
  end
end
