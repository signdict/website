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

  describe "vote_video/2" do
    test "vote for a video" do
      user   = insert(:user)
      entry  = insert(:entry)
      {:ok, video} = %{build(:video) | entry: entry} |> Repo.insert
      Vote.vote_video(user, video)
      assert Vote |> Repo.aggregate(:count, :id) == 1
    end

    test "deletes only the already given vote by the user and sets a new one" do
      user   = insert(:user)
      entry  = insert(:entry)
      {:ok, video} = %{build(:video) | entry: entry} |> Repo.insert
      %Vote{user: user, video: video} |> Repo.insert
      insert(:vote)

      Vote.vote_video(user, video)
      query = from(v in Vote, where: v.user_id == ^user.id and v.video_id == ^video.id)
      assert query |> Repo.aggregate(:count, :id) == 1
      assert Vote |> Repo.aggregate(:count, :id) == 2
    end

    # TODO: test if current video is updated in entry
  end

end
