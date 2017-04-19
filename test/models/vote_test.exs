defmodule SignDict.VoteTest do
  use SignDict.ModelCase

  import SignDict.Factory

  alias SignDict.Vote

  @valid_attrs %{user_id: 42, video_id: 42}
  @invalid_attrs %{}

  test "changeset of vote default factory" do
    vote = insert(:vote)
    changeset = Vote.changeset(vote)
    assert changeset.valid?
  end

  test "changeset with valid attributes" do
    changeset = Vote.changeset(%Vote{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Vote.changeset(%Vote{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with values violating uniqueness constraint" do
    %Vote{} |> Vote.changeset(@valid_attrs) |> Repo.insert!
    vote_changeset = %Vote{} |> Vote.changeset(@valid_attrs)
    assert {:error, changeset} = Repo.insert(vote_changeset)
    assert changeset.errors[:video_id] == {"Only one vote per video and user", []}
  end

  test "changeset with values respecting uniqueness constraint" do
    %Vote{} |> Vote.changeset(%{user_id: 42, video_id: 42}) |> Repo.insert!
    vote_changeset = %Vote{} |> Vote.changeset(%{user_id: 42, video_id: 43})
    assert {:ok, _} = Repo.insert(vote_changeset)
  end

  # TODO: test vote_video
end
