defmodule SignDict.VideoTest do
  import SignDict.Factory
  use SignDict.ModelCase

  alias SignDict.Video

  @invalid_attrs %{}

  defp valid_attributes do
    %{
      copyright: "some content", license: "some content",
      original_href: "some content", state: "uploaded",
      type: "some content",
      user_id: user().id, entry_id: entry().id,
      thumbnail_url: "https://example.com/thumbnail.jpg",
      video_url: "https://example.com/video.mp4"
    }
  end

  test "changeset with valid attributes" do
    changeset = Video.changeset(%Video{}, valid_attributes())
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Video.changeset(%Video{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "Video state logic" do
    test "changeset with invalid state" do
      attrs = Map.put(valid_attributes(), :state, "invalid_state")

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

    test "the default state for a new video is 'created'" do
      attrs = Map.delete(valid_attributes(), :state)

      v = %Video{}
          |> Video.changeset(attrs)
          |> Repo.insert!()

      assert v.state == "created"
    end

    test "allow transition from created to uploaded & deleted" do
      v = %Video{}

      assert Video.current_state(v) == :created
      assert Video.can_upload?(v)
      assert Video.can_delete?(v)
    end

    test "allow transition from uploaded to transcoded and deleted" do
      v = %Video{state: "uploaded"}

      assert Video.current_state(v) == :uploaded
      assert Video.can_transcode?(v)
      assert Video.can_delete?(v)
    end

    test "allow transition from transcoded to waiting_for_review and deleted" do
      v = %Video{state: "transcoded"}

      assert Video.current_state(v) == :transcoded
      assert Video.can_wait_for_review?(v)
      assert Video.can_delete?(v)
    end

    test "allow transition from waiting_for_review to published and deleted" do
      v = %Video{state: "waiting_for_review"}

      assert Video.current_state(v) == :waiting_for_review
      assert Video.can_publish?(v)
      assert Video.can_delete?(v)
    end

    test "the state traversal from start to end" do
      attrs = Map.put(valid_attributes(), :state, "created")

      v = %Video{}
          |> Video.changeset(attrs)
          |> Repo.insert!()

      assert Video.current_state(v) == :created

      {:ok, v} = Video.upload(v)
      assert Video.current_state(v) == :uploaded

      {:ok, v} = Video.transcode(v)
      assert Video.current_state(v) == :transcoded

      {:ok, v} = Video.wait_for_review(v)
      assert Video.current_state(v) == :waiting_for_review

      {:ok, v} = Video.publish(v)
      assert Video.current_state(v) == :published

      {:ok, v} = Video.delete(v)
      assert Video.current_state(v) == :deleted
    end
  end

  describe "with_vote_count/1" do
    test "returns video if vote count is already set" do
      assert Video.with_vote_count(%Video{vote_count: 100}) == %Video{vote_count: 100}
    end

    test "queries the database and returns video with added vote count" do
      vote = insert(:vote)
      assert Video.with_vote_count(vote.video).vote_count == 1
    end
  end

  describe "ordered_by_vote_for_entry/1" do

    setup do
      entry = insert(:entry)
      {:ok, user_1}  = %{build(:user) | name: "User 1"} |> Repo.insert
      {:ok, user_2}  = %{build(:user) | name: "User 2"} |> Repo.insert
      {:ok, user_3}  = %{build(:user) | name: "User 3"} |> Repo.insert
      {:ok, video_1} = %{build(:video) | state: "published", user: user_1, entry: entry } |> Repo.insert
      {:ok, video_2} = %{build(:video) | state: "published", user: user_2, entry: entry } |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_1, video: video_1} |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_2, video: video_1} |> Repo.insert
      {:ok, _vote}    = %SignDict.Vote{user: user_3, video: video_2} |> Repo.insert

      {:ok, entry: entry, video_1: video_1, video_2: video_2}
    end

    test "returns ordered list", %{entry: entry, video_1: video_1, video_2: video_2} do
      videos = Video.ordered_by_vote_for_entry(entry) |> Repo.all
      video_ids = Enum.map(videos, fn(video) -> video.id end)
      assert video_ids == [video_1.id, video_2.id]
    end

    test "returned videos have vote_count", %{entry: entry} do
      videos = Video.ordered_by_vote_for_entry(entry) |> Repo.all
      vote_counts = Enum.map(videos, fn(video) -> video.vote_count end)
      assert vote_counts == [2, 1]
    end
  end

  def user do
    insert :user
  end

  def entry do
    insert :entry
  end

end
