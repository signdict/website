defmodule SignDict.VoteTest do
  use SignDict.ModelCase

  import SignDict.Factory

  alias SignDict.Entry
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
    %Vote{} |> Vote.changeset(@valid_attrs) |> Repo.insert!()
    vote_changeset = %Vote{} |> Vote.changeset(@valid_attrs)
    assert {:error, changeset} = Repo.insert(vote_changeset)

    assert changeset.errors[:video_id] ==
             {"Only one vote per video and user",
              [constraint: :unique, constraint_name: "votes_user_video_id_index"]}
  end

  test "changeset with values respecting uniqueness constraint" do
    %Vote{} |> Vote.changeset(%{user_id: 42, video_id: 42}) |> Repo.insert!()
    vote_changeset = %Vote{} |> Vote.changeset(%{user_id: 42, video_id: 43})
    assert {:ok, _} = Repo.insert(vote_changeset)
  end

  describe "vote_video/2" do
    setup do
      user = insert(:user)
      entry = insert(:entry)
      video = insert(:video_published, %{entry: entry})
      {:ok, user: user, entry: entry, video: video}
    end

    test "vote for a video", %{user: user, video: video} do
      Vote.vote_video(user, video)
      assert Vote |> Repo.aggregate(:count, :id) == 1
    end

    test "deletes only the already given vote by the user and sets a new one", %{
      user: user,
      video: video
    } do
      %Vote{user: user, video: video} |> Repo.insert()
      insert(:vote)

      Vote.vote_video(user, video)
      query = from(v in Vote, where: v.user_id == ^user.id and v.video_id == ^video.id)
      assert query |> Repo.aggregate(:count, :id) == 1
      assert Vote |> Repo.aggregate(:count, :id) == 2
    end

    test "updates the current video on the entry", %{user: user, video: video, entry: entry} do
      Vote.vote_video(user, video)
      assert Repo.get(Entry, entry.id).current_video_id == video.id
    end
  end

  describe "delete_vote/2" do
    setup do
      user = insert(:user)
      entry = insert(:entry)
      video = insert(:video_published, %{entry: entry})
      {:ok, user: user, entry: entry, video: video}
    end

    test "it deletes the vote", %{user: user, video: video} do
      insert(:vote)
      %Vote{user: user, video: video} |> Repo.insert()

      Vote.delete_vote(user, video)
      query = from(v in Vote, where: v.user_id == ^user.id and v.video_id == ^video.id)
      assert query |> Repo.aggregate(:count, :id) == 0
      assert Vote |> Repo.aggregate(:count, :id) == 1
    end
  end
end
