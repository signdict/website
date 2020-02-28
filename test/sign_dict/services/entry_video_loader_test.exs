defmodule SignDict.Services.EntryVideoLoaderTest do
  use SignDict.ModelCase, async: true

  import SignDict.Factory

  alias SignDict.Services.EntryVideoLoader
  alias SignDict.Video

  setup do
    entry = insert(:entry)
    user_1 = insert(:user, %{name: "User 1"})
    user_2 = insert(:user, %{name: "User 2"})
    user_3 = insert(:user, %{name: "User 3"})
    video_1 = insert(:video, %{state: "published", user: user_1, entry: entry})
    video_2 = insert(:video, %{state: "published", user: user_2, entry: entry})

    {:ok, _vote} = %SignDict.Vote{user: user_1, video: video_1} |> Repo.insert()
    {:ok, _vote} = %SignDict.Vote{user: user_2, video: video_1} |> Repo.insert()
    {:ok, _vote} = %SignDict.Vote{user: user_3, video: video_2} |> Repo.insert()

    video_1_with_votes =
      Repo.get(Video, video_1.id) |> Repo.preload(:user) |> Video.with_vote_count()

    video_2_with_votes =
      Repo.get(Video, video_2.id) |> Repo.preload(:user) |> Video.with_vote_count()

    {
      :ok,
      entry: entry,
      user_1: user_1,
      user_2: user_2,
      user_3: user_3,
      video_1: video_1_with_votes,
      video_2: video_2_with_votes
    }
  end

  test "it returns the highest voted video for an entry", %{
    entry: entry,
    video_1: video_1,
    video_2: video_2
  } do
    conn = %{assigns: %{current_user: nil}, host: "signdict.org"}
    result = EntryVideoLoader.load_videos_for_entry(conn, id: entry.id)
    assert result.conn == conn
    assert result.entry |> SignDict.Repo.preload(:domains) == entry
    assert result.video == video_1
    assert result.voted == %Video{}
    assert result.videos == [video_1, video_2]
  end

  test "it returns the voted video if the user has voted one for the entry", %{
    entry: entry,
    video_1: video_1,
    video_2: video_2,
    user_3: user
  } do
    conn = %{assigns: %{current_user: user}, host: "signdict.org"}

    result = EntryVideoLoader.load_videos_for_entry(conn, id: entry.id)

    assert result.conn == conn
    assert result.entry |> SignDict.Repo.preload(:domains) == entry
    assert result.video == video_2
    assert result.voted == video_2
    assert result.videos == [video_1, video_2]
  end

  test "it returns a specific video if given", %{
    entry: entry,
    video_1: video_1,
    video_2: video_2,
    user_3: user
  } do
    conn = %{assigns: %{current_user: user}, host: "signdict.org"}
    result = EntryVideoLoader.load_videos_for_entry(conn, id: entry.id, video_id: video_1.id)
    assert result.conn == conn
    assert result.entry |> SignDict.Repo.preload(:domains) == entry
    assert result.video == video_1
    assert result.voted == video_2
    assert result.videos == [video_1, video_2]
  end

  test "it returns nil for the video if non could be found", %{
    entry: entry,
    video_1: video_1,
    video_2: video_2,
    user_3: user
  } do
    conn = %{assigns: %{current_user: user}, host: "signdict.org"}
    result = EntryVideoLoader.load_videos_for_entry(conn, id: entry.id, video_id: 0)
    assert result.conn == conn
    assert result.entry |> SignDict.Repo.preload(:domains) == entry
    assert result.video == nil
    assert result.voted == video_2
    assert result.videos == [video_1, video_2]
  end

  test "it returns nil if no entry be found and an entry is given" do
    conn = %{assigns: %{current_user: nil}, host: "signdict.org"}
    result = EntryVideoLoader.load_videos_for_entry(conn, id: 0, video_id: 0)
    assert result.conn == conn
    assert result.entry == nil
    assert result.videos == []
  end
end
