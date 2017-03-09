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

    [state: errmsg] = errors_on(%Video{}, attrs)
    assert errmsg == "must be in the list of created, uploaded, transcoded, waiting_for_review, published, deleted"
  end

  test "checks if a state is valid" do
    Enum.each(~w(uploaded transcoded waiting_for_review published deleted), fn s ->
      assert Video.valid_state?(s)
    end)
  end

  test "checks if a state is invalid" do
    Enum.each(~w(not_uploaded random_state blah PUBLISHED), fn s ->
      refute Video.valid_state?(s)
    end)
  end
end
