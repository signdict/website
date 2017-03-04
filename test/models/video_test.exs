defmodule SignDict.VideoTest do
  use SignDict.ModelCase

  alias SignDict.Video

  @valid_attrs %{copyright: "some content", license: "some content", original_href: "some content", state: "uploaded", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Video.changeset(%Video{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Video.changeset(%Video{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid state" do
    attrs = Map.put(@valid_attrs, :state, "invalid_state")

    changeset = Video.changeset(%Video{}, attrs)
    refute changeset.valid?
  end

  test "checks if a state is valid" do
    assert Video.valid_state?("uploaded")
    assert Video.valid_state?("transcoded")
    assert Video.valid_state?("waiting_for_review")
    assert Video.valid_state?("published")
    assert Video.valid_state?("deleted")
  end

  test "checks if a state is invalid" do
    refute Video.valid_state?("not_uploaded")
    refute Video.valid_state?("random_state")
  end
end
