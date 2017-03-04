defmodule SignDict.VideoTest do
  use SignDict.ModelCase

  alias SignDict.Video

  @valid_attrs %{copyright: "some content", license: "some content", original_href: "some content", state: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Video.changeset(%Video{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Video.changeset(%Video{}, @invalid_attrs)
    refute changeset.valid?
  end
end
